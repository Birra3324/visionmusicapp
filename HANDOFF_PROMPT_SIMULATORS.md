# Prompt for OpenClaw — simulator + emulator verification

Copy everything below the line into OpenClaw.

---

Stop using the physical iPhone. The wireless connection keeps dropping and LLDB will not attach, so
no runtime log has ever been captured. Use an **iOS Simulator** and an **Android emulator** instead.

Both run over a local socket rather than Wi-Fi, so the Dart VM Service connects reliably, the
`[VM-AUDIO]` log finally becomes capturable, and screenshots become possible for the first time.

**Project:** `/Users/birragemedi/Desktop/visionmusicapp`

## What changed since your last run — your numbers are stale

Re-run analyze and test before anything else. Since your report:

- All 39 `withOpacity` calls were converted to `withValues(alpha:)`. Analyze should now be around
  **15 issues, not 54**.
- The counter template test is **gone**, replaced by 30 real tests in `test/song_test.dart` and
  `test/widget_test.dart`. **These have never been executed.** `flutter test` should now pass — if
  it does not, that is a genuine finding and the failure output is what I need.
- Seven stream subscriptions in `lib/audio/audio_handler.dart` are now retained and cancellable.

## Rules

- **Do not `git reset`, `git checkout --`, `git stash drop`, or `git clean`.** 59 missing blobs, no
  remote. Anything discarded is gone.
- **Do not delete** anything under `assets/`, `_recovered-from-apk/`, `_audit-backup-*/`,
  `backup-catalog-fix/`, `lib/_archive/`, `ios/Pods.stale-icloud-20260811`.
- **Do not upgrade packages**, and **do not add HEADER_SEARCH_PATHS patches** to any Podfile.
- **Do not change signing, certificates or the development team.** Simulators do not need them.
- **Do not deploy Firebase rules.** `firestore.rules` and `storage.rules` are undeployed by design.
- Diagnose and report. Do not fix beyond what is asked.

## Step 1 — Static gate, again

```bash
cd /Users/birragemedi/Desktop/visionmusicapp
flutter pub get
flutter analyze 2>&1 | tail -20
flutter test 2>&1 | tail -40
```

Report both verbatim. **Any test failure is a real finding** — those tests are new and unproven.

## Step 2 — iOS Simulator

```bash
xcrun simctl list devices available | head -30
open -a Simulator
flutter devices
```

If no suitable simulator exists, create one (adjust the runtime to whatever is installed):

```bash
xcrun simctl list runtimes
xcrun simctl create "VisionMusic-iPhone" \
  com.apple.CoreSimulator.SimDeviceType.iPhone-15 \
  com.apple.CoreSimulator.SimRuntime.iOS-18-0
xcrun simctl boot "VisionMusic-iPhone"
```

Then:

```bash
flutter run -d <simulator-id> 2>&1 | tee /tmp/sim_ios.log
```

**Turn the Mac's volume up.** The simulator plays audio through the Mac's speakers, so playback is
genuinely testable here.

## Step 3 — Android emulator

```bash
flutter emulators
```

If one exists, launch it. If none does, create one via Android Studio's Device Manager, or:

```bash
sdkmanager "system-images;android-34;google_apis;arm64-v8a"
avdmanager create avd -n VisionMusic-Pixel \
  -k "system-images;android-34;google_apis;arm64-v8a" -d pixel_6
flutter emulators --launch VisionMusic-Pixel
```

Then:

```bash
flutter run -d emulator-5554 2>&1 | tee /tmp/sim_android.log
```

**This is the first Android run of this codebase in this project's recent history.** Report any
Gradle, manifest or `audio_service` foreground-service error verbatim — Android has its own
notification and audio-focus path that iOS never exercises.

## Step 4 — Capture the log

On both platforms:

```bash
grep "\[VM-AUDIO\]" /tmp/sim_ios.log
grep "\[VM-AUDIO\]" /tmp/sim_android.log
grep -iE "error|fatal|exception|RenderFlex|overflow" /tmp/sim_ios.log | head -30
grep -iE "error|fatal|exception|RenderFlex|overflow" /tmp/sim_android.log | head -30
```

`RenderFlex overflow` warnings matter — the Home screen was redesigned and has never been rendered
at any size. Report the widget named in any overflow.

## Step 5 — Screenshots

This has not been possible until now. Capture Home, and Now Playing with audio loaded:

```bash
xcrun simctl io booted screenshot /tmp/vm_ios_home.png
adb exec-out screencap -p > /tmp/vm_android_home.png
```

## Step 6 — Playback and UI checks

You can drive these yourself on a simulator — clicking a simulator is deterministic, unlike the
OCR-and-synthetic-click approach that failed before. **But you cannot judge audio.** Ask the owner
to listen, and be explicit that you are asking because you cannot hear.

1. Tap a song that is **not** the first in the list
2. Does Now Playing open, with the correct title, artist and cover?
3. **Sound?** — owner answers
4. Pause, then play
5. Seek by dragging the progress bar
6. Next, then previous
7. **Let a track run to its end — does the next start by itself?**
8. Repeat, then shuffle — do they change behaviour?
9. Home: header reads "Vision Music" white and gold?
10. Watch card burgundy, not blue?
11. All three Trending cards fully visible?
12. Tabs read Recently Played / Popular / New Releases / Trending, and switching changes the list?
13. Gold pill behind the Home nav icon gone?
14. With music playing, is the last list row hidden behind the mini-player?
15. Search bar opens the Search tab?
16. Mini-player opens Now Playing?

Items 7 and 8 are the priority — auto-advance, repeat and shuffle are new code that has still never
executed anywhere.

## Known simulator limits — do not report these as bugs

- **Lock-screen and Bluetooth controls are unreliable on simulator.** Those need the physical phone
  eventually. Skip item 9 from the earlier checklist here.
- Simulator audio can be a touch choppy; that is the simulator, not the app.
- Firebase works on both, but Google Sign-In may need extra setup on the Android emulator.

## Step 7 — Report

1. `flutter analyze` — issue count and any error verbatim
2. `flutter test` — **pass or fail, with full output if anything failed**
3. iOS simulator: build result, run result
4. Android emulator: build result, run result, plus any Android-specific error
5. **The complete `[VM-AUDIO]` block from each, unedited**
6. Every `RenderFlex overflow`, with the widget named
7. Answers to the 16 checks, marking clearly which came from the owner's ears
8. The screenshot paths

Raw output beats interpretation. If something is ambiguous, say so rather than resolving it with a
guess.
