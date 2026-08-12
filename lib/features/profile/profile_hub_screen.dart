import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/features/auth/auth_service.dart';
import 'package:visionmusicapp/settings_manager.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/vision_background.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';

class ProfileHubScreen extends StatelessWidget {
  const ProfileHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsManager>();
    final audioManager = context.watch<AudioManager>();
    final user = AuthService.instance.isFirebaseReady
        ? FirebaseAuth.instance.currentUser
        : null;

    return VisionBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.profile),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kDarkCard.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: kVisionGold.withValues(alpha: 0.16),
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person_rounded,
                            color: kVisionGoldLight,
                            size: 30,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName?.trim().isNotEmpty == true
                              ? user!.displayName!
                              : 'Guest listener',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: kTextMain,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user?.email ??
                              'Your listening activity is saved on this device.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: kTextSoft,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildLanguageRow(settings, l10n),
            const SizedBox(height: 24),
            _buildPlaybackSection(settings, audioManager, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageRow(SettingsManager settings, AppLocalizations l10n) {
    final languageNames = {
      'en': 'English',
      'om': 'Afaan Oromo',
      'am': 'Amharic',
      'ar': 'العربية',
      'fr': 'Français',
      'es': 'Español',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.language,
          style: const TextStyle(color: kTextMain, fontSize: 15),
        ),
        DropdownButton<String>(
          value: settings.localeCode,
          dropdownColor: kDarkCard,
          onChanged: (code) {
            if (code == null || code == settings.localeCode) return;
            // Let the dropdown's reverse animation finish before rebuilding
            // the MaterialApp. A next-frame callback is too early on iOS and
            // can leave the menu's composited surface over the next screen.
            Future<void>.delayed(const Duration(milliseconds: 350), () {
              settings.localeCode = code;
            });
          },
          items: languageNames.entries
              .map(
                (e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(
                    e.value,
                    style: const TextStyle(color: kTextMain),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPlaybackSection(
    SettingsManager settings,
    AudioManager audioManager,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.playback,
          style: const TextStyle(
            color: kTextMain,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _settingSwitch(
          title: l10n.autoplay,
          subtitle: l10n.autoplayDescription,
          value: settings.autoplay,
          onChanged: (value) => settings.autoplay = value,
        ),
        _settingSwitch(
          title: l10n.shuffle,
          subtitle: l10n.shuffleDescription,
          value: settings.shuffle,
          onChanged: (_) => audioManager.toggleShuffle(),
        ),
        _settingSwitch(
          title: l10n.repeat,
          subtitle: l10n.repeatDescription,
          // Binary view over a 3-state model: OFF vs everything else. Set it
          // directly instead of calling the cycler (which would silently step
          // off→all→one→off and make one tap appear to do nothing when the
          // current state is already "on").
          value: settings.repeatMode != LoopMode.off,
          onChanged: (on) =>
              settings.repeatMode = on ? LoopMode.all : LoopMode.off,
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
      activeThumbColor: kDarkBackground,
      activeTrackColor: kVisionGoldLight,
      onChanged: onChanged,
    );
  }
}
