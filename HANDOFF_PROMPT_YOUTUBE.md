# Prompt for OpenClaw — import the whole channel into the video catalog

Copy everything below the line into OpenClaw.

---

Good work collecting the channel. You have 187 public videos, full titles, and
the channel ID `UCUMRvDa74KYAovuMM21_Iag`. **Change of plan: stop matching the
twelve placeholders and import the whole channel instead.**

Twelve hand-written demo entries were only ever a stand-in for real content.
You now have 187 real videos. Filling in twelve of them and discarding the rest
would throw away the entire catalog.

**Project:** `/Users/birragemedi/Desktop/visionmusicapp`
**Target file:** `lib/mock_videos.dart`

## Something changed while you were working

`Video.displayThumbnail` now falls back to YouTube's own poster frame before
the brand logo. **So imported videos need no artwork from you.** Set
`thumbnailUrl` to `null` and every video gets its real thumbnail automatically,
at `https://img.youtube.com/vi/<id>/hqdefault.jpg`. Every screen in the app
already branches correctly between asset paths and network URLs.

Do not set `thumbnailUrl` to a local asset for imported videos. Leave it null.

## Rules

- **Back up first:** `cp lib/mock_videos.dart lib/mock_videos.dart.pre-import`
- **Do not `git reset`, `git checkout --`, `git stash drop`, or `git clean`.**
  The repo has 59 missing blobs and no remote. Anything discarded is gone.
- **Do not delete** anything under `assets/`, `_recovered-from-apk/`,
  `_audit-backup-20260810-210827/`, `backup-catalog-fix/`, `lib/_archive/`.
- **Do not add a YouTube API key** anywhere in the project.
- **Import the 187 public videos only.** Do not sign in to YouTube, and do not
  try to reach the 12 videos that are unlisted, private or members-only. The
  owner has decided those stay out of the app. A logged-out browser is correct.
- **Do not invent metadata.** No made-up durations, view counts or release
  dates. Omit what you do not know — the model allows nulls.
- Edit only `lib/mock_videos.dart`.

## Step 1 — Replace the catalog

Rewrite `final List<Video> mockVideos` with one entry per channel video:

```dart
  Video(
    id: 'yt_8zlm6JVbi2U',
    title: '<exact title from the channel>',
    artistName: '<parsed artist, see below>',
    thumbnailUrl: null,
    videoUrl: 'https://www.youtube.com/watch?v=8zlm6JVbi2U',
    category: '<see below>',
  ),
```

Use `yt_<videoId>` for ids — unique, stable, and it makes the source obvious.

**Keep the two getters at the bottom of the file** (`featuredVideos` and
`mockVideosByCategory`) exactly as they are. Other files import them.

## Step 2 — Artist names

Most YouTube titles follow `Artist - Song Title` or `Artist | Song Title`. Take
the part before the separator, trimmed.

When there is no separator, or the result looks like a song title rather than a
person, use `'Vision Entertainment'`. **Do not guess an artist name.** A wrong
artist is worse than a generic one — this project has already had one incident
where content was assigned to the wrong artists by assumption.

Strip common noise from titles for the artist field only: `New Oromo Music
2024`, `Official Video`, `Official Music Video`, `4K`, `HD`. Leave the `title`
field exactly as YouTube has it.

## Step 3 — Categories

Assign by keyword on the lowercased title. Use exactly these ids:

| Category id | Match on |
| --- | --- |
| `live_performances` | live, concert, stage, performance |
| `studio_sessions` | studio, session, cover, acoustic, behind the scenes |
| `interviews` | interview, gaaffii, conversation, talk |
| `podcast_clips` | podcast, episode, ep. |
| `oromo_classics` | classic, old, tribute, memorial, legend |
| `new_releases` | 2025, 2026, new single, new release |
| `music_videos` | **everything else — this is the default** |

Set `isFeatured: true` on the six most recent videos only. Leave the rest false.

## Step 4 — Verify

```bash
cd /Users/birragemedi/Desktop/visionmusicapp
flutter analyze 2>&1 | tail -20
grep -c "Video(" lib/mock_videos.dart
grep -c "REPLACE_" lib/mock_videos.dart
```

Expect zero new errors, roughly 187 `Video(` entries, and zero `REPLACE_`.
About 48 `withOpacity` deprecation infos are known — ignore those.

Then run it and confirm the Watch tab shows real thumbnails rather than a wall
of identical logos:

```bash
flutter run -d macos
```

## Step 5 — Report

1. How many videos imported, and the per-category counts
2. Any video where you could not determine an artist and used the fallback
3. Confirmation that thumbnails render as real YouTube posters
4. `flutter analyze` result

## Leave the songs alone

You already added three `youtubeUrl` values to `lib/mock_songs.dart`
(`yosan_getahun`, `shagoye`, `andualem_gosa`). **Keep those and add no more
for now.** The owner wants to review those three pairings before the rest are
matched. Song–video matching is the error-prone half; the catalog import is not.
