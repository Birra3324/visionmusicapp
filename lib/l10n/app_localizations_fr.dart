// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Vision Music';

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
      'Lire automatiquement le titre suivant de la file';

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

  @override
  String get welcome => 'Bienvenue sur Vision Music';

  @override
  String greeting(String name) {
    return 'Bienvenue, $name';
  }

  @override
  String get recent => 'Récents';

  @override
  String get all => 'Tout';

  @override
  String get added => 'Ajoutés';

  @override
  String get listen => 'Écouter';

  @override
  String get music => 'Musique';

  @override
  String get videos => 'Vidéos';

  @override
  String get exploreMusic => 'Découvrir la musique';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get audioCatalogTitle => 'Notre catalogue audio arrive bientôt';

  @override
  String get audioCatalogDescription =>
      'Découvrez les clips officiels de Vision Entertainment pendant la préparation des versions audio.';

  @override
  String get watchMusicVideos => 'Voir les clips musicaux';

  @override
  String get guestListener => 'Invité';

  @override
  String get activitySaved =>
      'Votre activité d’écoute est enregistrée sur cet appareil.';

  @override
  String get loginDescription =>
      'Découvrez les artistes oromo, leurs albums, chansons et clips.';

  @override
  String get signInGoogle => 'Se connecter avec Google';

  @override
  String get signInUnavailable => 'Connexion temporairement indisponible';

  @override
  String get guestAvailable => 'Vous pouvez continuer sans vous connecter.';

  @override
  String get localActivity =>
      'Les favoris et l’historique sont enregistrés sur cet appareil.';

  @override
  String signedInAs(String name) {
    return 'Connecté en tant que $name';
  }

  @override
  String get favorites => 'Favoris';

  @override
  String get favoritesHint =>
      'Touchez le cœur d’une chanson pour l’enregistrer ici.';

  @override
  String get favoritesEmpty => 'Vos favoris apparaîtront ici.';

  @override
  String get exploreCatalog => 'Explorer le catalogue';

  @override
  String get recentlyPlayed => 'Écoutés récemment';

  @override
  String get recentHint => 'Les titres que vous écoutez apparaîtront ici.';

  @override
  String get recentEmpty =>
      'Écoutez une chanson pour commencer votre historique.';

  @override
  String get yourCollection => 'Votre collection';

  @override
  String get collectionHint => 'Votre musique et vos playlists enregistrées.';

  @override
  String get playlists => 'Playlists';

  @override
  String get playlistsHint => 'Créez et organisez vos playlists';

  @override
  String get artists => 'Artistes';

  @override
  String get albums => 'Albums';

  @override
  String get songs => 'Chansons';

  @override
  String get noAlbums => 'Aucun album pour le moment.';

  @override
  String songCount(int count) {
    return 'Chansons : $count';
  }

  @override
  String artistCount(int count) {
    return 'Artistes : $count';
  }

  @override
  String albumCount(int count) {
    return 'Albums : $count';
  }

  @override
  String favoriteCount(int count) {
    return 'Favoris : $count';
  }

  @override
  String recentCount(int count) {
    return 'Écoutés récemment : $count';
  }

  @override
  String get videoLibraryHint => 'Clips, podcasts et plus encore';

  @override
  String get removeFavorite => 'Retirer des favoris';

  @override
  String get addFavorite => 'Ajouter aux favoris';

  @override
  String get channelDescription => 'Découvrez nos clips sur YouTube.';

  @override
  String get openChannel => 'Ouvrir la chaîne YouTube';

  @override
  String get loadingVideos => 'Chargement des vidéos…';

  @override
  String get videoLoadError => 'Impossible de charger les vidéos';

  @override
  String get checkConnection => 'Vérifiez votre connexion et réessayez.';

  @override
  String get retry => 'Réessayer';

  @override
  String get searchVideos => 'Rechercher des vidéos';

  @override
  String get videoSearchHint => 'Vidéos et artistes';

  @override
  String get clear => 'Effacer';

  @override
  String get back => 'Retour';

  @override
  String get noVideoMatches => 'Aucune vidéo correspondante.';

  @override
  String get featured => 'À la une';

  @override
  String get upNext => 'À suivre';

  @override
  String get openYouTube => 'Ouvrir dans YouTube';

  @override
  String get watchYouTube => 'Voir sur YouTube';

  @override
  String get playVideo => 'Lire la vidéo';

  @override
  String get videoUnpublished => 'Cette vidéo n’a pas encore été publiée.';

  @override
  String get videoPlaybackError =>
      'Impossible de lire cette vidéo. Vérifiez votre connexion et réessayez.';

  @override
  String get noCategoryVideos => 'Aucune vidéo dans cette catégorie';

  @override
  String get youTubeError => 'Impossible d’ouvrir YouTube. Réessayez.';

  @override
  String get lyricsLoadError => 'Impossible de charger les paroles';

  @override
  String get tryLater => 'Réessayez dans un instant.';

  @override
  String get lyricsUnavailable => 'Paroles indisponibles pour le moment';

  @override
  String get lyricsSourceHint =>
      'Seules les paroles fournies par l’artiste ou une source autorisée sont affichées.';

  @override
  String get volume => 'Volume';

  @override
  String volumePercent(int count) {
    return '$count pour cent';
  }

  @override
  String get noSongPlaying => 'Aucune chanson en cours';

  @override
  String get playbackPosition => 'Position de lecture';

  @override
  String get songPlaybackError =>
      'Impossible de lire cette chanson. Réessayez.';

  @override
  String get newPlaylist => 'Nouvelle playlist';

  @override
  String get renamePlaylist => 'Renommer la playlist';

  @override
  String get playlistName => 'Nom de la playlist';

  @override
  String get cancel => 'Annuler';

  @override
  String get create => 'Créer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get rename => 'Renommer';

  @override
  String get deletePlaylistTitle => 'Supprimer la playlist ?';

  @override
  String deletePlaylistMessage(String name) {
    return 'Supprimer « $name » ? Les chansons resteront dans votre catalogue.';
  }

  @override
  String get createPlaylist => 'Créer une playlist';

  @override
  String get noPlaylists => 'Aucune playlist';

  @override
  String managePlaylist(String name) {
    return 'Gérer $name';
  }

  @override
  String get emptyPlaylist =>
      'Cette playlist est vide. Ajoutez des chansons depuis leur menu.';

  @override
  String moreSongOptions(String title) {
    return 'Plus d’options pour $title';
  }

  @override
  String get removeFromPlaylist => 'Retirer de la playlist';

  @override
  String get addToQueue => 'Ajouter à la file';

  @override
  String get removeFromLibrary => 'Retirer de la bibliothèque';

  @override
  String get addToLibrary => 'Ajouter à la bibliothèque';

  @override
  String get addToPlaylist => 'Ajouter à une playlist';

  @override
  String get share => 'Partager';

  @override
  String get shareCopied => 'Texte de partage copié.';

  @override
  String get addedToPlaylist => 'Ajouté à la playlist.';

  @override
  String watchSong(String title) {
    return 'Voir $title sur YouTube';
  }

  @override
  String playSong(String title) {
    return 'Lire $title';
  }

  @override
  String playSongBy(String artist, String title) {
    return 'Lire $title de $artist';
  }

  @override
  String get startupError => 'Impossible de démarrer Vision Music.';

  @override
  String get loadingApp => 'Ouverture de Vision Music…';

  @override
  String get slowConnection =>
      'Cela prend plus de temps que prévu. Vérifiez votre connexion.';

  @override
  String get allowSignInWindow =>
      'Autorisez la fenêtre de connexion Google dans votre navigateur, puis réessayez.';

  @override
  String get signInCanceled =>
      'Connexion annulée. Réessayez ou continuez en tant qu’invité.';

  @override
  String get accountUnavailable =>
      'Ce compte est indisponible. Contactez l’assistance.';

  @override
  String get noArtistSongs => 'Aucune chanson de cet artiste pour le moment.';

  @override
  String get categoryMusic => 'Clips musicaux';

  @override
  String get categoryLive => 'Spectacles en direct';

  @override
  String get categoryStudio => 'Sessions en studio';

  @override
  String get categoryInterviews => 'Entretiens';

  @override
  String get categoryPodcasts => 'Extraits de podcasts';

  @override
  String get categoryConcerts => 'Concerts';

  @override
  String get categoryNew => 'Nouveautés';

  @override
  String get categoryClassics => 'Classiques oromo';
}
