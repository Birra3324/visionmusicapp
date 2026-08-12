# Vision Music — Catalog Audit (read-only)

**Author:** OpenClaw backend/cloud session
**Date:** 2026-08-11 23:30 (EAT)
**Scope:** Read-only inventory of the on-disk master audio catalog. **No files were modified, moved, renamed, transcoded, or deleted during this audit.** No service-account keys, no writes to Firebase, no `gcloud`/`firebase` operations performed.

---

## 1. Executive summary

| Metric | Value |
|---|---|
| Audio files inventoried | **521** |
| Format breakdown | 519 MP3 + 2 WAV |
| Total storage | **≈ 2.54 GB** (2,724,127,902 bytes) |
| Zero-byte (suspicious/empty) files | **0** |
| Duplicate basenames (case-insensitive) | **0** (all 521 unique) |
| Artist subfolders | 19 |
| Files with embedded title tag | 401 / 514 lowercase-mp3 |
| Files with embedded artist tag | 376 / 514 |
| Files with embedded album tag | 294 / 514 |
| Files with embedded date tag | 7 / 514 |
| Files with NO tags at all | 0 / 514 |
| Quality | Mixed, mostly 64–160 kbps; **not lossless masters** |
| Audio codec / FFmpeg tooling on Mac | `ffprobe` / `ffmpeg` available (`/opt/homebrew/bin`) |

**Caveat on scope:** The task brief cites a "2,000+" catalog. The fully-auditable on-disk catalog **this session** is the 521-file set under `~/Desktop` (see §3). The larger master set historically lives on the external `/Volumes/VISON` drive, which was **not mounted** during this audit. Figures below are for the verified 521-file set; the VISION volume reconnect is required before the 2,000+ byte-level inventory is possible.

---

## 2. Location & canonical source

Two directory entries hold an identical catalog (same 521 files, same newest-file mtime), but are **separate on-disk entries** (different inodes):

| Path | Mode | Notes |
|---|---|---|
| `/Users/birragemedi/Desktop/Music ` | `drwxr-xr-x` | **Trailing space in the name.** Newer, open perms. |
| `/Users/birragemedi/Desktop/durrii` | `drwx------` | Private perms. Byte-identical except `.DS_Store` metadata. |

The two differ only by macOS `.DS_Store`; file lists are otherwise identical.

> ⚠️ **Ingestion hazard #1 — duplicated source + trailing-space dir name.** Ingesting from both paths would double-ingest the full catalog. Ingesting from `Music ` risks path mishandling from the trailing space (many tools/targets do not tolerate a trailing space; git, most objects stores, and some scripts mangle or reject it). **Decision required before migration:** designate ONE canonical source path and rename/dedupe accordingly. Recommend canonicalizing to a clean path (e.g. `/Volumes/VISON/Music` or a new `~/VisionMusic_Catalog`) before any pipeline work.

---

## 3. Folder breakdown (19 artist-initial subfolders)

Counts are audio files directly in each folder (excluding `.DS_Store`):

| Audio files | Folder |
|---|---|
| 72 | `A B` |
| 52 | `E A` |
| 48 | `N G` |
| 34 | `New folder 1` |
| 26 | `Z W` |
| 23 | `Q Y` |
| 20 | `U M` |
| 19 | `A K` |
| 19 | `A H` |
| 14 | `U S` |
| 11 | `K M` |
| 11 | `H D` |
| 10 | `E Ad` |
| 10 | `B G` |
| 10 | `A M` |
| 9 | `U A` |
| 8 | `Sh Sh` |
| 8 | `D M` |
| 8 | `A S` |

The `K M` folder contains a nested `Kiyyaa best/` subfolder (masters/WAVs). Artist-initial groupings are **not** a substitute for structured artist/album metadata — folder names are display initials, not verified artist identities.

---

## 4. Format, codec & quality profile

- **Formats:** 519 MP3 + 2 WAV = 521.
  - 514 files have lowercase `.mp3`
  - **5 files have uppercase `.MP3`** (e.g. `Wolloo.MP3`, `Umar Suleyman (12).MP3`, `IBRAHI~1.MP3`) — a case-insensitive filesystem hides these but case-sensitive globs / object-store prefixes and some pipelines miss them.
  - 2 WAV: `K M/Kiyyaa best/Dagim Mokonnen-agadaa biraa.wav`, `K M/Kiyyaa best/A B O.wav`
- **Codec/sample rate/channels** (514 lowercase-mp3 probed): MP3 codec, sample rates **22050 Hz** and **44100 Hz**, all **stereo**.
- **Bitrate distribution (514 files):**

| Bitrate bucket | Files |
|---|---|
| 100–160 kbps | 268 |
| 64–100 kbps | 192 |
| 160–200 kbps | 32 |
| 200+ kbps | 16 |
| < 64 kbps | 6 |

> ⚠️ **Ingestion hazard #2 — source quality ceiling.** These are **not** lossless masters. A large share is 64–160 kbps MP3. **Loudness normalization and DSP can improve consistency but cannot add data** — a 56 kbps source transcends to 256 kbps AAC and gains nothing but bytes. The pipeline must record each source's original bitrate and expose it to the admin so low-quality sources are flagged for re-sourcing rather than silently "mastered."

- **Duration distribution (514 files):**

| Duration | Files |
|---|---|
| 60s – 20min (normal) | 506 |
| < 60s (suspicious: ringtones/intros/truncated) | 6 |
| > 20min (likely mixes/compilations) | 2 |

---

## 5. Metadata completeness

Probed embedded ID3 tags via `ffprobe` (514 lowercase-mp3):

| Tag | Files present | Coverage |
|---|---|---|
| title | 401 | 78% |
| artist | 376 | 73% |
| album | 294 | 57% |
| date (original year) | 7 | 1% |
| no tags at all | 0 | 0% |

**Implications:**
- ~22% of files have no title tag and ~27% no artist tag → **filename is the de-facto source of truth for a meaningful minority of the catalog.** The pipeline must map filename → title/artist via a curated normalization table, reviewed by an admin, not guessed at ingest.
- Release **date is essentially absent** (7 files) → treat date as admin-entered metadata during review, not file-derived.
- Filenames are inconsistently formatted (some `Artist - Song`, some `Unknown Artist - nuho - 06. Track 6.mp3`, some raw like `Shantm.mp3`) → filename parsing must be heuristic + human-review, never fully automatic.

---

## 6. Integrity & anomalies

- **Zero-byte files:** 0 (no empty/truncated objects to quarantine).
- **Duplicate basenames:** 0 case-insensitive across the whole tree (all 521 unique) — good news for keying by filename, though slug collisions remain possible after normalization.
- **Suspicious short files (< 60s):** 6 — flag for admin review (may be intros, ringtones, or truncated downloads that should not be published as full tracks).
- **Filename hygiene for ingestion:**
  - All 521 names contain spaces/symbols (spaces, `&`, `( )`, `-`, `=`, `'`) — safe as filesystem names but **not safe as object keys / URLs without slugification**.
  - 5 files named `*.MP3` (uppercase extension).
  - Names include `,` and `=` characters; one has `~` (DOS short-name `IBRAHI~1.MP3`) — treat as normalized to a clean ASCII slug with a collision check.
  - One file per the 03:18 QA history is a doc'd rename: `markato → nuho_gobana.mp3` (asset rename already applied in the app; catalog-side still uses the old name in places).

---

## 7. Read-only audit method (for reproducibility)

Commands (all read-only: `find`, `stat`, `ls`, `ffprobe` — no transcodes, no writes):

```bash
CAT="/Users/birragemedi/Desktop/Music "   # NOTE trailing space; quote everywhere

# Totals, storage, formats
find "$CAT" -type f -not -name '.DS_Store' | wc -l
find "$CAT" -type f -not -name '.DS_Store' -exec stat -f %z {} \; | awk '{s+=$1} END{print s}'
find "$CAT" -type f -not -name '.DS_Store' | sed -E 's/.*\.([A-Za-z0-9]+)$/\1/' | tr 'A-Z' 'a-z' | sort | uniq -c

# Zero-byte + duplicates
find "$CAT" -type f -size 0
find "$CAT" -type f -not -name '.DS_Store' | sed 's#.*/##' | tr 'A-Z' 'a-z' | sort | uniq -d

# Metadata (title/artist/album/date) via ffprobe
ffprobe -v error -show_entries format_tags=title,artist,album,date -of csv=p=0 "<file>"

# Bitrate / sample rate / channels / duration
ffprobe -v error -select_streams a:0 -show_entries stream=codec_name,sample_rate,channels,bit_rate -of csv=p=0 "<file>"
ffprobe -v error -show_entries format=duration,bit_rate -of csv=p=0 "<file>"
```

> The `Music ` trailing space breaks naive shell loops; always assign to a quoted variable or read paths from a file list.

---

## 8. Decisions needed before the pipeline can ingest

1. **Canonical source** — pick ONE path (or the VISION volume) and resolve the `durrii` / `Music ` duplication; rename away the trailing space.
2. **Re-mount `/Volumes/VISON`** — required to audit the full 2,000+ catalog; the on-disk 521 set may be a subset or a working copy.
3. **Slug/keying strategy** — define a deterministic, collision-checked slug from filename + embedded tags.
4. **Low-quality policy** — how to handle the 6 <64k files and 64–128k files (re-source vs accept with documented ceiling).
5. **Suspicious short files** — 6 <60s to be excluded or flagged for manual review.
6. **Metadata authority** — filename is not reliable; define the admin review step as mandatory before publish.

---

## 9. What this audit did NOT do

- Did **not** modify, move, rename, transcode, or delete a single catalog file.
- Did **not** write to Firebase, did not run any `firebase`/`gcloud` commands (none installed).
- Did **not** touch the external VISION volume (not mounted).
- Did **not** attempt any mass processing or migration — per the task constraint, this is audit + contract only.
