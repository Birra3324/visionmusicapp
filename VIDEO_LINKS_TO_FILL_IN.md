# Video links — fill these in and the video side switches on

Vision Music already has a complete music-video system. It is dormant for one
reason: **no real links have ever been added.** Paste YouTube URLs into the
tables below and send this file back, and I will wire all of it in one pass.

Any format works — I parse `watch?v=`, `youtu.be/` and `/shorts/`:

```
https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://youtu.be/dQw4w9WgXcQ
```

Leave a row blank if there is no video. Blank rows now show **"Coming soon"**
instead of opening a dead player.

---

## 1. Music videos for the 8 songs in the audio catalog

This is the feature that makes it a music *and* video app: a YouTube button
appears on each song row, so people listening can jump to the video.

`lib/widgets/song_row.dart` already renders this button, opens the link, and
the Firestore repository already reads the field. **Not one song sets it**, so
the button has never appeared for anyone. One paste per row turns it on.

| # | Song | Artist | YouTube URL |
| --- | --- | --- | --- |
| 1 | Markato | Ali Birra | |
| 2 | Hirphaa | Hirphaa Gaanfuree | |
| 3 | 3Obsaa | Yosan Getahun | |
| 4 | Lagaa | Davo *(artist unconfirmed)* | |
| 5 | Marartuu | Shukri Jamal | |
| 6 | Kuyubisaa | Asanti | |
| 7 | Alibiyyanqabaa | Naaima Abdurahman | |
| 8 | Gumgume | Andualem Gosa | |

---

## 2. The 12 videos in the Watch tab

Every one of these currently has a placeholder URL such as
`https://www.youtube.com/watch?v=REPLACE_ALI_BIRRA_MARKATO`. They look like
real content in the UI and do nothing when tapped.

| # | Video | Artist | Category | YouTube URL |
| --- | --- | --- | --- | --- |
| 1 | Markato | Ali Birra | Music video | |
| 2 | 3Obsaa | Yosan Getahun | Music video | |
| 3 | Marartuu | Shukri Jamal | Music video | |
| 4 | Live at Finfinne | Hirphaa Gaanfuree | Live | |
| 5 | Kuyubisaa — Acoustic | Asanti | Live | |
| 6 | Studio session | Andualem Gosa | Studio | |
| 7 | Interview | Yosan Getahun | Interview | |
| 8 | Interview | Shukri Jamal | Interview | |
| 9 | Podcast | Davo | Podcast | |
| 10 | Documentary | Ali Birra | Documentary | |
| 11 | Documentary | Shukri Jamal | Documentary | |
| 12 | New release | Naaima Abdurahman | New release | |

If your channel has videos not in this list, add rows at the bottom — artist,
title, category, URL — and I will create the entries.

---

## 3. Optional — auto-import your whole channel

Instead of filling in the tables, I can fetch everything from
`@visionentertainment4507` automatically. That needs two things:

- **Channel ID** — YouTube Studio → Settings → Channel → Advanced. Starts `UC…`
- **A YouTube Data API v3 key** — Google Cloud Console

Say the word and I'll set it up, but **do not paste the API key to me or put it
in the app.** Anyone can extract a key from a shipped app and run up your quota.
It belongs in a Cloud Function that the app calls. `lib/core/services/youtube_config.dart`
currently has a `static const String? apiKey` field designed to hold it directly
— that field should be removed rather than filled in.

Trade-off worth knowing: auto-import gives you everything with no manual work,
but you lose control over categories, ordering and which videos appear. The
tables above give a curated app. Most services do both — curated shelves on top,
full catalog underneath.

---

## What I already changed

You do not need to do anything for these:

- Unpublished videos now show **"Coming soon"** instead of a spinner that
  resolves into a network error.
- No video controller is created for a URL that cannot resolve.
- Added `isPlayable`, `youtubeId`, `youtubeThumbnailUrl` and `bestThumbnail` to
  the `Video` model. `bestThumbnail` means any video with a real YouTube link
  gets its poster frame automatically — no artwork needed from you.
