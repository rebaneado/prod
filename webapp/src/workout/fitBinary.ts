// Low-level primitives shared by the FIT file reader and writer.
// FIT (Flexible and Interoperable Data Transfer) is Garmin's binary format
// used by TrainingPeaks for "send workout to device" exports and for
// activity/ride uploads. Reference: Garmin FIT SDK "Profile" (message and
// field numbers) and "Binary Encoding" documents.

/** Seconds between the Unix epoch (1970-01-01) and the FIT epoch (1989-12-31T00:00:00Z). */
export const FIT_EPOCH_OFFSET_SEC = 631065600;

export function toFitTimestamp(date: Date): number {
  return Math.floor(date.getTime() / 1000) - FIT_EPOCH_OFFSET_SEC;
}

export function fromFitTimestamp(fitTime: number): Date {
  return new Date((fitTime + FIT_EPOCH_OFFSET_SEC) * 1000);
}

export const BASE_TYPE = {
  enum: 0x00,
  sint8: 0x01,
  uint8: 0x02,
  sint16: 0x83,
  uint16: 0x84,
  sint32: 0x85,
  uint32: 0x86,
  string: 0x07,
  float32: 0x88,
  float64: 0x89,
  uint8z: 0x0a,
  uint16z: 0x8b,
  uint32z: 0x8c,
  byte: 0x0d,
} as const;

export interface BaseTypeInfo {
  size: number;
  invalid: number;
}

export const BASE_TYPE_INFO: Record<number, BaseTypeInfo> = {
  [BASE_TYPE.enum]: { size: 1, invalid: 0xff },
  [BASE_TYPE.sint8]: { size: 1, invalid: 0x7f },
  [BASE_TYPE.uint8]: { size: 1, invalid: 0xff },
  [BASE_TYPE.sint16]: { size: 2, invalid: 0x7fff },
  [BASE_TYPE.uint16]: { size: 2, invalid: 0xffff },
  [BASE_TYPE.sint32]: { size: 4, invalid: 0x7fffffff },
  [BASE_TYPE.uint32]: { size: 4, invalid: 0xffffffff },
  [BASE_TYPE.string]: { size: 1, invalid: 0x00 },
  [BASE_TYPE.float32]: { size: 4, invalid: 0xffffffff },
  [BASE_TYPE.float64]: { size: 8, invalid: 0xffffffffffffffff },
  [BASE_TYPE.uint8z]: { size: 1, invalid: 0x00 },
  [BASE_TYPE.uint16z]: { size: 2, invalid: 0x0000 },
  [BASE_TYPE.uint32z]: { size: 4, invalid: 0x00000000 },
  [BASE_TYPE.byte]: { size: 1, invalid: 0xff },
};

// Global message numbers (subset relevant to workouts + activity export).
export const GLOBAL_MESSAGE = {
  fileId: 0,
  lap: 19,
  record: 20,
  event: 21,
  workout: 26,
  workoutStep: 27,
  session: 18,
  activity: 34,
};

/**
 * FIT CRC-16, per Garmin's published nibble-table algorithm
 * (same table used across the FIT SDK and all interoperable implementations).
 */
const CRC_TABLE = [
  0x0000, 0xcc01, 0xd801, 0x1400, 0xf001, 0x3c00, 0x2800, 0xe401, 0xa001, 0x6c00, 0x7800, 0xb401, 0x5000, 0x9c01,
  0x8801, 0x4400,
];

export function fitCrc16(bytes: Uint8Array, initial = 0): number {
  let crc = initial;
  for (const byte of bytes) {
    let tmp = CRC_TABLE[crc & 0xf];
    crc = (crc >> 4) & 0x0fff;
    crc = crc ^ tmp ^ CRC_TABLE[byte & 0xf];

    tmp = CRC_TABLE[crc & 0xf];
    crc = (crc >> 4) & 0x0fff;
    crc = crc ^ tmp ^ CRC_TABLE[(byte >> 4) & 0xf];
  }
  return crc & 0xffff;
}
