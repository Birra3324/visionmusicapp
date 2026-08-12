// Script Conversion Service
// Converts between different scripts: Latin, Amharic, Arabic, etc.
// Useful for displaying song metadata in different writing systems

class ScriptConversionService {
  static final ScriptConversionService _instance =
      ScriptConversionService._internal();

  factory ScriptConversionService() => _instance;
  ScriptConversionService._internal();

  /// Convert Afaan Oromo from Latin to Ge'ez (Amharic script)
  /// Example: "Hirphaa" -> "ሂርፋ"
  String convertLatinoToGeez(String latinText) {
    // Mapping of common Oromo Latin characters to Ge'ez equivalents
    final latinToGeez = {
      'h': 'ህ',
      'H': 'ሃ',
      'l': 'ል',
      'L': 'ላ',
      'm': 'ም',
      'M': 'ማ',
      'n': 'ን',
      'N': 'ና',
      'r': 'ር',
      'R': 'ራ',
      's': 'ስ',
      'S': 'ሳ',
      'b': 'ብ',
      'B': 'ባ',
      'f': 'ፍ',
      'F': 'ፋ',
      'g': 'ግ',
      'G': 'ጋ',
      'p': 'ፕ',
      'P': 'ፓ',
      'd': 'ድ',
      'D': 'ዳ',
      't': 'ት',
      'T': 'ታ',
      'c': 'ች',
      'C': 'ቻ',
      'j': 'ጅ',
      'J': 'ጃ',
      'k': 'ክ',
      'K': 'ካ',
      'x': 'ች',
      'X': 'ቻ',
      'z': 'ዝ',
      'Z': 'ዛ',
      'y': 'ይ',
      'Y': 'ያ',
      'w': 'ው',
      'W': 'ዋ',
      'q': 'ቅ',
      'Q': 'ቃ',
    };

    // TODO: Implement proper Oromo Latin to Ge'ez conversion
    // This is a simplified mapping - real implementation needs full character set
    var result = latinText;
    latinToGeez.forEach((latin, geez) {
      result = result.replaceAll(latin, geez);
    });

    return result;
  }

  /// Convert text to Arabic script (if applicable for Oromo names)
  /// Not commonly used but available for specialized metadata
  String convertToArabic(String latinText) {
    // TODO: Implement for Oromo words that might have Arabic roots
    // Most Oromo is not typically written in Arabic script
    return latinText;
  }

  /// Transliterate text to IPA (International Phonetic Alphabet)
  /// Useful for pronunciation guides
  String convertToIPA(String text, {required String language}) {
    // TODO: Implement language-specific IPA conversion
    // Language codes: 'om' (Oromo), 'am' (Amharic), 'ar' (Arabic), etc.
    return text;
  }

  /// Normalize text (remove diacritics, standardize script)
  String normalize(String text) {
    // TODO: Implement script normalization
    // Remove combining diacritics, standardize Unicode forms
    return text;
  }

  /// Detect script of given text
  /// Returns: 'latin', 'amharic', 'arabic', 'mixed', etc.
  String detectScript(String text) {
    bool hasArabic = false;
    bool hasAmharic = false;
    bool hasLatin = false;

    for (int i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);

      // Amharic/Ge'ez: U+1200 to U+137F
      if (code >= 0x1200 && code <= 0x137F) {
        hasAmharic = true;
      }
      // Arabic: U+0600 to U+06FF
      else if (code >= 0x0600 && code <= 0x06FF) {
        hasArabic = true;
      }
      // Latin: U+0041 to U+005A (A-Z), U+0061 to U+007A (a-z)
      else if ((code >= 0x0041 && code <= 0x005A) ||
          (code >= 0x0061 && code <= 0x007A)) {
        hasLatin = true;
      }
    }

    if (hasAmharic && !hasLatin && !hasArabic) return 'amharic';
    if (hasArabic && !hasLatin && !hasAmharic) return 'arabic';
    if (hasLatin && !hasAmharic && !hasArabic) return 'latin';
    if ((hasLatin || hasAmharic || hasArabic) &&
        (hasLatin && (hasAmharic || hasArabic))) {
      return 'mixed';
    }
    return 'unknown';
  }
}
