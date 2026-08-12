// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Vision Musique';

  @override
  String get home => 'Accueil';

  @override
  String get search => 'Recherche';

  @override
  String get play => 'Lire';

  @override
  String get pause => 'Pause';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get shuffle => 'Mélanger';

  @override
  String get repeat => 'Répéter';

  @override
  String get lyrics => 'Paroles';

  @override
  String get detectLanguage => 'Détecter la langue';

  @override
  String get detectSong => 'Détecter la chanson';

  @override
  String get settings => 'Paramètres';

  @override
  String get equalizer => 'Égaliseur';

  @override
  String get speed => 'Vitesse';

  @override
  String get loop => 'Boucle';

  @override
  String get transpose => 'Transposer';

  @override
  String get language => 'Langue';

  @override
  String get languageChanged => 'Langue changée en français';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get aiTranslationNotConnected =>
      'Le moteur de traduction IA n\'est pas encore connecté';

  @override
  String get generateLyrics => 'Générer les paroles';

  @override
  String get translateLyrics => 'Traduire les paroles';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get originalLyrics => 'Paroles originales';

  @override
  String get translatedLyrics => 'Paroles traduites';

  @override
  String get noLyricsAvailable => 'Aucune parole disponible';

  @override
  String get audioLanguageDetectionComing =>
      'Détection de la langue audio à venir';

  @override
  String get watch => 'Regarder';

  @override
  String get library => 'Bibliothèque';

  @override
  String get profile => 'Profil';

  @override
  String get playback => 'Lecture';

  @override
  String get autoplay => 'Lecture automatique';

  @override
  String get autoplayDescription =>
      'Lire automatiquement le titre associé suivant';

  @override
  String get shuffleDescription => 'Lire les titres dans un ordre aléatoire';

  @override
  String get repeatDescription => 'Répéter la file d\'attente actuelle';

  @override
  String get searchDescription =>
      'Recherchez des titres, artistes et albums dans le catalogue Vision Music.';

  @override
  String get searchHint => 'Titres, artistes, albums…';

  @override
  String get searchQuestion => 'Que voulez-vous écouter ?';

  @override
  String get searchInstructions => 'Recherchez par titre, artiste ou album.';

  @override
  String get noMatches => 'Aucun résultat trouvé.';

  @override
  String get continueAsGuest => 'Continuer en tant qu\'invité';
}
