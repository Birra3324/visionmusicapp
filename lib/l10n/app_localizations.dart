import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_om.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('om'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Vision Music'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// No description provided for @detectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Detect Language'**
  String get detectLanguage;

  /// No description provided for @detectSong.
  ///
  /// In en, this message translates to:
  /// **'Detect Song'**
  String get detectSong;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @equalizer.
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get equalizer;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @loop.
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get loop;

  /// No description provided for @transpose.
  ///
  /// In en, this message translates to:
  /// **'Transpose'**
  String get transpose;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to English'**
  String get languageChanged;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @aiTranslationNotConnected.
  ///
  /// In en, this message translates to:
  /// **'AI translation engine not connected yet'**
  String get aiTranslationNotConnected;

  /// No description provided for @generateLyrics.
  ///
  /// In en, this message translates to:
  /// **'Generate Lyrics'**
  String get generateLyrics;

  /// No description provided for @translateLyrics.
  ///
  /// In en, this message translates to:
  /// **'Translate Lyrics'**
  String get translateLyrics;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @originalLyrics.
  ///
  /// In en, this message translates to:
  /// **'Original Lyrics'**
  String get originalLyrics;

  /// No description provided for @translatedLyrics.
  ///
  /// In en, this message translates to:
  /// **'Translated Lyrics'**
  String get translatedLyrics;

  /// No description provided for @noLyricsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No lyrics available'**
  String get noLyricsAvailable;

  /// No description provided for @audioLanguageDetectionComing.
  ///
  /// In en, this message translates to:
  /// **'Audio language detection coming soon'**
  String get audioLanguageDetectionComing;

  /// No description provided for @watch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watch;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @playback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playback;

  /// No description provided for @autoplay.
  ///
  /// In en, this message translates to:
  /// **'Autoplay'**
  String get autoplay;

  /// No description provided for @autoplayDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically play the next track in the queue'**
  String get autoplayDescription;

  /// No description provided for @shuffleDescription.
  ///
  /// In en, this message translates to:
  /// **'Play songs in random order'**
  String get shuffleDescription;

  /// No description provided for @repeatDescription.
  ///
  /// In en, this message translates to:
  /// **'Repeat the current queue'**
  String get repeatDescription;

  /// No description provided for @searchDescription.
  ///
  /// In en, this message translates to:
  /// **'Find songs, artists, and albums in the Vision Music catalog.'**
  String get searchDescription;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Songs, artists, albums…'**
  String get searchHint;

  /// No description provided for @searchQuestion.
  ///
  /// In en, this message translates to:
  /// **'What do you want to hear?'**
  String get searchQuestion;

  /// No description provided for @searchInstructions.
  ///
  /// In en, this message translates to:
  /// **'Search by song, artist, or album—or choose a suggestion above.'**
  String get searchInstructions;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches found.'**
  String get noMatches;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vision Music'**
  String get welcome;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String greeting(String name);

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @exploreMusic.
  ///
  /// In en, this message translates to:
  /// **'Explore music'**
  String get exploreMusic;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @audioCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Our audio catalog is on its way'**
  String get audioCatalogTitle;

  /// No description provided for @audioCatalogDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore Vision Entertainment’s official music videos while we prepare the audio releases.'**
  String get audioCatalogDescription;

  /// No description provided for @watchMusicVideos.
  ///
  /// In en, this message translates to:
  /// **'Watch music videos'**
  String get watchMusicVideos;

  /// No description provided for @guestListener.
  ///
  /// In en, this message translates to:
  /// **'Guest listener'**
  String get guestListener;

  /// No description provided for @activitySaved.
  ///
  /// In en, this message translates to:
  /// **'Your listening activity is saved on this device.'**
  String get activitySaved;

  /// No description provided for @loginDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover Oromo artists, albums, songs, and music videos.'**
  String get loginDescription;

  /// No description provided for @signInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInGoogle;

  /// No description provided for @signInUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign in temporarily unavailable'**
  String get signInUnavailable;

  /// No description provided for @guestAvailable.
  ///
  /// In en, this message translates to:
  /// **'You can continue without signing in.'**
  String get guestAvailable;

  /// No description provided for @localActivity.
  ///
  /// In en, this message translates to:
  /// **'Favorites and recent listening are saved on this device.'**
  String get localActivity;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String signedInAs(String name);

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @favoritesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any song to save it here.'**
  String get favoritesHint;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your favorites will appear here.'**
  String get favoritesEmpty;

  /// No description provided for @exploreCatalog.
  ///
  /// In en, this message translates to:
  /// **'Explore catalog'**
  String get exploreCatalog;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get recentlyPlayed;

  /// No description provided for @recentHint.
  ///
  /// In en, this message translates to:
  /// **'What you\'ve been listening to will show up here.'**
  String get recentHint;

  /// No description provided for @recentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Play a song to start your history.'**
  String get recentEmpty;

  /// No description provided for @yourCollection.
  ///
  /// In en, this message translates to:
  /// **'Your Collection'**
  String get yourCollection;

  /// No description provided for @collectionHint.
  ///
  /// In en, this message translates to:
  /// **'Your saved music and playlists.'**
  String get collectionHint;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @playlistsHint.
  ///
  /// In en, this message translates to:
  /// **'Create and organize your listening sets'**
  String get playlistsHint;

  /// No description provided for @artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artists;

  /// No description provided for @albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// No description provided for @songs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs;

  /// No description provided for @noAlbums.
  ///
  /// In en, this message translates to:
  /// **'No albums yet.'**
  String get noAlbums;

  /// No description provided for @songCount.
  ///
  /// In en, this message translates to:
  /// **'Songs: {count}'**
  String songCount(int count);

  /// No description provided for @artistCount.
  ///
  /// In en, this message translates to:
  /// **'Artists: {count}'**
  String artistCount(int count);

  /// No description provided for @albumCount.
  ///
  /// In en, this message translates to:
  /// **'Albums: {count}'**
  String albumCount(int count);

  /// No description provided for @favoriteCount.
  ///
  /// In en, this message translates to:
  /// **'Favorites: {count}'**
  String favoriteCount(int count);

  /// No description provided for @recentCount.
  ///
  /// In en, this message translates to:
  /// **'Recently played: {count}'**
  String recentCount(int count);

  /// No description provided for @videoLibraryHint.
  ///
  /// In en, this message translates to:
  /// **'Music videos, podcasts, and more'**
  String get videoLibraryHint;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addFavorite;

  /// No description provided for @channelDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore our music videos on YouTube.'**
  String get channelDescription;

  /// No description provided for @openChannel.
  ///
  /// In en, this message translates to:
  /// **'Open YouTube channel'**
  String get openChannel;

  /// No description provided for @loadingVideos.
  ///
  /// In en, this message translates to:
  /// **'Loading videos…'**
  String get loadingVideos;

  /// No description provided for @videoLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load videos'**
  String get videoLoadError;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get checkConnection;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @searchVideos.
  ///
  /// In en, this message translates to:
  /// **'Search videos'**
  String get searchVideos;

  /// No description provided for @videoSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Videos and artists'**
  String get videoSearchHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @noVideoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching videos.'**
  String get noVideoMatches;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get upNext;

  /// No description provided for @openYouTube.
  ///
  /// In en, this message translates to:
  /// **'Open in YouTube'**
  String get openYouTube;

  /// No description provided for @watchYouTube.
  ///
  /// In en, this message translates to:
  /// **'Watch on YouTube'**
  String get watchYouTube;

  /// No description provided for @playVideo.
  ///
  /// In en, this message translates to:
  /// **'Play video'**
  String get playVideo;

  /// No description provided for @videoUnpublished.
  ///
  /// In en, this message translates to:
  /// **'This video has not been published yet.'**
  String get videoUnpublished;

  /// No description provided for @videoPlaybackError.
  ///
  /// In en, this message translates to:
  /// **'This video could not be played. Check your connection and try again.'**
  String get videoPlaybackError;

  /// No description provided for @noCategoryVideos.
  ///
  /// In en, this message translates to:
  /// **'No videos in this category'**
  String get noCategoryVideos;

  /// No description provided for @youTubeError.
  ///
  /// In en, this message translates to:
  /// **'Could not open YouTube. Please try again.'**
  String get youTubeError;

  /// No description provided for @lyricsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load lyrics'**
  String get lyricsLoadError;

  /// No description provided for @tryLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get tryLater;

  /// No description provided for @lyricsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Lyrics not available yet'**
  String get lyricsUnavailable;

  /// No description provided for @lyricsSourceHint.
  ///
  /// In en, this message translates to:
  /// **'We only show lyrics provided by the artist or a licensed source.'**
  String get lyricsSourceHint;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @volumePercent.
  ///
  /// In en, this message translates to:
  /// **'{count} percent'**
  String volumePercent(int count);

  /// No description provided for @noSongPlaying.
  ///
  /// In en, this message translates to:
  /// **'No song playing'**
  String get noSongPlaying;

  /// No description provided for @playbackPosition.
  ///
  /// In en, this message translates to:
  /// **'Playback position'**
  String get playbackPosition;

  /// No description provided for @songPlaybackError.
  ///
  /// In en, this message translates to:
  /// **'This song could not be played. Please try again.'**
  String get songPlaybackError;

  /// No description provided for @newPlaylist.
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get newPlaylist;

  /// No description provided for @renamePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Rename Playlist'**
  String get renamePlaylist;

  /// No description provided for @playlistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @deletePlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist?'**
  String get deletePlaylistTitle;

  /// No description provided for @deletePlaylistMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? The songs will stay in your catalog.'**
  String deletePlaylistMessage(String name);

  /// No description provided for @createPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create Playlist'**
  String get createPlaylist;

  /// No description provided for @noPlaylists.
  ///
  /// In en, this message translates to:
  /// **'No Playlists'**
  String get noPlaylists;

  /// No description provided for @managePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Manage {name}'**
  String managePlaylist(String name);

  /// No description provided for @emptyPlaylist.
  ///
  /// In en, this message translates to:
  /// **'This playlist is empty. Add songs from the song menu.'**
  String get emptyPlaylist;

  /// No description provided for @moreSongOptions.
  ///
  /// In en, this message translates to:
  /// **'More options for {title}'**
  String moreSongOptions(String title);

  /// No description provided for @removeFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from Playlist'**
  String get removeFromPlaylist;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to Queue'**
  String get addToQueue;

  /// No description provided for @removeFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Remove from Library'**
  String get removeFromLibrary;

  /// No description provided for @addToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Add to Library'**
  String get addToLibrary;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get addToPlaylist;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareCopied.
  ///
  /// In en, this message translates to:
  /// **'Share text copied.'**
  String get shareCopied;

  /// No description provided for @addedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added to playlist.'**
  String get addedToPlaylist;

  /// No description provided for @watchSong.
  ///
  /// In en, this message translates to:
  /// **'Watch {title} on YouTube'**
  String watchSong(String title);

  /// No description provided for @playSong.
  ///
  /// In en, this message translates to:
  /// **'Play {title}'**
  String playSong(String title);

  /// No description provided for @playSongBy.
  ///
  /// In en, this message translates to:
  /// **'Play {title} by {artist}'**
  String playSongBy(String artist, String title);

  /// No description provided for @startupError.
  ///
  /// In en, this message translates to:
  /// **'Could not start Vision Music.'**
  String get startupError;

  /// No description provided for @loadingApp.
  ///
  /// In en, this message translates to:
  /// **'Opening Vision Music…'**
  String get loadingApp;

  /// No description provided for @slowConnection.
  ///
  /// In en, this message translates to:
  /// **'This is taking longer than usual. Check your connection.'**
  String get slowConnection;

  /// No description provided for @allowSignInWindow.
  ///
  /// In en, this message translates to:
  /// **'Allow the Google sign-in window in your browser, then try again.'**
  String get allowSignInWindow;

  /// No description provided for @signInCanceled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was canceled. Try again or continue as a guest.'**
  String get signInCanceled;

  /// No description provided for @accountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This account is unavailable. Please contact support.'**
  String get accountUnavailable;

  /// No description provided for @noArtistSongs.
  ///
  /// In en, this message translates to:
  /// **'No songs for this artist yet.'**
  String get noArtistSongs;

  /// No description provided for @categoryMusic.
  ///
  /// In en, this message translates to:
  /// **'Music Videos'**
  String get categoryMusic;

  /// No description provided for @categoryLive.
  ///
  /// In en, this message translates to:
  /// **'Live Performances'**
  String get categoryLive;

  /// No description provided for @categoryStudio.
  ///
  /// In en, this message translates to:
  /// **'Studio Sessions'**
  String get categoryStudio;

  /// No description provided for @categoryInterviews.
  ///
  /// In en, this message translates to:
  /// **'Interviews'**
  String get categoryInterviews;

  /// No description provided for @categoryPodcasts.
  ///
  /// In en, this message translates to:
  /// **'Podcast Clips'**
  String get categoryPodcasts;

  /// No description provided for @categoryConcerts.
  ///
  /// In en, this message translates to:
  /// **'Concerts'**
  String get categoryConcerts;

  /// No description provided for @categoryNew.
  ///
  /// In en, this message translates to:
  /// **'New Releases'**
  String get categoryNew;

  /// No description provided for @categoryClassics.
  ///
  /// In en, this message translates to:
  /// **'Oromo Classics'**
  String get categoryClassics;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'am',
    'ar',
    'en',
    'es',
    'fr',
    'om',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'om':
      return AppLocalizationsOm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
