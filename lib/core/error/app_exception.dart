/// Base class for all application-level exceptions.
///
/// Converts low-level platform, network, database, or API errors into structured,
/// type-safe exceptions. Ensures raw exception details are encapsulated and
/// never leaked directly to presentation components.
abstract class AppException implements Exception {
  /// User-friendly error message.
  final String message;

  /// Optional underlying cause or stack trace reference for debugging.
  final Object? cause;

  const AppException(this.message, [this.cause]);

  @override
  String toString() => 'AppException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Thrown when local database (Hive) operations fail.
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.cause]);
}

/// Thrown when network operations or HTTP requests fail.
class NetworkException extends AppException {
  const NetworkException(super.message, [super.cause]);
}

/// Thrown when Gemini API communication or context injection fails.
class AiTutorException extends AppException {
  const AiTutorException(super.message, [super.cause]);
}
