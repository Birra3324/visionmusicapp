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
  String get autoplayDescription =>
      'Automatically play the next track in the queue';

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

  @override
  String get welcome => 'Welcome to Vision Music';

  @override
  String greeting(String name) {
    return 'Welcome, $name';
  }

  @override
  String get recent => 'Recent';

  @override
  String get all => 'All';

  @override
  String get added => 'Added';

  @override
  String get listen => 'Listen';

  @override
  String get music => 'Music';

  @override
  String get videos => 'Videos';

  @override
  String get exploreMusic => 'Explore music';

  @override
  String get seeAll => 'See all';

  @override
  String get audioCatalogTitle => 'Our audio catalog is on its way';

  @override
  String get audioCatalogDescription =>
      'Explore Vision Entertainment’s official music videos while we prepare the audio releases.';

  @override
  String get watchMusicVideos => 'Watch music videos';

  @override
  String get guestListener => 'Guest listener';

  @override
  String get activitySaved =>
      'Your listening activity is saved on this device.';

  @override
  String get loginDescription =>
      'Discover Oromo artists, albums, songs, and music videos.';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String get signInUnavailable => 'Sign in temporarily unavailable';

  @override
  String get guestAvailable => 'You can continue without signing in.';

  @override
  String get localActivity =>
      'Favorites and recent listening are saved on this device.';

  @override
  String signedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get favorites => 'Favorites';

  @override
  String get favoritesHint => 'Tap the heart on any song to save it here.';

  @override
  String get favoritesEmpty => 'Your favorites will appear here.';

  @override
  String get exploreCatalog => 'Explore catalog';

  @override
  String get recentlyPlayed => 'Recently Played';

  @override
  String get recentHint => 'What you\'ve been listening to will show up here.';

  @override
  String get recentEmpty => 'Play a song to start your history.';

  @override
  String get yourCollection => 'Your Collection';

  @override
  String get collectionHint => 'Your saved music and playlists.';

  @override
  String get playlists => 'Playlists';

  @override
  String get playlistsHint => 'Create and organize your listening sets';

  @override
  String get artists => 'Artists';

  @override
  String get albums => 'Albums';

  @override
  String get songs => 'Songs';

  @override
  String get noAlbums => 'No albums yet.';

  @override
  String songCount(int count) {
    return 'Songs: $count';
  }

  @override
  String artistCount(int count) {
    return 'Artists: $count';
  }

  @override
  String albumCount(int count) {
    return 'Albums: $count';
  }

  @override
  String favoriteCount(int count) {
    return 'Favorites: $count';
  }

  @override
  String recentCount(int count) {
    return 'Recently played: $count';
  }

  @override
  String get videoLibraryHint => 'Music videos, podcasts, and more';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get channelDescription => 'Explore our music videos on YouTube.';

  @override
  String get openChannel => 'Open YouTube channel';

  @override
  String get loadingVideos => 'Loading videos…';

  @override
  String get videoLoadError => 'Could not load videos';

  @override
  String get checkConnection => 'Please check your connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get searchVideos => 'Search videos';

  @override
  String get videoSearchHint => 'Videos and artists';

  @override
  String get clear => 'Clear';

  @override
  String get back => 'Back';

  @override
  String get noVideoMatches => 'No matching videos.';

  @override
  String get featured => 'Featured';

  @override
  String get upNext => 'Up next';

  @override
  String get openYouTube => 'Open in YouTube';

  @override
  String get watchYouTube => 'Watch on YouTube';

  @override
  String get playVideo => 'Play video';

  @override
  String get videoUnpublished => 'This video has not been published yet.';

  @override
  String get videoPlaybackError =>
      'This video could not be played. Check your connection and try again.';

  @override
  String get noCategoryVideos => 'No videos in this category';

  @override
  String get youTubeError => 'Could not open YouTube. Please try again.';

  @override
  String get lyricsLoadError => 'Could not load lyrics';

  @override
  String get tryLater => 'Please try again in a moment.';

  @override
  String get lyricsUnavailable => 'Lyrics not available yet';

  @override
  String get lyricsSourceHint =>
      'We only show lyrics provided by the artist or a licensed source.';

  @override
  String get volume => 'Volume';

  @override
  String volumePercent(int count) {
    return '$count percent';
  }

  @override
  String get noSongPlaying => 'No song playing';

  @override
  String get playbackPosition => 'Playback position';

  @override
  String get songPlaybackError =>
      'This song could not be played. Please try again.';

  @override
  String get newPlaylist => 'New Playlist';

  @override
  String get renamePlaylist => 'Rename Playlist';

  @override
  String get playlistName => 'Playlist name';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get rename => 'Rename';

  @override
  String get deletePlaylistTitle => 'Delete playlist?';

  @override
  String deletePlaylistMessage(String name) {
    return 'Delete “$name”? The songs will stay in your catalog.';
  }

  @override
  String get createPlaylist => 'Create Playlist';

  @override
  String get noPlaylists => 'No Playlists';

  @override
  String managePlaylist(String name) {
    return 'Manage $name';
  }

  @override
  String get emptyPlaylist =>
      'This playlist is empty. Add songs from the song menu.';

  @override
  String moreSongOptions(String title) {
    return 'More options for $title';
  }

  @override
  String get removeFromPlaylist => 'Remove from Playlist';

  @override
  String get addToQueue => 'Add to Queue';

  @override
  String get removeFromLibrary => 'Remove from Library';

  @override
  String get addToLibrary => 'Add to Library';

  @override
  String get addToPlaylist => 'Add to Playlist';

  @override
  String get share => 'Share';

  @override
  String get shareCopied => 'Share text copied.';

  @override
  String get addedToPlaylist => 'Added to playlist.';

  @override
  String watchSong(String title) {
    return 'Watch $title on YouTube';
  }

  @override
  String playSong(String title) {
    return 'Play $title';
  }

  @override
  String playSongBy(String artist, String title) {
    return 'Play $title by $artist';
  }

  @override
  String get startupError => 'Could not start Vision Music.';

  @override
  String get loadingApp => 'Opening Vision Music…';

  @override
  String get slowConnection =>
      'This is taking longer than usual. Check your connection.';

  @override
  String get allowSignInWindow =>
      'Allow the Google sign-in window in your browser, then try again.';

  @override
  String get signInCanceled =>
      'Sign-in was canceled. Try again or continue as a guest.';

  @override
  String get accountUnavailable =>
      'This account is unavailable. Please contact support.';

  @override
  String get noArtistSongs => 'No songs for this artist yet.';

  @override
  String get categoryMusic => 'Music Videos';

  @override
  String get categoryLive => 'Live Performances';

  @override
  String get categoryStudio => 'Studio Sessions';

  @override
  String get categoryInterviews => 'Interviews';

  @override
  String get categoryPodcasts => 'Podcast Clips';

  @override
  String get categoryConcerts => 'Concerts';

  @override
  String get categoryNew => 'New Releases';

  @override
  String get categoryClassics => 'Oromo Classics';
}
