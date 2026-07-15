# ErgSync

A browser-based ERG-mode trainer app for the Saris H3 (or any FTMS-compatible
smart trainer), built so you don't need a Zwift subscription just to execute
structured workouts.

Runs entirely client-side via the [Web Bluetooth API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Bluetooth_API) —
**Chrome or Edge on desktop or Android only**. Web Bluetooth is blocked in
Safari/WebKit, so this cannot run on iPhone/iPad.

## What it does

- Connects directly to your trainer over Bluetooth and drives ERG mode using
  the Bluetooth SIG Fitness Machine Service (FTMS) protocol.
- Imports structured workouts from `.zwo` (Zwift) or `.fit` (Garmin device
  workout export) files — including ramps and repeated interval blocks.
- Executes the workout, pushing target watts to the trainer as the workout
  progresses, and shows live power/cadence/heart-rate/target.
- Records the ride and exports it as a real `.fit` activity file you can
  drop onto your TrainingPeaks calendar (or upload to Strava/Garmin Connect,
  if you already have those auto-forwarding into TrainingPeaks).

## Why file-based sync instead of a "TrainingPeaks integration"

TrainingPeaks doesn't offer a self-serve public API — pulling workouts or
pushing activities via their API requires becoming an approved Partner,
which isn't realistic for a personal project. Instead:

- **Getting a workout in:** open the planned workout in TrainingPeaks and use
  "Send to Device" to export a `.fit` file (this is the same file Garmin/Wahoo
  head units use), or use a `.zwo` file directly. Import it here.
- **Getting the ride back out:** after finishing, download the `.fit` activity
  file this app generates and drop it onto the TrainingPeaks calendar to log
  it.

No API keys, no partner approval, and it still means you never have to
manually re-type a workout or its results.

## Development

```sh
npm install
npm run dev      # local dev server
npm run build    # type-check + production build
npm run test     # FIT binary reader/writer regression checks
npm run lint     # oxlint
```

## Project layout

- `src/ble/` — Web Bluetooth + FTMS protocol client (connect, control point,
  live Indoor Bike Data parsing).
- `src/workout/` — workout model, `.zwo` parser, FIT binary reader/writer
  (shared low-level primitives in `fitBinary.ts` / `fitReader.ts` /
  `fitWriter.ts`).
- `src/erg/ergEngine.ts` — drives ERG execution: computes target watts over
  time (handling ramps and %FTP conversion) and records samples.
- `src/ride/` — ride recording types.
- `src/state/` — `localStorage`-backed settings (FTP) and workout library.
- `src/components/` — UI screens (dashboard, live ride, summary).

## Known limitations / things to double-check on real hardware

- The FIT workout reader assumes the common Garmin/TrainingPeaks convention
  for encoding "% of FTP" power targets (`value = pct*100 + 1000`) and for
  encoding repeated interval blocks (a trailing "repeat" step that replays an
  earlier step range). This matches the public FIT SDK conventions used by
  most encoders, but hasn't been tested against a real TrainingPeaks-exported
  `.fit` file — if a specific export doesn't import correctly, that's the
  first place to look.
- Zone-based or heart-rate-based power targets in a `.fit` workout (rather
  than an explicit %FTP target) aren't resolved to a wattage and will import
  as an open/free-ride step instead of guessing.
- This was built and verified in a sandboxed environment without a physical
  Saris H3 or a Bluetooth adapter — the FTMS control point protocol and
  Indoor Bike Data parsing follow the Bluetooth SIG spec closely, and the app
  logic was exercised against a simulated trainer, but real-hardware
  behavior (quirks in the Saris H3's FTMS implementation, timing, etc.)
  hasn't been confirmed firsthand.
