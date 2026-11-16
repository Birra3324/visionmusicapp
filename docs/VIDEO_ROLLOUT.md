# Vision Music: audio and YouTube first

## Owner direction — November 15, 2026

Most listeners are in Ethiopia, with additional listeners in the United States
and Europe. Prioritize mobile data use, low operating costs, and a simple first
release. Birra confirmed the channel https://www.youtube.com/@visionentertainment4507.

## First release

- Keep Listen for original or licensed audio tracks.
- Offer a visible link to the confirmed YouTube channel on Watch. Keep the link
  available when the app catalog is loading, empty, or unavailable.
- Keep individual video links opening YouTube. Pause app audio after opening the
  channel so music does not overlap with YouTube playback.
- Do not autoplay or preload video. A channel link does not synchronize channel
  uploads into the app catalog and does not require YouTube account permissions.
- A paid video-storage/transcoding backend is not a dependency for this version.
  Existing backend work remains available for later phases. Audio hosting is a
  separate release decision; this change does not migrate or publish audio.

## Recommended second phase

Embed YouTube's official player inside Watch, retaining YouTube branding,
controls, and advertising. Use a curated video/playlist list first and add
channel synchronization only when needed. Keep an Open in YouTube fallback for
videos that cannot be embedded. Configure and verify the embedding app identity
on web, iOS, and Android; do not extract direct streams from YouTube.

The audio player must use original/licensed audio files, not audio extracted
from YouTube or a hidden background YouTube player. Offline audio is only for
files we have permission to distribute. Embedded YouTube video remains online.

## Data use and later hosting

- Recommended audio options: Data Saver (64 kbps AAC) and Standard (128 kbps),
  subject to listening tests. These are targets, not implemented features.
- At a constant 64 kbps, an hour is about 28.8 MB before network overhead.
- Let listeners opt into video. YouTube controls its playback quality; the app
  must not promise a forced resolution or a precise data cap for YouTube video.
- Test startup/buffering with real listeners on Ethiopian mobile connections,
  in addition to network throttling in development.
- Evaluate Cloudflare R2 Standard for original audio: currently 10 GB-months,
  1 million Class A operations and 10 million Class B operations free monthly,
  with no egress bandwidth charges. Requests/storage above allowances cost money.
  Use a production custom domain and caching; r2.dev is for development.
- If independent video hosting becomes necessary, compare providers using actual
  delivered minutes. Cloudflare Stream currently starts at $5/month per 1,000
  stored minutes, plus $1 per 1,000 delivered minutes. This is an example, not a
  selected or activated service. No paid service has been enabled by this plan.

## Sources checked November 15, 2026

- https://developers.google.com/youtube/player_parameters
- https://developers.google.com/youtube/terms/developer-policies
- https://developers.google.com/youtube/iframe_api_reference
- https://support.google.com/youtube/answer/91449
- https://developers.cloudflare.com/r2/pricing/
- https://developers.cloudflare.com/r2/buckets/public-buckets/
- https://developers.cloudflare.com/stream/pricing/
