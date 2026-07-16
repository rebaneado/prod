import { useMemo, useState } from "react";
import type { RideRecording } from "../ride/types";
import type { StravaState } from "../strava/useStrava";
import { uploadRideToStrava } from "../strava/stravaUpload";
import { formatClock } from "../utils/format";
import { downloadFitActivity } from "../workout/fitActivityWriter";

interface SummaryViewProps {
  recording: RideRecording;
  onDone: () => void;
  strava: StravaState;
}

type UploadState = { status: "idle" } | { status: "uploading" } | { status: "done"; url: string } | { status: "error"; message: string };

export function SummaryView({ recording, onDone, strava }: SummaryViewProps) {
  const [upload, setUpload] = useState<UploadState>({ status: "idle" });

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

  const handleUpload = async () => {
    setUpload({ status: "uploading" });
    try {
      const result = await uploadRideToStrava(recording);
      setUpload({ status: "done", url: result.url });
    } catch (err) {
      setUpload({ status: "error", message: err instanceof Error ? err.message : String(err) });
    }
  };

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
        {strava.connected && (
          <>
            <button type="button" onClick={handleUpload} disabled={upload.status === "uploading" || upload.status === "done"}>
              {upload.status === "uploading" ? "Uploading..." : upload.status === "done" ? "Uploaded" : "Upload to Strava"}
            </button>
            {upload.status === "done" && (
              <p className="hint">
                <a href={upload.url} target="_blank" rel="noreferrer">
                  View on Strava
                </a>
              </p>
            )}
            {upload.status === "error" && <p className="error">{upload.message}</p>}
          </>
        )}

        <button type="button" onClick={() => downloadFitActivity(recording, filename)}>
          Download .fit
        </button>
        <p className="hint">
          {strava.connected
            ? "Or drop the downloaded file onto your TrainingPeaks calendar directly."
            : 'Drop the downloaded file onto your TrainingPeaks calendar to log it, or connect Strava on the dashboard for one-click upload.'}
        </p>
      </div>

      <button type="button" onClick={onDone}>
        Back to workouts
      </button>
    </div>
  );
}
