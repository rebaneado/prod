// Bluetooth SIG Fitness Machine Service (FTMS) constants.
// https://www.bluetooth.com/specifications/specs/fitness-machine-service-1-0/

export const FTMS_SERVICE = 0x1826;

export const CHAR = {
  fitnessMachineFeature: 0x2acc,
  indoorBikeData: 0x2ad2,
  trainingStatus: 0x2ad3,
  supportedPowerRange: 0x2ad8,
  fitnessMachineControlPoint: 0x2ad9,
  fitnessMachineStatus: 0x2ada,
};

// Fitness Machine Control Point op codes (client -> server request)
export const OP_CODE = {
  requestControl: 0x00,
  reset: 0x01,
  setTargetSpeed: 0x02,
  setTargetInclination: 0x03,
  setTargetResistanceLevel: 0x04,
  setTargetPower: 0x05,
  setTargetHeartRate: 0x06,
  startOrResume: 0x07,
  stopOrPause: 0x08,
  setIndoorBikeSimulation: 0x11,
  responseCode: 0x80,
};

// Result codes returned inside a 0x80 response message
export const RESULT_CODE = {
  success: 0x01,
  opCodeNotSupported: 0x02,
  invalidParameter: 0x03,
  operationFailed: 0x04,
  controlNotPermitted: 0x05,
};

export function resultCodeName(code: number): string {
  switch (code) {
    case RESULT_CODE.success:
      return "success";
    case RESULT_CODE.opCodeNotSupported:
      return "opCodeNotSupported";
    case RESULT_CODE.invalidParameter:
      return "invalidParameter";
    case RESULT_CODE.operationFailed:
      return "operationFailed";
    case RESULT_CODE.controlNotPermitted:
      return "controlNotPermitted";
    default:
      return `unknown(0x${code.toString(16)})`;
  }
}
