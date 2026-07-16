import { useCallback, useEffect, useState } from "react";
import {
  buildAuthorizeUrl,
  clearStravaTokens,
  exchangeCodeForTokens,
  isStravaConfigured,
  loadStravaTokens,
} from "./stravaAuth";

export interface StravaState {
  configured: boolean;
  connected: boolean;
  athleteName?: string;
  exchanging: boolean;
  error: string | null;
  connect: () => void;
  disconnect: () => void;
}

/**
 * Tracks Strava connection state and, on mount, completes the OAuth
 * Authorization Code redirect if the app was just sent back from Strava
 * with a `?code=...` query param.
 */
export function useStrava(): StravaState {
  const configured = isStravaConfigured();
  const [connected, setConnected] = useState(() => loadStravaTokens() !== null);
  const [athleteName, setAthleteName] = useState<string | undefined>(() => loadStravaTokens()?.athleteName);
  const [exchanging, setExchanging] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const code = params.get("code");
    const oauthError = params.get("error");

    if (!code && !oauthError) return;

    // Strip the OAuth params so a refresh doesn't try to redeem the code again.
    const cleanUrl = window.location.pathname;
    window.history.replaceState({}, "", cleanUrl);

    if (oauthError) {
      setError(`Strava authorization was not granted (${oauthError}).`);
      return;
    }

    setExchanging(true);
    exchangeCodeForTokens(code!)
      .then((tokens) => {
        setConnected(true);
        setAthleteName(tokens.athleteName);
      })
      .catch((err) => setError(err instanceof Error ? err.message : String(err)))
      .finally(() => setExchanging(false));
  }, []);

  const connect = useCallback(() => {
    setError(null);
    const redirectUri = `${window.location.origin}${window.location.pathname}`;
    try {
      window.location.href = buildAuthorizeUrl(redirectUri);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    }
  }, []);

  const disconnect = useCallback(() => {
    clearStravaTokens();
    setConnected(false);
    setAthleteName(undefined);
  }, []);

  return { configured, connected, athleteName, exchanging, error, connect, disconnect };
}
