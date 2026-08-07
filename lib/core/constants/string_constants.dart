class StringConstants {
  StringConstants._();

  // App Level
  static const String appName = 'Flutter AI Tutor';

  // Phases Screen
  static const String phasesTitle = 'Learning Phases';
  static const String phasesSubtitle =
      'Follow a structured roadmap from Dart fundamentals to production-ready Flutter development.';
  static const String phasePrefix = 'PHASE';
  static const String continueLearning = 'Continue Learning';
  static const String reviewPhase = 'Review Phase';

  // Modules Screen
  static const String modulesTitle = 'Modules';
  static const String modulesSubtitle =
      'Build your knowledge step by step by completing every module in this phase.';
  static const String modulePrefix = 'MODULE';
  static const String currentLabel = 'CURRENT';
  static const String progressLabel = 'PROGRESS';

  // Days Screen
  static const String daysTitle = 'Lessons';
  static const String daysSubtitle =
      'Complete every lesson to strengthen your understanding before moving forward.';
  static const String dayPrefix = 'DAY';

  // Lesson Screen
  static const String preparingLesson = 'Preparing your lesson...';
  static const String lessonUnavailable = 'Lesson Unavailable';
  static const String lessonErrorApology =
      'We apologise for your experience. Please read and learn other days\' lessons in the remaining time.';
  static const String goBack = 'Go Back';
  static const String tryAgain = 'Try Again';
  static const String relatedTags = 'Related Tags';
  static const String prerequisites = 'Prerequisites';
  static const String lastUpdated = 'Last updated:';

  // AI Tutor
  static const String aiTutorUnexpectedError =
      'An unexpected error occurred while communicating with the AI Tutor.';
  static const String aiTutorGenericError =
      'An unexpected error occurred. Please try again.';

  // API Key Errors
  static const String missingGeminiKey =
      'Gemini API Key is missing. Please configure it to use this model.';
  static const String missingOpenAiKey =
      'OpenAI API Key is missing. Please configure it to use this model.';
  static const String missingAnthropicKey =
      'Anthropic API Key is missing. Please configure it to use this model.';
}
