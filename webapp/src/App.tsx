import { useEffect, useRef, useState } from "react";
import "./App.css";
import { FtmsTrainer, isWebBluetoothSupported, type TrainerConnectionState } from "./ble/ftmsTrainer";
import { Dashboard } from "./components/Dashboard";
import { RideView } from "./components/RideView";
import { SummaryView } from "./components/SummaryView";
import { ErgEngine } from "./erg/ergEngine";
import type { RideRecording } from "./ride/types";
import { useLibrary, type StoredWorkout } from "./state/library";
import { useSettings } from "./state/settings";

type View = "dashboard" | "ride" | "summary";

function App() {
  const trainerRef = useRef<FtmsTrainer>(new FtmsTrainer());
  const [connectionState, setConnectionState] = useState<TrainerConnectionState>("disconnected");
  const [connectError, setConnectError] = useState<string | null>(null);

  const { settings, setSettings } = useSettings();
  const { workouts, addWorkout, removeWorkout } = useLibrary();

  const [view, setView] = useState<View>("dashboard");
  const [activeWorkout, setActiveWorkout] = useState<StoredWorkout | null>(null);
  const engineRef = useRef<ErgEngine | null>(null);
  const [lastRecording, setLastRecording] = useState<RideRecording | null>(null);

  useEffect(() => {
    return trainerRef.current.onConnectionChange(setConnectionState);
  }, []);

  const handleConnect = async () => {
    setConnectError(null);
    try {
      await trainerRef.current.connect();
    } catch (err) {
      setConnectError(err instanceof Error ? err.message : String(err));
    }
  };

  const handleDisconnect = () => {
    trainerRef.current.disconnect();
  };

  const handleStartWorkout = async (workout: StoredWorkout) => {
    setConnectError(null);
    const engine = new ErgEngine(trainerRef.current, workout, settings.ftpWatts);
    try {
      await engine.start();
    } catch (err) {
      setConnectError(err instanceof Error ? err.message : String(err));
      return;
    }
    engineRef.current = engine;
    setActiveWorkout(workout);
    setView("ride");
  };

  const handleFinishRide = (recording: RideRecording) => {
    engineRef.current = null;
    setLastRecording(recording);
    setView("summary");
  };

  const handleDoneSummary = () => {
    setLastRecording(null);
    setActiveWorkout(null);
    setView("dashboard");
  };

  return (
    <div className="app-shell">
      <header className="app-header">
        <h1>ErgSync</h1>
        <span className="hint">ERG-mode trainer control, no Zwift subscription</span>
      </header>

      {!isWebBluetoothSupported() && (
        <div className="error banner">
          Web Bluetooth isn't available in this browser. Open this app in Chrome or Edge on desktop or Android.
        </div>
      )}
      {connectError && <div className="error banner">{connectError}</div>}

      <main className="app-main">
        {view === "dashboard" && (
          <Dashboard
            connectionState={connectionState}
            deviceName={trainerRef.current.deviceName}
            onConnect={handleConnect}
            onDisconnect={handleDisconnect}
            settings={settings}
            setSettings={setSettings}
            workouts={workouts}
            addWorkout={addWorkout}
            removeWorkout={removeWorkout}
            onStartWorkout={handleStartWorkout}
          />
        )}

        {view === "ride" && engineRef.current && activeWorkout && (
          <RideView engine={engineRef.current} workout={activeWorkout} onFinish={handleFinishRide} />
        )}

        {view === "summary" && lastRecording && <SummaryView recording={lastRecording} onDone={handleDoneSummary} />}
      </main>
    </div>
  );
}

export default App;
