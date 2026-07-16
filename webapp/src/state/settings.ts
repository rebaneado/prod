import { useCallback, useState } from "react";

const STORAGE_KEY = "ergsync.settings.v1";

export interface Settings {
  ftpWatts: number;
}

const DEFAULT_SETTINGS: Settings = { ftpWatts: 200 };

function loadSettings(): Settings {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return DEFAULT_SETTINGS;
    return { ...DEFAULT_SETTINGS, ...JSON.parse(raw) };
  } catch {
    return DEFAULT_SETTINGS;
  }
}

export function useSettings() {
  const [settings, setSettingsState] = useState<Settings>(loadSettings);

  const setSettings = useCallback((next: Settings) => {
    setSettingsState(next);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
  }, []);

  return { settings, setSettings };
}
