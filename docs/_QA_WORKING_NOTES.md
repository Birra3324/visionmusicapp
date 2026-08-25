# QA Working Notes — VisionMusic (2026-08-13)

## Repo state (differs from handoff prompt — flagged)

The handoff claimed: single clean baseline `4d70eea` on main, pushed, clean tree.
Actual state:

- `HEAD` = `4e058c2`, **3 commits ahead of origin/main** (unpushed):
  - `0f52283` Fix Android launcher icon cropped/oversized
  - `8eeaa54` Remove FFmpegKit; pins Gradle to JDK 17 in repo file
  - `4e058c2` Formatting pass + recognition/localization adjustments
- `origin/main` = `4d70eea` (baseline)
- Working tree: one uncommitted change to `android/gradle.properties`
  (removes the machine-specific JDK 17 pin). This is INTENTIONAL per commit
  `8eeaa54`'s note — pin already moved to `~/.gradle/gradle.properties`
  (verified present). No action taken; preserved as-is.
- No `lib/` .dart file imports from `_archive` (verified clean).

Decision: do NOT rewrite history, do NOT discard the uncommitted change, do NOT
force-push. Continue QA on actual current state (HEAD 4e058c2 + worktree).

## Baseline

- `flutter --version`: Flutter 3.44.9 stable, Dart 3.12.2, DevTools 2.57.0
- `flutter pub get`: OK
- `flutter analyze`: No issues found
- `flutter test`: All 59 tests passed (see full list in transcript)

## Confirmed issues (appended as found)

## Fixes applied

## Tests added

## Device run attempts (2026-08-13)

Target: `Birra iphone` (iPhone 16 Pro Max, physical, paired, iOS 27.0, wireless).

Independently-detected device id from flutter: `00008140-0006024C3CEA801C`;
xcrun devicectl id: `25E36889-FFDC-51D4-A938-393A3DCAC05A`.

Attempts (all wireless):
1. `flutter run` -> pod install OK, Xcode build started, session SIGKILL'd
   midway; Runner.app eventually built (04:06) but run process died.
2. `flutter run` -> Xcode build done 17.4s, app installed+launching, LLDB
   attach slow, then "Dart VM Service was not discovered after 75 seconds" --
   wireless debugger could not attach.
3. `flutter run` -> Xcode build done 91.7s, then Xcode destination timeout:
   "Timed out waiting for all destinations... Birra iphone may need to be
   unlocked to recover from previously reported preparation errors."

Root cause: wireless debugging on iOS 27 is unreliable on this link; Mac
interface IP shifted 100.82.179.23 -> 172.20.10.2 at 04:51 mid-session.
Flutter tool itself recommends a wired (USB) connection.

=> BLOCKED on device driving until the iPhone is plugged in via USB.

The app DID build and install to the phone (native build + pods cached), so
once wired, `flutter run` should be quick and reliable.

NOTE (not started by me): an orphaned `flutterfire configure --project=visionmusic-dev`
process has been running since 10:29 PM (~6h) at ~99% CPU. Out of QA scope
(no cloud/Firebase actions). Flagged to user; not killed without approval.

## Unverified
