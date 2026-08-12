// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vision Music';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get repeat => 'Repeat';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get detectLanguage => 'Detect Language';

  @override
  String get detectSong => 'Detect Song';

  @override
  String get settings => 'Settings';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get speed => 'Speed';

  @override
  String get loop => 'Loop';

  @override
  String get transpose => 'Transpose';

  @override
  String get language => 'Language';

  @override
  String get languageChanged => 'Language changed to English';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get aiTranslationNotConnected =>
      'AI translation engine not connected yet';

  @override
  String get generateLyrics => 'Generate Lyrics';

  @override
  String get translateLyrics => 'Translate Lyrics';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get originalLyrics => 'Original Lyrics';

  @override
  String get translatedLyrics => 'Translated Lyrics';

  @override
  String get noLyricsAvailable => 'No lyrics available';

  @override
  String get audioLanguageDetectionComing =>
      'Audio language detection coming soon';

  @override
  String get watch => 'Watch';

  @override
  String get library => 'Library';

  @override
  String get profile => 'Profile';

  @override
  String get playback => 'Playback';

  @override
  String get autoplay => 'Autoplay';

  @override
  String get autoplayDescription => 'Automatically play the next related track';

  @override
  String get shuffleDescription => 'Play songs in random order';

  @override
  String get repeatDescription => 'Repeat the current queue';

  @override
  String get searchDescription =>
      'Find songs, artists, and albums in the Vision Music catalog.';

  @override
  String get searchHint => 'Songs, artists, albums…';

  @override
  String get searchQuestion => 'What do you want to hear?';

  @override
  String get searchInstructions =>
      'Search by song, artist, or album—or choose a suggestion above.';

  @override
  String get noMatches => 'No matches found.';

  @override
  String get continueAsGuest => 'Continue as Guest';
}
