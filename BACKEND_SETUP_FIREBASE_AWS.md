# VisionMusic Backend Setup — Firebase + AWS MediaConvert

Chosen architecture: **Firebase hosts and serves everything; AWS does transcoding only.**

```
Firebase Auth      →  login, Google sign-in, guest mode
Cloud Firestore    →  song catalog, playlists, favorites, history
Firebase Storage   →  the actual .mp3 / .m4a / artwork / video files
AWS S3             →  staging bucket for raw uploads + MediaConvert output
AWS MediaConvert   →  normalize audio, generate video renditions
```

Masters land in S3, MediaConvert transcodes them, the outputs get copied into
Firebase Storage, and Firestore stores the resulting download URLs. AWS never
serves a byte to the app.

---

## Read this tradeoff before you build it

This split works, but be aware of two costs, because they are the reason most
music apps do it the other way around.

**Egress.** Firebase Storage bills roughly $0.12/GB of download. A 4 MB track
streamed 10,000 times is about 40 GB, or ~$5. That scales linearly forever and
there is no CDN in front of it by default. S3 behind CloudFront is
substantially cheaper at volume and is the standard choice for streaming audio.
If VisionMusic gets real traction, this is the line item that will hurt first.

**A cross-cloud copy step.** Because AWS transcodes but Firebase serves, every
file has to move S3 → Firebase Storage after transcoding. That is an extra
moving part that has to be automated and can silently fail, leaving Firestore
pointing at a file that was never copied.

If you would rather avoid both, the change is small: serve from S3 + CloudFront
and put the CloudFront URL in `filePath` instead of the Firebase Storage
download URL. The app code already handles either — see
`lib/core/services/media_source_resolver.dart`. Nothing else needs to change.

Proceeding with Firebase-serves below, as chosen.

---

## Part 1 — Firebase (do this first; the app needs it either way)

### 1.1 Current state of this repo

`lib/firebase_options.dart` still contains **10 `REPLACE_WITH_` placeholders**,
and the one real project id in it was `device-streaming-6b79dd0d` (**resolved 2026-08-12: now `visionmusic-dev`**) — that was the
throwaway project Android Studio generates for device streaming, not a project
to ship on. `google-services.json` and `GoogleService-Info.plist` exist but
belong to that same scratch project.

`FirebaseBootstrap.hasPlaceholderConfig` detects this and skips
`Firebase.initializeApp()` entirely, so the app currently runs Firebase-free
and serves `lib/mock_songs.dart` from the bundle. That is why nothing is
visibly broken today.

### 1.2 Create a real project

1. Go to the Firebase console and create a project named `visionmusic`
   (or similar — not `device-streaming-*`).
2. Enable **Authentication** → Sign-in methods → Email/Password and Google.
3. Enable **Cloud Firestore** in production mode.
4. Enable **Storage**.
5. Pick a region close to your listeners and keep every service in it.
   Ethiopia and the Gulf are best served by `europe-west1` or
   `me-central1`. This cannot be changed later.

### 1.3 Wire it into the app

```bash
cd /Users/birragemedi/Desktop/visionmusicapp
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-project-id>
```

This rewrites `lib/firebase_options.dart` and replaces both native config
files. Afterwards verify no placeholders survive:

```bash
grep -c REPLACE_WITH_ lib/firebase_options.dart   # must print 0
```

Commit `google-services.json` and `GoogleService-Info.plist`. They are not
secrets — they are client identifiers, and Firebase security depends on rules,
not on hiding these files.

### 1.4 Security rules

`firestore.rules` and `storage.rules` already exist in the repo. Review them
before deploying, then:

```bash
firebase deploy --only firestore:rules,storage:rules,firestore:indexes
```

The catalog should be world-readable and admin-writable. Per-user data must be
scoped to the owner:

```
match /songs/{songId} {
  allow read: if true;
  allow write: if false;          // upload via console or Admin SDK only
}
match /users/{uid}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```

Guest mode must keep working — the app supports browsing without an account, so
do not gate `/songs` behind `request.auth != null`.

### 1.5 Storage layout

```
audio/{songId}.m4a
artwork/{songId}.jpg
video/{videoId}/master.m3u8
```

### 1.6 Flip the catalog over

`lib/core/services/app_config.dart` has two flags:

```dart
static const bool useFirebaseCatalog = false;   // ← flip to true
static const bool fallbackToLocalOnEmpty = true; // ← keep true
```

Do **not** flip `useFirebaseCatalog` until at least one real song document
exists in Firestore. Keep `fallbackToLocalOnEmpty` at `true` for the first
release so an outage degrades to the bundled catalog instead of a blank screen.

Document shape is specified at the top of
`lib/core/services/firestore_song_repository.dart`. Store **https download
URLs** in `filePath` and `imagePath`, not `gs://` references —
`gs://` artwork cannot be resolved synchronously and will fall back to the
placeholder logo.

### 1.7 Migrating the existing catalog

`lib/mock_songs.dart` holds 8 songs whose audio and artwork are bundled in
`assets/`. To move them:

1. Upload each `assets/audio/*` file to Storage under `audio/{songId}`.
2. Upload each `assets/images/*` file under `artwork/{songId}`.
3. Get the download URL for each.
4. Write one Firestore doc per song using the ids already in `mock_songs.dart`
   (`markato`, `lagaa`, etc.) so favorites and history survive the switch —
   `Song` equality is keyed on `id` alone.

Keep the bundled assets in the app for now. They are the offline fallback and
they are what makes first launch instant.

---

## Part 2 — AWS MediaConvert (transcoding only)

### 2.1 Why bother

Your source files are inconsistent: mixed `.mp3` and `.m4a`, and almost
certainly mixed loudness. MediaConvert gives you one output format and one
target loudness, so tracks stop jumping in volume between songs.

### 2.2 One-time AWS setup

1. Create two S3 buckets in the region nearest you, e.g. `eu-north-1`:
   - `visionmusic-ingest` — raw masters you upload
   - `visionmusic-transcoded` — MediaConvert output
2. Create an IAM role `MediaConvert_Default_Role` trusted by
   `mediaconvert.amazonaws.com`, with read on the ingest bucket and write on
   the transcoded bucket.
3. In the MediaConvert console, note your **account-specific endpoint**.

Block all public access on both buckets. Nothing in AWS is user-facing in this
architecture.

### 2.3 Audio job settings

Output group: **File group**, container **MP4**, codec **AAC**, 192 kbps,
48 kHz stereo. Add the **Loudness** audio normalization filter, ITU-R BS.1770-3,
target **-14 LUFS** (the streaming standard Spotify and Apple Music use).

### 2.4 Video job settings

Output group: **Apple HLS**, 6-second segments, with three renditions:

| Rendition | Resolution | Video bitrate | Audio |
|---|---|---|---|
| 1080p | 1920x1080 | 5000 kbps | AAC 128k |
| 720p  | 1280x720  | 3000 kbps | AAC 128k |
| 480p  | 854x480   | 1200 kbps | AAC 96k  |

Codec H.264, rate control QVBR. HLS is what iOS plays natively, and the
`video_player` plugin handles `.m3u8` on iOS without extra work.

### 2.5 The pipeline

1. Upload master to `s3://visionmusic-ingest/`.
2. Submit a MediaConvert job (console, CLI, or an S3-triggered Lambda).
3. Output lands in `s3://visionmusic-transcoded/`.
4. **Copy the output into Firebase Storage** — this is the cross-cloud step.
   Easiest reliable version is a small script run from your Mac using the AWS
   CLI plus the Firebase Admin SDK. Automate it before you have more than a
   handful of songs; doing it by hand is where the "Firestore points at a file
   that was never copied" failure comes from.
5. Write or update the Firestore doc with the Storage download URL.

A useful guard: before flipping a song live, fetch its `filePath` URL and
confirm it returns 200 with a non-zero content length.

### 2.6 Cost sanity check

MediaConvert bills per output minute — roughly $0.0075/min for basic audio
tiers and materially more for HLS video. Transcoding a 100-song catalog once is
a few dollars. It is a one-time cost per asset, not recurring, which is why
transcoding on AWS while serving from Firebase is defensible even though
serving from AWS would be cheaper.

---

## Part 3 — What the app code already does

`lib/core/services/media_source_resolver.dart` is the single place that decides
how a media path loads. It accepts:

| Path form | Audio | Artwork |
|---|---|---|
| `assets/audio/x.mp3` | bundled asset | bundled asset |
| `https://...` | streamed | `NetworkImage` |
| `gs://bucket/x.mp3` | resolved to a download URL at play time | falls back to logo |
| `/abs/path` or `file://` | local file | local file |
| empty / malformed | throws a clear `ArgumentError` | falls back to logo |

Before this existed, `AudioManager.playAtIndex` called
`AudioSource.asset(song.filePath)` unconditionally and seven widgets called
`Image.asset(...)`, so every remote URL would have failed the moment
`useFirebaseCatalog` was flipped on. Lock-screen artwork had the same problem in
`lib/audio/audio_handler.dart`, which loaded art through `rootBundle`.

Covered by `test/media_source_resolver_test.dart`.

---

## Ordered checklist

1. [ ] Create the real Firebase project, correct region
2. [ ] `flutterfire configure`, confirm `grep -c REPLACE_WITH_` prints 0
3. [ ] Enable Auth (Email + Google), Firestore, Storage
4. [ ] Review and deploy `firestore.rules` and `storage.rules`; verify guest mode still reads the catalog
5. [ ] Upload the 8 existing songs to Storage, write their Firestore docs with the same ids
6. [ ] Flip `useFirebaseCatalog = true`, leave `fallbackToLocalOnEmpty = true`
7. [ ] Test on device: playback, artwork, lock screen, offline, guest mode
8. [ ] Create the S3 buckets and the MediaConvert IAM role
9. [ ] Run one audio file through MediaConvert end to end and verify loudness
10. [ ] Script the S3 → Firebase Storage copy before scaling past a handful of songs
11. [ ] Re-check egress cost once you have real listening numbers

---

## Verification commands

None of the code changes in this repo have been compiled or run — no Flutter
toolchain was available where they were written. Run these on your Mac first:

```bash
cd /Users/birragemedi/Desktop/visionmusicapp
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Then on the connected iPhone:

```bash
flutter devices
flutter run -d <device-id>
```
