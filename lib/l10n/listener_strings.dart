import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

extension ListenerStrings on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

String localizedVideoCategory(
  BuildContext context,
  String id,
  String fallback,
) {
  final l10n = context.l10n;
  return switch (id) {
    'music_videos' => l10n.categoryMusic,
    'live_performances' => l10n.categoryLive,
    'studio_sessions' => l10n.categoryStudio,
    'interviews' => l10n.categoryInterviews,
    'podcast_clips' => l10n.categoryPodcasts,
    'concerts' => l10n.categoryConcerts,
    'new_releases' => l10n.categoryNew,
    'oromo_classics' => l10n.categoryClassics,
    _ => fallback,
  };
}
