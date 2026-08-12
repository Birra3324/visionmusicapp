# VisionMusic Listener Analytics Event Specification

Analytics must never include names, email addresses, lyrics, raw search text,
authentication tokens, exact file URLs, or administrator information. Catalog
objects are represented by opaque IDs only.

| Event | Trigger | Parameters |
|---|---|---|
| `track_impression` | Track becomes visible on a measured surface | `track_id`, `surface` |
| `play_started` | A track is loaded and playback is requested | `track_id` |
| `play_30_seconds` | Playback reaches 30 seconds once per track/session | `track_id` |
| `play_completed` | Player reaches the end of a track | `track_id` |
| `skip` | Listener selects next/previous before completion | `track_id`, `direction` |
| `seek` | Listener moves playback position | `track_id`, `position_seconds` |
| `favorite` | Listener adds a favorite | `track_id` |
| `unfavorite` | Listener removes a favorite | `track_id` |
| `share` | Listener copies/shares a track reference | `track_id` |
| `search` | Listener submits a search | `has_results` (0/1); never query text |
| `search_result_selected` | Listener selects a result | `track_id` |
| `artist_opened` | Listener opens an artist | `artist_id` |
| `album_opened` | Listener opens an album | `album_id` |
| `playlist_add` | Listener begins adding a track to a playlist | `track_id` |
| `video_started` | Native video starts or an official YouTube link opens | `video_id` |
| `video_completed` | Native video reaches its end | `video_id` |

Implemented in `AppObservability`. Crashlytics collection is disabled for
debug builds and enabled for release builds. App Check is activated in the
client; enforcement must remain in Firebase monitoring mode until production
token metrics are reviewed.

## Remaining instrumentation

`track_impression`, `artist_opened`, and `album_opened` have typed service
methods but require stable backend IDs/surface names from the Admin API contract
before all call sites can be finalized. Do not substitute display names.
