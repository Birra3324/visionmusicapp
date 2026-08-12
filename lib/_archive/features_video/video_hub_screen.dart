import 'package:flutter/material.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/vision_background.dart';

class VideoHubScreen extends StatelessWidget {
  const VideoHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Video',
                  style: TextStyle(
                    color: kTextMain,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This section is not fully launched yet, but the product direction is clear.',
                  style: TextStyle(color: kTextSoft, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: kDarkCard.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.ondemand_video_rounded,
                            color: kVisionGoldLight,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Vision Video roadmap',
                            style: TextStyle(
                              color: kTextMain,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14),
                      _VideoPoint(
                        text: 'Mini desk performances and live sessions',
                      ),
                      _VideoPoint(
                        text: 'Official music videos and artist releases',
                      ),
                      _VideoPoint(
                        text: 'Podcast episodes and clipped highlights',
                      ),
                      _VideoPoint(
                        text:
                            'Featured content for sponsors and branded campaigns',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended next build steps',
                        style: TextStyle(
                          color: kTextMain,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12),
                      _VideoPoint(
                        text: 'Create a video content model and sample dataset',
                      ),
                      _VideoPoint(
                        text:
                            'Design video cards, categories, and detail screen',
                      ),
                      _VideoPoint(
                        text:
                            'Choose playback source: YouTube, hosted files, or backend streaming',
                      ),
                      _VideoPoint(
                        text: 'Add admin workflow for publishing video entries',
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: kVisionGold.withValues(
                        alpha: 0.35,
                      ),
                      disabledForegroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Video module planned for next phase'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoPoint extends StatelessWidget {
  final String text;

  const _VideoPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.circle, size: 8, color: kVisionGoldLight),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: kTextSoft, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
