import { BASE_TYPE, BASE_TYPE_INFO } from "./fitBinary";

export interface FieldSpec {
  num: number;
  baseType: number;
}

/** Accumulates raw bytes for a FIT message stream (definitions + data), one growable buffer. */
export class ByteWriter {
  private chunks: number[] = [];
  private scratch = new DataView(new ArrayBuffer(4));

  get length(): number {
    return this.chunks.length;
  }

  writeUInt8(v: number): void {
    this.chunks.push(v & 0xff);
  }

  writeInt8(v: number): void {
    this.scratch.setInt8(0, v);
    this.chunks.push(this.scratch.getUint8(0));
  }

  writeUInt16(v: number): void {
    this.scratch.setUint16(0, v, true);
    this.chunks.push(this.scratch.getUint8(0), this.scratch.getUint8(1));
  }

  writeInt16(v: number): void {
    this.scratch.setInt16(0, v, true);
    this.chunks.push(this.scratch.getUint8(0), this.scratch.getUint8(1));
  }

  writeUInt32(v: number): void {
    this.scratch.setUint32(0, v, true);
    for (let i = 0; i < 4; i++) this.chunks.push(this.scratch.getUint8(i));
  }

  writeInt32(v: number): void {
    this.scratch.setInt32(0, v, true);
    for (let i = 0; i < 4; i++) this.chunks.push(this.scratch.getUint8(i));
  }

  writeField(baseType: number, value: number): void {
    switch (baseType) {
      case BASE_TYPE.enum:
      case BASE_TYPE.uint8:
      case BASE_TYPE.uint8z:
        this.writeUInt8(value);
        break;
      case BASE_TYPE.sint8:
        this.writeInt8(value);
        break;
      case BASE_TYPE.uint16:
      case BASE_TYPE.uint16z:
        this.writeUInt16(value);
        break;
      case BASE_TYPE.sint16:
        this.writeInt16(value);
        break;
      case BASE_TYPE.uint32:
      case BASE_TYPE.uint32z:
        this.writeUInt32(value);
        break;
      case BASE_TYPE.sint32:
        this.writeInt32(value);
        break;
      default:
        throw new Error(`Unsupported FIT base type for writing: 0x${baseType.toString(16)}`);
    }
  }

  toBytes(): Uint8Array {
    return Uint8Array.from(this.chunks);
  }
}

/**
 * A reusable FIT message definition. Emits its definition record once (via
 * writeDefinition), then any number of data records with matching field
 * order/count via writeData.
 */
export class FitMessageType {
  readonly localType: number;
  readonly globalMessageNumber: number;
  readonly fields: FieldSpec[];

  constructor(localType: number, globalMessageNumber: number, fields: FieldSpec[]) {
    this.localType = localType;
    this.globalMessageNumber = globalMessageNumber;
    this.fields = fields;
  }

  writeDefinition(writer: ByteWriter): void {
    writer.writeUInt8(0x40 | this.localType); // definition message, no dev fields
    writer.writeUInt8(0); // reserved
    writer.writeUInt8(0); // architecture: 0 = little endian
    writer.writeUInt16(this.globalMessageNumber);
    writer.writeUInt8(this.fields.length);
    for (const f of this.fields) {
      const info = BASE_TYPE_INFO[f.baseType];
      writer.writeUInt8(f.num);
      writer.writeUInt8(info.size);
      writer.writeUInt8(f.baseType);
    }
  }

  /** values must align 1:1 with `fields`, in order. Use `undefined` for an invalid/absent value. */
  writeData(writer: ByteWriter, values: Array<number | undefined>): void {
    writer.writeUInt8(this.localType); // data message
    for (let i = 0; i < this.fields.length; i++) {
      const field = this.fields[i];
      const info = BASE_TYPE_INFO[field.baseType];
      const value = values[i];
      writer.writeField(field.baseType, value === undefined ? info.invalid : value);
    }
  }
}
