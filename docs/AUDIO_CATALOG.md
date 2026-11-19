# Vision Music catalog reset — November 15, 2026

## Owner correction

All eight previous audio entries were design samples. Their names, artist photos,
audio and video pairings must not be treated as correct. No sample track is in
the listener catalog, and the app cannot fall back to them. Original sample files
remain untouched under assets/audio and assets/images; they are excluded from the
Flutter asset bundle. Tests use an explicitly labeled fixture in test/fixtures.

## Current catalog

The local audio catalog is intentionally empty until the owner saves the real
masters from Telegram. The app shows a helpful Watch action instead of sample
songs. Three independently verified videos are available on Watch:

| Song | Artist | Official video | Video length |
| --- | --- | --- | --- |
| 3Obsa | Yosan Getahun | https://www.youtube.com/watch?v=8zlm6JVbi2U | 5:29 |
| Marartuu | Shukri Jamal | https://www.youtube.com/watch?v=F1cfzTGxcCs | 3:26 |
| Gumgume | Andualem Gosaa | https://www.youtube.com/watch?v=LK0J9Au84-o | 5:19 |

Source: the public, verified Vision Entertainment channel at
https://www.youtube.com/@visionentertainment4507, inspected November 15, 2026.
Channel ID: UCUMRvDa74KYAovuMM21_Iag. The videos use their own YouTube thumbnails.
This is a small curated video catalog, not a complete channel synchronization.
These video entries establish no match to any local audio file.

## Saved playlists

Playlists now use stable song IDs instead of catalog positions. Existing playlist
names and legacy position references remain stored, but legacy sample positions
are not assigned to new songs. New saved songs retain their identity if the
catalog is reordered or a track is temporarily unavailable.

## Incoming collections

Desktop intake folder: `~/Desktop/Vision Music Audio/`

1. `01_Vision_YouTube_Masters`: published Vision masters saved from Telegram.
2. `02_Legacy_Originals`: the owner's separate collection of over 2,000 older
   songs. Preserve filenames and original directory structure.
3. `03_Remaster_Exports`: separate outputs from future remix/remaster work.
   Never overwrite originals. A remaster is not automatically the same version
   as an existing official YouTube video.

No files had been supplied to these intake folders when this reset was prepared.

## Import workflow when masters arrive

1. Inventory audio format, length, file size and checksum; detect duplicates.
2. Confirm title, credited artist, version and artwork for each file. Filenames,
   photos and similar durations alone are not proof of a song match.
3. Compare each published master with its exact official YouTube video; preserve
   audio-only entries when no matching video exists.
4. Prepare a small first batch and audition it before release. Keep uncompressed
   originals; create separate data-saving delivery versions only after listening
   checks. Avoid autoplay or preloading videos on mobile data.
5. Add reviewed entries to lib/catalog/bundled_catalog.dart and declare only
   their approved delivery assets in pubspec.yaml. Run tests and preview the batch.

## Cost and publishing

This reset enables no paid service, storage subscription, YouTube API key or
channel permissions. Videos open on YouTube on demand. No media was downloaded
or extracted from YouTube. Initial approved audio can be bundled for a small
pilot; a 2,000-song library needs a separate hosting/data-budget decision.
Daily publishing, remastering, production deployment and store submission are
not enabled by this work. The app is not audio-release-ready until real masters
and their metadata are imported and reviewed.
