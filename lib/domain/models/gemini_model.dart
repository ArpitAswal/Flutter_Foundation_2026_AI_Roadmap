/// Available Gemini model options for the AI Tutor.
enum GeminiModel {
  /// gemini-1.5-flash — Fast, cost-effective, ideal for quick explanations (default).
  flash('gemini-1.5-flash', 'Gemini 1.5 Flash (Fast)'),

  /// gemini-1.5-pro — More capable, deeper reasoning for complex architectural questions.
  pro('gemini-1.5-pro', 'Gemini 1.5 Pro (Deep)');

  /// The model identifier string passed to the google_generative_ai SDK.
  final String modelName;

  /// User-friendly label for display in UI selector menus.
  final String label;

  const GeminiModel(this.modelName, this.label);
}
