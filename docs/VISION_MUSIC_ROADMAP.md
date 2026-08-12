# Vision Music — Roadmap

**Date:** 11 August 2026
**Companion to:** `VISION_MUSIC_MASTER_AUDIT.md`

Three horizons. The discipline that matters is not what goes in NOW — it is what is kept out of it.

---

## NOW

*Ship-blocking. Everything here is small, and most of it is not code.*

**Updated 11 Aug 2026, 02:35.** Several items previously in this section are done and have been
removed rather than left ticked — a roadmap full of completed work stops being read.

### Close the last runtime checks — owner only

**Updated 02:50.** `flutter analyze` 11/0/0, `flutter test` 26/26. Playback, auto-advance,
**audibility and repeat are confirmed** — the last two by the owner, by ear. What remains:

- **Shuffle.** The one core playback path never exercised. `toggleShuffle`, `cycleRepeatMode` and
  `_relativeIndex` now log to `[VM-AUDIO]`, so a single tap on the shuffle icon prints the resulting
  play order — no screen-reading required.
- **Physical iPhone:** background audio, lock-screen metadata and controls, Bluetooth. The simulator
  is not a valid surface for any of these.
- **Lyrics empty state.** One tap. Lowest value of the three.

### Get 8 more testers opted in

Google needs 12 testers opted in *continuously* for 14 days before the Play production button
unlocks. 12 invited, 4 opted in. **The clock has not started** and cannot until the 12th completes
opt-in at `https://play.google.com/apps/testing/com.visionmusic.app`, on the same Google account
they were invited with — which is where most people fail.

Invite 15 or 16, not exactly 12. One person uninstalling on day 9 costs the whole run.

**This remains the single longest-lead item in the project and requires no engineering.** It runs in
parallel with everything else. Start it before any further code work.

### Push a current build to closed testing

Testers are on the April build, which predates every fix in the audit. Bump above `1.0.0+3` — Play
rejects duplicate version codes.

### Deploy the security rules — to dev first

`firestore.rules` and `storage.rules` are written, least-privilege and default-deny, but
**undeployed**. Deploy to `visionmusic-dev`, test with the emulator, and only then to production.
Rules that deny too much are a bug found in minutes; rules that allow too much are a breach found
much later.

### Capture 10-inch tablet screenshots

Required field, currently empty, not recoverable from the APK.

### Install Android SDK command-line tools

Android Studio → SDK Tools → **Android SDK Command-line Tools (latest)**. Without it there is no
`sdkmanager` or `avdmanager`, so no emulator can be created. **Android has never been run.**

---

## NEXT

*Weeks. Real engineering, in dependency order.*

### Remove the temporary `[VM-AUDIO]` diagnostics

Only once repeat and shuffle are RUNTIME VERIFIED. They are debug-only and harmless, but they are
scaffolding and should not become permanent.

### Extract play order into a testable class

Shuffle, repeat and next/previous logic currently lives inside `AudioManager`, which cannot be
constructed in `flutter test` because it creates a real `AudioPlayer` needing platform channels.
Pulling the ordering into a pure class would make the most failure-prone logic in the app unit
testable. **Wait until repeat and shuffle are verified** — refactoring unverified behaviour hides
which change broke what.

### Move to a real Firebase project

**[Resolved 2026-08-12: app repointed to `visionmusic-dev`.]** `device-streaming-6b79dd0d` was an auto-generated scratch project and macOS is registered under the
iOS appId. Plan is written in `docs/FIREBASE_MIGRATION_PLAN.md`. **Do this before Firestore becomes
the live catalogue, not after.**

### Turn on the Firestore catalogue

`AppConfig.useFirebaseCatalog` is `false`. Flipping it is now safe — `Song` has proper equality, so
the queue no longer breaks when songs stop being compile-time constants. Security rules first.

### Import the 187-video channel catalogue

The Watch tab shows twelve fictional entries while the channel has 187 real videos.
`HANDOFF_PROMPT_YOUTUBE.md` is written and ready. `displayThumbnail` already falls back to YouTube
poster frames, so imported videos get artwork with no manual work.

### Localise the 39 hardcoded strings

Six ARB files exist and are wired correctly, but 39 `Text('...')` literals bypass them entirely.
A six-language app that is only partly translated is worse than an honest one-language app.
**Afaan Oromo translations need a native speaker's review** — do not ship machine output as final.

### Archive the five dead services

`AITranslationService`, `AudioLanguageDetectionService`, `MusicMetadataAIService`,
`ScriptConversionService`, `SearchEnhancementService` and `FirestoreSongModel` are referenced by
nothing outside their own files. Prove no dynamic or generated references exist, then **move to a
documented archive location rather than deleting.**

Two still contain `_geminiApiKey` constants. They are unfilled and guarded, but they look like
fields waiting to be filled in — and a key pasted there ships inside the app bundle.

## LATER

*Architect for these now; build them when there is demand and data.*

### Downloads and offline playback

The highest-value feature for your actual audience. Ethiopian mobile data is expensive, and offline
is the difference between an app people try and an app people keep. Requires encrypted local
storage and a licensing position — an unencrypted download folder is a piracy problem, not a
feature.

### Media delivery on AWS

S3 for storage, **CloudFront for delivery** — S3 alone has no edge caching and expensive egress,
and CloudFront has edge locations in Nairobi, Johannesburg and Lagos. Keep Firebase for auth and
metadata; use AWS only for media. The real work is a Lambda that mints short-lived signed URLs.
**AWS credentials must never ship in the app.** Video additionally needs MediaConvert and HLS —
a 500 MB MP4 will not play on mobile data.

### Artist and album pages

The catalogue model already carries `albumTitle` and `genre`. Build these when the catalogue is
large enough that browsing beats searching.

### Recommendations

Start rule-based — genre and artist adjacency over real listening history. Do not claim AI
recommendations without the data to support them; users notice immediately.

### Oromo discovery as a curated surface

This is the actual differentiator, and it is a **metadata and curation** problem far more than a
code one. Design the schema so an administrator can curate Oromo Classics, Emerging Artists,
Traditional and Regional sections. Do not hardcode the categories.

### Lyrics

Future feature only. Depends on artist-provided or licensed data (artist/label-supplied lyrics or a licensed provider such as Musixmatch/LyricFind). Do not scrape, and do not generate/invent. Historical note (2026-08-11): the app previously shipped fabricated English lyrics presented as real; that has been removed — `LyricsService` now returns an honest unavailable state, and the fabricated content is preserved only as a recovered backup, not active app content. See audit P2-15.

### Video and social

Short-form, uploads, follows, comments. **Moderation and reporting are not optional and not last** —
both app stores require them the moment users can upload. Build them alongside upload, never after.

### Monetisation

Apple and Google take 15–30% on in-app digital goods and forbid steering to external payment for
digital content. That collides directly with Telebirr, CBE Birr and M-Pesa, each of which needs a
local entity and licensing. **Start the legal groundwork roughly a year before you need it.**
Ticketing and merchandise are physical goods and exempt.

---

## The one thing to hold onto

The temptation with a brief this large is to build in every direction at once. Vision Music does not
need to match Spotify feature for feature — it will lose that race, and it is the wrong race.

Its advantage is a catalogue and a community nobody else is serving properly. **A fast, reliable
player with excellent Oromo discovery and offline support beats a feature-complete app that stutters
on a 3G connection in Adama.** Spend the effort there.
