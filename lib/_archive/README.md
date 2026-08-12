# Archived (dead/duplicate) Dart files

These files are **not reachable** from `main.dart`. They were left over from an
earlier flat `lib/` layout before the migration to `lib/features/` and
`lib/app/`. They were moved here so the live tree is easy to read without
permanently deleting anything.

If nothing breaks after a full `flutter clean && flutter pub get && flutter run`,
you can safely delete this `_archive/` folder.

## What's here and what replaced it

| Archived path                              | Superseded by (live file)                         |
|--------------------------------------------|---------------------------------------------------|
| `top_level/home_screen.dart`               | `lib/gold_discover_screen.dart`                   |
| `top_level/library_screen.dart`            | `lib/features/library/library_hub_screen.dart`    |
| `top_level/search_screen.dart`             | `lib/features/search/search_hub_screen.dart`      |
| `top_level/profile_screen.dart`            | `lib/features/profile/profile_hub_screen.dart`    |
| `top_level/splash_screen.dart`             | `lib/features/auth/login_screen.dart` (entry)     |
| `top_level/artist_profile_screen.dart`     | `lib/artist_screen.dart`                          |
| `top_level/playlist_screen.dart`           | `lib/playlists_screen.dart`                       |
| `top_level/mini_player.dart`               | `lib/widgets/mini_player.dart`                    |
| `top_level/audio_handler.dart`             | `lib/audio/audio_handler.dart`                    |
| `top_level/playlist.dart`                  | `lib/models/playlist.dart`                        |
| `top_level/color_palette.dart`             | `lib/vision_theme.dart`                           |
| `top_level/queue_screen.dart`              | *(Not in MVP navigation)*                         |
| `top_level/video_screen.dart`              | *(Video module cut from MVP for now)*             |
| `top_level/settings.dart`                  | *(Empty file)*                                    |
| `core/audio/audio_manager.dart`            | `lib/audio_manager.dart`                          |
| `core/models/song.dart`                    | `lib/song.dart`                                   |
| `core/models/playlist.dart`                | `lib/models/playlist.dart`                        |
| `core/settings_manager.dart`               | `lib/settings_manager.dart`                       |
| `controllers/settings_controller.dart`     | `lib/settings_manager.dart`                       |
| `features_video/video_hub_screen.dart`     | *(Video module cut from MVP for now)*             |
| `models/playback_settings.dart`            | `lib/settings_manager.dart`                       |
| `widgets/mini_player_bar.dart`             | `lib/widgets/mini_player.dart`                    |
| `widgets/song_list_tile.dart`              | `lib/widgets/song_row.dart`                       |

## How to restore a file

```bash
mv lib/_archive/top_level/queue_screen.dart lib/queue_screen.dart
```
Then re-add imports wherever you want it referenced.
