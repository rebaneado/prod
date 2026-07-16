import { GLOBAL_MESSAGE } from "./fitBinary";
import { readFitMessages } from "./fitReader";
import type { Workout, WorkoutStep } from "./types";

// workout_step (global message 27) field definition numbers.
const FIELD = {
  messageIndex: 254,
  stepName: 0,
  durationType: 1,
  durationValue: 2,
  targetType: 3,
  targetValue: 4,
  customTargetValueLow: 5,
  customTargetValueHigh: 6,
};

// workout (global message 26) field definition numbers.
const WORKOUT_FIELD = {
  workoutName: 8,
};

// workout_step_duration enum (subset we handle).
const DURATION_TYPE = {
  time: 0,
  open: 5,
  repeatUntilStepsComplete: 6,
};

// workout_step_target enum.
const TARGET_TYPE = {
  power: 4,
};

/** Garmin/TrainingPeaks convention: custom %FTP power targets are encoded as (pct*100 + 1000). */
const CUSTOM_POWER_TARGET_OFFSET = 1000;

interface RawStep {
  index: number;
  name?: string;
  durationType: number;
  durationValue: number;
  targetType?: number;
  targetValue?: number;
  customLow?: number;
  customHigh?: number;
}

function toWorkoutStep(step: RawStep): WorkoutStep {
  if (step.durationType === DURATION_TYPE.open) {
    return {
      name: step.name ?? "Free ride",
      durationSec: step.durationValue > 0 ? step.durationValue / 1000 : 300,
      powerLow: 0,
      powerHigh: 0,
      isFreeRide: true,
    };
  }

  const durationSec = step.durationValue / 1000;

  const isCustomPowerTarget =
    step.targetType === TARGET_TYPE.power && (step.targetValue ?? 0) === 0 && step.customLow !== undefined;

  if (isCustomPowerTarget) {
    const high = step.customHigh ?? step.customLow!;
    return {
      name: step.name,
      durationSec,
      powerLow: (step.customLow! - CUSTOM_POWER_TARGET_OFFSET) / 100,
      powerHigh: (high - CUSTOM_POWER_TARGET_OFFSET) / 100,
    };
  }

  // No usable power target (zone-based, HR-based, or missing) — surface as a
  // free-ride block rather than silently guessing a wattage.
  return {
    name: step.name ?? "Open step",
    durationSec: durationSec || 300,
    powerLow: 0,
    powerHigh: 0,
    isFreeRide: true,
  };
}

/**
 * Parses a Garmin FIT structured workout file (as produced by TrainingPeaks'
 * "Send to Device" export) into our internal Workout model.
 *
 * Handles the FIT repeat-step encoding: a `repeat_until_steps_complete`
 * step doesn't carry its own target — it tells the reader to replay an
 * earlier range of steps N times, which is how interval sets are stored.
 */
export function parseFitWorkout(buffer: ArrayBuffer): Workout {
  const messages = readFitMessages(buffer);

  let workoutName = "Imported workout";
  const rawSteps: RawStep[] = [];

  for (const msg of messages) {
    if (msg.globalMessageNumber === GLOBAL_MESSAGE.workout) {
      const name = msg.fields[WORKOUT_FIELD.workoutName];
      if (typeof name === "string" && name.trim()) workoutName = name.trim();
    } else if (msg.globalMessageNumber === GLOBAL_MESSAGE.workoutStep) {
      const f = msg.fields;
      rawSteps.push({
        index: Number(f[FIELD.messageIndex] ?? rawSteps.length),
        name: typeof f[FIELD.stepName] === "string" ? (f[FIELD.stepName] as string) : undefined,
        durationType: Number(f[FIELD.durationType] ?? DURATION_TYPE.time),
        durationValue: Number(f[FIELD.durationValue] ?? 0),
        targetType: f[FIELD.targetType] !== undefined ? Number(f[FIELD.targetType]) : undefined,
        targetValue: f[FIELD.targetValue] !== undefined ? Number(f[FIELD.targetValue]) : undefined,
        customLow: f[FIELD.customTargetValueLow] !== undefined ? Number(f[FIELD.customTargetValueLow]) : undefined,
        customHigh: f[FIELD.customTargetValueHigh] !== undefined ? Number(f[FIELD.customTargetValueHigh]) : undefined,
      });
    }
  }

  if (rawSteps.length === 0) {
    throw new Error("Invalid .fit file: no workout_step messages found (is this a workout export, not an activity?)");
  }

  rawSteps.sort((a, b) => a.index - b.index);

  function expandRange(start: number, end: number): WorkoutStep[] {
    const out: WorkoutStep[] = [];
    let i = start;
    while (i < end) {
      const step = rawSteps[i];
      if (step.durationType === DURATION_TYPE.repeatUntilStepsComplete) {
        const repeatCount = Math.max(1, Math.round(step.durationValue));
        const fromIndex = step.targetValue ?? start;
        // The referenced block [fromIndex, i) was already emitted once by the
        // forward walk above (this is how Garmin FIT encodes intervals: the
        // "on"/"off" steps appear once, then a trailing marker says how many
        // times total to have run them) — so only repeatCount-1 more copies
        // are needed here.
        const block = expandRange(fromIndex, i);
        for (let r = 0; r < repeatCount - 1; r++) out.push(...block);
        i += 1;
      } else {
        out.push(toWorkoutStep(step));
        i += 1;
      }
    }
    return out;
  }

  const steps = expandRange(0, rawSteps.length);
  return { name: workoutName, steps, source: "fit" };
}
