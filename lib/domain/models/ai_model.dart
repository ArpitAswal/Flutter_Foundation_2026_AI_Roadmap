/// Available AI model options for the AI Tutor.
enum AiModel {
  /// gemini-2.5-flash — Google's fast model with grounding/web search capability.
  geminiFlash('gemini-2.5-flash', 'Gemini 2.5 Flash'),

  /// claude-3-haiku-20240307 — Anthropic's fastest model for quick responses.
  claudeHaiku('claude-3-haiku-20240307', 'Claude 3 Haiku'),

  /// gpt-4o-mini — OpenAI's fastest and most cost-effective model.
  gpt4oMini('gpt-4o-mini', 'GPT-4o Mini');

  /// The model identifier string passed to the SDKs.
  final String modelName;

  /// User-friendly label for display in UI selector menus.
  final String label;

  const AiModel(this.modelName, this.label);
}
