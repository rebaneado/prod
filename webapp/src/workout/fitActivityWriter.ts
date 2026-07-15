import { BASE_TYPE, fitCrc16, GLOBAL_MESSAGE, toFitTimestamp } from "./fitBinary";
import { ByteWriter, FitMessageType } from "./fitWriter";
import type { RideRecording } from "../ride/types";

// FIT enum values used below (Garmin FIT SDK "Profile" constants).
const FILE_TYPE_ACTIVITY = 4;
const MANUFACTURER_DEVELOPMENT = 255;
const EVENT_TIMER = 0;
const EVENT_TYPE_START = 0;
const EVENT_TYPE_STOP_ALL = 4;
const SPORT_CYCLING = 2;
const SUB_SPORT_INDOOR_CYCLING = 6;
const ACTIVITY_TYPE_MANUAL = 0;
const ACTIVITY_EVENT = 26;
const ACTIVITY_EVENT_TYPE_STOP = 1;

function buildFitHeader(dataSize: number): Uint8Array {
  const w = new ByteWriter();
  w.writeUInt8(14); // header size
  w.writeUInt8(0x10); // protocol version 1.0
  w.writeUInt16(2140); // profile version (arbitrary, matches a real FIT SDK release)
  w.writeUInt32(dataSize);
  for (const ch of ".FIT") w.writeUInt8(ch.charCodeAt(0));
  w.writeUInt16(0); // header CRC: 0 = not used
  return w.toBytes();
}

/**
 * Builds a FIT activity file from a recorded ride so it can be dropped onto
 * TrainingPeaks' calendar (or Strava/Garmin Connect, which most people
 * already have auto-forwarding into TrainingPeaks) without any API access.
 */
export function buildFitActivity(recording: RideRecording): Uint8Array {
  const { startedAt, samples } = recording;
  const startTimestamp = toFitTimestamp(startedAt);
  const durationSec = samples.length > 0 ? samples[samples.length - 1].tSec : 0;
  const endTimestamp = startTimestamp + Math.round(durationSec);

  const powers = samples.map((s) => s.powerWatts).filter((v): v is number => v !== undefined);
  const avgPower = powers.length ? Math.round(powers.reduce((a, b) => a + b, 0) / powers.length) : undefined;
  const maxPower = powers.length ? Math.max(...powers) : undefined;

  const fileId = new FitMessageType(0, GLOBAL_MESSAGE.fileId, [
    { num: 0, baseType: BASE_TYPE.enum }, // type
    { num: 1, baseType: BASE_TYPE.uint16 }, // manufacturer
    { num: 2, baseType: BASE_TYPE.uint16 }, // product
    { num: 4, baseType: BASE_TYPE.uint32 }, // time_created
  ]);

  const event = new FitMessageType(1, GLOBAL_MESSAGE.event, [
    { num: 253, baseType: BASE_TYPE.uint32 }, // timestamp
    { num: 0, baseType: BASE_TYPE.enum }, // event
    { num: 1, baseType: BASE_TYPE.enum }, // event_type
  ]);

  const record = new FitMessageType(2, GLOBAL_MESSAGE.record, [
    { num: 253, baseType: BASE_TYPE.uint32 }, // timestamp
    { num: 3, baseType: BASE_TYPE.uint8 }, // heart_rate
    { num: 4, baseType: BASE_TYPE.uint8 }, // cadence
    { num: 7, baseType: BASE_TYPE.uint16 }, // power
  ]);

  const lap = new FitMessageType(3, GLOBAL_MESSAGE.lap, [
    { num: 253, baseType: BASE_TYPE.uint32 }, // timestamp (end)
    { num: 2, baseType: BASE_TYPE.uint32 }, // start_time
    { num: 7, baseType: BASE_TYPE.uint32 }, // total_elapsed_time
    { num: 8, baseType: BASE_TYPE.uint32 }, // total_timer_time
    { num: 19, baseType: BASE_TYPE.uint16 }, // avg_power
    { num: 20, baseType: BASE_TYPE.uint16 }, // max_power
  ]);

  const session = new FitMessageType(4, GLOBAL_MESSAGE.session, [
    { num: 253, baseType: BASE_TYPE.uint32 }, // timestamp
    { num: 2, baseType: BASE_TYPE.uint32 }, // start_time
    { num: 7, baseType: BASE_TYPE.uint32 }, // total_elapsed_time
    { num: 8, baseType: BASE_TYPE.uint32 }, // total_timer_time
    { num: 5, baseType: BASE_TYPE.enum }, // sport
    { num: 6, baseType: BASE_TYPE.enum }, // sub_sport
    { num: 20, baseType: BASE_TYPE.uint16 }, // avg_power
    { num: 21, baseType: BASE_TYPE.uint16 }, // max_power
    { num: 25, baseType: BASE_TYPE.uint16 }, // first_lap_index
    { num: 26, baseType: BASE_TYPE.uint16 }, // num_laps
  ]);

  const activity = new FitMessageType(5, GLOBAL_MESSAGE.activity, [
    { num: 253, baseType: BASE_TYPE.uint32 }, // timestamp
    { num: 0, baseType: BASE_TYPE.uint32 }, // total_timer_time
    { num: 1, baseType: BASE_TYPE.uint16 }, // num_sessions
    { num: 2, baseType: BASE_TYPE.enum }, // type
    { num: 3, baseType: BASE_TYPE.enum }, // event
    { num: 4, baseType: BASE_TYPE.enum }, // event_type
  ]);

  const data = new ByteWriter();

  fileId.writeDefinition(data);
  fileId.writeData(data, [FILE_TYPE_ACTIVITY, MANUFACTURER_DEVELOPMENT, 0, startTimestamp]);

  event.writeDefinition(data);
  event.writeData(data, [startTimestamp, EVENT_TIMER, EVENT_TYPE_START]);

  record.writeDefinition(data);
  for (const s of samples) {
    record.writeData(data, [startTimestamp + Math.round(s.tSec), s.heartRateBpm, s.cadenceRpm, s.powerWatts]);
  }

  event.writeData(data, [endTimestamp, EVENT_TIMER, EVENT_TYPE_STOP_ALL]);

  lap.writeDefinition(data);
  lap.writeData(data, [endTimestamp, startTimestamp, Math.round(durationSec * 1000), Math.round(durationSec * 1000), avgPower, maxPower]);

  session.writeDefinition(data);
  session.writeData(data, [
    endTimestamp,
    startTimestamp,
    Math.round(durationSec * 1000),
    Math.round(durationSec * 1000),
    SPORT_CYCLING,
    SUB_SPORT_INDOOR_CYCLING,
    avgPower,
    maxPower,
    0,
    1,
  ]);

  activity.writeDefinition(data);
  activity.writeData(data, [
    endTimestamp,
    Math.round(durationSec * 1000),
    1,
    ACTIVITY_TYPE_MANUAL,
    ACTIVITY_EVENT,
    ACTIVITY_EVENT_TYPE_STOP,
  ]);

  const dataBytes = data.toBytes();
  const header = buildFitHeader(dataBytes.length);

  const withoutCrc = new Uint8Array(header.length + dataBytes.length);
  withoutCrc.set(header, 0);
  withoutCrc.set(dataBytes, header.length);

  const crc = fitCrc16(withoutCrc);
  const out = new Uint8Array(withoutCrc.length + 2);
  out.set(withoutCrc, 0);
  new DataView(out.buffer).setUint16(withoutCrc.length, crc, true);

  return out;
}

export function downloadFitActivity(recording: RideRecording, filename: string): void {
  const bytes = buildFitActivity(recording);
  const blob = new Blob([bytes.buffer as ArrayBuffer], { type: "application/octet-stream" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}
