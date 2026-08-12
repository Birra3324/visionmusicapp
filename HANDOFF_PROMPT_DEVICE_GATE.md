# Prompt for OpenClaw — physical iPhone release gate

Copy everything below the line into OpenClaw.

---

**Project:** `/Users/birragemedi/Desktop/visionmusicapp`

Priority changed. Not shuffle, not lyrics, not Android. The physical iPhone background-audio and
lock-screen path is the release-blocking check: `UIBackgroundModes: audio` was added today and has
never executed on real hardware. **A music app that stops when the phone locks is broken in the way
users notice first.**

## Rules

- **Do not `git reset`, `git checkout --`, `git stash drop`, or `git clean`.** 59 missing blobs, no
  remote. Discarded work is unrecoverable.
- **Do not delete** anything under `assets/`, `_recovered-from-apk/`, `_audit-backup-*/`,
  `backup-catalog-fix/`, `lib/_archive/`, `ios/Pods.stale-icloud-20260811`.
- **Do not upgrade packages**; **do not add HEADER_SEARCH_PATHS patches**; **do not run
  `pod deintegrate`**.
- **Do not change signing, certificates, provisioning or the development team.**
- **If a test fails, do not patch. Capture evidence and report.** One agent edits at a time, and
  `audio_manager.dart` is currently Claude's.

## Step 1 — Restore the static gate

`audio_manager.dart` gained three log statements at 02:55, after the last clean analyze. The current
tree is **not** statically verified.

```bash
cd /Users/birragemedi/Desktop/visionmusicapp
flutter analyze 2>&1 | tail -20
flutter test 2>&1 | tail -20
```

Expect ~11 infos, 0 errors, 0 warnings, and 26/26 passing. **Any error, or any new warning, stops
this run** — report it and do not continue to device testing on an unexplained regression.

The new log lines are `toggleShuffle`, `cycleRepeatMode` and `_relativeIndex`. If analyze complains,
it will be in one of those.

## Step 2 — Install on the phone, then detach

Build and install however works — `flutter run -d 00008140-0006024C3CEA801C`, or Xcode ⌘R. A wireless
LLDB or VM Service timeout is **not** a failure if build, signing, install and launch succeeded.

**Then stop the debugger and launch the app from the iPhone home screen.**

This matters. A debug build with Xcode attached can be kept alive artificially when backgrounded,
which would produce a false pass on the exact thing being tested. Testing with nothing attached is
the honest test, and it makes the wireless attach problem irrelevant.

You will have no `[VM-AUDIO]` log for these steps. That is expected and acceptable — the owner's
eyes and ears are the instrument here.

## Step 3 — Basic playback on the device

Ask the owner to confirm each, and be explicit that you are asking because you cannot hear:

1. Launch Vision Music, enter as guest if needed
2. Play a song that is **not** the first in the list
3. **Audible from the iPhone speaker?**
4. Correct title, artist and artwork?
5. Position advancing?
6. Pause, resume, seek, next, previous — all working?

## Step 4 — Background audio

With a song playing, swipe to the home screen and leave the app backgrounded.

7. Does the music keep playing?
8. **Wait at least 60 seconds.** A short transition proves nothing; iOS suspends misconfigured apps
   after a delay, not instantly.
9. Return to the app — same song, correct position, correct play/pause state?

## Step 5 — Lock screen

With audio playing, lock the phone.

10. Does the Now Playing card appear?
11. Correct title, artist, **artwork**?
12. Is the progress moving?
13. From the lock screen: pause, resume, next, previous — do they work?
14. After each, unlock and check the app agrees — same song, same state, position in sync.

**Step 14 matters more than it looks.** This app had a defect where the player always displayed the
first catalogue entry regardless of what was playing. It is fixed and verified in the simulator, but
commands originating *outside* the app are a different path through the same code.

## Step 6 — Control Center

15. Same checks from Control Center: metadata correct, play/pause/next/previous work, app stays in
    sync.

## Step 7 — Background auto-advance

16. Backgrounded or locked, **let a track play all the way to its end.** Does the next song start by
    itself, and does the lock-screen metadata update to the new track?

This is the highest-value single check in the whole list. It exercises the completion handler, the
play-order logic and the media-session update together, on real hardware, with the app not in the
foreground.

## Step 8 — Repeat in background

17. Enable Repeat One, lock the phone, let the song finish. Same song restarts? Lock-screen metadata
    still correct?

## Step 9 — Optional

18. Bluetooth headphones or car: play, pause, next, previous.
19. An interruption — Siri, or an incoming call. Does playback pause and resume sensibly, and does
    state stay correct?

If the hardware is not available, record **NOT TESTED**. Do not invent a result, and do not block the
gate on missing hardware.

## If something fails

Stop. Do not patch. Capture:

- the exact step number that failed
- whether audio stopped, or the app crashed, or it merely desynced
- foreground / background / locked state at the moment of failure
- which song
- Xcode device console output if obtainable (Window → Devices and Simulators → View Device Logs)
- a screenshot if the lock screen looked wrong

Then hand it to Claude for root-cause analysis. One fix, one editor, then rebuild and retest.

## Report

```
STATIC
  flutter analyze:
  flutter test:

PHYSICAL IPHONE
  build:            install:            launch:
  audible:          pause/resume:       seek:        next/previous:
  background:       lock screen metadata:            lock screen controls:
  Control Center:   background auto-advance:         background repeat:
  Bluetooth:        interruption:

RESULT: PASS / FAIL
```

Use only: IMPLEMENTED · STATIC VERIFIED · BUILD VERIFIED · RUNTIME VERIFIED · HUMAN VERIFIED ·
NOT TESTED. **Never write "fixed" without a level.** Anything the owner confirmed by ear or eye is
HUMAN VERIFIED; anything you inferred is not.
