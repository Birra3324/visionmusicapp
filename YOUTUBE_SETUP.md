# YouTube Channel Integration Setup

## Your Channel
- **Name:** Vision Entertainment
- **URL:** https://youtube.com/@visionentertainment4507
- **Handle:** @visionentertainment4507

## Current Status
✅ YouTube repository created and ready
✅ Channel configured in app
✅ Auto-fallback to mock data when API is not configured

## To Fetch Real Videos (Optional)

### Step 1: Get YouTube API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable **YouTube Data API v3**
4. Go to Credentials → Create API Key
5. Copy the API key

### Step 2: Get Channel ID
1. Go to [YouTube Studio](https://studio.youtube.com/)
2. Settings → Channel → Advanced settings
3. Copy your **Channel ID** (starts with UC...)

### Step 3: Configure App
Edit `lib/core/services/youtube_config.dart`:

```dart
static const String? channelId = 'UCxxxxxxxxxxxxxxxxxxx';  // Your channel ID
static const String? apiKey = 'YOUR_API_KEY_HERE';          // Your API key
```

### Step 4: Test
Run the app — videos will now load directly from your YouTube channel!

## Alternative: Manual Firebase Setup
If you don't want to use the YouTube API, you can manually add videos to Firebase:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Firestore Database → Create `videos` collection
3. Add documents with your video details
4. Use the schema in `firebase_video_setup.json`

## Video ID Format
YouTube video URLs look like:
```
https://www.youtube.com/watch?v=VIDEO_ID_HERE
```

The `VIDEO_ID_HERE` is what you need. Examples:
- `https://www.youtube.com/watch?v=dQw4w9WgXcQ` → ID: `dQw4w9WgXcQ`
- `https://youtu.be/ABC123DEF45` → ID: `ABC123DEF45`

## Current Mock Videos
The app currently has 6 placeholder videos. To replace with your real videos:

1. Open `lib/mock_videos.dart`
2. Replace the `videoUrl` values with your real video URLs
3. Update titles, descriptions, and thumbnails to match your content

Example:
```dart
Video(
  id: 'your_video_id',
  title: 'Your Video Title',
  artist: 'Artist Name',
  videoUrl: 'https://www.youtube.com/watch?v=YOUR_REAL_VIDEO_ID',
  type: VideoType.musicVideo,
  // ...
),
```

## Features
- ✅ Loads videos from YouTube API (when configured)
- ✅ Falls back to Firebase Firestore (when available)
- ✅ Falls back to mock data (offline/development)
- ✅ Auto-detects video type from title/description
- ✅ Shows video thumbnails, duration, and metadata
- ✅ Opens YouTube app when user taps play
