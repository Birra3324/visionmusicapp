// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'Vision Music';

  @override
  String get home => 'ዋና ገጽ';

  @override
  String get search => 'ፈልግ';

  @override
  String get play => 'አጫውት';

  @override
  String get pause => 'ፋታ';

  @override
  String get next => 'ሚቀጥለው';

  @override
  String get previous => 'ወደ ኋላ';

  @override
  String get shuffle => 'በዘፈቀደ';

  @override
  String get repeat => 'ድገም';

  @override
  String get lyrics => 'ግጥሞች';

  @override
  String get detectLanguage => 'ቋንቋውን ለይ';

  @override
  String get detectSong => 'ዘፈኑን ለይ';

  @override
  String get settings => 'ቅንብሮች';

  @override
  String get equalizer => 'ድምጽ አመጣጣን';

  @override
  String get speed => 'ፍጥነት';

  @override
  String get loop => 'ደጋግም';

  @override
  String get transpose => 'የድምፅ ከፍታ ቀይር';

  @override
  String get language => 'ቋንቋ';

  @override
  String get languageChanged => 'ቋንቋ ወደ አማርኛ ተቀየረ';

  @override
  String get comingSoon => 'በቅርቡ ይመጣል';

  @override
  String get aiTranslationNotConnected => 'የ AI ትርጉም ሞተር ገና አልተገናኘም';

  @override
  String get generateLyrics => 'ግጥሞች ይፈጠሩ';

  @override
  String get translateLyrics => 'ግጥሞች ተረጉም';

  @override
  String get selectLanguage => 'ቋንቋ ይምረጡ';

  @override
  String get originalLyrics => 'ዋናዎቹ ግጥሞች';

  @override
  String get translatedLyrics => 'የተተረጉሙ ግጥሞች';

  @override
  String get noLyricsAvailable => 'ምንም ግጥሞች የሉም';

  @override
  String get audioLanguageDetectionComing => 'የድምፅ ቋንቋ መለየት በቅርቡ ይመጣል';

  @override
  String get watch => 'ይመልከቱ';

  @override
  String get library => 'ማዕከለ ሙዚቃ';

  @override
  String get profile => 'መገለጫ';

  @override
  String get playback => 'መልሶ ማጫወት';

  @override
  String get autoplay => 'በራስ አጫውት';

  @override
  String get autoplayDescription => 'በማጫወቻ ተራው ያለውን ቀጣይ ዘፈን በራስ ሰር ያጫውቱ';

  @override
  String get shuffleDescription => 'ዘፈኖችን በዘፈቀደ ቅደም ተከተል አጫውት';

  @override
  String get repeatDescription => 'የአሁኑን ዝርዝር ድገም';

  @override
  String get searchDescription =>
      'በVision Music ማውጫ ውስጥ ዘፈኖችን፣ አርቲስቶችን እና አልበሞችን ያግኙ።';

  @override
  String get searchHint => 'ዘፈኖች፣ አርቲስቶች፣ አልበሞች…';

  @override
  String get searchQuestion => 'ምን መስማት ይፈልጋሉ?';

  @override
  String get searchInstructions => 'በዘፈን፣ አርቲስት ወይም አልበም ይፈልጉ።';

  @override
  String get noMatches => 'ተዛማጅ ውጤት አልተገኘም።';

  @override
  String get continueAsGuest => 'እንደ እንግዳ ይቀጥሉ';

  @override
  String get welcome => 'እንኳን ወደ Vision Music በደህና መጡ';

  @override
  String greeting(String name) {
    return 'እንኳን በደህና መጡ፣ $name';
  }

  @override
  String get recent => 'የቅርብ ጊዜ';

  @override
  String get all => 'ሁሉም';

  @override
  String get added => 'የተጨመሩ';

  @override
  String get listen => 'ያዳምጡ';

  @override
  String get music => 'ሙዚቃ';

  @override
  String get videos => 'ቪዲዮዎች';

  @override
  String get exploreMusic => 'ሙዚቃ ያስሱ';

  @override
  String get seeAll => 'ሁሉንም ይመልከቱ';

  @override
  String get audioCatalogTitle => 'የድምፅ ሙዚቃ ስብስባችን እየተዘጋጀ ነው';

  @override
  String get audioCatalogDescription =>
      'የድምፅ ሙዚቃዎቹን እስክናዘጋጅ ድረስ የVision Entertainment ይፋዊ የሙዚቃ ቪዲዮዎችን ይመልከቱ።';

  @override
  String get watchMusicVideos => 'የሙዚቃ ቪዲዮዎችን ይመልከቱ';

  @override
  String get guestListener => 'እንግዳ አድማጭ';

  @override
  String get activitySaved => 'የማዳመጥ ታሪክዎ በዚህ መሣሪያ ላይ ይቀመጣል።';

  @override
  String get loginDescription =>
      'የኦሮሞ አርቲስቶችን፣ አልበሞችን፣ ዘፈኖችን እና የሙዚቃ ቪዲዮዎችን ያግኙ።';

  @override
  String get signInGoogle => 'በGoogle ይግቡ';

  @override
  String get signInUnavailable => 'ለጊዜው መግባት አይቻልም';

  @override
  String get guestAvailable => 'ሳይገቡ መቀጠል ይችላሉ።';

  @override
  String get localActivity => 'ተወዳጆች እና የቅርብ ጊዜ ማዳመጥ በዚህ መሣሪያ ላይ ይቀመጣሉ።';

  @override
  String signedInAs(String name) {
    return 'እንደ $name ገብተዋል';
  }

  @override
  String get favorites => 'ተወዳጆች';

  @override
  String get favoritesHint => 'ዘፈን እዚህ ለማስቀመጥ የልብ ምልክቱን ይንኩ።';

  @override
  String get favoritesEmpty => 'ተወዳጆችዎ እዚህ ይታያሉ።';

  @override
  String get exploreCatalog => 'ስብስቡን ያስሱ';

  @override
  String get recentlyPlayed => 'በቅርቡ የተጫወቱ';

  @override
  String get recentHint => 'ያዳመጧቸው ዘፈኖች እዚህ ይታያሉ።';

  @override
  String get recentEmpty => 'ታሪክዎን ለመጀመር ዘፈን ያጫውቱ።';

  @override
  String get yourCollection => 'የእርስዎ ስብስብ';

  @override
  String get collectionHint => 'የተቀመጡ ሙዚቃዎችዎ እና ዝርዝሮችዎ።';

  @override
  String get playlists => 'የማጫወቻ ዝርዝሮች';

  @override
  String get playlistsHint => 'የማዳመጫ ዝርዝሮችን ይፍጠሩ እና ያደራጁ';

  @override
  String get artists => 'አርቲስቶች';

  @override
  String get albums => 'አልበሞች';

  @override
  String get songs => 'ዘፈኖች';

  @override
  String get noAlbums => 'እስካሁን አልበሞች የሉም።';

  @override
  String songCount(int count) {
    return 'ዘፈኖች፦ $count';
  }

  @override
  String artistCount(int count) {
    return 'አርቲስቶች፦ $count';
  }

  @override
  String albumCount(int count) {
    return 'አልበሞች፦ $count';
  }

  @override
  String favoriteCount(int count) {
    return 'ተወዳጆች፦ $count';
  }

  @override
  String recentCount(int count) {
    return 'በቅርቡ የተጫወቱ፦ $count';
  }

  @override
  String get videoLibraryHint => 'የሙዚቃ ቪዲዮዎች፣ ፖድካስቶች እና ሌሎችም';

  @override
  String get removeFavorite => 'ከተወዳጆች ያስወግዱ';

  @override
  String get addFavorite => 'ወደ ተወዳጆች ያክሉ';

  @override
  String get channelDescription => 'የሙዚቃ ቪዲዮዎቻችንን በYouTube ይመልከቱ።';

  @override
  String get openChannel => 'የYouTube ቻናሉን ይክፈቱ';

  @override
  String get loadingVideos => 'ቪዲዮዎች እየተጫኑ ነው…';

  @override
  String get videoLoadError => 'ቪዲዮዎችን መጫን አልተቻለም';

  @override
  String get checkConnection => 'እባክዎ ግንኙነትዎን ያረጋግጡ እና እንደገና ይሞክሩ።';

  @override
  String get retry => 'እንደገና ይሞክሩ';

  @override
  String get searchVideos => 'ቪዲዮዎችን ይፈልጉ';

  @override
  String get videoSearchHint => 'ቪዲዮዎች እና አርቲስቶች';

  @override
  String get clear => 'አጽዳ';

  @override
  String get back => 'ተመለስ';

  @override
  String get noVideoMatches => 'ተዛማጅ ቪዲዮዎች አልተገኙም።';

  @override
  String get featured => 'ተመራጮች';

  @override
  String get upNext => 'ቀጣይ';

  @override
  String get openYouTube => 'በYouTube ይክፈቱ';

  @override
  String get watchYouTube => 'በYouTube ይመልከቱ';

  @override
  String get playVideo => 'ቪዲዮውን ያጫውቱ';

  @override
  String get videoUnpublished => 'ይህ ቪዲዮ ገና አልታተመም።';

  @override
  String get videoPlaybackError =>
      'ይህን ቪዲዮ ማጫወት አልተቻለም። ግንኙነትዎን ያረጋግጡ እና እንደገና ይሞክሩ።';

  @override
  String get noCategoryVideos => 'በዚህ ምድብ ቪዲዮዎች የሉም';

  @override
  String get youTubeError => 'YouTubeን መክፈት አልተቻለም። እንደገና ይሞክሩ።';

  @override
  String get lyricsLoadError => 'ግጥሞችን መጫን አልተቻለም';

  @override
  String get tryLater => 'እባክዎ ከትንሽ ጊዜ በኋላ እንደገና ይሞክሩ።';

  @override
  String get lyricsUnavailable => 'ግጥሞች ገና አልተገኙም';

  @override
  String get lyricsSourceHint => 'ከአርቲስቱ ወይም ፈቃድ ካለው ምንጭ የተገኙ ግጥሞችን ብቻ እናሳያለን።';

  @override
  String get volume => 'የድምፅ መጠን';

  @override
  String volumePercent(int count) {
    return '$count በመቶ';
  }

  @override
  String get noSongPlaying => 'የሚጫወት ዘፈን የለም';

  @override
  String get playbackPosition => 'የማጫወቻ ቦታ';

  @override
  String get songPlaybackError => 'ይህን ዘፈን ማጫወት አልተቻለም። እንደገና ይሞክሩ።';

  @override
  String get newPlaylist => 'አዲስ የማጫወቻ ዝርዝር';

  @override
  String get renamePlaylist => 'የዝርዝሩን ስም ይቀይሩ';

  @override
  String get playlistName => 'የዝርዝሩ ስም';

  @override
  String get cancel => 'ይቅር';

  @override
  String get create => 'ፍጠር';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get delete => 'ሰርዝ';

  @override
  String get rename => 'ስም ቀይር';

  @override
  String get deletePlaylistTitle => 'የማጫወቻ ዝርዝሩ ይሰረዝ?';

  @override
  String deletePlaylistMessage(String name) {
    return '“$name” ይሰረዝ? ዘፈኖቹ በስብስብዎ ውስጥ ይቀራሉ።';
  }

  @override
  String get createPlaylist => 'የማጫወቻ ዝርዝር ይፍጠሩ';

  @override
  String get noPlaylists => 'የማጫወቻ ዝርዝሮች የሉም';

  @override
  String managePlaylist(String name) {
    return '$nameን ያስተዳድሩ';
  }

  @override
  String get emptyPlaylist => 'ይህ ዝርዝር ባዶ ነው። ከዘፈኑ ምናሌ ዘፈኖችን ያክሉ።';

  @override
  String moreSongOptions(String title) {
    return 'ተጨማሪ አማራጮች፦ $title';
  }

  @override
  String get removeFromPlaylist => 'ከዝርዝሩ ያስወግዱ';

  @override
  String get addToQueue => 'ወደ ማጫወቻ ተራ ያክሉ';

  @override
  String get removeFromLibrary => 'ከማዕከለ ሙዚቃ ያስወግዱ';

  @override
  String get addToLibrary => 'ወደ ማዕከለ ሙዚቃ ያክሉ';

  @override
  String get addToPlaylist => 'ወደ ማጫወቻ ዝርዝር ያክሉ';

  @override
  String get share => 'አጋራ';

  @override
  String get shareCopied => 'የማጋሪያ ጽሑፍ ተቀድቷል።';

  @override
  String get addedToPlaylist => 'ወደ ዝርዝሩ ተጨምሯል።';

  @override
  String watchSong(String title) {
    return '$titleን በYouTube ይመልከቱ';
  }

  @override
  String playSong(String title) {
    return '$titleን ያጫውቱ';
  }

  @override
  String playSongBy(String artist, String title) {
    return 'የ$artistን $title ያጫውቱ';
  }

  @override
  String get startupError => 'Vision Musicን ማስጀመር አልተቻለም።';

  @override
  String get loadingApp => 'Vision Music እየተከፈተ ነው…';

  @override
  String get slowConnection => 'ይህ ከተለመደው በላይ ጊዜ እየወሰደ ነው። ግንኙነትዎን ያረጋግጡ።';

  @override
  String get allowSignInWindow =>
      'በአሳሽዎ የGoogle መግቢያ መስኮትን ይፍቀዱ፣ ከዚያ እንደገና ይሞክሩ።';

  @override
  String get signInCanceled => 'መግባት ተሰርዟል። እንደገና ይሞክሩ ወይም እንደ እንግዳ ይቀጥሉ።';

  @override
  String get accountUnavailable => 'ይህ መለያ አይገኝም። እባክዎ ድጋፍን ያነጋግሩ።';

  @override
  String get noArtistSongs => 'የዚህ አርቲስት ዘፈኖች እስካሁን የሉም።';

  @override
  String get categoryMusic => 'የሙዚቃ ቪዲዮዎች';

  @override
  String get categoryLive => 'የቀጥታ ትርኢቶች';

  @override
  String get categoryStudio => 'የስቱዲዮ ትርኢቶች';

  @override
  String get categoryInterviews => 'ቃለ መጠይቆች';

  @override
  String get categoryPodcasts => 'የፖድካስት ክፍሎች';

  @override
  String get categoryConcerts => 'ኮንሰርቶች';

  @override
  String get categoryNew => 'አዳዲስ ልቀቶች';

  @override
  String get categoryClassics => 'የቆዩ የኦሮሞ ዘፈኖች';
}
