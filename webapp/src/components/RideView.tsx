import { useEffect, useState } from "react";
import type { ErgEngine, ErgEngineState } from "../erg/ergEngine";
import type { RideRecording } from "../ride/types";
import { formatClock } from "../utils/format";
import type { Workout } from "../workout/types";
import { PowerChart } from "./PowerChart";

interface RideViewProps {
  engine: ErgEngine;
  workout: Workout;
  onFinish: (recording: RideRecording) => void;
}

export function RideView({ engine, workout, onFinish }: RideViewProps) {
  const [state, setState] = useState<ErgEngineState>(() => engine.currentState());

  useEffect(() => {
    return engine.onChange(setState);
  }, [engine]);

  const step = workout.steps[state.currentStepIndex];
  const nextStep = workout.steps[state.currentStepIndex + 1];
  const stepRemaining = step ? Math.max(0, step.durationSec - state.elapsedInStepSec) : 0;
  const stepProgress = step ? Math.min(1, state.elapsedInStepSec / Math.max(1, step.durationSec)) : 1;

  const handleEnd = async () => {
    const recording = await engine.stop();
    onFinish(recording);
  };

  return (
    <div className="ride-view">
      <div className="ride-numbers">
        <div className="ride-number">
          <span className="ride-number-value">{state.live.powerWatts ?? "--"}</span>
          <span className="ride-number-label">watts</span>
        </div>
        <div className="ride-number ride-number-target">
          <span className="ride-number-value">{step?.isFreeRide ? "free" : state.targetWatts ?? "--"}</span>
          <span className="ride-number-label">target</span>
        </div>
        <div className="ride-number">
          <span className="ride-number-value">{state.live.cadenceRpm ?? "--"}</span>
          <span className="ride-number-label">rpm</span>
        </div>
        <div className="ride-number">
          <span className="ride-number-value">{state.live.heartRateBpm ?? "--"}</span>
          <span className="ride-number-label">bpm</span>
        </div>
      </div>

      <div className="ride-step-info">
        <div className="ride-step-title">
          <strong>{step?.name ?? "Step"}</strong>
          <span>{formatClock(stepRemaining)} remaining</span>
        </div>
        <div className="progress-bar">
          <div className="progress-bar-fill" style={{ width: `${stepProgress * 100}%` }} />
        </div>
        {nextStep && (
          <p className="ride-next-step">
            Next: {nextStep.name ?? "Step"} ({formatClock(nextStep.durationSec)})
          </p>
        )}
      </div>

      <PowerChart samples={engine.getSamples()} targetWatts={step && !step.isFreeRide ? state.targetWatts : undefined} />

      <div className="ride-total-time">
        {formatClock(state.totalElapsedSec)} / {formatClock(state.totalDurationSec)}
      </div>

      <div className="ride-controls">
        {state.status === "running" && (
          <button type="button" onClick={() => engine.pause()}>
            Pause
          </button>
        )}
        {state.status === "paused" && (
          <button type="button" onClick={() => engine.resume()}>
            Resume
          </button>
        )}
        <button type="button" onClick={() => engine.skipStep()}>
          Skip step
        </button>
        <button type="button" className="danger" onClick={handleEnd}>
          End ride
        </button>
      </div>
    </div>
  );
}
