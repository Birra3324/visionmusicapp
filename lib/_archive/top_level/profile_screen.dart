import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:visionmusicapp/settings_manager.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/widgets/vision_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsManager>();
    final audioManager = context.watch<AudioManager>();

    return VisionBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildThemeRow(context, settings),
            const SizedBox(height: 24),
            _buildPlaybackSection(context, settings, audioManager),
            const SizedBox(height: 24),
            _buildCrossfadeSection(context, settings),
            const SizedBox(height: 24),
            _buildQualitySection(context, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeRow(BuildContext context, SettingsManager settings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Theme', style: TextStyle(color: kTextMain, fontSize: 15)),
        DropdownButton<ThemeMode>(
          value: settings.themeMode,
          dropdownColor: kDarkCard,
          onChanged: (mode) {
            if (mode != null) settings.themeMode = mode;
          },
          items: const [
            DropdownMenuItem(
              value: ThemeMode.dark,
              child: Text('Dark', style: TextStyle(color: kTextMain)),
            ),
            DropdownMenuItem(
              value: ThemeMode.light,
              child: Text('Light', style: TextStyle(color: kTextMain)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaybackSection(
    BuildContext context,
    SettingsManager settings,
    AudioManager audioManager,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Playback',
          style: TextStyle(
            color: kTextMain,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _settingSwitch(
          title: 'Autoplay',
          subtitle: 'Automatically play next related track',
          value: settings.autoplay,
          onChanged: (v) => settings.autoplay = v,
        ),
        _settingSwitch(
          title: 'Shuffle',
          subtitle: 'Play songs in random order',
          value: settings.shuffle,
          onChanged: (v) => audioManager.toggleShuffle(),
        ),
        _settingSwitch(
          title: 'Repeat',
          subtitle: 'Repeat the current queue',
          value: settings.repeatMode != LoopMode.off,
          onChanged: (v) => audioManager.cycleRepeatMode(),
        ),
      ],
    );
  }

  Widget _buildCrossfadeSection(
    BuildContext context,
    SettingsManager settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Crossfade',
          style: TextStyle(
            color: kTextMain,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: settings.crossfadeSeconds.toDouble(),
          min: 0,
          max: 12,
          activeColor: kVisionGoldLight,
          inactiveColor: Colors.white24,
          onChanged: (value) {
            settings.crossfadeSeconds = value.round();
          },
        ),
        Text(
          'Crossfade: ${settings.crossfadeSeconds} seconds',
          style: const TextStyle(color: kTextSoft, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQualitySection(BuildContext context, SettingsManager settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Audio Quality',
          style: TextStyle(
            color: kTextMain,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Streaming quality',
              style: TextStyle(color: kTextMain, fontSize: 14),
            ),
            DropdownButton<StreamingQuality>(
              value: settings.quality,
              dropdownColor: kDarkCard,
              onChanged: (value) {
                if (value != null) settings.quality = value;
              },
              items: const [
                DropdownMenuItem(
                  value: StreamingQuality.low,
                  child: Text('Low', style: TextStyle(color: kTextMain)),
                ),
                DropdownMenuItem(
                  value: StreamingQuality.normal,
                  child: Text('Normal', style: TextStyle(color: kTextMain)),
                ),
                DropdownMenuItem(
                  value: StreamingQuality.high,
                  child: Text('High', style: TextStyle(color: kTextMain)),
                ),
                DropdownMenuItem(
                  value: StreamingQuality.lossless,
                  child: Text('Lossless', style: TextStyle(color: kTextMain)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _settingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: kTextMain)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: kTextSoft, fontSize: 12),
      ),
      value: value,
      activeColor: kDarkBackground,
      activeTrackColor: kVisionGoldLight,
      onChanged: onChanged,
    );
  }
}
