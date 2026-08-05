/// Central application-wide constants.
abstract class AppConstants {
  /// Hive box name for storing curriculum lessons used by the AI context pipeline.
  static const String lessonsBox = 'lessons_box';

  /// Hive box name for storing user's local curriculum progress (completed lesson IDs).
  static const String progressBox = 'progress_box';

  /// Maximum number of historical completed lessons to inject into Gemini prompt.
  static const int maxHistoricalLessons = 5;

  /// Maximum character limit for the assembled system prompt.
  static const int maxSystemPromptCharacters = 8000;
}
