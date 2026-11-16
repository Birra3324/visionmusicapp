import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../audio_manager.dart';
import '../song.dart';

/// Launch on the tap, before any asynchronous work can lose the web gesture.
Future<void> openSongVideo(
  BuildContext context,
  Song song,
  AudioManager audioManager,
) async {
  if (song.youtubeUrl == null) return;
  var opened = false;
  try {
    opened = await launchUrl(
      Uri.parse(song.youtubeUrl!),
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  } catch (_) {
    // A failed launch leaves audio playing and offers a useful retry message.
  }
  if (!opened) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open YouTube. Please try again.'),
        ),
      );
    }
    return;
  }
  try {
    await audioManager.player.pause();
  } catch (error) {
    debugPrint('Could not pause music for YouTube: $error');
  }
}
