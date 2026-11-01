# Screenshots

Captured 2026-11-01 from a release web build (`flutter build web`), guest mode, bundled catalog, 430×932 viewport.

| File | Screen |
| --- | --- |
| `01_login.png` | Login card: Continue as Guest, optional Google Sign-In |
| `02_home.png` | Home: Trending Now, Listen and Watch, track list |
| `03_player.png` | Now Playing for **Markato** (Ali Birra) |
| `04_library.png` | Library: favorites, recently played, collection |
| `05_search.png` | Search with suggestion chips |

No Firebase console, terminal, or credential files appear in any frame.

## Recapture

Run the [walkthrough](../demo.md) (`flutter run -d chrome` or a device), then save PNGs into this folder. Suggested names and captions:

| File | When to capture | Caption |
| --- | --- | --- |
| `01-login-guest.png` | Login card before entering the app | Continue as Guest. Google Sign-In is optional. |
| `02-now-playing.png` | After tapping **Markato** | Now Playing for a bundled track. |
| `03-library-favorites.png` | Library after tapping the heart on a row | Favorites stored on this device. |
| `04-search-ali-birra.png` | Search with the **Ali Birra** chip | Local catalog search, no admin tools. |

On Chrome: the device frame is the browser window. Crop to the app. On Android or iOS, use the platform screenshot shortcut.

Do not include Firebase console, terminal secrets, `google-services.json`, or a service-account file in the frame.

After the PNGs are in this folder, link them from [the README](../../README.md) and [docs/demo.md](../demo.md) with the captions above.
