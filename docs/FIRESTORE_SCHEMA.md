# Vision Music — Firestore Schema (Admin Ingestion + Public Catalog)

**Version:** 0.1 (proposal)
**Date:** 2026-08-11
**Companion:** `ADMIN_API_CONTRACT.md`, `CATALOG_AUDIT.md`, `SECURITY_MODEL.md`, `COST_ESTIMATE.md`
**Status:** Not deployed. Extends the existing public-read/write-denied model; adds the private admin ingestion collections. The public `songs` shape is fixed by the app's `PublicCatalogPolicy` and `FirestoreSongRepository`.

---

## 1. Collection map

| Collection | Reader | Writer | Purpose |
|---|---|---|---|
| `songs/{songId}` | Public (read) | Only publish step (Admin SDK/CF) | Public catalog — exact app contract (§3) |
| `videos/{videoId}` | Public (read) | Only CF/console | Public video catalog (existing, unchanged) |
| `videoCategories/{id}` | Public (read) | Only CF/console | Existing (unchanged) |
| `users/{userId}` + subcollections | Owner | Owner | Existing user data (unchanged) |
| `adminRoles/{uid}` | Admin/service | Admin | Admin membership + custom-claim source of truth |
| `ingestionRequests/{requestId}` | Admin only | CF + service account | Upload/review/publish state machine (§4) |
| `processingJobs/{jobId}` | Admin only | CF + service account | Per-request processing job progress (§5) |
| `tracks/{trackId}` | Public (read) | Publish step | Canonical track record; `songs` is the app-facing projection (§6) |
| `artists/{artistId}` / `albums/{albumId}` | Public (read) | Publish step | (Reserved) enrichment; not required for current app |

> Note: the app currently reads only the flat `songs` collection (no `tracks`/`artists`/`albums` references). Those collections are added by the pipeline as canonical records and for future artist/album pages — **but the app-facing contract stays `songs`** so `useFirebaseCatalog` flips safely. Keep `tracks` as the single source of truth and derive the flat `songs` doc at publish time.

---

## 2. Conventions

- Every write carries `createdAt`/`updatedAt` (server timestamp) + `createdBy`/`updatedBy` (`{uid,email}`).
- **Slugs** for `trackId`/`songId`: `proposedArtist — proposedTitle` normalized to ASCII lower, spaces→`-`, strip `/`, `&`, `'`, `=`, `,` (see audit hazards). Collision check before write → `869 conflict` on dup, admin resolves.
- Enum fields are plain strings; the app/functions validate, rules do not enforce enum (rules can't read a whitelist portably).
- Public docs carry `status=='published' && approved==true`. The app query is `.where('status', isEqualTo: 'published').where('approved', isEqualTo: true)` — **every public catalog doc must always satisfy this**, or it is invisible to the app.

---

## 3. Public `songs/{songId}` (app contract — REQUIRED shape)

Must satisfy `PublicCatalogPolicy`:
- `status == 'published'`, `approved == true`
- Audio resolves to https/gs via, in priority order: `publishedAudioUrl`, or `renditions{aac256|aac128|aac64|mp3}.url` (any with `approved:true && public:true`), else legacy `filePath`.

```jsonc
songs/<trackId>:
{
  "id":            "ali-birra-nuho-gobana",   // == doc id, string required
  "title":         "Nuho Gobana",             // required
  "artist":        "Ali Birra",               // required
  "albumTitle":    "Best of Ali Birra",       // optional
  "genre":         "Oromo Music",             // optional
  "status":        "published",               // REQUIRED, fixed
  "approved":      true,                      // REQUIRED, fixed
  "publishedAudioUrl": "https://.../renditions/ali-birra-nuho-gobana/aac256.m4a", // preferred (optional if renditions present)
  "renditions": {
    "aac256": { "url": "https://.../aac256.m4a", "codec":"aac", "bitrateKbps":256, "approved": true, "public": true },
    "aac128": { "url": "https://.../aac128.m4a", "codec":"aac", "bitrateKbps":128, "approved": true, "public": true },
    "aac64":  { "url": "https://.../aac64.m4a",  "codec":"aac", "bitrateKbps": 64, "approved": true, "public": true },
    "mp3":    { "url": "https://.../mp3-192.mp3", "codec":"mp3", "bitrateKbps":192, "approved": true, "public": true }   // optional
  },
  "filePath":      "https://.../aac128.m4a",  // optional legacy fallback
  "imagePath":     "https://.../artwork/ali-birra-nuho-gobana.jpg",  // https ONLY (gs:// imagePath breaks Flutter image provider)
  "durationMs":    213000,
  "lyrics":        null,                      // optional; only licensed/owned text (see roadmap P2-15; no fabricated)
  "youtubeUrl":    null,                      // optional
  "sourceBitrateKbps": 128,                   // provenance: what the master actually was (audit honesty)
  "isLosslessSource":  false,
  "createdAt":     <ts>, "updatedAt": <ts>,
  "createdBy": {"uid":"...","email":"admin@..."},
  "publishedAt":   <ts>
}
```

> **Audit-consistency rule:** never set `approved:true` / `status:'published'` on anything that is not fully processed + admin-reviewed. The publish step is the only writer to `songs`.

---

## 4. `ingestionRequests/{requestId}` (private — state machine unit)

```jsonc
ingestionRequests/<auto>:
{
  "requestId":  "<auto>",
  "status":     "source_uploaded | processing | awaiting_review | approved_staged | published | rejected | unpublished | failed | draft",
  "sourceFilename": "original name (trailing-space/upper-ext warnings from audit)",
  "sourceObject":   "private/sources/<requestId>/<filename>",
  "mimeType":       "audio/mpeg | audio/x-wav | audio/mp4",
  "sourceBytes":    12345678,
  "sourceBitrateKbps": 128,       // ffprobe at upload
  "sourceDurationMs": 213000,     // ffprobe at upload
  "sourceSampleRateHz": 44100,
  "cameraOrSource":  "WAV master | CD rip | labeled source",  // NOT "YouTube" (forbidden)
  "proposedTitle":   "Nuho Gobana",
  "proposedArtist":  "Ali Birra",
  "proposedAlbum":   null, "proposedGenre": null, "proposedDate": null,
  "flags": { "lowQuality": false, "shortDuration": false, "oddChars": true, "needsReview": true },
  "renditions": {                       // filled by processing service
    "source":  { "bitrateKbps":128, "sampleRateHz":44100, "channels":2, "loudnessLufs":-16.2, "truePeakDbTp":-0.8 },
    "aac256":  { "stagingUrl":"private/renditions_staging/<requestId>/aac256.m4a", "bitrateKbps":256, "loudnessLufs":-14.0, "bytes":904100, "status":"staged" },
    "aac128":  { ... }, "aac64": { ... }, "mp3": { ... }   // same shape
  },
  "waveformStagingUrl": "private/processing/<requestId>/waveform.json",
  "artworkStagingUrl":  null,
  "review":    { "decision":"approve|reject", "reviewerUid":"...", "reviewedAt":<ts>, "comment": "..." , "corrections": { "proposedTitle":"...", "proposedArtist":"..." } },
  "publish":   { "publishedAt":<ts>, "publishedBy":{...}, "trackId":"ali-birra-nuho-gobana" },
  "createdAt": <ts>, "updatedAt": <ts>, "createdBy": {...}, "updatedBy": {...},
  "error":     null   // set on failed
}
```

Transitions (guards enforced in functions/service, see API contract §4.2):
`draft → source_uploaded → processing → awaiting_review → approved_staged → published`; branch `awaiting_review → rejected`; `published → unpublished`; any → `failed`.

---

## 5. `processingJobs/{jobId}` (private)

```jsonc
processingJobs/<auto>:
{
  "jobId":    "<auto>",
  "requestId":"<ingestion request>",
  "status":   "queued | running | succeeded | failed",
  "progress": { "step": "ffprobe|decode|analyze|loudness_normalize|encode_aac64|encode_aac128|encode_aac256|encode_mp3|waveform|finalize", "pct": 0-100, "detail": "..." },
  "startedAt": <ts>, "finishedAt": <ts>|null,
  "outputs":  { "waveform": { "buckets": 1500, "durationMs": 213000 }, "renditions": [ "aac64","aac128","aac256" ] },
  "retryCount": 0,
  "error":    null,
  "createdBy": {...}, "createdAt": <ts>, "updatedAt": <ts>
}
```

---

## 6. `tracks/{trackId}` (canonical record; the app-facing `songs` is derived)

Canonical destination of approved metadata; keeps provenance + rendition pointers; referenced by future artist/album enrichment.

```jsonc
tracks/<trackId>:
{
  "trackId": "<slug>",
  "title":"...", "artist":"...", "album":"...", "genre":"...",
  "artists": ["<artistId>"], "albumId": "...",         // reserved (empty until enrichment)
  "sourceBitrateKbps": 128, "sourceFormat":"mp3",
  "renditions": { "aac256":{"storagePath":"public/renditions/<trackId>/aac256.m4a","bytes":...,"durationMs":...}, ... },
  "waveform": { "storagePath":"public/renditions/<trackId>/waveform.json", "buckets":1500 },
  "artworkPath": "artwork/<trackId>.jpg",
  "status":"published", "approved":true,
  "publishedAt": <ts>, "createdBy": {...}, "createdAt":<ts>, "updatedAt":<ts>
}
```

---

## 7. `adminRoles/{uid}` (admin membership)

```jsonc
adminRoles/<uid>:
{ "uid":"...", "email":"admin@...", "role":"admin", "grantedBy":"...", "grantedAt":<ts>, "active": true }
```

- Source of truth for the `role == 'admin'` **custom claim** (claims are read-only per token refresh; the function re-checks the doc on sensitive ops, not just the claim). Publish/unpublish revalidates against this doc.
- Only provisionable out-of-band (console / service account) — **never by a client**.

---

## 8. Composite indexes

`firestore.indexes.json` is currently empty. Required for the admin dashboard query (request list filtered by status) and nothing else in the public read path (the app query is a single-collection equality on two fields — Firestore can serve that without a custom composite index in current SDKs, but verify). Add if the dashboard needs e.g. `ingestionRequests orderBy updatedAt desc where status == X`:

```jsonc
{
  "indexes": [
    // ingestionRequests: updatedAt desc, status ==
    { "collectionGroup":"ingestionRequests", "queryScope":"COLLECTION",
      "fields":[ {"fieldPath":"status","order":"ASCENDING"},
                 {"fieldPath":"updatedAt","order":"DESCENDING"} ] },
    // processingJobs: requestId ==, updatedAt desc
    { "collectionGroup":"processingJobs", "queryScope":"COLLECTION",
      "fields":[ {"fieldPath":"requestId","order":"ASCENDING"},
                 {"fieldPath":"updatedAt","order":"DESCENDING"} ] }
  ]
}
```

---

## 9. Rules boundary summary

- Public reads (`songs`, `videos`, `videoCategories`, `tracks`) → `allow read: if true`. No client write.
- `ingestionRequests`, `processingJobs`, `adminRoles` → **no direct client read/write** (deny all). Only Admin SDK / Cloud Functions (not subject to rules) access them. The Admin Studio reads them via callable functions, never via direct Firestore SDK.
- `users/*` user data → owner-only (unchanged).
- Storage: `private/**` deny-all to clients; `public/**` + `artwork/**` read; `audio`/`video` under existing model read for signed-in (unchanged) — see SECURITY_MODEL.md.
