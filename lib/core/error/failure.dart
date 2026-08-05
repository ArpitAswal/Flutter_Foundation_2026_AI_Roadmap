import 'package:equatable/equatable.dart';

/// Base sealed class representing expected failures across domain and presentation layers.
///
/// Failures translate exceptions into UI-safe objects that can be handled predictably
/// by Blocs and presented cleanly to the user.
sealed class Failure extends Equatable {
  /// User-facing message describing the failure.
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Represents a failure originating from Hive database storage.
final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Represents a failure originating from network connectivity or API calls.
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Represents a failure originating from Gemini API or AI prompt parsing.
final class AiTutorFailure extends Failure {
  const AiTutorFailure(super.message);
}
