# Vision Music — Technical Audit & Phased Plan

**Date:** 10 August 2026
**Scope:** Full read-only inspection of `/Users/birragemedi/Desktop/visionmusicapp`
**Nothing was deleted, reset, or overwritten.** A backup was taken first (see §0).

---

## 0. Backup taken before any analysis

Created `_audit-backup-20260810-210827/` inside the project:

| File | Contents |
| --- | --- |
| `source-and-assets.tar.gz` | 63 MB — `lib/`, `assets/`, `test/`, all platform folders, pubspec, l10n config. Excludes `build/`, `Pods/`, `.dart_tool/`, the APK. |
| `git-dir.tar.gz` | Byte-for-byte copy of `.git/` as it stands today |
| `git-status.txt`, `git-stash.txt`, `git-fsck.txt` | Working-tree and repository state snapshots |

Move this folder to `Desktop/Backups & Archives` when convenient — it should not stay inside the project long-term.

---

## 1. What I could and could not verify

This session runs in a Linux sandbox with your project folder mounted. That means:

**Verified directly:** source code, git object integrity, every asset byte, audio container/codec analysis via `ffprobe`, image content inspection, asset-reference cross-checking, build configuration, manifests, entitlements, secret scanning.

**Not verifiable here — needs your Mac:** `flutter analyze`, `flutter build`, `flutter test`, running the app, audible playback, `pod install`, `codesign`. §8 is a copy-paste runbook for those. Every finding below comes from static evidence, not guesswork, so the runbook is confirmation rather than discovery.

---

## 2. Critical findings

### C1 — Tapping a song never opens Now Playing (blocking `await`)

`lib/audio_manager.dart:139`

```dart
await _player.setAudioSource(AudioSource.asset(song.filePath));
await _player.play();          // ← does not complete until the track ENDS
_recordRecent(song);
notifyListeners();
```

In `just_audio`, `play()` returns a `Future` that only completes when playback **stops or finishes** — it is not "start playing." Because `playAtIndex` awaits it, the method hangs for the entire duration of the song. Consequences:

- `lib/gold_discover_screen.dart:396` does `await audioManager.playSong(song); ... Navigator.push(NowPlayingScreen)`. The push **never runs**. Audio starts, the screen never opens.
- `_recordRecent()` and `notifyListeners()` are deferred by minutes, so Recently Played and the mini-player stay stale.
- Any caller awaiting `skipToNext()` / `skipToPrevious()` hangs identically.

**Fix:** call `unawaited(_player.play())` or drop the `await`, and move `_recordRecent` + `notifyListeners` before it. Roughly a four-line change.

**This is almost certainly the "playback is broken" symptom.** The audio engine is fine; the UI never advances.

---

### C2 — Now Playing always displays the wrong song

`lib/audio_manager.dart:56`

```dart
Stream<Song?> get currentSongStream => _player.currentIndexStream.map((index) {
      if (index != null && index >= 0 && index < _queue.length) return _queue[index];
      return null;
    });
```

Since the change to load one song at a time, the player holds a **single** audio source, so `currentIndexStream` always emits `0`. This stream therefore always resolves to `_queue[0]` — **Markato** — no matter what is playing.

`lib/now_playing_screen.dart:230` and `lib/audio/audio_handler.dart:17` both consume this stream, so the full player *and* the OS lock-screen/media notification show the wrong title, artist and artwork.

**Fix:** drive the stream from `_currentIndex` via a `BehaviorSubject`/`StreamController` updated inside `playAtIndex`, rather than from `currentIndexStream`.

---

### C3 — Every album cover is shifted by one artist

`lib/mock_songs.dart`. I rendered the artwork; most files are self-labelling (the cover art contains the title and artist), which makes the mapping verifiable rather than a guess.

| Song | Artist | Current cover | Cover actually depicts | Correct |
| --- | --- | --- | --- | --- |
| Markato | Ali Birra | `alii birra.jpeg` | "Alii Birra" | ✅ |
| Hirphaa | Hirphaa Gaanfuree | `yosan_getahun.jpg` | "OBSA! Yosan Getahun" | ❌ |
| 3Obsaa | Yosan Getahun | `davo.jpg` | "Urjii Iluu — Tekalign Tena" | ❌ |
| Lagaa | Davo | `shukri_jamal.jpg` | "Marartuu — Shukri Jamal" | ❌ |
| Marartuu | Shukri Jamal | `asanti.jpg` | *(unlabelled duo)* | ❌ |
| Kuyubisaa | Asanti | `andualem_gosa.jpg` | "GUMGUME … Gosa" | ❌ |
| Alibiyyanqabaa | Naaima Abdurahman | `Naaima abdurahman.jpeg` | *(unlabelled woman)* | ✅ |
| Gumgume | Andualem Gosa | `null` | — | ❌ |

The pattern is an exact off-by-one shift: **each song is showing the next artist's photo.** Three covers carry printed titles that prove the correct owner:

- `yosan_getahun.jpg` reads **"OBSA! — YOSAN GETAHUN"** → belongs to the Yosan Getahun track. This also shows the title `3Obsaa` is a typo for **Obsa**.
- `shukri_jamal.jpg` reads **"Marartuu — Shukri Jamal"** → belongs to the Marartuu track.
- `andualem_gosa.jpg` reads **"GUMGUME … GOSA"** → belongs to the Gumgume track.

**Two items need your decision, so I have not touched them:**

1. **`davo.jpg` is not Davo.** The image is a "Urjii Iluu" music-video poster credited to **Tekalign Tena**. The filename is wrong, inherited from the APK. The Lagaa/Davo track has no correct cover on disk.
2. **Hirphaa** still has no verified cover — per your standing note, `hirphaa.jpg` is the wrong artist, and it is now deleted from disk anyway (see C5). I propose the Vision Music logo as an explicit placeholder rather than another artist's face.

---

### C4 — `assets/audio/lagaa.mp3` is not an MP3 — this is the `-11849` cause

```
lagaa.mp3        format=mov,mp4,m4a  codec=aac   (M4A wearing a .mp3 extension)
all other files  format=mp3          codec=mp3   ✅
```

macOS AVFoundation infers the container from the file extension. Handed an AAC/M4A stream named `.mp3`, it fails with exactly **`-11849 Operation Stopped`**. That matches your recorded error precisely.

The workaround already applied — pointing Lagaa at `daraara-lagaa.mp3` — resolved the crash, and **all nine remaining files are valid MP3** (48 kHz or 44.1 kHz, stereo, 180–200 kbps, durations 3:19–5:37). But `lagaa.mp3` is still on disk, and `pubspec.yaml` bundles the whole `assets/audio/` directory, so the broken file ships in every build and remains a landmine for anyone who references it. It should be re-encoded to real MP3 or renamed to `.m4a`.

**Separate question flagged, not changed:** the Lagaa entry (artist "Davo") now points at `daraara-lagaa.mp3`, whose filename suggests the artist **Daraaraa**. Combined with C3's finding that `davo.jpg` is Tekalign Tena, the entire "Lagaa / Davo" row is unverified. Please confirm the real artist before this ships.

---

### C5 — The git repository cannot restore deleted files

```
git fsck  →  59 missing blobs, 18 broken tree links
git remote -v  →  (empty — origin/main ref exists but no remote is configured)
```

There is no remote and the object database is holed. I confirmed that none of the working-tree deletions are recoverable from history:

```
MISS assets/images/hirphaa.jpg          MISS store_icon_512x512.png
MISS assets/images/haragee.jpg          MISS macos/…/app_icon_1024.png
MISS assets/images/Andualem gosa.jpg    MISS assets/images/shukri jamal.jpg
MISS assets/images/yosan getan.jpg
```

Also deleted and unrecoverable: five Play Store screenshots, three tablet screenshot sets, the 1024×500 feature graphic, four Android launcher-foreground densities, `mipmap-xxxhdpi/ic_launcher.png`, and three iOS app-icon sizes. **These are Play Store and App Store submission blockers, not code problems.**

Recovery sources, in order: `visionmusic.apk` (118 MB, unzips as an archive), `Desktop/Backups & Archives`, then regeneration from `visionlogo.jpg` (1024×1024, intact).

There is also a **stash from before the recovery** — `stash@{0}: WIP on main: 7bf2e22` — which has not been inspected and may hold work. Do not drop it.

---

## 3. High-priority findings

### H1 — iOS background audio is not enabled

`ios/Runner/Info.plist` has **no `UIBackgroundModes` key**. Without `<string>audio</string>`, iOS suspends playback the moment the app backgrounds, and `audio_service` cannot present lock-screen controls. One-line plist fix; macOS and Android are correctly configured.

### H2 — `flutter test` currently fails

`test/widget_test.dart` is still the untouched Flutter counter template — it pumps `AppBootstrapper` and looks for a `+` icon that has never existed. Any CI you add will be red from day one.

### H3 — Firestore and Storage have no security rules in the repo

No `firestore.rules`, `storage.rules`, or `firestore.indexes.json` anywhere, and `firebase.json` contains only FlutterFire platform config. Whatever rules exist live only in the console and are, in all likelihood, still the 30-day test-mode defaults. **The Firebase `apiKey` values in `firebase_options.dart` are client identifiers and are safe to commit — security rules are the actual boundary, and right now that boundary is unversioned and unreviewed.** This must be closed before Phase 2 puts real user data in Firestore.

### H4 — The Firebase project looks like a scratch project

**[RESOLVED 2026-08-12 — app repointed to `visionmusic-dev`.]** `projectId: device-streaming-6b79dd0d` was an auto-generated Firebase Studio / device-streaming identifier, not a deliberately named production project. Separately, the **macOS app is registered with the iOS `appId`** (`1:543708513948:ios:cac17d5f49c12db9f04f59` appears under both platforms in `firebase.json`), which will misattribute analytics and can break platform-scoped App Check later. Plan a proper `vision-music-prod` project with separate dev/prod environments before launch.

### H5 — Queue-management methods contradict the single-source model

`addToQueue`, `playNext` and `removeFromQueue` all call `_rebuildAudioSourcePreservingPosition()` (line 282), which rebuilds a **`ConcatenatingAudioSource` of the entire catalog** — the exact preloading behaviour that was deliberately removed from `playAtIndex`. Two incompatible models coexist in one class: adding a song to the queue silently reverts the player to full-playlist preloading and re-scrambles index semantics. `ConcatenatingAudioSource` is also deprecated in `just_audio` 0.10.x.

### H6 — Autoplay and repeat are silently dead

- `_player.hasNext` is always `false` with a single source, so the completion handler at line 84 **never advances** — when a track ends, playback simply stops even with autoplay on.
- `LoopMode.all` on a one-item source loops that same song forever instead of cycling the playlist.
- `setShuffleModeEnabled` is meaningless on a single source; shuffle is a no-op.

Manual Next/Previous work (they call `playAtIndex` directly). Everything automatic does not.

### H7 — `Song` has no `==` / `hashCode`

`playSong` relies on `_queue.indexOf(song)`, and `addToQueue`/`removeFromQueue` on `contains`. This works **only** because `mockSongs` are compile-time `const` and Dart canonicalises identical const instances. The moment the catalog comes from Firestore (Phase 2), every `Song` becomes a fresh non-const object, `indexOf` returns `-1`, and `playSong` silently falls into `setQueue([song])` — **destroying the user's queue on every tap.** This is a latent bug that will detonate exactly when you switch on `AppConfig.useFirebaseCatalog`.

### H8 — Song durations are never populated

`Song.duration` defaults to `Duration.zero` and no catalog entry sets it, so every `MediaItem` reports zero length and the lock-screen scrubber is unusable until the track loads. Real durations are known and listed in §6.

---

## 4. Medium and low findings

| # | Finding | Location |
| --- | --- | --- |
| M1 | Broken asset reference — `assets/images/hirphaa.jpg` no longer exists on disk | `lib/mock_videos.dart:65` |
| M2 | Two zero-byte PNGs are bundled into every build | `assets/images/bg_gold_4k.png`, `vision_icon_foreground.png` |
| M3 | Duplicate audio — `Nuho gobana.mp3` and `nuho_gobana.mp3` are byte-identical (md5 `b8cdc288…`), 6.9 MB wasted; only the underscored one is referenced | `assets/audio/` |
| M4 | `AudioSession` is configured *after* `AudioService.init()` and after the player is built; it should come first | `lib/main.dart:55-65` |
| M5 | The position listener republishes `playbackState` on every tick (~10×/sec), thrashing the media notification | `lib/audio/audio_handler.dart:50` |
| M6 | 48 uses of the deprecated `Color.withOpacity()`; also 10 × `onBackground`, 2 × `MaterialStateProperty` | across `lib/` |
| M7 | Missing `mipmap-xxxhdpi/ic_launcher.png` and 4 of 5 `ic_launcher_foreground` densities — icons will upscale from lower densities | `android/app/src/main/res/` |
| M8 | `AudioService` declares no `MediaBrowserService` intent-filter — blocks Android Auto / Wear later | `AndroidManifest.xml` |
| M9 | AI service keys are `static const` placeholders in client code — the wrong pattern even unfilled; these belong behind Cloud Functions | `lib/services/*_service.dart` |
| M10 | `Directionality` is forced app-wide from `settings.localeCode == 'ar'`, overriding per-locale direction rather than letting `MaterialApp` derive it | `lib/main.dart:167` |
| M11 | 22 dead `lib/_archive/` files plus `backup-catalog-fix/`, `Info.plist.bak`, `.bak2`, `Podfile.save` — analyzer-excluded but confusing | project root |
| M12 | `_audioManager` is never disposed; `AppBootstrapper` has no `dispose()` | `lib/main.dart` |
| M13 | `build/` is 4.2 GB, `.dart_tool/` 236 MB — a `flutter clean` reclaims ~4.4 GB without touching source | project root |

**Not a problem, checked and cleared:** `android/app/upload-keystore.jks` and `android/key.properties` exist on disk but are correctly excluded by `.gitignore` and confirmed **not tracked** by git. Signing config is properly externalised. No real secrets found in source.

---

## 5. Assessment

The recovery worked. The architecture is sound — a single `AudioPlayer` owned by `AudioManager`, with `VisionAudioHandler` wrapping that same instance rather than creating a second one, is the correct `just_audio` + `audio_service` pattern, and it means **there is no background-vs-direct playback conflict.** Localisation (6 locales, all ARBs present), theming, the repository abstraction with feature flags, and the feature-folder layout are all in good shape.

What is broken is a small, tight cluster in `audio_manager.dart` created by the single-source migration: the queue-index model was changed but the four things that depended on it — `currentSongStream`, autoplay, repeat/shuffle, and the queue-rebuild path — were not updated with it. C1 and C2 together fully explain "playback appears broken," and both are small, low-risk fixes.

**Nothing found requires an architecture rewrite.** C1–C4 plus H1 are roughly a day of careful work.

---

## 6. Verified audio inventory

| File | Container | Codec | Rate | Duration | Referenced as |
| --- | --- | --- | --- | --- | --- |
| `nuho_gobana.mp3` | MP3 | mp3 | 48 kHz | 5:00 | Markato — Ali Birra |
| `Nuho gobana.mp3` | MP3 | mp3 | 48 kHz | 5:00 | *(duplicate, unused)* |
| `hirphaa.mp3` | MP3 | mp3 | 48 kHz | 4:02 | Hirphaa |
| `yosan_getahun.mp3` | MP3 | mp3 | 44.1 kHz | 5:13 | 3Obsaa → **Obsa** |
| `daraara-lagaa.mp3` | MP3 | mp3 | 48 kHz | 4:50 | Lagaa — artist unverified |
| `shagoye.mp3` | MP3 | mp3 | 44.1 kHz | 3:19 | Marartuu — Shukri Jamal |
| `kuyubisaa.mp3` | MP3 | mp3 | 44.1 kHz | 5:37 | Kuyubisaa — Asanti |
| `alibiyyanqabaa.mp3` | MP3 | mp3 | 48 kHz | 3:59 | Alibiyyanqabaa — Naaima |
| `gungume_andualem_gosa.mp3` | MP3 | mp3 | 44.1 kHz | 5:10 | Gumgume — Andualem Gosa |
| **`lagaa.mp3`** | **M4A** | **aac** | 44.1 kHz | 4:33 | **unused — broken extension** |

Nine of ten decode cleanly. Every referenced audio path resolves to a real, valid file.

---

## 7. Phased plan

### Phase 1 — Stability (~1 week)

| # | Task | Complexity | Risk | Depends on |
| --- | --- | --- | --- | --- |
| 1.1 | Un-block `playAtIndex` — stop awaiting `play()` (**C1**) | Trivial | Very low | — |
| 1.2 | Rebuild `currentSongStream` from `_currentIndex` (**C2**) | Small | Low | 1.1 |
| 1.3 | Correct the off-by-one cover mapping + `3Obsaa`→`Obsa` (**C3**) | Trivial | Very low | **Your decision on Davo/Hirphaa** |
| 1.4 | Re-encode or rename `lagaa.mp3` (**C4**) | Trivial | Very low | — |
| 1.5 | Add `UIBackgroundModes: audio` to iOS plist (**H1**) | Trivial | Very low | — |
| 1.6 | Fix autoplay/repeat/shuffle for the single-source model (**H6**) | Medium | Medium | 1.2 |
| 1.7 | Reconcile queue methods with the single-source model; drop `ConcatenatingAudioSource` (**H5**) | Medium | Medium | 1.6 |
| 1.8 | Add `==`/`hashCode` to `Song`, key on `id` (**H7**) | Trivial | Low | — |
| 1.9 | Populate durations from §6 (**H8**) | Trivial | Very low | — |
| 1.10 | Replace the template test; add catalog + playback-state tests | Medium | Low | 1.1, 1.2 |
| 1.11 | Fix `mock_videos.dart:65`; remove zero-byte and duplicate assets | Trivial | Very low | — |
| 1.12 | Order `AudioSession` before `AudioService.init`; throttle position updates | Small | Low | — |
| 1.13 | Loading and error states for catalog load and audio failure | Medium | Low | — |
| 1.14 | `withOpacity` → `withValues` codemod, then `onBackground` (**M6**) | Small ×48 | Low | do last |
| 1.15 | Recover store assets from the APK; regenerate launcher icons (**C5**) | Medium | Low | — |
| 1.16 | Verify macOS, Android and web builds | Medium | — | all above |

**Order:** 1.1 → 1.2 → verify audibly → 1.3–1.5, 1.8, 1.9, 1.11 → 1.6, 1.7 → 1.10 → 1.12, 1.13 → 1.15 → 1.14 → 1.16. The app stays runnable after every step.

### Phase 2 — Music platform (6–10 weeks)

Prerequisites, in this order: a real Firebase project (**H4**); versioned `firestore.rules` + `storage.rules` with an emulator test suite (**H3**); then the `Song` equality fix (**H7**) *before* flipping `AppConfig.useFirebaseCatalog`, or queues will break on every tap.

Then: Auth (email + Google, Apple Sign-In required by App Store when Google is offered) → profiles → Firestore catalog → Storage/CDN media → favourites, playlists, recently-played → search → artist/album pages → lyrics → history and recommendations.

**Main risks.** Streaming from Firebase Storage will dominate cost — budget a CDN (Cloudflare R2 or Bunny) rather than serving audio from Storage directly. Offline downloads need encrypted local storage and a licence model, or you have a piracy problem. Recommendations should stay rule-based (genre/artist adjacency) until you have real listening data.

### Phase 3 — Video and social (8–12 weeks)

Music videos → short-form vertical feed → artist uploads → likes/comments/follows/shares → creator profiles and verification → notifications (FCM) → **moderation and reporting** → admin dashboard.

**Moderation is not optional and not last.** The moment users can upload, both app stores require reporting, blocking and a takedown path. Build it alongside upload, not after. Transcoding needs a real pipeline (Mux or Cloudflare Stream over self-hosted FFmpeg). A vertical video feed is the single hardest performance problem in the roadmap — preloading, recycling and cache eviction all need dedicated work.

### Phase 4 — Super app (6+ months)

Radio and podcasts → live events and ticketing → subscriptions, merchandise and creator monetisation → payments → ads → analytics → regional discovery.

**Payments are the gate.** Telebirr, CBE Birr and M-Pesa each need a local entity, licensing and settlement — start legal groundwork a year before launch. Apple and Google take 15–30% on in-app digital goods and forbid steering to external payment for digital content, which collides directly with local rails; this needs a deliberate strategy, not a late discovery. Ticketing and merchandise are physical goods and are exempt.

### Security requirements (running through every phase)

Versioned Firestore/Storage rules with emulator tests · App Check on all Firebase services · server-side validation in Cloud Functions, never client-side trust · all third-party API keys behind Functions (**M9**) · signed, expiring media URLs · rate limiting on uploads and search · PII minimisation and a data-deletion path (GDPR Art. 17, and both stores now require in-app account deletion) · keystore and service accounts in a secret manager, never in git · dependency scanning in CI.

---

## 8. Runbook — commands for your Mac

I cannot run these; paste the output back and I will work from it.

```bash
cd ~/Desktop/visionmusicapp

# 1. Analysis (expect withOpacity deprecations; look for errors)
flutter --version
flutter analyze 2>&1 | tee /tmp/analyze.txt
tail -5 /tmp/analyze.txt

# 2. Tests (H2: expect failure — template test)
flutter test 2>&1 | tail -30

# 3. Reclaim ~4.4 GB (safe: build artefacts only, no source)
du -sh build .dart_tool
flutter clean && flutter pub get

# 4. macOS run with full logs — the key step
flutter run -d macos -v 2>&1 | tee /tmp/macos_run.log
#    In the app: tap a song on Discover.
#    EXPECT (pre-fix): audio starts, Now Playing does NOT open  ← confirms C1
#    Then: grep -iE "error|exception|-11849|AVFoundation" /tmp/macos_run.log

# 5. Clear metadata and re-sign ONLY the built bundle (never the project)
APP=build/macos/Build/Products/Debug/VisionMusic.app
xattr -cr "$APP"
codesign --force --deep --sign - "$APP"
codesign --verify --verbose "$APP" && open "$APP"

# 6. Android readiness
flutter devices
flutter build apk --debug 2>&1 | tail -30

# 7. Web
flutter build web 2>&1 | tail -20

# 8. CocoaPods warnings (H4/deployment targets)
cd macos && pod install 2>&1 | tail -30 && cd ..

# 9. Inspect the pre-recovery stash — DO NOT DROP IT (C5)
git stash show -p stash@{0} | head -100

# 10. Recover store assets from the APK (C5)
mkdir -p /tmp/apk && cd /tmp/apk && unzip -o ~/Desktop/visionmusicapp/visionmusic.apk > /dev/null
find . -path "*mipmap*" -name "*.png" -o -name "*launcher*" | head -30
```

---

## 9. Decisions I need from you before Phase 1 starts

1. **Lagaa.** `davo.jpg` is a Tekalign Tena poster and `daraara-lagaa.mp3` suggests Daraaraa. Who is the artist, and which cover is correct?
2. **Hirphaa's cover.** Use the Vision Music logo as an explicit placeholder, or do you have the correct image?
3. **`3Obsaa` → `Obsa`.** The cover art prints "OBSA!" — shall I correct the title?
4. **Tekalign Tena.** `davo.jpg` is real cover art for a song not in the catalog. Add the track, or leave the image unused?
5. **Firebase project.** ~~Migrate off `device-streaming-6b79dd0d` to a purpose-built project now, or defer to the start of Phase 2?~~ **Answered 2026-08-12: migrated to `visionmusic-dev`. A separate production project is still required before launch.**

---

## 10. Recommended next step

Fix **C1 and C2** first — perhaps thirty lines across one file, no dependencies, no migration risk, and together they turn a seemingly broken player into a working one. Then run the §4 macOS test and confirm audibly before anything else changes.

I have not modified a single source file. Say the word and I will start with C1 and C2.
