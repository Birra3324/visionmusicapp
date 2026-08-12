# Prompt for OpenClaw — clean Pods reinstall, then run on the iPhone

Copy everything below the line into OpenClaw.

---

**Stop investigating gRPC header search paths. The root cause is found and the
fix is already applied to the Podfile.** Do not add any more
`HEADER_SEARCH_PATHS` patches.

**Project:** `/Users/birragemedi/Desktop/visionmusicapp`

## What was actually wrong

The previous `ios/Podfile` contained this in `post_install`:

```ruby
config.build_settings['HEADER_SEARCH_PATHS'] ||= []
config.build_settings['HEADER_SEARCH_PATHS'] << '${PODS_ROOT}/Headers/Public'
# ...four more appends
```

At `post_install`, a pod's `HEADER_SEARCH_PATHS` lives in its generated
**xcconfig**, not in `build_settings`, so that key reads as `nil`. `||= []`
creates an empty array, and the appends then write five paths into
`build_settings` — **which overrides the xcconfig completely**, with no
`$(inherited)`. Every pod lost its real header search paths.

That is why `#include <address_sorting/address_sorting.h>` fails despite the
file existing exactly where gRPC-Core's own xcconfig points. The compiler never
receives that `-I` flag. It is also why `leveldb-library`, `GoogleUtilities`,
`AppCheckCore` and `GoogleSignIn` each needed a rescue patch in that same file:
one block broke all of them, and four patches papered over four casualties.
gRPC-Core was the fifth.

The Podfile has been reset to Flutter's stock template. The old one is preserved
at `ios/Podfile.pre-cleanup-20260811`, and the lock at
`ios/Podfile.lock.pre-cleanup-20260811`.

The poisoned settings are baked into the generated `ios/Pods/Pods.xcodeproj`, so
that has to be regenerated.

Two things previously suspected are **not** the problem, so don't chase them:

- *"CocoaPods did not set the base configuration of your project"* — this is
  normal in every Flutter iOS project. `ios/Flutter/Debug.xcconfig` pulls in
  `Pods-Runner.debug.xcconfig` via `#include?`. Verified. Benign.
- The `0400` file permissions and `com.apple.provenance` xattrs — clang was
  proven to read those files fine. Not the blocker.

## Rules

- **Do not `git reset`, `git checkout --`, `git stash drop`, or `git clean`.**
  The repo has 59 missing blobs and no remote. Anything discarded is gone.
- **Do not delete anything except `ios/Pods` and `ios/Podfile.lock`.** Both are
  generated and untracked — verified safe. Nothing else.
- **Do not run `pod deintegrate`.** It rewrites `Runner.xcodeproj`, and that
  file is not recoverable from git if it goes wrong.
- **Do not edit the Podfile.** If a pod still fails after a clean install, report
  it. Do not add a header patch — that is what caused this.
- **Do not upgrade packages.** No `pod update`, no `flutter pub upgrade`.
- **Do not change signing, certificates, provisioning, or the development team.**
- **Do not run `xattr -cr` on the project directory.**

## Step 1 — Clean reinstall of pods

```bash
cd /Users/birragemedi/Desktop/visionmusicapp
rm -rf ios/Pods ios/Podfile.lock
flutter clean
flutter pub get
cd ios && pod install 2>&1 | tee /tmp/pod_install.log ; cd ..
tail -20 /tmp/pod_install.log
```

Report any error verbatim. The "did not set the base configuration" line is
expected — ignore it.

## Step 2 — Build and run

The iPhone is `00008140-0006024C3CEA801C` (iPhone 16 Pro Max, iOS 27.0). It may
need a longer enumeration timeout:

```bash
flutter devices --device-timeout 30
flutter run -d 00008140-0006024C3CEA801C 2>&1 | tee /tmp/ios_run.log
```

The first build after a clean reinstall will take a while — all pods recompile.

If it fails, capture the error and **stop**. Expected failure modes:

- **Signing** — the owner needs to sign into Xcode › Settings › Accounts. His
  Apple ID, his to do. Report and stop.
- **A pod header error** — report the pod name and full error. **Do not patch
  it.** If a pod genuinely needs a setting after a clean install, that is a real
  finding worth discussing, not something to fix silently.

## Step 3 — Hand the phone to the owner

Once it runs, do **not** drive the UI. No screenshots, no OCR, no synthetic taps.
Ask him this and wait:

> The app is on your iPhone. Please do these and tell me what happens:
> 1. Tap any song that is **not** the first one in the list
> 2. Is there sound?
> 3. Pause, then play — does the sound come back?
> 4. Next, then previous
> 5. **Let a song play all the way to the end** — does the next one start by itself?
> 6. Turn on repeat, then shuffle — do they do anything?
> 7. Lock the phone — does the lock screen show the right song and artwork, and
>    do its controls work?

Items 5, 6 and 7 matter most. Automatic advance, repeat and shuffle were
rewritten today and have never run anywhere. iOS background audio was enabled
today too.

## Step 4 — Report

```bash
grep "\[VM-AUDIO\]" /tmp/ios_run.log
grep -iE "error|fatal|failed|Unhandled" /tmp/ios_run.log | head -40
```

Send back:

1. Whether `pod install` succeeded, with any error verbatim
2. Whether the build succeeded, with the full error if not
3. **The complete `[VM-AUDIO]` block, unedited** — sequence is the point
4. The owner's answers to all seven questions

Raw output beats interpretation. If something is ambiguous, say so rather than
resolving it with a guess. If you find yourself three steps deep in a theory
about header search paths again, stop and report instead.
