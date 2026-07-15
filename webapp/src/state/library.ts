import { useCallback, useState } from "react";
import type { Workout } from "../workout/types";

const STORAGE_KEY = "ergsync.library.v1";

interface StoredWorkout extends Workout {
  id: string;
  importedAt: string;
}

function loadLibrary(): StoredWorkout[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    return JSON.parse(raw) as StoredWorkout[];
  } catch {
    return [];
  }
}

function persist(workouts: StoredWorkout[]): void {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(workouts));
}

export function useLibrary() {
  const [workouts, setWorkouts] = useState<StoredWorkout[]>(loadLibrary);

  const addWorkout = useCallback((workout: Workout) => {
    const stored: StoredWorkout = {
      ...workout,
      id: crypto.randomUUID(),
      importedAt: new Date().toISOString(),
    };
    setWorkouts((prev) => {
      const next = [stored, ...prev];
      persist(next);
      return next;
    });
  }, []);

  const removeWorkout = useCallback((id: string) => {
    setWorkouts((prev) => {
      const next = prev.filter((w) => w.id !== id);
      persist(next);
      return next;
    });
  }, []);

  return { workouts, addWorkout, removeWorkout };
}

export type { StoredWorkout };
