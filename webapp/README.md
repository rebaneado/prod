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
- Records the ride and exports it as a real `.fit` activity file. Can upload
  it straight to Strava with one click (see below), or you can just download
  it and drop it onto your TrainingPeaks calendar.

## Why file-based sync instead of a "TrainingPeaks integration"

TrainingPeaks doesn't offer a self-serve public API — pulling workouts or
pushing activities via their API requires becoming an approved Partner,
which isn't realistic for a personal project. Instead:

- **Getting a workout in:** open the planned workout in TrainingPeaks and use
  "Send to Device" to export a `.fit` file (this is the same file Garmin/Wahoo
  head units use), or use a `.zwo` file directly. Import it here.
- **Getting the ride back out:** after finishing, upload straight to Strava
  (see below), or download the `.fit` activity file this app generates and
  drop it onto the TrainingPeaks calendar to log it manually.

No API keys, no partner approval, and it still means you never have to
manually re-type a workout or its results.

## Automatic upload to Strava

Unlike TrainingPeaks, **Strava's API is genuinely self-serve** — anyone can
register a personal app instantly, no approval process. If you already have
Strava → TrainingPeaks (or Garmin Connect → Strava → TrainingPeaks) auto-sync
turned on, connecting Strava here makes the whole loop automatic.

Setup:

1. Go to <https://www.strava.com/settings/api> and create an app. Set
   **Authorization Callback Domain** to `localhost`.
2. Copy `.env.example` to `.env` and fill in the Client ID and Client Secret
   from that page.
3. Restart `npm run dev` (Vite only reads `.env` at startup).
4. On the dashboard, click **Connect Strava** and approve access.
5. After a ride, the summary screen gets an **Upload to Strava** button.

**Security note:** this app has no backend — it's a static site you run
locally. That means your Strava Client Secret ends up embedded in the
JavaScript bundle the browser loads. That's fine for running it yourself
locally, but never deploy a build of this app publicly (e.g. to a public
URL) with real credentials baked in, and don't commit `.env` (it's
gitignored already).

Garmin Connect intentionally isn't integrated: unlike Strava, it has no
self-serve API for individuals — the only way to automate a Garmin upload is
an unofficial, reverse-engineered login that violates their Terms of Service
and can break at any time. If your setup is Garmin-only, upload via Garmin
Connect's own website/app, which can auto-forward to Strava/TrainingPeaks if
you have that configured.

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
- `src/strava/` — Strava OAuth (`stravaAuth.ts`), upload + polling
  (`stravaUpload.ts`), and a `useStrava` React hook.
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
- The Strava OAuth + upload flow was exercised end-to-end against a mocked
  Strava API (real request shapes, real UI state transitions), but hasn't
  been run against Strava's actual servers with a real API app — the first
  real "Connect Strava" click is the first live test of that handshake.
