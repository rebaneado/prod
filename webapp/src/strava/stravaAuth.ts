// Strava OAuth (Authorization Code flow). Strava's API is genuinely
// self-serve for individuals: create a free app at
// https://www.strava.com/settings/api and put its client id/secret in a
// local .env file (see .env.example) — no partner approval needed, unlike
// TrainingPeaks.
//
// Note: because this app is 100% client-side (no backend), the client
// secret ends up embedded in the built JS bundle that ships to the browser.
// That's an accepted tradeoff for a personal tool you run yourself — do not
// deploy a build of this app publicly with real credentials baked in.

const STORAGE_KEY = "ergsync.strava.v1";
const AUTHORIZE_URL = "https://www.strava.com/oauth/authorize";
const TOKEN_URL = "https://www.strava.com/oauth/token";
const SCOPE = "activity:write";

export const STRAVA_CLIENT_ID = import.meta.env.VITE_STRAVA_CLIENT_ID as string | undefined;
export const STRAVA_CLIENT_SECRET = import.meta.env.VITE_STRAVA_CLIENT_SECRET as string | undefined;

export function isStravaConfigured(): boolean {
  return Boolean(STRAVA_CLIENT_ID && STRAVA_CLIENT_SECRET);
}

export interface StravaTokens {
  accessToken: string;
  refreshToken: string;
  /** Unix seconds. */
  expiresAt: number;
  athleteName?: string;
}

export function loadStravaTokens(): StravaTokens | null {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? (JSON.parse(raw) as StravaTokens) : null;
  } catch {
    return null;
  }
}

export function saveStravaTokens(tokens: StravaTokens): void {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(tokens));
}

export function clearStravaTokens(): void {
  localStorage.removeItem(STORAGE_KEY);
}

export function isStravaConnected(): boolean {
  return loadStravaTokens() !== null;
}

export function buildAuthorizeUrl(redirectUri: string): string {
  if (!STRAVA_CLIENT_ID) throw new Error("Strava isn't configured (missing VITE_STRAVA_CLIENT_ID)");
  const params = new URLSearchParams({
    client_id: STRAVA_CLIENT_ID,
    redirect_uri: redirectUri,
    response_type: "code",
    approval_prompt: "auto",
    scope: SCOPE,
  });
  return `${AUTHORIZE_URL}?${params.toString()}`;
}

interface StravaTokenResponse {
  access_token: string;
  refresh_token: string;
  expires_at: number;
  athlete?: { firstname?: string; lastname?: string };
}

async function requestToken(body: Record<string, string>): Promise<StravaTokens> {
  if (!STRAVA_CLIENT_ID || !STRAVA_CLIENT_SECRET) {
    throw new Error("Strava isn't configured (missing client id/secret)");
  }
  const res = await fetch(TOKEN_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: STRAVA_CLIENT_ID,
      client_secret: STRAVA_CLIENT_SECRET,
      ...body,
    }),
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Strava token request failed (${res.status}): ${text}`);
  }
  const json = (await res.json()) as StravaTokenResponse;
  const athleteName = json.athlete ? [json.athlete.firstname, json.athlete.lastname].filter(Boolean).join(" ") : undefined;
  return {
    accessToken: json.access_token,
    refreshToken: json.refresh_token,
    expiresAt: json.expires_at,
    athleteName,
  };
}

export async function exchangeCodeForTokens(code: string): Promise<StravaTokens> {
  const tokens = await requestToken({ code, grant_type: "authorization_code" });
  saveStravaTokens(tokens);
  return tokens;
}

async function refreshTokens(refreshToken: string): Promise<StravaTokens> {
  const previous = loadStravaTokens();
  const tokens = await requestToken({ refresh_token: refreshToken, grant_type: "refresh_token" });
  // Strava's refresh response doesn't repeat the athlete profile — carry it forward.
  const merged = { ...tokens, athleteName: tokens.athleteName ?? previous?.athleteName };
  saveStravaTokens(merged);
  return merged;
}

const EXPIRY_BUFFER_SEC = 60;

/** Returns a valid access token, transparently refreshing it if it's expired or about to be. */
export async function getValidStravaAccessToken(): Promise<string> {
  const tokens = loadStravaTokens();
  if (!tokens) throw new Error("Strava isn't connected yet");

  const nowSec = Math.floor(Date.now() / 1000);
  if (tokens.expiresAt - nowSec > EXPIRY_BUFFER_SEC) {
    return tokens.accessToken;
  }

  const refreshed = await refreshTokens(tokens.refreshToken);
  return refreshed.accessToken;
}
