import type { FtmsTrainer } from "../ble/ftmsTrainer";
import type { IndoorBikeSample } from "../ble/indoorBikeData";
import type { RideRecording, RideSample } from "../ride/types";
import { powerAtStepElapsed, workoutDurationSec, type Workout } from "../workout/types";

export type ErgEngineStatus = "idle" | "running" | "paused" | "finished";

export interface ErgEngineState {
  status: ErgEngineStatus;
  currentStepIndex: number;
  elapsedInStepSec: number;
  totalElapsedSec: number;
  totalDurationSec: number;
  targetWatts?: number;
  live: IndoorBikeSample;
}

type Listener = (state: ErgEngineState) => void;

/**
 * Drives ERG-mode execution of a structured workout: ticks once per second,
 * computes the target watts for "now" (handling ramps via interpolation and
 * %FTP -> watts conversion), pushes changes to the trainer, and records
 * live power/cadence/heart-rate samples for later export.
 */
export class ErgEngine {
  private status: ErgEngineStatus = "idle";
  private totalElapsedSec = 0;
  private lastSentTargetWatts: number | undefined;
  private samples: RideSample[] = [];
  private startedAt: Date | undefined;
  private latestLive: IndoorBikeSample = {};
  private tickHandle: ReturnType<typeof setInterval> | undefined;
  private unsubscribeData: (() => void) | undefined;
  private listeners = new Set<Listener>();
  private trainer: FtmsTrainer;
  private workout: Workout;
  private ftpWatts: number;

  constructor(trainer: FtmsTrainer, workout: Workout, ftpWatts: number) {
    this.trainer = trainer;
    this.workout = workout;
    this.ftpWatts = ftpWatts;
  }

  onChange(listener: Listener): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  private emit(): void {
    const state = this.currentState();
    for (const l of this.listeners) l(state);
  }

  private locate(tSec: number): { stepIndex: number; elapsedInStep: number } {
    let acc = 0;
    for (let i = 0; i < this.workout.steps.length; i++) {
      const step = this.workout.steps[i];
      if (tSec < acc + step.durationSec) {
        return { stepIndex: i, elapsedInStep: tSec - acc };
      }
      acc += step.durationSec;
    }
    return { stepIndex: this.workout.steps.length, elapsedInStep: 0 };
  }

  private cumulativeStartOf(stepIndex: number): number {
    let acc = 0;
    for (let i = 0; i < stepIndex; i++) acc += this.workout.steps[i].durationSec;
    return acc;
  }

  /** Snapshot of recorded samples so far, for live charting. */
  getSamples(): RideSample[] {
    return [...this.samples];
  }

  currentState(): ErgEngineState {
    const { stepIndex, elapsedInStep } = this.locate(this.totalElapsedSec);
    const step = this.workout.steps[stepIndex];
    const targetWatts = step && !step.isFreeRide ? Math.round(powerAtStepElapsed(step, elapsedInStep) * this.ftpWatts) : undefined;
    return {
      status: this.status,
      currentStepIndex: stepIndex,
      elapsedInStepSec: elapsedInStep,
      totalElapsedSec: this.totalElapsedSec,
      totalDurationSec: workoutDurationSec(this.workout),
      targetWatts,
      live: this.latestLive,
    };
  }

  async start(): Promise<void> {
    this.startedAt = new Date();
    this.totalElapsedSec = 0;
    this.samples = [];
    this.lastSentTargetWatts = undefined;
    this.status = "running";

    this.unsubscribeData = this.trainer.onData((sample) => {
      this.latestLive = sample;
    });

    await this.trainer.requestControl();
    await this.trainer.startResistance();

    this.tick();
    this.tickHandle = setInterval(() => this.tick(), 1000);
  }

  pause(): void {
    if (this.status !== "running") return;
    this.status = "paused";
    if (this.tickHandle) clearInterval(this.tickHandle);
    this.tickHandle = undefined;
    this.trainer.stopResistance().catch((err) => console.error("Failed to pause trainer resistance", err));
    this.emit();
  }

  resume(): void {
    if (this.status !== "paused") return;
    this.status = "running";
    this.trainer.startResistance().catch((err) => console.error("Failed to resume trainer resistance", err));
    this.tickHandle = setInterval(() => this.tick(), 1000);
    this.emit();
  }

  /** Jumps to the start of the next workout step (useful for skipping a free-ride/open block). */
  skipStep(): void {
    const { stepIndex } = this.locate(this.totalElapsedSec);
    const nextIndex = stepIndex + 1;
    this.totalElapsedSec = this.cumulativeStartOf(Math.min(nextIndex, this.workout.steps.length));
    this.tick();
  }

  async stop(): Promise<RideRecording> {
    if (this.tickHandle) clearInterval(this.tickHandle);
    this.tickHandle = undefined;
    this.unsubscribeData?.();
    this.status = "finished";
    try {
      await this.trainer.stopResistance();
    } catch (err) {
      console.error("Failed to stop trainer resistance", err);
    }
    this.emit();
    return {
      startedAt: this.startedAt ?? new Date(),
      workoutName: this.workout.name,
      samples: this.samples,
    };
  }

  private tick(): void {
    const { stepIndex, elapsedInStep } = this.locate(this.totalElapsedSec);

    if (stepIndex >= this.workout.steps.length) {
      this.stop();
      return;
    }

    const step = this.workout.steps[stepIndex];
    if (!step.isFreeRide) {
      const targetWatts = Math.round(powerAtStepElapsed(step, elapsedInStep) * this.ftpWatts);
      if (targetWatts !== this.lastSentTargetWatts) {
        this.lastSentTargetWatts = targetWatts;
        this.trainer.setTargetPower(targetWatts).catch((err) => console.error("Failed to set target power", err));
      }
    }

    this.samples.push({
      tSec: this.totalElapsedSec,
      powerWatts: this.latestLive.powerWatts,
      cadenceRpm: this.latestLive.cadenceRpm,
      heartRateBpm: this.latestLive.heartRateBpm,
      speedKmh: this.latestLive.speedKmh,
    });

    this.emit();

    if (this.status === "running") {
      this.totalElapsedSec += 1;
    }
  }
}
