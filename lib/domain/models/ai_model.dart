/// The underlying AI technology provider.
enum AiProvider {
  gemini('Google Gemini'),
  openAi('OpenAI'),
  anthropic('Anthropic');

  final String label;
  const AiProvider(this.label);
}

/// Available AI model options for the AI Tutor.
enum AiModel {
  /// gemini-3.5-flash — Google's speed and agentic-optimized model with low token overhead.
  geminiFlash('gemini-3.5-flash', 'Gemini 3.5 Flash', AiProvider.gemini),

  /// claude-3-5-haiku-20241022 — Anthropic's fast and capable lightweight model.
  claudeHaiku(
    'claude-3-5-haiku-20241022',
    'Claude 3.5 Haiku',
    AiProvider.anthropic,
  ),

  /// gpt-5-mini — OpenAI's fastest and most cost-effective reasoning/chat model.
  gpt5Mini('gpt-5-mini', 'GPT-5 Mini', AiProvider.openAi);

  /// The model identifier string passed to the SDKs/APIs.
  final String modelName;

  /// User-friendly label for display in UI selector menus.
  final String label;

  /// The underlying AI provider.
  final AiProvider provider;

  const AiModel(this.modelName, this.label, this.provider);

  /// Safely resolves a model from its saved enum name or legacy identifiers.
  static AiModel fromStoredName(String? name) {
    if (name == null || name == 'gemini-2.5-flash') return AiModel.geminiFlash;
    if (name == 'gpt4oMini' || name == 'gpt-4o-mini') return AiModel.gpt5Mini;
    for (final model in AiModel.values) {
      if (model.name == name || model.modelName == name) {
        return model;
      }
    }
    return AiModel.geminiFlash;
  }
}
