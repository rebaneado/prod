/** A single block of a structured workout. Power targets are fractions of FTP (1.0 = 100% FTP). */
export interface WorkoutStep {
  name?: string;
  durationSec: number;
  /** Target power at the start of the step, as a fraction of FTP. */
  powerLow: number;
  /** Target power at the end of the step, as a fraction of FTP. Equal to powerLow for steady steps. */
  powerHigh: number;
  cadenceTarget?: number;
  /** Free ride / open step: rider controls resistance/cadence, no ERG target is pushed. */
  isFreeRide?: boolean;
}

export interface Workout {
  name: string;
  steps: WorkoutStep[];
  source?: "zwo" | "fit";
}

export function workoutDurationSec(workout: Workout): number {
  return workout.steps.reduce((sum, s) => sum + s.durationSec, 0);
}

/** Linear power interpolation within a step, given seconds elapsed since the step started. */
export function powerAtStepElapsed(step: WorkoutStep, elapsedSec: number): number {
  if (step.durationSec <= 0) return step.powerLow;
  const t = Math.min(1, Math.max(0, elapsedSec / step.durationSec));
  return step.powerLow + (step.powerHigh - step.powerLow) * t;
}
