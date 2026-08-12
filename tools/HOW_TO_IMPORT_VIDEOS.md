# How to Import All 176 Videos into Vision Music App

## What this does
Automatically fetches every video from the **@visionentertainment4507** YouTube channel
and uploads them to your Firebase Firestore database — so they appear in the app instantly.

---

## Step 1 — Get a YouTube API Key (free, takes ~3 minutes)

1. Go to → https://console.cloud.google.com/apis/credentials
2. Sign in with your Google account
3. Click **"Create Credentials"** → **"API key"**
4. Copy the key (looks like: `AIzaSyABCDEFGHIJKLMNOP...`)
5. Optional but recommended: click "Restrict Key" → restrict to **YouTube Data API v3**

---

## Step 2 — Get your Firebase Service Account Key

1. Go to → https://console.firebase.google.com
2. Select your **Vision Music** project
3. Click the ⚙️ gear icon → **Project Settings**
4. Click the **"Service accounts"** tab
5. Click **"Generate new private key"** → **Download JSON**
6. **Rename** the downloaded file to **`firebase-key.json`**
7. **Move it** into this `tools/` folder

---

## Step 3 — Install Python dependencies

Open Terminal and run:
```bash
pip3 install google-api-python-client firebase-admin
```

---

## Step 4 — Run the importer

Open Terminal, navigate to your app's `tools/` folder:
```bash
cd ~/Desktop/visionmusicapp/tools
```

**First, do a dry run to preview** (no changes made):
```bash
python3 import_youtube_videos.py \
  --api-key "YOUR_YOUTUBE_API_KEY_HERE" \
  --channel-handle "@visionentertainment4507" \
  --dry-run \
  --category-map
```

**When ready, upload to Firestore:**
```bash
python3 import_youtube_videos.py \
  --api-key "YOUR_YOUTUBE_API_KEY_HERE" \
  --channel-handle "@visionentertainment4507" \
  --firebase-key "./firebase-key.json"
```

**To also update the app's local mock data (for offline/testing):**
```bash
python3 import_youtube_videos.py \
  --api-key "YOUR_YOUTUBE_API_KEY_HERE" \
  --channel-handle "@visionentertainment4507" \
  --firebase-key "./firebase-key.json" \
  --output-dart
```

---

## What happens automatically

| What | How |
|------|-----|
| **Category** | Auto-detected from video title (e.g. "Live Concert" → Live Performances) |
| **Artist name** | Extracted from title pattern like "Ali Birra - Song Name" |
| **Thumbnail** | Highest quality YouTube thumbnail (maxres/high/medium) |
| **Duration** | Converted from YouTube's format to seconds |
| **Tags** | Auto-tagged: oromo, ethiopian, live, official, etc. |
| **Duplicates** | Skipped — safe to run multiple times |

---

## After importing

Once uploaded to Firestore, videos appear in the app **immediately** — no app update needed.

To **feature** specific videos (shown in the hero banner):
1. Open Firebase Console → Firestore → `videos` collection
2. Click on any video document
3. Change `isFeatured` from `false` to `true`

---

## Troubleshooting

**"quota exceeded"** → YouTube API free tier allows 10,000 units/day. Fetching 176 videos uses ~400 units, well within the limit.

**"firebase-key.json not found"** → Make sure the file is in the `tools/` folder (same folder as this script).

**"channel not found"** → The channel handle `@visionentertainment4507` is hard-coded in the script. No changes needed.
