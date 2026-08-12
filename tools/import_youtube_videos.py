#!/usr/bin/env python3
"""
Vision Entertainment — YouTube → Firebase Importer
====================================================
Fetches ALL videos from the @visionentertainment4507 YouTube channel
and uploads them to your Firebase Firestore `videos` collection.

HOW TO USE:
  1. Install dependencies:
       pip3 install google-api-python-client firebase-admin

  2. Get your YouTube Data API v3 key:
       → https://console.cloud.google.com/apis/credentials
       → Create API key → restrict to YouTube Data API v3

  3. Download your Firebase service account key:
       → Firebase Console → Project Settings → Service Accounts
       → "Generate new private key" → save as firebase-key.json
       → Put firebase-key.json in this tools/ folder

  4. Run:
       cd tools
       python3 import_youtube_videos.py --api-key YOUR_YOUTUBE_API_KEY

  Optional flags:
       --dry-run          Preview videos without uploading to Firestore
       --output-dart      Also generate lib/mock_videos.dart with all videos
       --category-map     Show how videos were auto-categorized before uploading
"""

import argparse
import json
import os
import sys
import re
from datetime import datetime, timezone
from pathlib import Path

# ─── Dependency check ──────────────────────────────────────────────────────────
try:
    from googleapiclient.discovery import build
    from googleapiclient.errors import HttpError
except ImportError:
    print("❌  Missing dependency. Run:  pip3 install google-api-python-client")
    sys.exit(1)

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
    FIREBASE_AVAILABLE = True
except ImportError:
    FIREBASE_AVAILABLE = False

# ─── Config ────────────────────────────────────────────────────────────────────

CHANNEL_HANDLE   = "@visionentertainment4507"
CHANNEL_URL      = "https://www.youtube.com/@visionentertainment4507"
FIRESTORE_COLLECTION = "videos"

# Auto-category detection rules (applied in order — first match wins)
CATEGORY_RULES = [
    # Keywords → Firestore category ID
    (["official video", "official music video", "clip officiel"], "music_videos"),
    (["live", "concert", "stage", "performance", "show live"], "live_performances"),
    (["studio", "behind the scenes", "bts", "recording", "in studio"], "studio_sessions"),
    (["interview", "sits down", "speaks with", "conversation with", "talks to"], "interviews"),
    (["podcast", "episode", "ep."], "podcast_clips"),
    (["concert hall", "full concert", "live concert"], "concerts"),
    (["new release", "new single", "latest", "just released", "out now"], "new_releases"),
    (["oromo", "oromoo", "classic", "traditional", "afaan"], "oromo_classics"),
    # Default
    ([], "music_videos"),
]

# Artists commonly featured on Vision Entertainment
KNOWN_ARTISTS = [
    "Ali Birra", "Hachalu Hundessa", "Kemer Yousuf", "Tilahun Gessesse",
    "Mahmoud Ahmed", "Teddy Afro", "Hamelmal Abate", "Helen Hailu",
    "Zeritu Kebede", "Dawit Tsige", "Gossaye Tesfaye", "Vision Entertainment",
]

# ─── YouTube helpers ────────────────────────────────────────────────────────────

def get_channel_id(youtube, handle: str) -> str:
    """Resolve a @handle to a numeric channel ID."""
    # Try searching by handle
    handle_clean = handle.lstrip("@")
    resp = youtube.search().list(
        part="snippet",
        q=handle_clean,
        type="channel",
        maxResults=5,
    ).execute()

    for item in resp.get("items", []):
        snippet = item.get("snippet", {})
        cid = item.get("snippet", {}).get("channelId") or item.get("id", {}).get("channelId")
        title = snippet.get("channelTitle", "")
        if cid and (handle_clean.lower() in title.lower() or "vision" in title.lower()):
            return cid

    # Fallback: channels list by forHandle
    try:
        resp2 = youtube.channels().list(
            part="id",
            forHandle=handle_clean,
        ).execute()
        items = resp2.get("items", [])
        if items:
            return items[0]["id"]
    except Exception:
        pass

    # Last resort: return first result
    if resp.get("items"):
        return resp["items"][0]["snippet"]["channelId"]

    raise ValueError(f"Could not resolve channel handle: {handle}")


def fetch_all_video_ids(youtube, channel_id: str) -> list[dict]:
    """Fetch all video IDs + basic snippet from a channel using pagination."""
    video_ids = []
    page_token = None
    page = 1

    print(f"\n📡  Fetching video list from channel …")

    while True:
        kwargs = dict(
            part="snippet",
            channelId=channel_id,
            maxResults=50,
            order="date",
            type="video",
        )
        if page_token:
            kwargs["pageToken"] = page_token

        resp = youtube.search().list(**kwargs).execute()
        items = resp.get("items", [])
        video_ids.extend(items)

        total_so_far = len(video_ids)
        print(f"   Page {page}: fetched {len(items)} items  (total so far: {total_so_far})")

        page_token = resp.get("nextPageToken")
        if not page_token:
            break
        page += 1

    print(f"✅  Found {len(video_ids)} videos total\n")
    return video_ids


def fetch_video_details(youtube, video_ids: list[str]) -> dict[str, dict]:
    """Batch-fetch full details (snippet + contentDetails + statistics) for video IDs."""
    details = {}
    # YouTube API max 50 per request
    for i in range(0, len(video_ids), 50):
        chunk = video_ids[i : i + 50]
        resp = youtube.videos().list(
            part="snippet,contentDetails,statistics",
            id=",".join(chunk),
        ).execute()
        for item in resp.get("items", []):
            details[item["id"]] = item
        print(f"   Fetched details for videos {i+1}–{min(i+50, len(video_ids))}")
    return details


# ─── Parsing helpers ────────────────────────────────────────────────────────────

def parse_duration(iso_duration: str) -> int:
    """Convert ISO 8601 duration (PT4M13S) → total seconds."""
    match = re.match(
        r"PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?", iso_duration or ""
    )
    if not match:
        return 0
    h = int(match.group(1) or 0)
    m = int(match.group(2) or 0)
    s = int(match.group(3) or 0)
    return h * 3600 + m * 60 + s


def detect_category(title: str, description: str) -> str:
    """Auto-detect video category from title + description keywords."""
    text = f"{title} {description}".lower()
    for keywords, category in CATEGORY_RULES[:-1]:  # skip default
        if any(kw in text for kw in keywords):
            return category
    return "music_videos"  # default


def detect_artist(title: str, description: str, channel_title: str) -> str:
    """Try to extract the featured artist from the title/description."""
    text = f"{title} {description}"
    for artist in KNOWN_ARTISTS:
        if artist.lower() in text.lower():
            return artist
    # Try to parse "Artist - Song" or "Song | Artist" patterns
    dash_match = re.match(r"^([^|–\-]+?)\s*[-–|]\s*", title)
    if dash_match:
        candidate = dash_match.group(1).strip()
        if 2 < len(candidate) < 40:
            return candidate
    return channel_title  # fallback to channel name


def extract_tags(title: str, description: str) -> list[str]:
    """Generate meaningful tags from content."""
    tags = []
    text = f"{title} {description}".lower()
    keyword_tags = {
        "oromo": "oromo",
        "oromoo": "oromo",
        "ethiopian": "ethiopian",
        "ethiopia": "ethiopian",
        "music": "music",
        "official": "official",
        "live": "live",
        "concert": "concert",
        "interview": "interview",
        "podcast": "podcast",
        "classic": "classic",
        "traditional": "traditional",
        "new": "new release",
    }
    for keyword, tag in keyword_tags.items():
        if keyword in text and tag not in tags:
            tags.append(tag)
    return tags[:8]  # cap at 8 tags


def get_best_thumbnail(thumbnails: dict) -> str:
    """Pick the highest-quality thumbnail URL."""
    for quality in ["maxres", "standard", "high", "medium", "default"]:
        if quality in thumbnails:
            return thumbnails[quality]["url"]
    return ""


# ─── Convert to Firestore doc ──────────────────────────────────────────────────

def video_to_firestore(video_id: str, detail: dict) -> dict:
    """Convert a YouTube video API response to a Firestore document."""
    snippet = detail.get("snippet", {})
    content = detail.get("contentDetails", {})
    stats   = detail.get("statistics", {})

    title        = snippet.get("title", "Untitled")
    description  = snippet.get("description", "")
    channel_title = snippet.get("channelTitle", "Vision Entertainment")
    thumbnails   = snippet.get("thumbnails", {})
    published_at = snippet.get("publishedAt", "")
    duration_iso = content.get("duration", "PT0S")
    view_count   = int(stats.get("viewCount", 0))

    thumbnail_url = get_best_thumbnail(thumbnails)
    artist_name   = detect_artist(title, description, channel_title)
    category      = detect_category(title, description)
    duration_secs = parse_duration(duration_iso)
    tags          = extract_tags(title, description)

    release_date = None
    if published_at:
        try:
            release_date = datetime.fromisoformat(published_at.replace("Z", "+00:00"))
        except Exception:
            pass

    return {
        "title":       title,
        "artistName":  artist_name,
        "description": description[:500] if description else None,  # cap description
        "category":    category,
        "thumbnailUrl": thumbnail_url,
        "videoUrl":    f"https://www.youtube.com/watch?v={video_id}",
        "duration":    duration_secs,
        "releaseDate": release_date,
        "isFeatured":  False,      # set manually in Firebase console
        "isPublished": True,
        "viewCount":   view_count,
        "tags":        tags,
        "youtubeId":   video_id,   # extra field for easy reference
        "importedAt":  datetime.now(timezone.utc),
    }


# ─── Dart mock_videos.dart generator ──────────────────────────────────────────

def duration_to_dart(secs: int) -> str:
    m = secs // 60
    s = secs % 60
    return f"Duration(minutes: {m}, seconds: {s})"


def generate_dart(videos: list[dict]) -> str:
    lines = [
        "// AUTO-GENERATED by tools/import_youtube_videos.py",
        f"// Vision Entertainment — {len(videos)} videos",
        f"// Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
        "// DO NOT EDIT MANUALLY — re-run the importer to refresh",
        "",
        "import 'package:visionmusicapp/models/video.dart';",
        "",
        "final List<Video> mockVideos = [",
    ]
    for v in videos:
        vid_id = v["youtubeId"]
        title  = v["title"].replace("'", "\\'")
        artist = v["artistName"].replace("'", "\\'")
        cat    = v["category"]
        thumb  = v["thumbnailUrl"]
        url    = v["videoUrl"]
        dur    = v.get("duration", 0)
        tags   = v.get("tags", [])
        featured = "true" if v.get("isFeatured") else "false"

        dart_id = re.sub(r"[^a-z0-9]", "_", vid_id.lower())
        tags_dart = ", ".join(f"'{t}'" for t in tags)

        lines.append(f"  Video(")
        lines.append(f"    id: '{vid_id}',")
        lines.append(f"    title: '{title}',")
        lines.append(f"    artistName: '{artist}',")
        lines.append(f"    category: '{cat}',")
        lines.append(f"    thumbnailUrl: '{thumb}',")
        lines.append(f"    videoUrl: '{url}',")
        if dur:
            lines.append(f"    duration: {duration_to_dart(dur)},")
        lines.append(f"    isFeatured: {featured},")
        if tags:
            lines.append(f"    tags: [{tags_dart}],")
        lines.append(f"  ),")

    lines.append("];")
    lines.append("")
    lines.append("List<Video> get featuredMockVideos => mockVideos.where((v) => v.isFeatured).toList();")
    lines.append("")
    lines.append("Map<String, List<Video>> get mockVideosByCategory {")
    lines.append("  final map = <String, List<Video>>{};")
    lines.append("  for (final v in mockVideos) {")
    lines.append("    map.putIfAbsent(v.category, () => []).add(v);")
    lines.append("  }")
    lines.append("  return map;")
    lines.append("}")
    return "\n".join(lines)


# ─── Firebase upload ────────────────────────────────────────────────────────────

def upload_to_firestore(videos: list[dict], key_path: str):
    if not FIREBASE_AVAILABLE:
        print("\n❌  firebase-admin not installed. Run:  pip3 install firebase-admin")
        return False

    print(f"\n🔥  Connecting to Firebase …")
    if not firebase_admin._apps:
        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)

    db = firestore.client()
    col = db.collection(FIRESTORE_COLLECTION)

    print(f"📤  Uploading {len(videos)} videos to Firestore `{FIRESTORE_COLLECTION}` …")

    batch_size = 400  # Firestore limit is 500 per batch
    total = len(videos)
    uploaded = 0
    skipped  = 0

    for i in range(0, total, batch_size):
        batch = db.batch()
        chunk = videos[i : i + batch_size]
        for v in chunk:
            vid_id = v["youtubeId"]
            doc_ref = col.document(vid_id)
            # Check if already exists
            existing = doc_ref.get()
            if existing.exists:
                skipped += 1
                continue
            # Remove Python datetime objects — convert to Firestore Timestamps
            doc_data = {k: val for k, val in v.items()}
            batch.set(doc_ref, doc_data)
            uploaded += 1
        batch.commit()
        print(f"   Batch {i//batch_size + 1}: committed")

    print(f"\n✅  Upload complete: {uploaded} new, {skipped} already existed")
    return True


# ─── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Import Vision Entertainment YouTube videos → Firebase"
    )
    parser.add_argument("--api-key", required=True, help="YouTube Data API v3 key")
    parser.add_argument("--firebase-key", default="firebase-key.json",
                        help="Path to Firebase service account JSON (default: firebase-key.json)")
    parser.add_argument("--channel-handle", default=CHANNEL_HANDLE,
                        help=f"YouTube channel handle (default: {CHANNEL_HANDLE})")
    parser.add_argument("--dry-run", action="store_true",
                        help="Fetch and preview without uploading to Firestore")
    parser.add_argument("--output-dart", action="store_true",
                        help="Write lib/mock_videos.dart with all videos")
    parser.add_argument("--output-json", action="store_true",
                        help="Write videos.json with all fetched data")
    parser.add_argument("--category-map", action="store_true",
                        help="Print category breakdown before uploading")
    args = parser.parse_args()

    print("=" * 60)
    print("  Vision Entertainment  —  YouTube → Firebase Importer")
    print("=" * 60)
    channel_handle = args.channel_handle
    channel_url = f"https://www.youtube.com/{channel_handle}"

    print(f"  Channel : {channel_url}")
    print(f"  Mode    : {'DRY RUN (no upload)' if args.dry_run else 'LIVE UPLOAD'}")
    print()

    # ── Build YouTube client ────────────────────────────────────────────
    youtube = build("youtube", "v3", developerKey=args.api_key)

    # ── Resolve channel ID ──────────────────────────────────────────────
    print(f"🔍  Resolving channel ID for {channel_handle} …")
    channel_id = get_channel_id(youtube, channel_handle)
    print(f"✅  Channel ID: {channel_id}")

    # ── Fetch video list ────────────────────────────────────────────────
    search_items = fetch_all_video_ids(youtube, channel_id)
    raw_ids = [
        item["id"]["videoId"]
        for item in search_items
        if item.get("id", {}).get("kind") == "youtube#video"
    ]

    if not raw_ids:
        print("❌  No videos found. Check that the channel handle is correct.")
        sys.exit(1)

    # ── Fetch full details ──────────────────────────────────────────────
    print(f"📋  Fetching full details for {len(raw_ids)} videos …")
    details = fetch_video_details(youtube, raw_ids)

    # ── Convert to Firestore format ─────────────────────────────────────
    print(f"\n🔄  Processing videos …")
    firestore_docs = []
    for vid_id in raw_ids:
        if vid_id not in details:
            continue
        doc = video_to_firestore(vid_id, details[vid_id])
        firestore_docs.append(doc)

    print(f"✅  Processed {len(firestore_docs)} videos")

    # ── Category breakdown ──────────────────────────────────────────────
    if args.category_map or args.dry_run:
        category_counts: dict[str, int] = {}
        for doc in firestore_docs:
            cat = doc["category"]
            category_counts[cat] = category_counts.get(cat, 0) + 1

        print("\n📊  Category breakdown (auto-detected):")
        cat_labels = {
            "music_videos":       "Music Videos",
            "live_performances":  "Live Performances",
            "studio_sessions":    "Studio Sessions",
            "interviews":         "Interviews",
            "podcast_clips":      "Podcast Clips",
            "concerts":           "Concerts",
            "new_releases":       "New Releases",
            "oromo_classics":     "Oromo Classics",
        }
        for cat_id, count in sorted(category_counts.items(), key=lambda x: -x[1]):
            label = cat_labels.get(cat_id, cat_id)
            bar = "█" * min(count, 40)
            print(f"   {label:<22} {count:>3}  {bar}")

    # ── Preview (dry run) ───────────────────────────────────────────────
    if args.dry_run:
        print("\n🔍  PREVIEW — first 10 videos:")
        for i, doc in enumerate(firestore_docs[:10]):
            print(f"\n   [{i+1}] {doc['title']}")
            print(f"        Artist   : {doc['artistName']}")
            print(f"        Category : {doc['category']}")
            print(f"        Duration : {doc['duration']}s")
            print(f"        URL      : {doc['videoUrl']}")
        if len(firestore_docs) > 10:
            print(f"\n   … and {len(firestore_docs) - 10} more")
        print("\n⚠️   DRY RUN — nothing was uploaded. Remove --dry-run to upload.")

    # ── Output JSON ─────────────────────────────────────────────────────
    if args.output_json:
        out_path = Path("videos.json")
        # Convert datetime objects for JSON serialization
        def serialize(obj):
            if isinstance(obj, datetime):
                return obj.isoformat()
            raise TypeError(f"Not serializable: {type(obj)}")

        out_path.write_text(
            json.dumps(firestore_docs, indent=2, default=serialize), encoding="utf-8"
        )
        print(f"\n💾  JSON saved: {out_path.resolve()}")

    # ── Output Dart ─────────────────────────────────────────────────────
    if args.output_dart:
        dart_path = Path("../../lib/mock_videos.dart")
        dart_content = generate_dart(firestore_docs)
        dart_path.write_text(dart_content, encoding="utf-8")
        print(f"\n🎯  mock_videos.dart updated: {dart_path.resolve()}")
        print(f"    {len(firestore_docs)} videos written as Dart code")

    # ── Upload to Firestore ─────────────────────────────────────────────
    if not args.dry_run:
        key_path = args.firebase_key
        if not os.path.exists(key_path):
            print(f"\n⚠️   Firebase key not found at '{key_path}'")
            print("     Download it from Firebase Console → Project Settings → Service Accounts")
            print("     → Generate new private key → save as firebase-key.json in tools/")
            print("\n     Or run with --dry-run to preview without uploading.")
            sys.exit(1)
        upload_to_firestore(firestore_docs, key_path)

    print("\n🎉  Done!")


if __name__ == "__main__":
    main()
