/// Central application-wide constants.
///
/// Contains Hive box names, AI context limits, and default configuration values.
abstract class AppConstants {
  /// Hive box name for storing curriculum lessons and completion states.
  static const String lessonsBox = 'lessons_box';

  /// Maximum number of historical completed lessons to inject into Gemini prompt.
  static const int maxHistoricalLessons = 5;

  /// Maximum character limit for the assembled system prompt to prevent exceeding context window.
  static const int maxSystemPromptCharacters = 8000;
}
