// ignore_for_file: constant_identifier_names

/// Represents the languages supported for number-to-words conversion.
///
/// Each enum value corresponds to a specific language implementation
/// managed by the [Num2Text] class. The comments indicate the full language
/// name and examples of associated currency codes (ISO 4217). These codes
/// provide context; the actual currency formatting depends on the [CurrencyInfo]
/// provided in the options.
enum Lang {
  /// English (e.g., USD, GBP, AUD, CAD, EUR, INR)
  EN,

  /// Estonian (e.g., EUR)
  ET,

  /// Vietnamese (e.g., VND)
  VI,

  /// Afrikaans (e.g., ZAR)
  AF,

  /// Amharic (e.g., ETB)
  AM,

  /// Arabic (e.g., SAR, AED, EGP, KWD, QAR)
  AR,

  /// Azerbaijani (e.g., AZN)
  AZ,

  /// Belarusian (e.g., BYN)
  BE,

  /// Bulgarian (e.g., BGN, EUR)
  BG,

  /// Bengali (e.g., BDT, INR)
  BN,

  /// Bosnian (e.g., BAM)
  BS,

  /// Czech (e.g., CZK, EUR)
  CS,

  /// Danish (e.g., DKK)
  DA,

  /// German (e.g., EUR, CHF)
  DE,

  /// Greek (e.g., EUR)
  EL,

  /// Spanish (e.g., EUR, MXN, COP, ARS, CLP)
  ES,

  /// Persian/Farsi (e.g., IRR)
  FA,

  /// Finnish (e.g., EUR)
  FI,

  /// Filipino (e.g., PHP)
  FIL,

  /// French (e.g., EUR, CHF, CAD, XOF, XAF)
  FR,

  /// Hausa (e.g., NGN)
  HA,

  /// Hebrew (e.g., ILS)
  HE,

  /// Hindi (e.g., INR)
  HI,

  /// Croatian (e.g., EUR; formerly HRK)
  HR,

  /// Hungarian (e.g., HUF, EUR)
  HU,

  /// Armenian (e.g., AMD)
  HY,

  /// Indonesian (e.g., IDR)
  ID,

  /// Igbo (e.g., NGN)
  IG,

  /// Icelandic (e.g., ISK)
  IS,

  /// Italian (e.g., EUR, CHF)
  IT,

  /// Japanese (e.g., JPY)
  JA,

  /// Georgian (e.g., GEL)
  KA,

  /// Kazakh (e.g., KZT)
  KK,

  /// Khmer (e.g., KHR)
  KM,

  /// Korean (e.g., KRW, KPW)
  KO,

  /// Kyrgyz (e.g., KGS)
  KY,

  /// Lao (e.g., LAK)
  LO,

  /// Lithuanian (e.g., EUR)
  LT,

  /// Latvian (e.g., EUR)
  LV,

  /// Macedonian (e.g., MKD)
  MK,

  /// Mongolian (e.g., MNT)
  MN,

  /// Malay (e.g., MYR, SGD, BND)
  MS,

  /// Maltese (e.g., EUR)
  MT,

  /// Burmese (e.g., MMK)
  MY,

  /// Nepali (e.g., NPR)
  NE,

  /// Dutch (e.g., EUR, ANG, SRD)
  NL,

  /// Norwegian (Bokmål) (e.g., NOK)
  NO,

  /// Polish (e.g., PLN, EUR)
  PL,

  /// Portuguese (e.g., BRL, EUR, AOA, CVE)
  PT,

  /// Romanian (e.g., RON, MDL, EUR)
  RO,

  /// Russian (e.g., RUB)
  RU,

  /// Sinhala (e.g., LKR)
  SI,

  /// Slovak (e.g., EUR)
  SK,

  /// Slovenian (e.g., EUR)
  SL,

  /// Albanian (e.g., ALL, EUR)
  SQ,

  /// Serbian (e.g., RSD, EUR)
  SR,

  /// Swedish (e.g., SEK, EUR)
  SV,

  /// Swahili (e.g., KES, TZS, UGX)
  SW,

  /// Tamil (e.g., INR, LKR, SGD, MYR)
  TA,

  /// Tajik (e.g., TJS)
  TG,

  /// Thai (e.g., THB)
  TH,

  /// Turkmen (e.g., TMT)
  TK,

  /// Turkish (e.g., TRY)
  TR,

  /// Ukrainian (e.g., UAH)
  UK,

  /// Urdu (e.g., PKR, INR)
  UR,

  /// Uzbek (e.g., UZS)
  UZ,

  /// Xhosa (e.g., ZAR)
  XH,

  /// Yoruba (e.g., NGN)
  YO,

  /// Chinese (Mandarin primarily) (e.g., CNY, HKD, TWD, MOP)
  ZH,

  /// Zulu (e.g., ZAR)
  ZU,
}

// Removed the unused `final Lang l = Lang.EN;` variable.
// If it was for internal testing, keep it within a test file or mark it clearly.
