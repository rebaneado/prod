import { useMemo } from "react";
import type { RideRecording } from "../ride/types";
import { formatClock } from "../utils/format";
import { downloadFitActivity } from "../workout/fitActivityWriter";

interface SummaryViewProps {
  recording: RideRecording;
  onDone: () => void;
}

export function SummaryView({ recording, onDone }: SummaryViewProps) {
  const stats = useMemo(() => {
    const powers = recording.samples.map((s) => s.powerWatts).filter((v): v is number => v !== undefined);
    const cadences = recording.samples.map((s) => s.cadenceRpm).filter((v): v is number => v !== undefined);
    const durationSec = recording.samples.length ? recording.samples[recording.samples.length - 1].tSec : 0;
    const avg = (arr: number[]) => (arr.length ? Math.round(arr.reduce((a, b) => a + b, 0) / arr.length) : undefined);
    return {
      durationSec,
      avgPower: avg(powers),
      maxPower: powers.length ? Math.max(...powers) : undefined,
      avgCadence: avg(cadences),
    };
  }, [recording]);

  const filename = `${recording.workoutName ?? "ride"}-${recording.startedAt.toISOString().slice(0, 10)}.fit`
    .replace(/\s+/g, "_")
    .toLowerCase();

  return (
    <div className="summary-view">
      <h2>Ride complete</h2>
      <p>{recording.workoutName}</p>

      <div className="summary-stats">
        <div>
          <span className="ride-number-value">{formatClock(stats.durationSec)}</span>
          <span className="ride-number-label">duration</span>
        </div>
        <div>
          <span className="ride-number-value">{stats.avgPower ?? "--"}</span>
          <span className="ride-number-label">avg watts</span>
        </div>
        <div>
          <span className="ride-number-value">{stats.maxPower ?? "--"}</span>
          <span className="ride-number-label">max watts</span>
        </div>
        <div>
          <span className="ride-number-value">{stats.avgCadence ?? "--"}</span>
          <span className="ride-number-label">avg rpm</span>
        </div>
      </div>

      <div className="summary-export">
        <button type="button" onClick={() => downloadFitActivity(recording, filename)}>
          Download .fit
        </button>
        <p className="hint">
          Drop the downloaded file onto your TrainingPeaks calendar to log it, or upload it to Strava/Garmin Connect if
          you already have that syncing into TrainingPeaks.
        </p>
      </div>

      <button type="button" onClick={onDone}>
        Back to workouts
      </button>
    </div>
  );
}
