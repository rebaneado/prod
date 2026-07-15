import { buildFitActivity } from "./src/workout/fitActivityWriter";
import { fitCrc16 } from "./src/workout/fitBinary";
import { readFitMessages } from "./src/workout/fitReader";
import { parseFitWorkout } from "./src/workout/fitWorkoutReader";
import { BASE_TYPE, GLOBAL_MESSAGE } from "./src/workout/fitBinary";
import { ByteWriter, FitMessageType } from "./src/workout/fitWriter";
import type { RideRecording } from "./src/ride/types";

function assert(cond: unknown, msg: string): void {
  if (!cond) {
    console.error(`FAIL: ${msg}`);
    process.exitCode = 1;
  } else {
    console.log(`PASS: ${msg}`);
  }
}

// --- Test 1: FIT activity writer produces a well-formed file with correct CRC ---
{
  const recording: RideRecording = {
    startedAt: new Date("2026-07-15T14:00:00Z"),
    workoutName: "Test Ride",
    samples: [
      { tSec: 0, powerWatts: 100, cadenceRpm: 80, heartRateBpm: 120 },
      { tSec: 1, powerWatts: 150, cadenceRpm: 85, heartRateBpm: 125 },
      { tSec: 2, powerWatts: 200, cadenceRpm: 90 }, // no heart rate this sample
    ],
  };

  const bytes = buildFitActivity(recording);

  assert(bytes.length > 14 + 2, "activity FIT file has plausible length");
  assert(bytes[0] === 14, "header size byte is 14");
  const magic = String.fromCharCode(bytes[8], bytes[9], bytes[10], bytes[11]);
  assert(magic === ".FIT", `magic bytes are .FIT (got ${magic})`);

  const view = new DataView(bytes.buffer);
  const dataSize = view.getUint32(4, true);
  const withoutCrc = bytes.slice(0, 14 + dataSize);
  const expectedCrc = fitCrc16(withoutCrc);
  const actualCrc = view.getUint16(14 + dataSize, true);
  assert(actualCrc === expectedCrc, `trailing CRC matches recomputed CRC (${actualCrc} === ${expectedCrc})`);

  // Round-trip through our own reader to sanity check record messages decode.
  const messages = readFitMessages(bytes.buffer);
  const records = messages.filter((m) => m.globalMessageNumber === GLOBAL_MESSAGE.record);
  assert(records.length === 3, `wrote and read back 3 record messages (got ${records.length})`);
  assert(records[0].fields[7] === 100, `first record power is 100 (got ${records[0].fields[7]})`);
  assert(records[2].fields[3] === undefined, "invalid (missing) heart rate field is omitted, not zero");

  const sessions = messages.filter((m) => m.globalMessageNumber === GLOBAL_MESSAGE.session);
  assert(sessions.length === 1, "exactly one session message");
}

// --- Test 2: FIT workout reader handles steady-state, ramp, and repeated intervals ---
{
  const w = new ByteWriter();

  const nameBytes = Array.from(new TextEncoder().encode("Interval Test\0"));
  // workout_step fields: message_index, name(skip), duration_type, duration_value, target_type, target_value, custom_low, custom_high
  const stepMsg = new FitMessageType(1, GLOBAL_MESSAGE.workoutStep, [
    { num: 254, baseType: BASE_TYPE.uint16 }, // message_index
    { num: 1, baseType: BASE_TYPE.enum }, // duration_type
    { num: 2, baseType: BASE_TYPE.uint32 }, // duration_value
    { num: 3, baseType: BASE_TYPE.enum }, // target_type
    { num: 4, baseType: BASE_TYPE.uint32 }, // target_value
    { num: 5, baseType: BASE_TYPE.uint32 }, // custom_low
    { num: 6, baseType: BASE_TYPE.uint32 }, // custom_high
  ]);

  // FitMessageType/writeField only handles numeric base types, so the workout
  // name (a variable-length string) is hand-encoded directly here.
  w.writeUInt8(0x40 | 0); // definition msg for local type 0 with a wider string field
  w.writeUInt8(0);
  w.writeUInt8(0);
  w.writeUInt16(GLOBAL_MESSAGE.workout);
  w.writeUInt8(1);
  w.writeUInt8(8);
  w.writeUInt8(nameBytes.length);
  w.writeUInt8(BASE_TYPE.string);
  w.writeUInt8(0x00); // data msg local type 0
  for (const b of nameBytes) w.writeUInt8(b);

  stepMsg.writeDefinition(w);
  const DURATION_TIME = 0;
  const DURATION_REPEAT = 6;
  const TARGET_POWER = 4;
  // Step 0: warmup ramp 50%->75% FTP, 60s
  stepMsg.writeData(w, [0, DURATION_TIME, 60_000, TARGET_POWER, 0, 1050, 1075]);
  // Step 1: "on" interval, 30s @ 120% FTP
  stepMsg.writeData(w, [1, DURATION_TIME, 30_000, TARGET_POWER, 0, 1120, 1120]);
  // Step 2: "off" interval, 15s @ 50% FTP
  stepMsg.writeData(w, [2, DURATION_TIME, 15_000, TARGET_POWER, 0, 1050, 1050]);
  // Step 3: repeat steps 1-2, 3 times
  stepMsg.writeData(w, [3, DURATION_REPEAT, 3, 0, 1, undefined, undefined]);
  // Step 4: cooldown steady 60% FTP, 120s
  stepMsg.writeData(w, [4, DURATION_TIME, 120_000, TARGET_POWER, 0, 1060, 1060]);

  const dataBytes = w.toBytes();
  const header = new ByteWriter();
  header.writeUInt8(14);
  header.writeUInt8(0x10);
  header.writeUInt16(2140);
  header.writeUInt32(dataBytes.length);
  for (const ch of ".FIT") header.writeUInt8(ch.charCodeAt(0));
  header.writeUInt16(0);
  const headerBytes = header.toBytes();

  const withoutCrc = new Uint8Array(headerBytes.length + dataBytes.length);
  withoutCrc.set(headerBytes, 0);
  withoutCrc.set(dataBytes, headerBytes.length);
  const crc = fitCrc16(withoutCrc);
  const full = new Uint8Array(withoutCrc.length + 2);
  full.set(withoutCrc, 0);
  new DataView(full.buffer).setUint16(withoutCrc.length, crc, true);

  const workout = parseFitWorkout(full.buffer);

  assert(workout.name === "Interval Test", `workout name decoded correctly (got "${workout.name}")`);
  // Expect: warmup, then (on, off) x3, then cooldown = 8 steps total
  assert(workout.steps.length === 8, `repeat block expanded to 8 total steps (got ${workout.steps.length})`);
  assert(Math.abs(workout.steps[0].powerLow - 0.5) < 1e-6, `warmup powerLow is 0.5 (got ${workout.steps[0].powerLow}`);
  assert(Math.abs(workout.steps[0].powerHigh - 0.75) < 1e-6, `warmup powerHigh is 0.75 (got ${workout.steps[0].powerHigh})`);
  assert(workout.steps[0].durationSec === 60, "warmup duration is 60s");

  for (let i = 0; i < 3; i++) {
    const on = workout.steps[1 + i * 2];
    const off = workout.steps[2 + i * 2];
    assert(Math.abs(on.powerLow - 1.2) < 1e-6, `interval ${i} on-power is 1.2 (got ${on.powerLow})`);
    assert(on.durationSec === 30, `interval ${i} on-duration is 30s`);
    assert(Math.abs(off.powerLow - 0.5) < 1e-6, `interval ${i} off-power is 0.5 (got ${off.powerLow})`);
    assert(off.durationSec === 15, `interval ${i} off-duration is 15s`);
  }

  const cooldown = workout.steps[7];
  assert(Math.abs(cooldown.powerLow - 0.6) < 1e-6, `cooldown power is 0.6 (got ${cooldown.powerLow})`);
  assert(cooldown.durationSec === 120, "cooldown duration is 120s");
}

if (process.exitCode === 1) {
  console.error("\nSome checks FAILED");
} else {
  console.log("\nAll checks passed");
}
