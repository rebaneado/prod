export interface RideSample {
  /** Seconds elapsed since the ride started. */
  tSec: number;
  powerWatts?: number;
  cadenceRpm?: number;
  heartRateBpm?: number;
  speedKmh?: number;
}

export interface RideRecording {
  startedAt: Date;
  workoutName?: string;
  samples: RideSample[];
}
