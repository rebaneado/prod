import type { Workout, WorkoutStep } from "./types";

function num(el: Element, attr: string, fallback = 0): number {
  const raw = el.getAttribute(attr);
  return raw === null ? fallback : parseFloat(raw);
}

function stepsFromElement(el: Element): WorkoutStep[] {
  const cadence = el.hasAttribute("Cadence") ? num(el, "Cadence") : undefined;

  switch (el.tagName) {
    case "Warmup":
    case "Ramp": {
      return [
        {
          name: el.tagName,
          durationSec: num(el, "Duration"),
          powerLow: num(el, "PowerLow"),
          powerHigh: num(el, "PowerHigh"),
          cadenceTarget: cadence,
        },
      ];
    }
    case "Cooldown": {
      return [
        {
          name: "Cooldown",
          durationSec: num(el, "Duration"),
          powerLow: num(el, "PowerLow"),
          powerHigh: num(el, "PowerHigh"),
          cadenceTarget: cadence,
        },
      ];
    }
    case "SteadyState": {
      const power = num(el, "Power");
      return [
        {
          name: "SteadyState",
          durationSec: num(el, "Duration"),
          powerLow: power,
          powerHigh: power,
          cadenceTarget: cadence,
        },
      ];
    }
    case "IntervalsT": {
      const repeat = Math.max(1, Math.round(num(el, "Repeat", 1)));
      const onDuration = num(el, "OnDuration");
      const offDuration = num(el, "OffDuration");
      const onPower = num(el, "OnPower");
      const offPower = num(el, "OffPower");
      const onCadence = cadence;
      const offCadence = el.hasAttribute("CadenceResting") ? num(el, "CadenceResting") : cadence;
      const steps: WorkoutStep[] = [];
      for (let i = 0; i < repeat; i++) {
        steps.push({
          name: "Interval (on)",
          durationSec: onDuration,
          powerLow: onPower,
          powerHigh: onPower,
          cadenceTarget: onCadence,
        });
        if (offDuration > 0) {
          steps.push({
            name: "Interval (off)",
            durationSec: offDuration,
            powerLow: offPower,
            powerHigh: offPower,
            cadenceTarget: offCadence,
          });
        }
      }
      return steps;
    }
    case "FreeRide": {
      return [
        {
          name: "Free ride",
          durationSec: num(el, "Duration"),
          powerLow: 0,
          powerHigh: 0,
          isFreeRide: true,
        },
      ];
    }
    default:
      return [];
  }
}

/** Parses a Zwift .zwo workout XML document into our internal Workout model. */
export function parseZwo(xmlText: string): Workout {
  const doc = new DOMParser().parseFromString(xmlText, "application/xml");

  const parserError = doc.querySelector("parsererror");
  if (parserError) {
    throw new Error("Invalid .zwo file: not well-formed XML");
  }

  const name = doc.querySelector("name")?.textContent?.trim() || "Imported workout";
  const workoutEl = doc.querySelector("workout");
  if (!workoutEl) {
    throw new Error("Invalid .zwo file: missing <workout> element");
  }

  const steps: WorkoutStep[] = [];
  for (const child of Array.from(workoutEl.children)) {
    steps.push(...stepsFromElement(child));
  }

  if (steps.length === 0) {
    throw new Error("Invalid .zwo file: no workout steps found");
  }

  return { name, steps, source: "zwo" };
}
