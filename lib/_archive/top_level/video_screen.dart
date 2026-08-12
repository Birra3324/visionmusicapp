import 'package:flutter/material.dart';
import 'package:visionmusicapp/vision_theme.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kAppBackground,
      body: Center(
        child: Text(
          'Videos coming soon...',
          style: TextStyle(color: kTextSoft),
        ),
      ),
    );
  }
}
