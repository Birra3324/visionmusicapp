# Screenshots

This listener repo does not contain product UI screenshots. `assets/images/` holds artist artwork and the launcher mark. Those are catalog assets, not app captures, so they are not used here as demo shots.

No `_demo_screenshots` or `store_prep` folder is in this tree.

## Already public

The marketing site repo has one home-screen capture, used on [visionmusic.et](https://www.visionmusic.et):

- [screen-home.png](https://github.com/Birra3324/visionmusic-site/blob/main/assets/img/screen-home.png) — Home, from [visionmusic-site](https://github.com/Birra3324/visionmusic-site)

That file stays in the site repo. It is not copied here.

## Capture the listener demo

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
