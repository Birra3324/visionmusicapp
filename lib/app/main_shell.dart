import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/features/library/library_hub_screen.dart';
import 'package:visionmusicapp/features/profile/profile_hub_screen.dart';
import 'package:visionmusicapp/features/search/search_hub_screen.dart';
import 'package:visionmusicapp/features/video/video_hub_screen.dart';
import 'package:visionmusicapp/gold_discover_screen.dart';
import 'package:visionmusicapp/settings_manager.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/mini_player.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final audioManager = context.watch<AudioManager>();
    final settings = context.watch<SettingsManager>();
    // Hide mini player while on the Watch tab (index 1) to avoid audio/video confusion
    final bool showMiniPlayer =
        audioManager.currentSong != null && _currentIndex != 1;

    final pages = <Widget>[
      GoldDiscoverScreen(
        audioManager: audioManager,
        onSwitchTab: (i) => setState(() => _currentIndex = i),
      ),
      const VideoHubScreen(),
      LibraryHubScreen(audioManager: audioManager),
      SearchHubScreen(audioManager: audioManager, settings: settings),
      const ProfileHubScreen(),
    ];

    return Scaffold(
      backgroundColor: kAppBackground,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Mini player sits right above the nav bar ──
          if (showMiniPlayer)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: MiniPlayer(audioManager: audioManager),
            ),

          // ── Navigation bar ──
          ColoredBox(
            color: kSurfaceDark,
            child: SafeArea(
              top: false,
              child: NavigationBar(
                selectedIndex: _currentIndex,
                animationDuration: const Duration(milliseconds: 300),
                onDestinationSelected: (index) {
                  setState(() => _currentIndex = index);
                },
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: l10n.home,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.play_circle_outline_rounded),
                    selectedIcon: const Icon(Icons.play_circle_rounded),
                    label: l10n.watch,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.library_music_outlined),
                    selectedIcon: const Icon(Icons.library_music_rounded),
                    label: l10n.library,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.search_outlined),
                    selectedIcon: const Icon(Icons.search_rounded),
                    label: l10n.search,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline_rounded),
                    selectedIcon: const Icon(Icons.person_rounded),
                    label: l10n.profile,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
