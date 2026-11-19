// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Vision Music';

  @override
  String get home => 'الرئيسية';

  @override
  String get search => 'بحث';

  @override
  String get play => 'تشغيل';

  @override
  String get pause => 'إيقاف';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get shuffle => 'خلط';

  @override
  String get repeat => 'إعادة';

  @override
  String get lyrics => 'كلمات';

  @override
  String get detectLanguage => 'الكشف عن اللغة';

  @override
  String get detectSong => 'كشف الأغنية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get equalizer => 'معادل';

  @override
  String get speed => 'السرعة';

  @override
  String get loop => 'حلقة';

  @override
  String get transpose => 'تحويل';

  @override
  String get language => 'اللغة';

  @override
  String get languageChanged => 'تم تغيير اللغة إلى العربية';

  @override
  String get comingSoon => 'قريبا';

  @override
  String get aiTranslationNotConnected =>
      'محرك الترجمة الاصطناعي غير متصل حاليا';

  @override
  String get generateLyrics => 'إنشاء كلمات';

  @override
  String get translateLyrics => 'ترجمة كلمات';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get originalLyrics => 'الكلمات الأصلية';

  @override
  String get translatedLyrics => 'الكلمات المترجمة';

  @override
  String get noLyricsAvailable => 'لا توجد كلمات متاحة';

  @override
  String get audioLanguageDetectionComing => 'قادم قريبا: كشف لغة الصوت';

  @override
  String get watch => 'شاهد';

  @override
  String get library => 'المكتبة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get playback => 'التشغيل';

  @override
  String get autoplay => 'التشغيل التلقائي';

  @override
  String get autoplayDescription =>
      'تشغيل الأغنية التالية في قائمة الانتظار تلقائيًا';

  @override
  String get shuffleDescription => 'تشغيل الأغاني بترتيب عشوائي';

  @override
  String get repeatDescription => 'تكرار قائمة التشغيل الحالية';

  @override
  String get searchDescription =>
      'ابحث عن الأغاني والفنانين والألبومات في مكتبة Vision Music.';

  @override
  String get searchHint => 'أغانٍ، فنانون، ألبومات…';

  @override
  String get searchQuestion => 'ماذا تريد أن تسمع؟';

  @override
  String get searchInstructions => 'ابحث حسب الأغنية أو الفنان أو الألبوم.';

  @override
  String get noMatches => 'لم يتم العثور على نتائج.';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get welcome => 'مرحبًا بك في Vision Music';

  @override
  String greeting(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get recent => 'الأخيرة';

  @override
  String get all => 'الكل';

  @override
  String get added => 'المضافة';

  @override
  String get listen => 'استمع';

  @override
  String get music => 'الموسيقى';

  @override
  String get videos => 'الفيديوهات';

  @override
  String get exploreMusic => 'اكتشف الموسيقى';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get audioCatalogTitle => 'كتالوج الموسيقى قيد الإعداد';

  @override
  String get audioCatalogDescription =>
      'شاهد فيديوهات Vision Entertainment الرسمية ريثما نجهّز الإصدارات الصوتية.';

  @override
  String get watchMusicVideos => 'شاهد فيديوهات الموسيقى';

  @override
  String get guestListener => 'مستمع ضيف';

  @override
  String get activitySaved => 'يُحفظ نشاط استماعك على هذا الجهاز.';

  @override
  String get loginDescription =>
      'اكتشف فناني الأورومو وألبوماتهم وأغانيهم وفيديوهاتهم الموسيقية.';

  @override
  String get signInGoogle => 'تسجيل الدخول باستخدام Google';

  @override
  String get signInUnavailable => 'تسجيل الدخول غير متاح مؤقتًا';

  @override
  String get guestAvailable => 'يمكنك المتابعة دون تسجيل الدخول.';

  @override
  String get localActivity => 'تُحفظ المفضلة وسجل الاستماع على هذا الجهاز.';

  @override
  String signedInAs(String name) {
    return 'تم تسجيل الدخول باسم $name';
  }

  @override
  String get favorites => 'المفضلة';

  @override
  String get favoritesHint => 'اضغط على القلب بجانب أي أغنية لحفظها هنا.';

  @override
  String get favoritesEmpty => 'ستظهر مفضلتك هنا.';

  @override
  String get exploreCatalog => 'تصفح الكتالوج';

  @override
  String get recentlyPlayed => 'تم تشغيلها مؤخرًا';

  @override
  String get recentHint => 'سيظهر ما استمعت إليه هنا.';

  @override
  String get recentEmpty => 'شغّل أغنية لبدء سجل الاستماع.';

  @override
  String get yourCollection => 'مجموعتك';

  @override
  String get collectionHint => 'موسيقاك وقوائم تشغيلك المحفوظة.';

  @override
  String get playlists => 'قوائم التشغيل';

  @override
  String get playlistsHint => 'أنشئ قوائم الاستماع ونظّمها';

  @override
  String get artists => 'الفنانون';

  @override
  String get albums => 'الألبومات';

  @override
  String get songs => 'الأغاني';

  @override
  String get noAlbums => 'لا توجد ألبومات بعد.';

  @override
  String songCount(int count) {
    return 'الأغاني: $count';
  }

  @override
  String artistCount(int count) {
    return 'الفنانون: $count';
  }

  @override
  String albumCount(int count) {
    return 'الألبومات: $count';
  }

  @override
  String favoriteCount(int count) {
    return 'المفضلة: $count';
  }

  @override
  String recentCount(int count) {
    return 'تم تشغيلها مؤخرًا: $count';
  }

  @override
  String get videoLibraryHint => 'فيديوهات موسيقية وبودكاست والمزيد';

  @override
  String get removeFavorite => 'إزالة من المفضلة';

  @override
  String get addFavorite => 'إضافة إلى المفضلة';

  @override
  String get channelDescription => 'شاهد فيديوهاتنا الموسيقية على YouTube.';

  @override
  String get openChannel => 'فتح قناة YouTube';

  @override
  String get loadingVideos => 'جارٍ تحميل الفيديوهات…';

  @override
  String get videoLoadError => 'تعذر تحميل الفيديوهات';

  @override
  String get checkConnection => 'تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get searchVideos => 'البحث عن فيديوهات';

  @override
  String get videoSearchHint => 'الفيديوهات والفنانون';

  @override
  String get clear => 'مسح';

  @override
  String get back => 'رجوع';

  @override
  String get noVideoMatches => 'لا توجد فيديوهات مطابقة.';

  @override
  String get featured => 'مختارة';

  @override
  String get upNext => 'التالي';

  @override
  String get openYouTube => 'فتح في YouTube';

  @override
  String get watchYouTube => 'شاهد على YouTube';

  @override
  String get playVideo => 'تشغيل الفيديو';

  @override
  String get videoUnpublished => 'لم يُنشر هذا الفيديو بعد.';

  @override
  String get videoPlaybackError =>
      'تعذر تشغيل الفيديو. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get noCategoryVideos => 'لا توجد فيديوهات في هذه الفئة';

  @override
  String get youTubeError => 'تعذر فتح YouTube. حاول مرة أخرى.';

  @override
  String get lyricsLoadError => 'تعذر تحميل الكلمات';

  @override
  String get tryLater => 'حاول مرة أخرى بعد قليل.';

  @override
  String get lyricsUnavailable => 'الكلمات غير متاحة بعد';

  @override
  String get lyricsSourceHint => 'نعرض فقط كلمات يقدمها الفنان أو مصدر مرخّص.';

  @override
  String get volume => 'مستوى الصوت';

  @override
  String volumePercent(int count) {
    return '$count بالمئة';
  }

  @override
  String get noSongPlaying => 'لا توجد أغنية قيد التشغيل';

  @override
  String get playbackPosition => 'موضع التشغيل';

  @override
  String get songPlaybackError => 'تعذر تشغيل الأغنية. حاول مرة أخرى.';

  @override
  String get newPlaylist => 'قائمة تشغيل جديدة';

  @override
  String get renamePlaylist => 'إعادة تسمية القائمة';

  @override
  String get playlistName => 'اسم القائمة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get create => 'إنشاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get rename => 'إعادة التسمية';

  @override
  String get deletePlaylistTitle => 'حذف قائمة التشغيل؟';

  @override
  String deletePlaylistMessage(String name) {
    return 'هل تريد حذف «$name»؟ ستبقى الأغاني في الكتالوج.';
  }

  @override
  String get createPlaylist => 'إنشاء قائمة تشغيل';

  @override
  String get noPlaylists => 'لا توجد قوائم تشغيل';

  @override
  String managePlaylist(String name) {
    return 'إدارة $name';
  }

  @override
  String get emptyPlaylist => 'هذه القائمة فارغة. أضف أغاني من قائمة الأغنية.';

  @override
  String moreSongOptions(String title) {
    return 'خيارات إضافية لـ $title';
  }

  @override
  String get removeFromPlaylist => 'إزالة من القائمة';

  @override
  String get addToQueue => 'إضافة إلى قائمة الانتظار';

  @override
  String get removeFromLibrary => 'إزالة من المكتبة';

  @override
  String get addToLibrary => 'إضافة إلى المكتبة';

  @override
  String get addToPlaylist => 'إضافة إلى قائمة تشغيل';

  @override
  String get share => 'مشاركة';

  @override
  String get shareCopied => 'تم نسخ نص المشاركة.';

  @override
  String get addedToPlaylist => 'تمت الإضافة إلى القائمة.';

  @override
  String watchSong(String title) {
    return 'شاهد $title على YouTube';
  }

  @override
  String playSong(String title) {
    return 'تشغيل $title';
  }

  @override
  String playSongBy(String artist, String title) {
    return 'تشغيل $title لـ $artist';
  }

  @override
  String get startupError => 'تعذر بدء Vision Music.';

  @override
  String get loadingApp => 'جارٍ فتح Vision Music…';

  @override
  String get slowConnection =>
      'يستغرق هذا وقتًا أطول من المعتاد. تحقق من اتصالك.';

  @override
  String get allowSignInWindow =>
      'اسمح بنافذة تسجيل الدخول إلى Google في المتصفح، ثم أعد المحاولة.';

  @override
  String get signInCanceled =>
      'تم إلغاء تسجيل الدخول. حاول مرة أخرى أو تابع كضيف.';

  @override
  String get accountUnavailable => 'هذا الحساب غير متاح. تواصل مع الدعم.';

  @override
  String get noArtistSongs => 'لا توجد أغاني لهذا الفنان بعد.';

  @override
  String get categoryMusic => 'فيديوهات موسيقية';

  @override
  String get categoryLive => 'عروض مباشرة';

  @override
  String get categoryStudio => 'جلسات الاستوديو';

  @override
  String get categoryInterviews => 'مقابلات';

  @override
  String get categoryPodcasts => 'مقاطع بودكاست';

  @override
  String get categoryConcerts => 'حفلات موسيقية';

  @override
  String get categoryNew => 'إصدارات جديدة';

  @override
  String get categoryClassics => 'كلاسيكيات الأورومو';
}
