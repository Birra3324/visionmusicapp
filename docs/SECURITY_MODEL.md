# Vision Music — Security Model (Admin Ingestion Pipeline)

**Version:** 0.1 (proposal)
**Date:** 2026-08-11
**Companion:** `ADMIN_API_CONTRACT.md`, `CATALOG_AUDIT.md`, `FIRESTORE_SCHEMA.md`, `COST_ESTIMATE.md`
**Status:** Not deployed. Preserves the existing rules' least-privilege/default-deny philosophy and adds the private ingestion boundary.

---

## 1. Threat model

| Threat | Mitigation |
|---|---|
| Non-admin floods the catalogue | Admin-only endpoints (custom claim + `adminRoles` doc re-check); callable functions reject non-admins |
| Public user writes `songs` | Existing `firestore.rules`: catalogue write denied to ALL clients (`allow write: if false`) |
| Source masters leak to public | Sources live under `private/sources/**`; never written to a public prefix; no public URL is minted for them (only short-lived signed URLs to an admin) |
| Unapproved rendition becomes publicly streamable | Renditions staged in `private/renditions_staging/**`; only the publish step finalizes them into `public/renditions/`; `approved:true && public:true` gate in the app policy |
| Billing abuse (open bucket streaming) | Media under authenticated/public prefixes with rules; Cloud Run private (no unauthenticated invoke); max-instances + egress budget |
| Stolen service-account key | Keys only in Secret Manager / CI secret store (never repo/bundle); Cloud Run uses metadata server / Workload Identity, not a checked-in JSON |
| Malicious uploaded file (content-type/size spoof) | Upload validates MIME + size on the function side; service re-reads with ffprobe (never trusts client MIME); file is **not** executable/macro-capable audio |
| Admin account takeover | App Check on admin surface; MFA recommended on the admin Google/email identity; sensitive ops (publish/unpublish/delete) require revalidation |
| Replay of signed upload URL | Short-lived upload URLs (≤ ~15 min), single-use, bound to the requestId + uid; confirmed-before-use |
| Low-quality source shipped as "mastered" | `flags.lowQuality` + `sourceBitrateKbps` persisted and shown at review; no claim of lossless remaster (audit-honesty rule) |

---

## 2. Trust boundaries

```
 [Public app]                 [Admin Studio (browser)]        [Cloud Run process]
      │  published songs             │ callable (ID+AppCheck)       │ Admin SDK (service acct)
      ▼                              ▼                              ▼
Firestore (rules: public read,      ─ ingestionRequests/ ─── CF ─── Cloud Run (private) ──> private source
  no client write)                    processingJobs (deny-all rules)
Storage (rules: public read,         public/renditions (publish step)
  no client write, private deny-all)
```

- **Firestore/Storage security rules** are the enforcement for *client* access. They **cannot** restrict the Admin SDK / Cloud Functions (those bypass rules by design) — so **client rules must deny all ingestion paths**, and the function layer is the second, authoritative gate.
- **Functions** re-check `role == 'admin'` (custom claim **and** live `adminRoles` doc for sensitive ops) because claims can be stale for up to an hour.

---

## 3. Firestore rules (delta to existing)

The existing `firestore.rules` (catalogue read public / write denied; user data owner-scoped) stay. Add:

```c
// ── Private ingestion collections: no direct client access ─────────────
// The Admin Studio never talks to these via the Firestore SDK; it goes
// through callable functions. Rules deny them to ALL clients; only the
// Admin SDK / Cloud Functions (not subject to rules) may touch them.
match /ingestionRequests/{requestId} {
  allow read, write: if false;   // function-only
}
match /processingJobs/{jobId} {
  allow read, write: if false;   // function-only
}
match /adminRoles/{uid} {
  allow read, write: if false;   // provisioned out-of-band only
}

// Public canonical records: readable, never client-written
match /tracks/{trackId} {
  allow read: if true;
  allow write: if false;
}
```

Do **not** weaken the existing `songs` write denial. The pipeline publishes via Admin SDK, which rules do not govern.

---

## 4. Storage rules (delta)

Keep the existing buckets' intent (audio/video authenticated read; artwork public; no client write to catalogue media). The new prefixes:

```c
// ── Private ingestion: deny all clients ────────────────────────────────
// Sources, processing intermediates, and staging renditions live here and
// must NEVER be reachable by a client URL. Only Admin SDK / Cloud Run
// (service account) read/write these.
match /private/{allPaths=**} {
  allow read, write: if false;   // service-account / SDK only
}

// Public renditions + waveform (minted ONLY by the publish step)
match /public/renditions/{trackId}/{file} {
  allow read: if true;
  allow write: if false;
}
match /public/waveforms/{trackId}/{file} {
  allow read: if true;
  allow write: if false;
}
```

> **Bucket topology call:** prefer a **single bucket** with `private/` vs `public/` prefixes and rules, for simplicity + one set of Firestore-free ACLs, OR **two buckets** (one private, one public-CDN-fronted) for stronger separation + easier CloudFront/CDN. Recommendation: start single-bucket + prefix rules (less moving parts); revisit two-bucket only when CDN egress costs demand CloudFront. `COST_ESTIMATE.md` assumes single bucket.

---

## 5. App Check

- **Enable App Check** on Firestore, Storage, and the callable functions (migration plan already lists it as a gate).
- Admin Studio registers as a **web app** with App Check (reCAPTCHA Enterprise or a custom provider). The Cloud Run `process` service uses **Workload Identity / service-account** credentials, not App Check tokens.

---

## 6. Secrets

- Service-account JSON keys: **never** in git, never in the Flutter bundle (`FIREBASE_MIGRATION_PLAN.md` hard rule). Live in **Secret Manager** (Cloud Run mounts at runtime) or **CI secret store**.
- No API keys for Gemini/other external services stored in code (roadmap flags two dead services with unfilled `_geminiApiKey` fields to be archived — do not fill them in).
- No admins' credentials, no downloader (YouTube prohibited).

---

## 7. Admin identity provisioning

1. Provision the first admin via Firebase console / service account (out-of-band), writing `adminRoles/{uid}` + setting the `role: admin` custom claim.
2. `adminRoles` doc is the source of truth; claims are a fast path. Sensitive ops re-check the doc.
3. Audit log: every admin action records `createdBy`/`updatedBy` + `publishedBy`/`reviewerUid` + timestamps in the request/processing docs — an immutable-ish audit trail (Firestore documents are append-only in practice via these audit fields).

---

## 8. What is explicitly NOT included (escapes)

- No YouTube / external downloader (prohibited by task).
- No client-initiated catalogue writes, ever.
- No auto-deletion of existing catalog/VISION originals (deletes are explicit + confirm-gated, unpublished-first).
- No private master cleanup without an explicit, separately-approved step.
- Public users cannot reach any upload/process/review/publish endpoint — the surface is entirely disjoint from the app's `songs` read.
