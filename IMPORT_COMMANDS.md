# Vision Music — YouTube Import Commands

## Prerequisites

1. **YouTube Data API v3 key**
   - Get from: https://console.cloud.google.com/apis/credentials
   - Create API key → restrict to YouTube Data API v3

2. **Firebase service account key**
   - Get from: https://console.firebase.google.com → Project Settings → Service Accounts
   - Generate new private key → rename to `firebase-key.json`
   - Place in `~/Desktop/visionmusicapp/tools/firebase-key.json`

3. **Python dependencies**
```bash
cd ~/Desktop/visionmusicapp/tools
python3 -m pip install google-api-python-client firebase-admin
```

---

## Commands

### 1. Dry Run (Preview Only — No Upload)

```bash
cd ~/Desktop/visionmusicapp/tools
python3 import_youtube_videos.py \
  --api-key "YOUR_YOUTUBE_API_KEY_HERE" \
  --channel-handle "@visionentertainment4507" \
  --dry-run \
  --category-map
```

This will:
- Fetch all 176 videos from your channel
- Show category breakdown
- Preview first 10 videos
- **Nothing is uploaded**

### 2. Full Import to Firestore

```bash
cd ~/Desktop/visionmusicapp/tools
python3 import_youtube_videos.py \
  --api-key "YOUR_YOUTUBE_API_KEY_HERE" \
  --channel-handle "@visionentertainment4507" \
  --firebase-key "./firebase-key.json"
```

This will:
- Fetch all videos
- Upload to Firestore `videos` collection
- Skip duplicates (safe to re-run)
- Use `youtubeId` as document ID

### 3. Import + Generate Local Mock Data

```bash
cd ~/Desktop/visionmusicapp/tools
python3 import_youtube_videos.py \
  --api-key "YOUR_YOUTUBE_API_KEY_HERE" \
  --channel-handle "@visionentertainment4507" \
  --firebase-key "./firebase-key.json" \
  --output-dart
```

This will:
- Import to Firestore
- Also update `lib/mock_videos.dart` for offline use

### 4. Export to JSON (No Firestore)

```bash
cd ~/Desktop/visionmusicapp/tools
python3 import_youtube_videos.py \
  --api-key "YOUR_YOUTUBE_API_KEY_HERE" \
  --channel-handle "@visionentertainment4507" \
  --dry-run \
  --output-json
```

This creates `videos.json` for inspection.

---

## Firestore Document Structure

Each video document (ID = YouTube video ID):

```json
{
  "title": "Video Title",
  "artistName": "Artist Name",
  "description": "Video description...",
  "category": "music_videos",
  "thumbnailUrl": "https://i.ytimg.com/vi/.../maxresdefault.jpg",
  "videoUrl": "https://www.youtube.com/watch?v=VIDEO_ID",
  "duration": 270,
  "releaseDate": "2024-01-15T00:00:00Z",
  "isFeatured": false,
  "isPublished": true,
  "viewCount": 12500,
  "tags": ["oromo", "official", "music"],
  "youtubeId": "VIDEO_ID",
  "importedAt": "2026-04-30T..."
}
```

Categories: `music_videos`, `live_performances`, `studio_sessions`, `interviews`, `podcast_clips`, `concerts`, `new_releases`, `oromo_classics`

---

## After Import

Videos appear in the app immediately. To feature a video:
1. Open Firebase Console → Firestore → `videos`
2. Find the video
3. Change `isFeatured` from `false` to `true`

Featured videos appear in the hero banner on the Watch tab.
