import { BASE_TYPE, BASE_TYPE_INFO } from "./fitBinary";

export interface FitMessage {
  globalMessageNumber: number;
  /** Keyed by FIT field definition number (not a friendly name — callers map these per message type). */
  fields: Record<number, number | string>;
}

interface FieldDef {
  fieldDefNum: number;
  size: number;
  baseType: number;
}

interface MessageDef {
  globalMessageNumber: number;
  littleEndian: boolean;
  fields: FieldDef[];
  /** Total byte length of developer fields for this definition, skipped (not decoded) in data messages. */
  devFieldsByteLength: number;
}

function decodeField(view: DataView, offset: number, size: number, baseType: number, littleEndian: boolean): number | string {
  switch (baseType) {
    case BASE_TYPE.enum:
    case BASE_TYPE.uint8:
    case BASE_TYPE.uint8z:
      return view.getUint8(offset);
    case BASE_TYPE.sint8:
      return view.getInt8(offset);
    case BASE_TYPE.uint16:
    case BASE_TYPE.uint16z:
      return view.getUint16(offset, littleEndian);
    case BASE_TYPE.sint16:
      return view.getInt16(offset, littleEndian);
    case BASE_TYPE.uint32:
    case BASE_TYPE.uint32z:
      return view.getUint32(offset, littleEndian);
    case BASE_TYPE.sint32:
      return view.getInt32(offset, littleEndian);
    case BASE_TYPE.float32:
      return view.getFloat32(offset, littleEndian);
    case BASE_TYPE.float64:
      return view.getFloat64(offset, littleEndian);
    case BASE_TYPE.string: {
      const bytes = new Uint8Array(view.buffer, view.byteOffset + offset, size);
      const nul = bytes.indexOf(0);
      const slice = nul >= 0 ? bytes.subarray(0, nul) : bytes;
      return new TextDecoder().decode(slice);
    }
    default:
      // Unknown/byte-array base type: return the raw first byte, callers that
      // care about this field type should not rely on this fallback.
      return view.getUint8(offset);
  }
}

/**
 * Parses a raw FIT file into its sequence of data messages. Definition
 * messages are consumed internally to know how to decode subsequent data
 * messages and are not returned.
 */
export function readFitMessages(buffer: ArrayBuffer): FitMessage[] {
  const view = new DataView(buffer);
  const headerSize = view.getUint8(0);
  if (headerSize < 12) {
    throw new Error("Invalid .fit file: bad header size");
  }
  const dataSize = view.getUint32(4, true);
  const dataStart = headerSize;
  const dataEnd = dataStart + dataSize;

  const definitions = new Map<number, MessageDef>();
  const messages: FitMessage[] = [];

  let offset = dataStart;
  while (offset < dataEnd) {
    const recordHeader = view.getUint8(offset);
    offset += 1;

    const isCompressedTimestamp = (recordHeader & 0x80) !== 0;
    if (isCompressedTimestamp) {
      const localMessageType = (recordHeader >> 5) & 0x3;
      const def = definitions.get(localMessageType);
      if (!def) throw new Error("Malformed .fit file: data message before its definition");
      offset = readDataMessage(view, offset, def, messages);
      continue;
    }

    const isDefinition = (recordHeader & 0x40) !== 0;
    const localMessageType = recordHeader & 0xf;

    if (isDefinition) {
      const hasDevFields = (recordHeader & 0x20) !== 0;
      offset += 1; // reserved
      const architecture = view.getUint8(offset);
      offset += 1;
      const littleEndian = architecture === 0;
      const globalMessageNumber = view.getUint16(offset, littleEndian);
      offset += 2;
      const numFields = view.getUint8(offset);
      offset += 1;

      const fields: FieldDef[] = [];
      for (let i = 0; i < numFields; i++) {
        fields.push({
          fieldDefNum: view.getUint8(offset),
          size: view.getUint8(offset + 1),
          baseType: view.getUint8(offset + 2),
        });
        offset += 3;
      }

      let devFieldsByteLength = 0;
      if (hasDevFields) {
        const numDevFields = view.getUint8(offset);
        offset += 1;
        for (let i = 0; i < numDevFields; i++) {
          devFieldsByteLength += view.getUint8(offset + 1); // size byte of each dev field def
          offset += 3;
        }
      }

      definitions.set(localMessageType, { globalMessageNumber, littleEndian, fields, devFieldsByteLength });
      continue;
    }

    const def = definitions.get(localMessageType);
    if (!def) throw new Error("Malformed .fit file: data message before its definition");
    offset = readDataMessage(view, offset, def, messages);
  }

  return messages;
}

function readDataMessage(view: DataView, offset: number, def: MessageDef, out: FitMessage[]): number {
  const fields: Record<number, number | string> = {};
  for (const field of def.fields) {
    const info = BASE_TYPE_INFO[field.baseType];
    const value = decodeField(view, offset, field.size, field.baseType, def.littleEndian);
    if (!info || value !== info.invalid) {
      fields[field.fieldDefNum] = value;
    }
    offset += field.size;
  }
  offset += def.devFieldsByteLength;
  out.push({ globalMessageNumber: def.globalMessageNumber, fields });
  return offset;
}
