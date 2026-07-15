import { useRef, useState } from "react";
import type { TrainerConnectionState } from "../ble/ftmsTrainer";
import type { Settings } from "../state/settings";
import type { StoredWorkout } from "../state/library";
import type { StravaState } from "../strava/useStrava";
import { workoutDurationSec } from "../workout/types";
import { formatClock } from "../utils/format";
import { importWorkoutFile } from "../workout/importWorkoutFile";

interface DashboardProps {
  connectionState: TrainerConnectionState;
  deviceName?: string;
  onConnect: () => void;
  onDisconnect: () => void;
  settings: Settings;
  setSettings: (s: Settings) => void;
  workouts: StoredWorkout[];
  addWorkout: (w: Awaited<ReturnType<typeof importWorkoutFile>>) => void;
  removeWorkout: (id: string) => void;
  onStartWorkout: (workout: StoredWorkout) => void;
  strava: StravaState;
}

export function Dashboard({
  connectionState,
  deviceName,
  onConnect,
  onDisconnect,
  settings,
  setSettings,
  workouts,
  addWorkout,
  removeWorkout,
  onStartWorkout,
  strava,
}: DashboardProps) {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [importError, setImportError] = useState<string | null>(null);

  const handleFiles = async (files: FileList | null) => {
    if (!files) return;
    setImportError(null);
    for (const file of Array.from(files)) {
      try {
        const workout = await importWorkoutFile(file);
        addWorkout(workout);
      } catch (err) {
        setImportError(err instanceof Error ? err.message : String(err));
      }
    }
    if (fileInputRef.current) fileInputRef.current.value = "";
  };

  return (
    <div className="dashboard">
      <section className="card">
        <h2>Trainer</h2>
        <div className="connection-row">
          <span className={`status-pill status-${connectionState}`}>
            {connectionState === "connected" ? `Connected: ${deviceName ?? "trainer"}` : connectionState}
          </span>
          {connectionState === "connected" ? (
            <button type="button" onClick={onDisconnect}>
              Disconnect
            </button>
          ) : (
            <button type="button" onClick={onConnect} disabled={connectionState === "connecting"}>
              Connect Saris H3
            </button>
          )}
        </div>
      </section>

      <section className="card">
        <h2>Settings</h2>
        <label className="settings-field">
          FTP (watts)
          <input
            type="number"
            min={50}
            max={600}
            value={settings.ftpWatts}
            onChange={(e) => setSettings({ ...settings, ftpWatts: Number(e.target.value) || settings.ftpWatts })}
          />
        </label>
      </section>

      <section className="card">
        <h2>Strava</h2>
        {!strava.configured && (
          <p className="hint">
            Not set up yet. Create a free app at{" "}
            <a href="https://www.strava.com/settings/api" target="_blank" rel="noreferrer">
              strava.com/settings/api
            </a>{" "}
            and add its client id/secret to your local <code>.env</code> (see README) to enable automatic upload
            after a ride.
          </p>
        )}
        {strava.configured && (
          <div className="connection-row">
            {strava.connected ? (
              <>
                <span className="status-pill status-connected">Connected{strava.athleteName ? `: ${strava.athleteName}` : ""}</span>
                <button type="button" onClick={strava.disconnect}>
                  Disconnect
                </button>
              </>
            ) : (
              <button type="button" onClick={strava.connect} disabled={strava.exchanging}>
                {strava.exchanging ? "Connecting..." : "Connect Strava"}
              </button>
            )}
          </div>
        )}
      </section>

      <section className="card">
        <h2>Workout library</h2>
        <p className="hint">
          In TrainingPeaks, open a planned workout and use "Send to Device" to export a .fit file (or import a .zwo
          file directly) — no TrainingPeaks account access needed.
        </p>
        <input
          ref={fileInputRef}
          type="file"
          accept=".zwo,.fit"
          multiple
          onChange={(e) => handleFiles(e.target.files)}
          style={{ display: "none" }}
        />
        <button type="button" onClick={() => fileInputRef.current?.click()}>
          Import workout file(s)
        </button>
        {importError && <p className="error">{importError}</p>}

        <ul className="workout-list">
          {workouts.length === 0 && <li className="hint">No workouts imported yet.</li>}
          {workouts.map((w) => (
            <li key={w.id} className="workout-list-item">
              <div>
                <strong>{w.name}</strong>
                <span className="hint"> {formatClock(workoutDurationSec(w))} &middot; {w.source}</span>
              </div>
              <div className="workout-list-actions">
                <button type="button" disabled={connectionState !== "connected"} onClick={() => onStartWorkout(w)}>
                  Start
                </button>
                <button type="button" className="danger" onClick={() => removeWorkout(w.id)}>
                  Remove
                </button>
              </div>
            </li>
          ))}
        </ul>
      </section>
    </div>
  );
}
