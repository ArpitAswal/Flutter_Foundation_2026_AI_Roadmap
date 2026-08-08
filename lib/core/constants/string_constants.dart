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
  static const String aiAssistantSettingsLoadError =
      'Unable to load your AI assistant settings.';
  static const String aiAssistantSettingsSaveError =
      'Unable to save your selected model.';
  static const String aiAssistantKeySaveError =
      'Unable to save the API key securely.';
  static const String aiAssistantKeyDeleteError =
      'Unable to remove the saved API key.';

  // API Key Errors
  static const String missingGeminiKey =
      'Gemini API Key is missing. Please configure it to use this model.';
  static const String missingOpenAiKey =
      'OpenAI API Key is missing. Please configure it to use this model.';
  static const String missingAnthropicKey =
      'Anthropic API Key is missing. Please configure it to use this model.';

  // AI Assistant Settings Screen
  static const String settingsTitle = 'AI Assistant Settings';
  static const String settingsAssistantLocked = 'Assistant locked';
  static const String settingsAssistantReady = 'Assistant ready';
  static const String settingsUnlockPrompt =
      'Add at least one provider key to unlock chat.';
  static const String settingsKeysSaved =
      'Your keys are saved locally in encrypted storage on this device.';
  static const String settingsDefaultModelTitle = 'Default model';
  static const String settingsDefaultModelDesc =
      'This model will be restored automatically the next time you open the assistant.';
  static const String settingsSecureStorageDesc =
      'Stored securely in the platform keychain or keystore.';
  static const String settingsApiKeySuffix = 'API key';
  static const String settingsPasteHint = 'Paste your API key here';
  static const String settingsEnterKeyFirst = 'Enter a key before saving.';
  static const String settingsSaveKeyBtn = 'Save key';
  static const String settingsRemoveBtn = 'Remove';
  static const String settingsSavedChip = 'Saved';
  static const String settingsMissingChip = 'Missing';

  // AI Tutor Bottom Sheet
  static const String bottomSheetTitle = 'AI Tutor';
  static const String bottomSheetOnline = 'Online';
  static const String bottomSheetTooltipSettings = 'Open AI settings';
  static const String bottomSheetKeyMissing = 'Key missing';
  static const String bottomSheetReady = 'Ready';
  static const String bottomSheetNotConfigured =
      'is not configured. Open Settings or switch to another model.';
  static const String bottomSheetHintLocked =
      'Add a key in Settings to start chatting';
  static const String bottomSheetHintAsk = 'Ask a question...';
  static const String bottomSheetLockTitle = 'AI Assistant Locked';
  static const String bottomSheetLockDesc =
      'Add at least one provider key to unlock the assistant. Keys stay encrypted on this device.';
  static const String bottomSheetOpenSettings = 'Open Settings';
}
