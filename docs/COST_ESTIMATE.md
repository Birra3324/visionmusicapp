# Vision Music — Cost Estimate (Admin Ingestion Pipeline)

**Version:** 0.1 (planning — figures are estimates, not quotes)
**Date:** 2026-08-11
**Basis:** Verified audit — 521 audio files, ≈2.54 GB sources, mostly 64–160 kbps MP3 (see `CATALOG_AUDIT.md`). Assumes **single-bucket** topology, Firebase Standard (Spark → Blaze), Cloud Run private FFmpeg, one admin.
**Status:** Not deployed. No spend incurred yet.

> These are planning numbers for one reasonable configuration. Actual billing depends on tier, region (`us-central1` assumed, cheapest), traffic, and whether CDN/CloudFront is added later. Rounded, with headroom.

---

## 1. One-time catalog migration (521 files → full pipeline)

| Item | Basis | Est. |
|---|---|---|
| Cloud Run compute (process 521 files) | ~avg 3 min/file wall, 2 vCPU, 2 GiB mem; burn ~3 GB-s/vCPU-GiB | **$18–45** |
| Convert storage (sources read → renditions written) | 521 sources ≈ 2.5 GB read; 521 × ~3 renditions × ~6 MB ≈ ~9 GB written | < **$1** |
| Cloud Run egress (staging + publish within same region) | ~10 GB intra-region (mostly free); some internet egress for admin preview | < **$1** |
| Firestore writes | ingestion px2 requests + jobs + tracks + songs ≈ a few thousand docs | < **$1** |
| Storage (persist renditions + sources) | ≈ 2.5 GB sources (private) + ≈ 10 GB renditions/waveforms/artwork | ~$0.03/mo |
| **One-time total** | | **≈ $20–50** |

Takeaway: **migrating the whole verified 521-file catalog costs roughly $20–50 one-time** with Cloud Run. The 2,000+ catalog on the VISION volume would scale roughly ×4 → **$80–200** one-time (unchanged per-file cost, more files).

---

## 2. Steady-state (after migration)

| Item | Assumption | Est./mo |
|---|---|---|
| Storage (sources + renditions, ~12 GB) | Standard: ~$0.026/GB | ~$0.31 |
| Firestore | Low write/read; native pricing | ~$1–5 |
| Cloud Run | Idle (scale-to-zero); only per-ingest bursts | ~$0–2 |
| **Baseline empty-traffic** | | **≈ $2–8/mo** |
| Streaming egress (per 1k plays @ 128k) | ~1k × ~3.3 MB ≈ 3.3 GB | ~$0.3/1k plays |

Add **Firebase Blaze** (no flat fee; pay-as-you-go) — the Spark free tier is likely insufficient for public streaming. Blaze + these usage levels keeps the monthly bill in the **single digits to low tens of dollars** until real listening volume arrives.

---

## 3. Cloud Run FFmpeg: cost model

Cloud Run bills **vCPU-seconds + GiB-seconds**, scale-to-zero (no idle cost), plus requests/egress. For encoding, CPU **always-on** (not throttled) is correct.

- Rough burn for one 3–4 min source → 3 renditions + loudness + waveform: ~3–4 GB-seconds vCPU + GiB-mem.
- At ~$0.000024/vCPU-sec + ~$0.0000025/GiB-sec (us-central1), each file is **~$0.04–0.09**.
- **521 files ≈ $20–45**; **2,000+ files ≈ $80–200** (same per-file, more files).
- Control with `--max-instances 4`, a per-job CPU limit, and finishing each file (the `process` service completes one request per invocation; the queue paces concurrency — see §5).

---

## 4. Cost drivers & how to control them

| Driver | Levers |
|---|---|
| **Egress** (largest long-term risk — streaming to users) | Keep renditions in same region as Firestore; revisit **CloudFront/S3** (roadmap LATER) only once public streaming volume is real (Nairobi/Johannesburg/Lagos edges) |
| **Encode compute** | Batch at off-peak; cap Cloud Run max-instances; two-pass only where needed; skip `mp3` rendition if AAC-only is acceptable (AAC is the standard target) |
| **Storage** | Keep only published renditions + waveform public; keep sources as private originals (don't duplicate); consider lifecycle rule to cold-archive un-republished rejected sources after N days (explicit, approved) |
| **Firestore reads** | App already batches `fetchAll` once per load; no per-track read loops. Watch bursty pulls after publish |
| **Auth/App Check** | App Check tokens are free; no separate cost |
| **Emulator testing** | Local Firestore emulator + local ffmpeg dry-run = ~$0 (test first, the audit's #1 cost control) |

---

## 5. Recommended minimal-resource profile (for the build phase)

- **Local first, spend nothing:** use the local `ffmpeg`/`ffprobe` (already on this Mac) + Firestore **emulator** to validate loudness/rendition/waveform output and rules. Zero cloud spend during development.
- **Project:** run the pipeline against `visionmusic-dev`, not prod (`FIREBASE_MIGRATION_PLAN.md`). Dev tier is cheap/discardable.
- **Cloud Run:** minimal `--cpu 2 --memory 2Gi --max-instances 4`, private (no unauthenticated), CPU-always-on, region `us-central1`.
- **Queue:** Cloud Tasks/Workflows to pace the 521-file batch (don't fan out 500 Cloud Run instances at once — cost spike + egress). Slow-and-steady keeps the bill flat.

---

## 6. Assumptions / caveats

- Sources are **not lossless** (mostly 64–160 kbps MP3). Rendition output volume (~6 MB/rendition) is based on AAC at 44.1 kHz; high-bitrate lossless sources would be larger — but the catalog is what it is.
- Number of renditions: default **AAC 64/128/256** (3 renditions) + optional MP3. Adding MP3 adds ~30% encode time + storage.
- Egress estimate for streaming assumes regional/same-region reads; public internet egress from Firebase-hosted URLs is the dominant cost at scale and is the reason CDN is deferred, not forgotten.
- Pricing excludes Firebase app/usage analytics, Crashlytics, or Performance Monitoring (mostly free tiers).

---

## 7. Bottom line

- **Build + test:** ~$0 (local emulator + local ffmpeg).
- **Migrate 521 (verified) catalog:** ~$20–50 one-time.
- **Migrate full 2,000+ (VISION volume, once remounted):** ~$80–200 one-time.
- **Run the service:** ~$2–8/month baseline; + ~$0.3 per 1k streams at 128 kbps.

No significant cost blocker. The real controls are **egress discipline** (defer CDN until streaming is real) and **not over-provisioning Cloud Run** during the batch.
