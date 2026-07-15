import type { RideRecording } from "../ride/types";
import { buildFitActivity } from "../workout/fitActivityWriter";
import { getValidStravaAccessToken } from "./stravaAuth";

const UPLOADS_URL = "https://www.strava.com/api/v3/uploads";

interface StravaUploadStatus {
  id: number;
  external_id?: string;
  error?: string | null;
  status: string;
  activity_id?: number | null;
}

async function createUpload(accessToken: string, bytes: Uint8Array, name: string): Promise<number> {
  const form = new FormData();
  form.set("file", new Blob([bytes.buffer as ArrayBuffer], { type: "application/octet-stream" }), `${name}.fit`);
  form.set("data_type", "fit");
  form.set("name", name);
  form.set("trainer", "1");
  form.set("activity_type", "virtualride");

  const res = await fetch(UPLOADS_URL, {
    method: "POST",
    headers: { Authorization: `Bearer ${accessToken}` },
    body: form,
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Strava upload failed (${res.status}): ${text}`);
  }
  const json = (await res.json()) as StravaUploadStatus;
  return json.id;
}

async function getUploadStatus(accessToken: string, uploadId: number): Promise<StravaUploadStatus> {
  const res = await fetch(`${UPLOADS_URL}/${uploadId}`, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Strava upload status check failed (${res.status}): ${text}`);
  }
  return (await res.json()) as StravaUploadStatus;
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export interface StravaUploadResult {
  activityId: number;
  url: string;
}

/**
 * Uploads a completed ride to Strava and polls until it finishes processing.
 * Throws if Strava reports an error (e.g. a duplicate activity) or if
 * processing doesn't finish within the poll budget.
 */
export async function uploadRideToStrava(
  recording: RideRecording,
  options: { pollIntervalMs?: number; maxPolls?: number } = {}
): Promise<StravaUploadResult> {
  const { pollIntervalMs = 1500, maxPolls = 20 } = options;

  const accessToken = await getValidStravaAccessToken();
  const bytes = buildFitActivity(recording);
  const name = recording.workoutName ?? "ErgSync ride";

  const uploadId = await createUpload(accessToken, bytes, name);

  for (let i = 0; i < maxPolls; i++) {
    await sleep(pollIntervalMs);
    const status = await getUploadStatus(accessToken, uploadId);
    if (status.error) {
      throw new Error(`Strava rejected the upload: ${status.error}`);
    }
    if (status.activity_id) {
      return { activityId: status.activity_id, url: `https://www.strava.com/activities/${status.activity_id}` };
    }
  }

  throw new Error("Strava is still processing the upload — check strava.com in a minute.");
}
