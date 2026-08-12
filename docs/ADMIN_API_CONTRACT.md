# Vision Music — Admin Ingestion & Publishing API Contract

**Version:** 0.1 (proposal — nothing deployed)
**Date:** 2026-08-11
**Companion:** `CATALOG_AUDIT.md` (read-only audit), `FIRESTORE_SCHEMA.md`, `SECURITY_MODEL.md`, `COST_ESTIMATE.md`
**Constraint honored:** read-only audit + contract first. No mass processing/migration executed. No code/service deployed yet.

---

## 0. Design principles (non-negotiable)

1. **Public clients can never write the catalogue.** The existing `firestore.rules` deliberately deny catalogue writes to *all* clients (including signed-in users); only a trusted context (Admin SDK / Cloud Functions) publishes. This contract preserves that invariant.
2. **Original masters stay private.** Public listeners stream only published renditions; the source WAV/MP3 never gets a public URL.
3. **No credentials in the client, the repo, or the Flutter bundle.** Admin uploads are signed in the browser; the browser never holds a storage credential.
4. **Admin-only.** The ingestion surface is a separate, authenticated admin UI/server path. A public `Vision Music` app user can never reach it.
5. **Human review before publish.** Nothing reaches the public `songs` collection without an approving admin action. Date/artist/title are reviewed, not trusted from filename or tags.
6. **Loudness/quality honesty.** Sources are mostly 64–160 kbps MP3 (see audit) — the pipeline records source bitrate and surfaces low-quality/short/suspicious items for review rather than silently "mastering" them.

---

## 1. Actors & trust boundaries

| Actor | Authenticated as | Can |
|---|---|---|
| **Admin** (curator) | Special admin identity, verified in App Check + custom claims (`role == 'admin'`) | Upload source; run a processing job; review/approve/publish; unpublish/rollback |
| **Cloud Run `process` service** | Service account (out-of-band; Admin SDK trust) | The **only** writer to private source/processing output Storage + the `processingJobs`/`tracks` Firestore; **never** writes public `songs` directly (writes `status=awaiting_review`) |
| **Publish function / admin review action** | Admin-triggered Cloud Function / callable with admin claim | The **only** step that writes the public `songs` collection (sets `status=published`, `approved=true`) |
| **Public app user** | Optional signed-in | Read published `songs` only (existing rules). **Cannot** call any ingestion endpoint |

---

## 2. Transport & auth

- **Uploads + admin actions:** Firebase **Cloud Functions (callable functions)** for admin actions; the admin controls them via the Admin Studio web UI. Callables carry Firebase Auth ID token + App Check token and are only reachable by admins (custom claim `role == 'admin'` checked inside the function, not just in rules).
- **Onward processing:** Cloud Run `process` service is invoked **only** by a Cloud Function (or a queue), never by a browser. It authenticates to Firestore/Storage via its own **service account** (Admin SDK). Cloud Run is private (no `--allow-unauthenticated`).
- **No REST key in the client.** The browser never talks to Cloud Run directly.

Auth flow for an admin action:

```
Admin Studio (browser)
  └─ firebase.auth().signInWithCredential(...)   → ID token
  └─ firebase.functions().httpsCallable('ingestRequests_create')({...})   
        ├─ Firebase verifies ID token + App Check
        └─ function checks customClaims.role == 'admin'  → else aborts
```

---

## 3. Storage layout (private by default)

Bucket paths (all under the single project bucket unless multi-bucket is chosen — see Security Model):

| Prefix | Visibility | Contents |
|---|---|---|
| `private/sources/{requestId}/` | **private** (only service account + Admin SDK) | Original upload (WAV/MP3/M4A). Never given a public URL. |
| `private/processing/{requestId}/` | **private** | Intermediate work products (loudness analysis, waveform JSON, DSP intermediates) |
| `public/renditions/{trackId}/{rendition}/` | **public read** (created by publish step) | Final approved AAC 64/128/256 (optional MP3) + artwork + waveform JSON |
| `artwork/{trackId}.jpg` | public read (as today) | Cover art for unfurling |

> Rule: the `process` service writes under `private/processing` and `public/renditions` **only** after admin approval (publish step copies/delivers), OR the publish function publishes from a per-request staging area. Prefer: renditions are staged in `private/renditions_staging/{requestId}/`, then the publish action atomically moves/`finalizes` them into `public/renditions/` — so an unapproved rendition never has a public URL even transiently.

---

## 4. Firestore data model (new ingestion collections)

(Full schemas in `FIRESTORE_SCHEMA.md`; here the contract-relevant state machine and fields.)

### 4.1 `ingestionRequests/{requestId}` — the upload + review unit

```
{
  requestId:         string   // auto
  status:            ENUM,
  sourceFilename:    string   // original filename (audit hazard: trailing spaces/upper ext)
  sourceBucket:      "private/sources/{requestId}/{filename}",
  mimeType,
  sourceBytes,
  sourceBitrateKbps,          // captured at upload via ffprobe
  sourceDurationMs,
  cameraOrSource:    string?  // e.g. "WAV master" | "CD rip" | "YouTube" (forbidden: see §9)
  proposedTitle, proposedArtist, proposedAlbum, proposedGenre, proposedDate,
  adminNotes,
  createdAt, updatedAt, createdBy {uid,email}, updatedBy,
  flags: { lowQuality: bool, shortDuration: bool, oddChars: bool, needsReview: bool },
  renditions: { aac64:{...}, aac128:{...}, aac256:{...}, mp3?:{...} },  // added by processing
  waveformUrl, artworkUrl,      // staging URLs until publish
  review: { decision, reviewerUid, reviewedAt, comment? },  // set by admin
  publish: { publishedAt, publishedBy, publicTrackId }?      // set on publish
}
```

### 4.2 Request state machine

```
          (admin uploads)            (function invokes)          (service account)
[ draft ] ──────────────────► [ source_uploaded ] ──────────► [ processing ]
                                                                    │  ffmpeg loudness + renditions + waveform
                                                                    │  writes staging + results
                                                                    ▼
                                                              [ awaiting_review ]
                                                                    │  admin approves (callable)
                                                                    ▼
                                           ┌──────────────── [ approved_staged ] ─┐
                                           │  publish step moves renditions       │
                                           │  public + writes public tracks/songs  │
                                           ▼                                       ▼
                                         [ published ]                        [ rejected ] (admin, with comment)
                                                │  admin un-publishes                 │ (resumable if re-submitted)
                                                ▼
                                          [ unpublished ]
```

Status enum: `draft`, `source_uploaded`, `processing`, `awaiting_review`, `approved_staged`, `published`, `rejected`, `unpublished`, `failed`.

Transition guards (enforced inside Cloud Functions / service):

- Any state → `failed` (on processing/ffmpeg error, with `error.message`).
- Only `awaiting_review` → `approved_staged` (admin).
- Only `approved_staged` → `published` (admin publish action; moves staging → public, writes `tracks/{trackId}` + `songs/{songId}`).
- `published` → `unpublished` (admin rollback; removes public URL exposure but keeps staging for re-publish).
- Unknown/invalid transitions → `409 Conflict` (see error codes).

### 4.3 Published-track contract (must satisfy the Flutter app)

`FirestoreSongRepository` today reads `songs` docs and expects at minimum:

```
songs/{id}:
  id, title, artist,
  albumTitle?, genre?,
  filePath      // https download URL (preferred) or gs://
  imagePath?    // https ONLY (Flutter image provider is synchronous; gs:// imagePath falls back to logo)
  durationMs?,
  lyrics?, youtubeUrl?,
  status == 'published', approved == true
  renditions: { aac256:{url, approved:true, public:true}, aac128:{...}, aac64:{...}, mp3:{...} }
```

> The app already has partial rendition support in `FirestoreSongRepository._approvedPublicAudioPath` (prefers `publishedAudioUrl`, then walks `renditions` for `approved==true && public==true`, preferring `aac256 → aac128 → aac64 → mp3`). **The pipeline's publish step must write exactly this shape** so `useFirebaseCatalog` can be flipped without rewriting the client.

---

## 5. Admin endpoints (callable functions)

All are `httpsCallable` and enforce `role == 'admin'`. Request → response JSON.

### 5.1 `adminUpload_create`
- **Input:** `{ fileName, mimeType, bytes? (in callable is impractical for large files) }` — for large sources, use a **presigned/upload-url flow** instead: function returns a short-lived upload target.
- **Preferred large-file flow (avoids 10 MB callable limit):**
  1. `ingestRequests_create` → returns `{ requestId, uploadUrl or uploadToken, expiresAt }`
  2. Admin Studio PUTs the source file to the signed URL (or uses Firebase Storage with a restricted write token scoped to `private/sources/{requestId}/` for the admin's own request).
  3. `ingestRequests_confirmUpload` → sets `status=source_uploaded`, runs `ffprobe` metadata capture.
- **Response:** `{ requestId, uploadUrl, expiresAt }`.
- **Errors:** `unauthenticated` / `permission-denied` / `invalid-argument` (bad mime, >500 MB source) / `not-found`.

### 5.2 `ingestRequests_process` (admin triggers processing)
- **Input:** `{ requestId }`
- **Behavior:** confirms source present, creates `processingJobs/{jobId}`, invokes Cloud Run (or enqueues) with `{ requestId }`.
- **Response:** `{ jobId, status:'queued' }`.
- **Errors:** `invalid-state` (must be `source_uploaded`), `not-found`.

### 5.3 `ingestRequests_list` (admin dashboard)
- **Input:** `{ status? , limit, cursor? }`
- **Response:** `{ requests: [summary...], nextCursor }`
- **Errors:** `permission-denied` (non-admin).

### 5.4 `ingestRequests_get`
- **Input:** `{ requestId }`
- **Response:** full doc + `processingJobs` history + preview URLs (short-lived signed URLs into `private/processing`).
- **Errors:** `not-found`, `permission-denied`.

### 5.5 `ingestRequests_review` (approve or reject)
- **Input:** `{ requestId, decision: 'approve'|'reject', comment? , corrections? {proposedTitle, proposedArtist, proposedAlbum, proposedGenre, proposedDate, artworkSuggested?} }`
- **Behavior:** if `approve` → `approved_staged`; if `reject` → `rejected` + comment. Corrections update proposed metadata (admin-entered, overrides file-derived).
- **Errors:** `invalid-state` (must be `awaiting_review`), `invalid-argument` (approve without required title/artist), `permission-denied`.

### 5.6 `ingestRequests_publish`
- **Input:** `{ requestId }`
- **Behavior:** (must be `approved_staged`) → finalizes renditions from staging into `public/renditions/{trackId}/`, writes `tracks/{trackId}` + `songs/{songId}` with exact app shape, sets `status=published`, records `publish`.
- **Response:** `{ trackId, songsDocId, publicUrls: {...} }`
- **Errors:** `invalid-state`, `conflict` (track id collision), `permission-denied`.

### 5.7 `ingestRequests_unpublish` (rollback)
- **Input:** `{ requestId }`
- **Behavior:** sets `status=unpublished`; removes/revokes the public `songs`/`tracks` doc exposure (soft: flips `approved=false`/`status='unpublished'` so the app's published-only query drops it). Keeps staging for re-publish.
- **Errors:** `invalid-state` (must be `published`), `permission-denied`.

### 5.8 `ingestRequests_delete` (admin-only purge — destructive, requires confirmation param)
- **Input:** `{ requestId, confirm: 'DELETE' }`
- **Behavior:** soft-deletes the request; optionally deletes `private/sources` + staging. **Never touches public history automatically** — a published track must be `unpublished` first, and removal from public collections is a separate explicit action.
- **Errors:** `invalid-argument` (missing confirm), `conflict` (still published).

---

## 6. Cloud Run `process` service contract (internal)

Invoked by a Cloud Function/queue with a service-account-authorized request (not browser-callable). Private deployment.

- **Request:** `POST /process` with `{ requestId, sourceUri, sourceFilename, stagingPrefix, targetRenditions: ['aac64','aac128','aac256'] (+optional 'mp3'), output: { lufs: -14, truePeak: -1.0 } }` (audience-normalized loudness; see note).
- **Steps (idempotent):**
  1. Stream source from `private/sources/{requestId}/` (never copy to public).
  2. `ffprobe`: duration, bitrate, sample rate, channels → confirm/override `ingestionRequests.renditions.sources`.
  3. **Loudness analysis + normalization** (EBU R128 / ITU-R BS.1770): measure integrated LUFS, true peak; normalize to target (default −14 LUFS, −1.0 dBTP) with `loudnorm` (single-pass or two-pass) — standard for streaming platforms.
  4. **Mastering/DSP** (optional, applied conservatively and only where beneficial — see audit's "quality ceiling" caveat): loudness normalization is the default; broad EQ/compression is opt-in per request, never auto.
  5. **Renditions:** encode AAC 64/128/256 kbps (and optional MP3 128/192) at 44.1 kHz stereo; keep sample-rate downmix at 44.1k (sources are 22.05k/44.1k).
  6. **Waveform:** generate JSON peaks (e.g. 1000–2000 buckets) via `astats`/`ebur128` or a small FFT reader → store `private/processing/{requestId}/waveform.json`.
  7. **Write results** to `ingestionRequests` (renditions metadata + staging URLs) and set `status=awaiting_review`. Also write `processingJobs/{jobId}` completion.
- **Response:** `200 { status:'awaiting_review', outputs:[...] }` | `4xx` invalid input | `5xx` ffmpeg failure (writes `failed`).
- **Idempotency:** keyed on `requestId` + `jobId`; re-running the same job must not duplicate renditions (overwrite staging, don't append).
- **Timeouts/resources:** Cloud Run CPU always-on for the encode duration; generous `requestTimeout` for long sources (the 2 audio files >20 min in the audit); `max-instances` guard for cost.

---

## 7. Progress polling

The Admin Studio polls `ingestRequests_get` (or a lightweight `processingJobs_get`) while `status` is one of `processing`/`queued`. The function returns:

```
{ jobId, status, progress: { step:'ffprobe'|'loudness'|'encode_aac64'|'encode_aac128'|'encode_aac256'|'waveform'|'finalize', pct: 0-100, currentFile?, error? } }
```

Client rule: read `updatedAt`, never long-poll; use Firestore `onSnapshot` on the request doc. Cloud Run updates `progress` periodic fields; the function is the only writer.

---

## 8. Error codes (callable)

| Code | HTTP-ish | Meaning |
|---|---|---|
| `unauthenticated` | 401 | No/invalid ID token or App Check |
| `permission-denied` | 403 | Valid user but not `role == 'admin'` |
| `not-found` | 404 | requestId/jobId missing |
| `invalid-argument` | 400 | malformed payload, bad mime, missing required field |
| `invalid-state` | 409 | transition not allowed from current status |
| `conflict` | 409 | slug/trackId collision, or already published |
| `source-too-large` | 413 | > source size limit |
| `processing-failed` | 500 | ffmpeg/encode error (details in `ingestionRequests.error`) |
| `deadline-exceeded` | 504 | Cloud Run encode timed out |
| `internal` | 500 | unexpected |

---

## 9. Explicit non-goals / forbidden

- **No YouTube downloading.** The `proposedTitle`/source pipeline has a `cameraOrSource` field; values on the ingest path must come from owned masters / labeled sources. No downloader service will be built. (The app's *Watch* tab YouTube import noted in the roadmap is a **catalogue import of metadata/thumbnails for licensed/owned video**, handled separately and NOT part of this audio ingestion pipeline.)
- **No destructive auto-cleanup** of the existing 521-file catalog or the VISION volume. All pipeline mutations happen on *new* copies (private sources/renditions); the originals are read-only inputs.
- **No client-writable catalogue** (preserves existing `firestore.rules`).
- **No credentials in repo/bundle** (service-account keys live in Secret Manager or CI secret store, per migration plan).
- **No false "mastering."** Sources are mostly 64–160 kbps; we normalize loudness and document ceilings, we do not claim lossless remaster.

---

## 10. Open decisions for the implementer

1. Callable vs REST — **LOCKED: callable** (see DECISIONS_LOCKED.md §1).
2. Upload — **LOCKED: signed HTTPS PUT URL** (§2).
3. Loudness target — **LOCKED: −14 LUFS / −1.0 dBTP** (§4).
4. Multi-bucket vs single-bucket — **LOCKED: single bucket + prefix rules** (private/ vs public/).
5. Queue — **LOCKED: direct Cloud Function → Cloud Run invoke** (simple, sufficient at DEV scale); upgrade to Cloud Tasks/Workflows only if ordering/retry needs demand it.
6. MP3 renditions — **LOCKED: AAC-only default; MP3 optional/off** (`RENDITIONS_MP3=false`).

---

## 11. Added capabilities (LOCKED contracts — this phase)

These extend §5. All are callable, enforce `role == 'admin'` (see DECISIONS_LOCKED.md §7), and re-check `adminRoles/{uid}.active` server-side.

### 11.1 `ingestRequests_checkDuplicate`
- **Input:** `{ proposedTitle?, proposedArtist?, sourceFilename?, sourceHash? }` (at least one discriminator required).
- **Behavior:** checks a normalized duplicate across BOTH:
  1. **pending** `ingestionRequests` (status `draft|source_uploaded|processing|awaiting_review`), AND
  2. **published catalog** `tracks`+`songs` (status `published` + `approved`)
  Normalization: lowercase, trim, collapse spaces, strip diacritics; `sourceHash` is `sha256` of the source bytes (authoritative if provided).
- **Response:** `{ duplicate: bool, matches: [{ kind:'pending'|'published'|'existing-track', requestId?, trackId?, songId?, title?, artist?, matchScore: number }] }`
- **Errors:** `invalid-argument` (no discriminator), `permission-denied`.

### 11.2 `ingestRequests_stats`
- **Input:** `{}`
- **Behavior:** dashboard summary counts, computed from `ingestionRequests` + `processingJobs` + published `tracks`.
- **Response:** `{ byStatus: { draft, source_uploaded, processing, awaiting_review, approved_staged, published, rejected, unpublished, failed }, totalJobs, activeJobs, totalPublished, totalPendingReview, avgProcessingMs?, lastUpdatedAt }`
- **Errors:** `permission-denied`.

### 11.3 `ingestRequests_auditLog` (audit-history query)
- **Input:** `{ requestId, limit?, cursor? }`
- **Behavior:** returns the append-only audit trail for one request from `ingestionRequests/{requestId}/audit`.
- **Response:** `{ entries: [ { at, actorUid, email, event:'created'|'source_uploaded'|'process_started'|'processing'|'awaiting_review'|'approved'|'rejected'|'published'|'unpublished'|'deleted', from?, to?, comment?, source?: 'function'|'cloud-run'|'admin' } ], nextCursor }`
- **Errors:** `not-found`, `permission-denied`.

### 11.4 `ingestRequests_artworkUpload_create` (artwork upload)
- **Input:** `{ requestId?, trackId?, fileName, mimeType }`
- **Behavior:** returns a signed PUT URL scoped to `artwork/{trackId}.jpg` (public-read prefix) for cover art. Bound to the request/track, short TTL.
- **Response:** `{ uploadUrl, expiresAt, publicReadPath:'artwork/{trackId}.jpg' }`
- **Errors:** `invalid-argument` (bad MIME/name), `permission-denied`.

### 11.5 `adminCatalog_list` (admin published-catalog query)
- **Input:** `{ status? ('published'|'unpublished'|'all'), limit?, cursor? }`
- **Behavior:** admin view of the catalog (full metadata, incl. unpublished) — distinct from the app's public read-only query (which stays `status=='published' && approved==true`).
- **Response:** `{ tracks: [ full docs ], nextCursor }`
- **Errors:** `permission-denied`.

### 11.6 Bulk publishing — **NOT implemented** (explicitly deferred; single-request publish only).

---

## 12. Admin authorization (LOCKED, supersedes any `admin: true` convention)

- **Single authoritative admin representation: the `role: 'admin'` custom claim + live `adminRoles/{uid}` doc (`active: true`).**
- There is **no `admin: true`** and none shall be introduced (DECISIONS_LOCKED.md §7).
- Every privileged function, and publish/unpublish in particular, **re-reads `adminRoles/{uid}` live** — never trusts the ID-token claim alone or stale browser state, because custom claims can lag revocation by up to an hour.

The Flutter app-side `PublicCatalogPolicy`/`FirestoreSongRepository` do **not** use the admin claim at all (public read-only model); the admin surface is entirely function-gated.
