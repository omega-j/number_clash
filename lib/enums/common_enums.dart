enum DotType {
  one,
  five,
  twenty,
  fifty,
}

extension DotTypeExtension on DotType {
  int get value {
    switch (this) {
      case DotType.one:
        return 1;
      case DotType.five:
        return 5;
      case DotType.twenty:
        return 20;
      case DotType.fifty:
        return 50;
    }
  }
}

///old TODO: sort dem out:
// Measurement types used throughout the application:
enum MeasurementType {
  fluoride,
  temperature,
  ph,
  realTime,
  graph,
  data,
}

// Connection status codes:
enum ConnectionStatusCode {
  connected,
  paused,
  disconnected,
}

// Status codes or other enums can be added here as the project grows:
enum StatusCode {
  success,
  error,
  loading,
}

enum DataFileType {
  csv,
  image,
  pdf,
  json,
  unknown,
}

enum LanguageCode {
  arabic('ar'),
  bulgarian('bg'),
  catalan('ca'),
  chineseSimplified('zh-Hans'),
  chineseTraditional('zh-Hant'),
  croatian('hr'),
  czech('cs'),
  danish('da'),
  dutch('nl'),
  english('en'),
  estonian('et'),
  finnish('fi'),
  french('fr'),
  german('de'),
  greek('el'),
  hebrew('he'),
  hindi('hi'),
  hungarian('hu'),
  icelandic('is'),
  indonesian('id'),
  italian('it'),
  japanese('ja'),
  korean('ko'),
  latvian('lv'),
  lithuanian('lt'),
  maltese('mt'),
  norwegian('no'),
  polish('pl'),
  portuguese('pt'),
  romanian('ro'),
  russian('ru'),
  serbian('sr'),
  slovak('sk'),
  slovenian('sl'),
  spanish('es'),
  swedish('sv'),
  thai('th'),
  turkish('tr'),
  ukrainian('uk'),
  vietnamese('vi'),
  welsh('cy'),
  zulu('zu');

  final String code;

  const LanguageCode(this.code);

  String get value => code;

  // Method to convert string to LanguageCode
  static LanguageCode? fromString(String code) {
    try {
      return LanguageCode.values.firstWhere((locale) => locale.code == code);
    } catch (e) {
      return null; // Return null if no match is found
    }
  }
}

enum LogLevel { debug, info, warning, error, view }

enum DialogType { info, error, warning }
