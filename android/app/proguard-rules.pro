# =========================================================
#  Vision Music App — ProGuard / R8 rules
# =========================================================

# ---- Flutter ----
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# ---- Kotlin ----
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# ---- Firebase ----
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ---- audio_service (ryanheise) ----
-keep class com.ryanheise.audioservice.** { *; }
-dontwarn com.ryanheise.audioservice.**

# ---- just_audio ----
-keep class com.ryanheise.just_audio.** { *; }
-dontwarn com.ryanheise.just_audio.**

# ---- audio_session ----
-keep class com.ryanheise.audio_session.** { *; }
-dontwarn com.ryanheise.audio_session.**

# ---- Google Sign-In ----
-keep class com.google.android.gms.auth.** { *; }

# ---- Prevent stripping of MediaSession / MediaBrowserService ----
-keep class android.support.v4.media.** { *; }
-keep class androidx.media.** { *; }
-keep class androidx.media2.** { *; }

# ---- Keep serialisation classes (shared_preferences, json) ----
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# ---- Keep enums ----
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
