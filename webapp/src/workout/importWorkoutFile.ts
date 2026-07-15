import { parseFitWorkout } from "./fitWorkoutReader";
import { parseZwo } from "./zwoParser";
import type { Workout } from "./types";

export async function importWorkoutFile(file: File): Promise<Workout> {
  const lowerName = file.name.toLowerCase();

  if (lowerName.endsWith(".zwo")) {
    const text = await file.text();
    return parseZwo(text);
  }

  if (lowerName.endsWith(".fit")) {
    const buffer = await file.arrayBuffer();
    return parseFitWorkout(buffer);
  }

  throw new Error(`Unsupported file type: ${file.name}. Import a .zwo or .fit structured workout file.`);
}
