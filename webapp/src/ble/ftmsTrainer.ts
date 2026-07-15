import { CHAR, FTMS_SERVICE, OP_CODE, RESULT_CODE, resultCodeName } from "./ftmsConstants";
import { parseIndoorBikeData, type IndoorBikeSample } from "./indoorBikeData";

export type TrainerConnectionState = "disconnected" | "connecting" | "connected";

export type TrainerListener = (sample: IndoorBikeSample) => void;
export type ConnectionListener = (state: TrainerConnectionState) => void;

/** Thrown when the trainer responds to a control point request with a non-success result code. */
export class FtmsControlError extends Error {
  opCode: number;
  resultCode: number;

  constructor(opCode: number, resultCode: number) {
    super(`FTMS control point request 0x${opCode.toString(16)} failed: ${resultCodeName(resultCode)}`);
    this.opCode = opCode;
    this.resultCode = resultCode;
  }
}

export function isWebBluetoothSupported(): boolean {
  return typeof navigator !== "undefined" && !!navigator.bluetooth;
}

/**
 * Manages a Web Bluetooth connection to an FTMS-compatible smart trainer
 * (e.g. Saris H3) and exposes ERG-mode control (target power) plus live
 * power/cadence/speed/heart-rate data.
 */
export class FtmsTrainer {
  private device: BluetoothDevice | null = null;
  private controlPoint: BluetoothRemoteGATTCharacteristic | null = null;
  private dataListeners = new Set<TrainerListener>();
  private connectionListeners = new Set<ConnectionListener>();
  private pendingControlResponse: ((value: DataView) => void) | null = null;
  private _state: TrainerConnectionState = "disconnected";
  private _hasControl = false;

  get state(): TrainerConnectionState {
    return this._state;
  }

  get deviceName(): string | undefined {
    return this.device?.name ?? undefined;
  }

  onData(listener: TrainerListener): () => void {
    this.dataListeners.add(listener);
    return () => this.dataListeners.delete(listener);
  }

  onConnectionChange(listener: ConnectionListener): () => void {
    this.connectionListeners.add(listener);
    return () => this.connectionListeners.delete(listener);
  }

  private setState(state: TrainerConnectionState) {
    this._state = state;
    for (const l of this.connectionListeners) l(state);
  }

  /** Opens the browser's device picker filtered to FTMS trainers and connects. */
  async connect(): Promise<void> {
    if (!isWebBluetoothSupported()) {
      throw new Error(
        "Web Bluetooth isn't available in this browser. Use Chrome or Edge on desktop/Android."
      );
    }

    this.setState("connecting");
    try {
      this.device = await navigator.bluetooth.requestDevice({
        filters: [{ services: [FTMS_SERVICE] }],
        optionalServices: [CHAR.fitnessMachineFeature, CHAR.fitnessMachineStatus],
      });

      this.device.addEventListener("gattserverdisconnected", this.handleDisconnected);

      const server = await this.device.gatt!.connect();
      const service = await server.getPrimaryService(FTMS_SERVICE);

      const indoorBikeData = await service.getCharacteristic(CHAR.indoorBikeData);
      await indoorBikeData.startNotifications();
      indoorBikeData.addEventListener("characteristicvaluechanged", this.handleIndoorBikeData);

      this.controlPoint = await service.getCharacteristic(CHAR.fitnessMachineControlPoint);
      await this.controlPoint.startNotifications();
      this.controlPoint.addEventListener("characteristicvaluechanged", this.handleControlPointResponse);

      this.setState("connected");
    } catch (err) {
      this.setState("disconnected");
      throw err;
    }
  }

  disconnect(): void {
    this.device?.gatt?.disconnect();
  }

  private handleDisconnected = () => {
    this._hasControl = false;
    this.controlPoint = null;
    this.setState("disconnected");
  };

  private handleIndoorBikeData = (event: Event) => {
    const characteristic = event.target as BluetoothRemoteGATTCharacteristic;
    const value = characteristic.value;
    if (!value) return;
    const sample = parseIndoorBikeData(value);
    for (const l of this.dataListeners) l(sample);
  };

  private handleControlPointResponse = (event: Event) => {
    const characteristic = event.target as BluetoothRemoteGATTCharacteristic;
    const value = characteristic.value;
    if (!value || !this.pendingControlResponse) return;
    this.pendingControlResponse(value);
    this.pendingControlResponse = null;
  };

  /** Writes a control point op code and awaits its indication response, per FTMS spec. */
  private async sendControlCommand(opCode: number, payload: number[] = []): Promise<void> {
    if (!this.controlPoint) throw new Error("Trainer not connected");

    const bytes = Uint8Array.from([opCode, ...payload]);

    const responsePromise = new Promise<DataView>((resolve, reject) => {
      const timeout = setTimeout(() => {
        this.pendingControlResponse = null;
        reject(new Error(`FTMS control point 0x${opCode.toString(16)} timed out waiting for response`));
      }, 5000);
      this.pendingControlResponse = (value) => {
        clearTimeout(timeout);
        resolve(value);
      };
    });

    await this.controlPoint.writeValueWithResponse(bytes);
    const response = await responsePromise;

    const responseOpCode = response.getUint8(0);
    const requestOpCode = response.getUint8(1);
    const resultCode = response.getUint8(2);
    if (responseOpCode !== OP_CODE.responseCode || requestOpCode !== opCode) {
      throw new Error("Unexpected FTMS control point response");
    }
    if (resultCode !== RESULT_CODE.success) {
      throw new FtmsControlError(opCode, resultCode);
    }
  }

  /** Must be called once before the trainer will accept ERG target-power commands. */
  async requestControl(): Promise<void> {
    await this.sendControlCommand(OP_CODE.requestControl);
    this._hasControl = true;
  }

  async startResistance(): Promise<void> {
    await this.ensureControl();
    await this.sendControlCommand(OP_CODE.startOrResume);
  }

  async stopResistance(): Promise<void> {
    await this.ensureControl();
    await this.sendControlCommand(OP_CODE.stopOrPause, [0x01]);
  }

  /** Sets the ERG-mode target power. Trainer firmware handles the resistance servo loop. */
  async setTargetPower(watts: number): Promise<void> {
    await this.ensureControl();
    const clamped = Math.round(Math.max(0, watts));
    const payload = new Uint8Array(2);
    new DataView(payload.buffer).setInt16(0, clamped, true);
    await this.sendControlCommand(OP_CODE.setTargetPower, Array.from(payload));
  }

  private async ensureControl(): Promise<void> {
    if (!this._hasControl) {
      await this.requestControl();
    }
  }
}
