// Parses the FTMS "Indoor Bike Data" (0x2AD2) notification payload.
// Field presence is flag-driven, and every present field must be walked in
// spec order even when we don't care about its value, since later field
// offsets depend on it.

export interface IndoorBikeSample {
  speedKmh?: number;
  cadenceRpm?: number;
  powerWatts?: number;
  heartRateBpm?: number;
  elapsedTimeSec?: number;
}

const FLAG = {
  moreData: 1 << 0, // inverted: 0 means Instantaneous Speed IS present
  avgSpeed: 1 << 1,
  instCadence: 1 << 2,
  avgCadence: 1 << 3,
  totalDistance: 1 << 4,
  resistanceLevel: 1 << 5,
  instPower: 1 << 6,
  avgPower: 1 << 7,
  expendedEnergy: 1 << 8,
  heartRate: 1 << 9,
  metabolicEquivalent: 1 << 10,
  elapsedTime: 1 << 11,
  remainingTime: 1 << 12,
};

export function parseIndoorBikeData(data: DataView): IndoorBikeSample {
  let offset = 0;
  const flags = data.getUint16(offset, true);
  offset += 2;

  const sample: IndoorBikeSample = {};

  if ((flags & FLAG.moreData) === 0) {
    sample.speedKmh = data.getUint16(offset, true) * 0.01;
    offset += 2;
  }
  if (flags & FLAG.avgSpeed) {
    offset += 2;
  }
  if (flags & FLAG.instCadence) {
    sample.cadenceRpm = data.getUint16(offset, true) * 0.5;
    offset += 2;
  }
  if (flags & FLAG.avgCadence) {
    offset += 2;
  }
  if (flags & FLAG.totalDistance) {
    offset += 3; // uint24
  }
  if (flags & FLAG.resistanceLevel) {
    offset += 2;
  }
  if (flags & FLAG.instPower) {
    sample.powerWatts = data.getInt16(offset, true);
    offset += 2;
  }
  if (flags & FLAG.avgPower) {
    offset += 2;
  }
  if (flags & FLAG.expendedEnergy) {
    offset += 5; // total energy (2) + energy/hr (2) + energy/min (1)
  }
  if (flags & FLAG.heartRate) {
    sample.heartRateBpm = data.getUint8(offset);
    offset += 1;
  }
  if (flags & FLAG.metabolicEquivalent) {
    offset += 1;
  }
  if (flags & FLAG.elapsedTime) {
    sample.elapsedTimeSec = data.getUint16(offset, true);
    offset += 2;
  }
  if (flags & FLAG.remainingTime) {
    offset += 2;
  }

  return sample;
}
