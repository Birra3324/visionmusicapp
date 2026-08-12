# Vision Music — Master Audit

**Date:** 11 August 2026
**Checkpoint taken first:** `_audit-backup-20260811-0106/` (source, assets, platform folders, `.git`)
**Supersedes:** `TECHNICAL_AUDIT_2026-08-10.md`, which remains valid for the recovery history

---

## 0. Read this first

**Status as of 11 Aug 2026, 03:20.**

| Check | Level |
| --- | --- |
| `flutter analyze` — 11 issues, 0 errors, 0 warnings | STATIC VERIFIED — re-run at 03:05 against the current tree. The three added log statements introduced nothing. |
| `flutter test` — 26 / 26 passing | STATIC VERIFIED — re-run at 03:05 |
| iOS Simulator build and launch | BUILD VERIFIED |
| Playback loads, position advances | RUNTIME VERIFIED |
| Auto-advance on natural track completion | RUNTIME VERIFIED |
| Correct metadata after auto-advance | RUNTIME VERIFIED |
| **Audio is audible** | **HUMAN VERIFIED** — owner confirmed |
| **Repeat** | **HUMAN VERIFIED** — owner confirmed working |
| Shuffle | Not yet exercised |
| Lyrics honest empty state | BUILD VERIFIED, sheet not yet opened |
| Physical iPhone — build, install, launch | BUILD VERIFIED — installed via `devicectl`, launched with **no debugger attached** so backgrounding behaviour is honest |
| **Physical iPhone — audio audible** | **HUMAN VERIFIED** — owner confirmed on device speaker |
| **Physical iPhone — play / pause** | **HUMAN VERIFIED** — owner confirmed |
| **Physical iPhone — background audio survives** | **HUMAN VERIFIED** — owner backgrounded the app; audio continued |
| **Physical iPhone — lock screen controls** | **HUMAN VERIFIED** — owner confirmed working |
| **Physical iPhone — Control Center** | **HUMAN VERIFIED** — owner confirmed working |
| **Physical iPhone — state stays synchronised** | **HUMAN VERIFIED** — owner confirmed playback stayed in sync |
| Physical iPhone — seek, next, previous | NOT TESTED |
| Physical iPhone — background auto-advance | NOT TESTED — not separately reported |
| Bluetooth, interruption | NOT TESTED |
| Android | Never run — SDK `cmdline-tools` not installed |

**All P0 items are closed, and the release-blocking device gate has passed.** On real hardware,
with no debugger attached: a song loads, is audible, keeps playing when the app is backgrounded,
presents working controls on the lock screen and in Control Center, and stays synchronised
throughout. In the simulator it also advances by itself at track end and repeats when asked.

The status tables in §2 are the authoritative record. **Read the Status column, not the issue
text** — most entries describe a defect in the past tense that has since been fixed.

## 1. Architecture discovered

| Layer | Implementation |
| --- | --- |
| Framework | Flutter 3.44.9, Dart 3.12.2, SDK constraint `^3.10.1` |
| State | `provider` 6.x — `ChangeNotifierProvider` over `AudioManager` and `SettingsManager` |
| Navigation | Imperative `Navigator.push` with a custom `fadeRoute`. No named routes, no router package |
| Shell | `MainShell` → `IndexedStack` of 5 tabs, mini-player + `NavigationBar` in `bottomNavigationBar` |
| Audio | `just_audio` 0.10.x, single `AudioPlayer` owned by `AudioManager` |
| Background audio | `audio_service` 0.18.x — `VisionAudioHandler` wraps the *same* player instance |
| Video | `video_player` + `chewie`; YouTube links open externally via `url_launcher` |
| Catalog | `SongRepository` interface, `LocalSongRepository` (bundled) / `FirestoreSongRepository` (remote), switched by `AppConfig.useFirebaseCatalog` (currently `false`) |
| Auth | `firebase_auth` + `google_sign_in` |
| Storage | Firestore + Firebase Storage configured; `shared_preferences` for settings |
| Localisation | Flutter gen-l10n, 6 ARBs: en, om, am, ar, fr, es |
| Platforms | Android, iOS, macOS, web, Windows, Linux |

### There is only one playback architecture

This was the single most important thing to establish, and the answer is good news.
`VisionAudioHandler` takes `AudioManager` by constructor injection and delegates to
`_audioManager.player` — it does **not** construct a second `AudioPlayer`. That is the correct
`just_audio` + `audio_service` pattern. There is no competing audio engine and none should be added.

`lib/_archive/` contains an older `audio_manager.dart` and `audio_handler.dart`. Both are excluded
from analysis and imported by nothing. They are historical, not active.

---

## 2. Problems found, by priority

### P0 — Critical

| ID | Issue | Status |
| --- | --- | --- |
| P0-1 | `playAtIndex` awaited `_player.play()`, which in `just_audio` only completes when the track *ends*. Tapping a song started audio but never opened Now Playing, and deferred `notifyListeners()` for minutes. | **Fixed** |
| P0-2 | `currentSongStream` derived from `_player.currentIndexStream`, permanently `0` under single-source loading — so Now Playing and the lock screen always showed the first catalogue entry. | **Fixed** |
| P0-3 | `togglePlayPause` had the same awaited-`play()` defect in its resume branch. Pause worked, resume did not. | **Fixed** |
| P0-4 | `assets/audio/lagaa.mp3` was an AAC/M4A file with a `.mp3` extension. AVFoundation infers container from extension → `-11849 Operation Stopped`. | **Fixed** (renamed `.m4a`) |
| P0-5 | iOS build impossible — 3 app icons and the launch image missing, plus 13 zero-byte PNGs in the launch imageset. | **Fixed** (regenerated) |
| P0-6 | iOS Podfile `post_install` wrote `HEADER_SEARCH_PATHS` into `build_settings` without `$(inherited)`, overriding every pod's real header paths. Four rescue patches had accumulated; gRPC-Core was the fifth casualty. | **Fixed** (stock Podfile + clean reinstall) |

### P1 — High

| ID | Issue | Status |
| --- | --- | --- |
| P1-1 | Auto-advance dead — completion handler used `_player.hasNext`, always `false` with one loaded source. Tracks stopped at the end. | **Fixed** |
| P1-2 | Repeat and shuffle were no-ops; `LoopMode.all` would have looped one song forever. | **Fixed** — play order now owned by `AudioManager` |
| P1-3 | `addToQueue` / `playNext` / `removeFromQueue` rebuilt a `ConcatenatingAudioSource` of the whole catalogue, reverting the player to the old preload model mid-session. | **Fixed** |
| P1-4 | `Song` had no `==`/`hashCode`. Worked only because `mockSongs` is `const`; would have destroyed the queue on every tap once the catalogue came from Firestore. | **Fixed** |
| P1-5 | iOS had no `UIBackgroundModes: audio` — background playback and lock-screen controls could not work. | **Fixed** |
| P1-6 | Every album cover was shifted by one artist; each song displayed the *next* artist's photo. Proven by printed text on three covers. | **Fixed** |
| P1-7 | 8 `.listen()` calls with no `StreamSubscription` held and none cancelled. | **Fixed** — all 7 handler subscriptions retained with a `dispose()`; `AudioManager` cancels its own. Position updates also throttled to whole seconds. |
| P1-8 | Firestore and Storage security rules were not in the repo. | **Partly fixed** — `firestore.rules` and `storage.rules` written, least-privilege, default-deny, wired into `firebase.json`. **Not deployed.** Deployment needs authorisation and should hit dev first. |
| P1-9 | Firebase project is `device-streaming-6b79dd0d`, an auto-generated scratch project; macOS registered under the **iOS** appId. | **Resolved 2026-08-12** — app repointed to `visionmusic-dev` via `flutterfire configure`; all four config locations consistent. |
| P1-10 | `flutter test` failed — `widget_test.dart` was still the counter template. | **Fixed** — template replaced by 26 tests across `song_test.dart` and `widget_test.dart`. All passing. |

### P2 — Medium

| ID | Issue | Status |
| --- | --- | --- |
| P2-1 | Home search bar was decorative (`// Non-functional search bar (visual only)`) while real search existed on the Search tab. | **Fixed** — now navigates |
| P2-2 | All four Home filter tabs returned the identical list. | **Fixed** — each is a real view |
| P2-3 | Trending cards had a fixed 155pt width, clipping the third card on narrower phones. | **Fixed** — responsive |
| P2-4 | Watch card was blue, reading as a separate product rather than the other half of this one. | **Fixed** — burgundy token |
| P2-5 | Row play/overflow buttons had no size constraints, falling below the 44pt minimum touch target. | **Fixed** |
| P2-6 | 11 empty `catch` blocks. On inspection only 2 were genuine silent failures; the other 9 are `firstWhere` not-found or Firebase-unavailable returning null with logging upstream. | **Fixed** — `playlist_controller` was silently wiping every saved playlist on a parse error and now logs the error and raw payload; `video_player_screen` no longer swallows a related-videos failure. |
| P2-7 | **39 `Text('...')` literals not localised**, undermining the 6-language system. | **Open** |
| P2-8 | 39 deprecated `withOpacity()` calls. | **Fixed** — converted across 9 files. Analyze dropped 54 → 15. |
| P2-9 | 63 TODO/placeholder markers, concentrated in `lyrics_service`, `ai_translation_service`, `firestore_song_model`. | **Triaged** — Claude reviewed and classified them. Five AI/support services (`AITranslationService`, `AudioLanguageDetectionService`, `MusicMetadataAIService`, `ScriptConversionService`, `SearchEnhancementService`) plus `FirestoreSongModel` appear dead/unreferenced (archive candidates, not release blockers). `LyricsService` was the one active dangerous case — fabricated lyrics removed (see P2-15). Dead files are NOT deleted during verification; archive only after dependency proof. |
| P2-10 | `ios/Flutter/Profile.xcconfig` missing while `Pods-Runner.profile.xcconfig` was referenced. | **Fixed** — created and independently verified to match the Debug/Release pattern exactly. |
| P2-11 | `Nuho gobana.mp3` and `nuho_gobana.mp3` byte-identical — 6.9 MB shipped twice. | **Fixed** — proven identical by md5 and proven unreferenced, then **moved** to `_recovered-from-apk/superseded-duplicates/` rather than deleted. |
| P2-12 | Android missing `mipmap-xxxhdpi`; adaptive icon densities incomplete. | **Fixed** from APK |
| P2-13 | `_SectionCard` painted a decorated `Container` over the Material, so ListTile ripples rendered beneath the card — Library rows gave no touch feedback. Flutter warned 12–15× per launch. | **Fixed** — `Material` + `Ink`. Warning count 0, confirmed at runtime. |
| P2-14 | 4 unused-element warnings: two dead imports in `now_playing_screen`, an unused `_openaiApiKey` constant, and a `_translator` field constructed but never called. | **Fixed** — removed. The key constant was replaced with a note explaining why a key field must not return to client code. |
| P2-15 | **Lyrics integrity — fabricated lyrics.** The app shipped invented English lyrics presented as the real lyrics of real Oromo songs by real, living artists (e.g. fabricated verses attributed to Hirphaa Gaanfuree and Yosan Getahun), rendered under a spinner reading "Generating lyrics…" that implied a transcription which never occurred. Worse than no lyrics: it puts words into named artists' mouths, is published on the artists' own platform, and a listener who does not read Afaan Oromo cannot tell it is fiction. | **Fixed** — `LyricsService.getLyrics()` changed `Future<String>` → `Future<String?>`, the fabricated `fallbackLyrics` map removed (`licensedLyrics` is now deliberately empty and only accepts artist- or licence-supplied text), and Now Playing renders an honest empty state ("Lyrics not available yet — we only show lyrics provided by the artist or a licensed source"). No transcription/AI claim remains. **Verification: STATIC VERIFIED** (analyze 11/0/0, tests 26/26) **+ BUILD VERIFIED** + code review PASS (all 10 safety criteria). **Audibility now HUMAN VERIFIED** (owner confirmed by ear, 02:45). Only the lyrics-sheet runtime tap remains open (BUILD VERIFIED, not yet opened at runtime). Fabricated text preserved (not active) at `_recovered-from-apk/superseded-duplicates/lyrics_service.dart.fabricated-backup`. **Remaining limitation:** licensed lyrics must still be supplied from a real source before any lyrics can show. |

### P3 — Future, documented not built

Downloads and offline playback · lyrics (licensed only) · recommendation engine · artist and album
pages · collaborative playlists · deep links · social graph · analytics events · crash reporting ·
artist dashboard · monetisation · audio quality tiers.

---

## 3. Security

**No real secrets found in source.** Specifically checked and cleared:

- `android/app/upload-keystore.jks` and `android/key.properties` exist on disk but are correctly
  `.gitignore`d and confirmed **untracked**.
- Firebase `apiKey` values in `firebase_options.dart` are client identifiers, not secrets. Safe to
  commit. **Security rules are the actual boundary — see P1-8.**
- AI service keys are unfilled placeholders. They are nonetheless declared as `static const` in
  client code, which is the wrong pattern; they belong behind Cloud Functions.

---

## 4. What I could not verify

Work was performed in a Linux sandbox with the project mounted. No Dart toolchain, no Xcode, no
audio device, no simulator. Therefore:

**Verified directly:** source, git integrity, asset bytes, audio containers via `ffprobe`, image
content, asset reference resolution, build configuration, manifests, entitlements, secret scanning,
and structural checks on every edit.

**Not verified:** `flutter analyze` on the most recent five files, `flutter build`, `flutter test`,
runtime behaviour, audibility, UI rendering, screenshots. Phases 19 and 20 of the brief cannot be
completed from here.

Every code change made blind has been accompanied by a static verification pass. The previous
`flutter analyze` run — before the last five files — returned **0 errors**.

---

## 5. Files changed this session

| File | Change |
| --- | --- |
| `lib/audio_manager.dart` | P0-1, P0-3, P1-1, P1-2, P1-3 — play order, track advance, repeat/shuffle, queue reconciliation, temporary `[VM-AUDIO]` diagnostics |
| `lib/song.dart` | P1-4 — `==` / `hashCode` on `id` |
| `lib/mock_songs.dart` | P1-6 covers, real durations, 3 YouTube links |
| `lib/mock_videos.dart` | Broken reference, 3 YouTube links |
| `lib/models/video.dart` | `isPlayable`, `youtubeId`, `bestThumbnail`; `displayThumbnail` now falls back to YouTube poster frames |
| `lib/features/video/video_player_screen.dart` | Placeholder videos show "Coming soon" instead of a dead player |
| `lib/vision_theme.dart` | Design tokens, burgundy video accent, flat nav |
| `lib/gold_discover_screen.dart` | Home redesign |
| `lib/widgets/mini_player.dart` | Rebuilt — real state, transport, queue sheet |
| `lib/widgets/song_row.dart` | Touch targets, artwork, contrast |
| `ios/Runner/Info.plist` | P1-5 background audio |
| `ios/Podfile` | P0-6 reset to stock |
| iOS asset catalogs | P0-5 icons and launch images |
| `android/.../res/` | 5 launcher icons recovered from APK |

---

## 6. Store readiness

**Google Play — closest.** Vision Music (`com.visionmusic.app`) is in closed testing. Store listing
is Live. Developer verification complete. The blocker is **not code**: 12 testers are invited but
only 4 have opted in, and a 14-day clock cannot start until the 12th does. 10-inch tablet
screenshots are missing.

**App Store — not started.** Enrollment payment is unresolved. Likely causes are a D-U-N-S
requirement if enrolling as an Organization, two-factor not enabled, or an Ethiopian card without
international transactions enabled.

---

## 7. The honest summary

The recovery worked and the foundations are sound. The architecture is correct in the place it
matters most — one player, one owner, one source of truth. Localisation, theming, the repository
abstraction and the feature-folder layout are all in good shape.

What was broken was a tight cluster in `audio_manager.dart` created by an incomplete migration, plus
an iOS build blocked by a self-inflicted Podfile patch. Both are now fixed. Neither required an
architectural rewrite, and none should be attempted.

The largest remaining risks are not code quality. They are **unversioned security rules**, a
**scratch Firebase project**, and — historically — the fact that nobody had yet heard this app play
a song. *(That last risk is now resolved: audibility and repeat are HUMAN VERIFIED as of
2026-08-11 02:45. See the Human verification section below.)*

---

# Verification record — 11 August 2026

The first runtime verification this project has had. Performed on the iOS Simulator
(iPhone 17 Pro, iOS 27.0) after the physical iPhone proved unusable — wireless LLDB
attach never completed, so no runtime log could be captured from it.

## Commands and results

| Command | Result |
| --- | --- |
| `flutter pub get` | Clean |
| `flutter analyze` | **15 issues, 0 errors** — down from 54 after the `withOpacity` → `withValues` codemod. Since reduced to 11 by clearing the 4 unused-element warnings. |
| `flutter test` | **26 / 26 passing.** First execution of the suite that replaced the counter template. |
| iOS Simulator build | **Success**, 329.1s cold |
| Android emulator | **Blocked** — `cmdline-tools` not installed, so no `sdkmanager` or `avdmanager`. No AVD exists. Toolchain install deferred to the owner. |
| Physical iPhone | Build, sign and install succeeded. Debug attach failed: wireless VM Service timeout. |

## Playback verified at runtime

Captured from the `[VM-AUDIO]` diagnostics:

```
playAtIndex(0): Markato — assets/audio/nuho_gobana.mp3
  -> loaded, reported duration=0:05:00.279
  -> play() requested
        … position advanced continuously to 02:29 / 05:00 …
completed: repeat=off shuffle=false autoplay=true
playAtIndex(1): Hirphaa — assets/audio/hirphaa.mp3
  -> loaded, reported duration=0:04:02.399
  -> play() requested
```

This closes four findings at once:

- **P0-1 confirmed fixed.** Position advances continuously, which only happens if the
  decoder is running — the awaited `play()` no longer stalls the method.
- **P0-2 confirmed fixed.** After advancing, the screen showed *Hirphaa Gaanfuree*. The
  old defect always rendered `_queue[0]`, so it would have said Markato.
- **P1-1 confirmed fixed.** Auto-advance fired from the natural `completed` callback and
  loaded the next track unaided. This code had never executed anywhere.
- **H8 confirmed.** Reported durations match the `ffprobe` values to the millisecond.

## UI verified

| Check | Result |
| --- | --- |
| Watch card burgundy | Pixel reads `(142,43,43)` — exactly `kVisionRed` `0xFF8E2B2B` |
| RenderFlex overflow | **None**, at simulator size |
| Header, search, Listen/Watch, Trending, tabs, bottom nav | All render |
| Now Playing metadata | Correct title and artist, real progress |

## Bug found and fixed during verification

**ListTile ink invisible** — `_SectionCard` in `library_hub_screen.dart` painted a decorated
`Container` over the Material, so ListTile ripples rendered beneath the card. Tapping a
Library row produced no touch feedback. Flutter warned 12–15 times at launch, because
`MainShell`'s `IndexedStack` pre-builds every tab. Replaced with `Material` + `Ink`.
**Warning count after fix: 0**, confirmed at runtime. The other four files combining
ListTiles and decorations were checked and are unaffected.

## Still unverified

> **Historical note:** audibility and repeat were listed here as unverified at the time of the first
> runtime record. Both have since been closed — audibility and repeat are **HUMAN VERIFIED**
> (owner confirmed by ear, 2026-08-11 02:45). Background audio and lock-screen controls were
> likewise listed here until the physical-device release gate — they are now **HUMAN VERIFIED**
> (owner confirmed on the physical iPhone at 03:20; see the release-gate record below). Shuffle
> remains unexercised. The items below are the current remaining unverified set — the genuinely
> untested items only.

- **Physical-device seek, next, previous.** Not separately reported on hardware; see Step 2.
- **Physical-device background auto-advance.** Not separately reported on hardware; see Step 3.
- **Shuffle.** Rewritten with the play-order work; not yet exercised anywhere. Open item for runtime
  verification.
- **Lyrics sheet at runtime.** BUILD VERIFIED, sheet never opened; see Step 5.
- **Bluetooth / headphone controls, interruptions.** Need real hardware (headset/car, Siri/call).
- **Android.** Blocked on the missing SDK component. No Android run has ever occurred.

The physical-device background-audio, lock-screen, Control Center, and state-sync checks that used
once to live under this heading are now closed by the 03:20 release gate and are **not** listed as
open here to avoid contradicting that record.

## Open items after this record

**P0:** none remaining.

**P1:** P1-8 rules written but undeployed · P1-9 Firebase migration planned, not executed.
P1-7 and P1-10 closed this session.

**P2:** 39 hardcoded strings bypassing the ARB files · 63 TODO markers (now triaged; see P2-9) ·
`Profile.xcconfig` structurally verified to match the Debug/Release Flutter/CocoaPods pattern —
release/archive verification remains outstanding (not yet release-built).

---

## Human verification — 11 August 2026, 02:45

Owner confirmed on the iOS Simulator, by ear:

- **Audio is audible.** This is the first time anyone has confirmed the app produces sound.
- **Repeat works as designed.**

Level: **HUMAN VERIFIED** for audibility and repeat.

This closes the question the entire session was built around. At the start of the day, tapping a
song started audio but never opened Now Playing (P0-1), the player always displayed the first
catalogue entry regardless of what played (P0-2), tracks stopped dead at the end (P1-1), repeat and
shuffle were no-ops (P1-2), one audio file crashed AVFoundation with `-11849` (P0-4), and iOS could
not build at all (P0-5, P0-6).

**Not yet exercised, and deliberately not claimed:**

- **Shuffle.** The owner confirmed repeat; shuffle was not mentioned and is not assumed.
- **Background audio, lock-screen controls, Bluetooth, interruption handling.** These need the
  physical iPhone; the simulator is not a valid test surface for them.
- **Android.** Never run.

---

## Human verification — 11 August 2026, 03:10 (physical iPhone)

Owner confirmed on the physical device, launched from the home screen with **no debugger attached**:

- **Audio is audible from the iPhone.**
- **Play and pause work.**

Level: **HUMAN VERIFIED** for device audibility and play/pause.

This is a distinct result from the simulator confirmation at 02:45. The simulator routes audio
through the Mac's output; the device exercises the real AVAudioSession, the real hardware path and
the real signed build. Both were needed.

**Explicitly not claimed from this test:** background playback, lock-screen metadata and controls,
Control Center, background auto-advance, seek, next/previous on device. The owner reported play,
pause and sound — nothing further is inferred from that.

---

## Root cause: "the app won't open on the iPhone" — 11 August 2026, 03:15

Recorded because it wasted hours and was never an application defect.

The **debug** build was being `SIGKILL`ed at launch (`App terminated due to signal 9`). A Flutter
debug build waits for a debugger to attach; over this wireless connection the attach never
completed, so iOS killed the unresponsive process. Every symptom pointed at the app, and none of it
was the app.

Two consequences, both useful:

- Installing with `devicectl device install app` succeeded all along. The `flutter run` VM Service
  timeout was masking a successful install.
- A **release** build runs standalone with no debugger dependency. It launches and stays running —
  and it is also the honest build for a background-audio test, because a debug build with a debugger
  attached can be held alive artificially when backgrounded.

**Rule going forward: test background and lock-screen behaviour on a release build with nothing
attached.** A debug build under a debugger can produce a false pass on exactly the behaviour being
measured.

---

## Release gate passed — 11 August 2026, 03:20 (physical iPhone)

Owner tested personally on the physical iPhone, on a **release build launched from the home screen
with no debugger attached** — the condition under which backgrounding behaviour is real rather than
artificially sustained by an attached debugger.

Confirmed:

- **Backgrounded the app — audio continued playing.**
- **Locked the phone — lock-screen controls worked.**
- **Control Center controls worked.**
- **Playback stayed synchronised throughout.**

Level: **HUMAN VERIFIED.**

This closes the release-blocking gate. `UIBackgroundModes: audio` was added on 10 August and had
never executed on real hardware until now. A music app that stops when the screen locks fails in the
way users notice before any other; this one does not.

It also exercises, on hardware, the path that produced the original P0-2 defect — commands arriving
from outside the app, where the player previously always reported the first catalogue entry. State
stayed correct.

**Still NOT TESTED:** seek / next / previous on device, background auto-advance on device (not
separately reported), shuffle anywhere, the lyrics sheet at runtime, Bluetooth, interruption
handling, and the whole of Android.
