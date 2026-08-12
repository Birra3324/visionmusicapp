# Prompt for OpenClaw — Phase 1 verification gate

Copy everything below the line into OpenClaw.

---

**Project:** `/Users/birragemedi/Desktop/visionmusicapp`
**Read first:** `docs/VISION_MUSIC_MASTER_AUDIT.md`

This is a verification gate, not a feature task. Ten source files have been changed over the last
two sessions and **five of them have never been compiled**. Nobody has confirmed by ear that this
app produces sound. Nothing else proceeds until that is settled.

## Rules

- **Do not `git reset`, `git checkout --`, `git stash drop`, or `git clean`.** The repo has 59
  missing blobs and no remote. Anything discarded is gone permanently.
- **Do not delete** anything under `assets/`, `_recovered-from-apk/`, `_audit-backup-*/`,
  `backup-catalog-fix/`, `lib/_archive/`, or `ios/Pods.stale-icloud-20260811`.
- **Do not upgrade packages.** No `pub upgrade`, no `pod update`.
- **Do not add HEADER_SEARCH_PATHS patches to the Podfile.** That reflex caused a multi-hour build
  failure once already. If a pod fails, report it.
- **Do not change signing, certificates, provisioning or the development team.**
- **Do not deploy Firebase rules.** `firestore.rules` and `storage.rules` are new and undeployed by
  design.
- **Do not drive the UI with screenshots, OCR or synthetic clicks.** A human does the listening.

## Step 1 — Static gate

```bash
cd /Users/birragemedi/Desktop/visionmusicapp
flutter pub get
flutter analyze 2>&1 | tee /tmp/analyze.txt
tail -5 /tmp/analyze.txt
```

Around 39 `withOpacity` deprecation infos are known and expected. **Report every error verbatim.**

Errors are most likely in the recently changed files: `lib/vision_theme.dart`,
`lib/gold_discover_screen.dart`, `lib/widgets/mini_player.dart`, `lib/widgets/song_row.dart`,
`lib/audio_manager.dart`, `lib/models/video.dart`.

**If analysis reports any error, fix only that error, rerun, and report. Do not continue.**

## Step 2 — Tests

```bash
flutter test 2>&1 | tail -30
```

`test/widget_test.dart` is still the Flutter counter template and **is expected to fail**. Confirm
that is the only reason, and report anything else.

## Step 3 — Build and run on the iPhone

Device is `00008140-0006024C3CEA801C` (iPhone 16 Pro Max, iOS 27.0), and may need a longer timeout:

```bash
flutter devices --device-timeout 30
flutter run -d 00008140-0006024C3CEA801C 2>&1 | tee /tmp/ios_run.log
```

If it fails, capture the error and stop. Signing failures are the owner's to resolve in Xcode.

## Step 4 — Hand the phone to the owner

Ask him this, verbatim, then wait. Do not simulate any of it.

> The app is running. Please work through these and tell me what happens at each step:
>
> **Playback**
> 1. Tap a song that is **not** the first one in the list
> 2. Is there sound?
> 3. Does Now Playing show the correct title, artist and cover for what you tapped?
> 4. Pause, then play — does the sound come back?
> 5. Drag the progress bar to seek
> 6. Next, then previous
> 7. **Let one track play all the way to the end** — does the next song start by itself?
> 8. Turn on repeat, then shuffle — do they do anything?
> 9. Lock the phone — right song and artwork on the lock screen? Do its controls work?
> 10. Unlock and return — is the app still showing the right state?
>
> **Home screen**
> 11. Does the header read "Vision Music" in white and gold?
> 12. Is the Watch card burgundy rather than blue?
> 13. Are all three Trending cards fully visible, none cut off?
> 14. Do the tabs read Recently Played / Popular / New Releases / Trending, and does switching them
>     change the list?
> 15. Is the gold pill behind the Home nav icon gone?
> 16. With music playing, is the last song in the list hidden behind the mini-player?
> 17. Does tapping the search bar open the Search tab?
> 18. Does tapping the mini-player open Now Playing?

Items 7, 8 and 9 matter most — automatic advance, repeat, shuffle and iOS background audio are all
new code that has never run anywhere.

## Step 5 — Report

```bash
grep "\[VM-AUDIO\]" /tmp/ios_run.log
grep -iE "error|fatal|exception|failed|overflow|RenderFlex" /tmp/ios_run.log | head -40
```

Send back:

1. `flutter analyze` — issue count and every error verbatim
2. Whether `flutter test` failed only because of the template test
3. Whether the build succeeded, with the full error if not
4. **The complete `[VM-AUDIO]` block, unedited** — the sequence is the point
5. Any `RenderFlex overflow` warnings, with the widget named
6. The owner's answers to all 18 questions

Raw output beats interpretation. If something is ambiguous, say so rather than resolving it with a
guess. If you find yourself three steps into a theory rather than reporting a fact, stop and report.
