# Bundled listener fonts

These fonts keep Latin, Ethiopic and Arabic listener text available without a
runtime Google Fonts request. They are distributed under the SIL Open Font
License 1.1; each family's copyright notice and license are included alongside
the font and bundled as Flutter assets.

| File | Upstream source | Flutter family |
| --- | --- | --- |
| Roboto-Regular.ttf | [Google Fonts Roboto](https://github.com/google/fonts/tree/main/ofl/roboto) | Roboto |
| NotoSansEthiopic-Regular.ttf | [Google Fonts Noto Sans Ethiopic](https://github.com/google/fonts/tree/main/ofl/notosansethiopic) | VisionEthiopic |
| NotoSansArabic-Regular.ttf | [Google Fonts Noto Sans Arabic](https://github.com/google/fonts/tree/main/ofl/notosansarabic) | VisionArabic |

On November 15, 2026, the upstream variable TTFs were converted to static regular
instances with FontTools `varLib.instancer.instantiateVariableFont`: weight 400,
with each other axis pinned to its default. Glyphs were not subsetted. The three
files total 717,920 bytes. Their combined Unicode character maps cover every
non-whitespace character in the six current UI catalogs.

Roboto must retain the exact Flutter family name `Roboto`: Flutter 3.44.4's
CanvasKit font loader fetches its own remote Roboto fallback if that family is
absent from FontManifest.json. The two Vision family names are application aliases;
the font files retain their upstream internal names. Weights other than 400 are
synthesized by the renderer. Actual future catalog content may require more glyphs.
