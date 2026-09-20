/// Represents the typed outcome of an AI provider API key validation attempt.
enum KeyValidationResult {
  /// The key was accepted by the provider and authorized for use.
  valid,

  /// The provider rejected the key (e.g. HTTP 401 Unauthorized / Invalid API Key).
  unauthorized,

  /// The account has exceeded its rate limits, tokens, or billing quota (HTTP 429).
  rateLimited,

  /// The key is valid, but does not have permission or access to the chosen model (HTTP 404 / 403).
  modelUnavailable,

  /// Could not reach the provider's server (DNS failure, timeout, or no internet).
  networkUnavailable,

  /// An unknown or unclassified error occurred during validation.
  unknown;

  /// Whether the validation succeeded.
  bool get isValid => this == KeyValidationResult.valid;
}
