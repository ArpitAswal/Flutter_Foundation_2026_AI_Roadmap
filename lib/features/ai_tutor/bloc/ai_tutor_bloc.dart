import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../../domain/usecases/ask_ai_tutor_use_case.dart';
import 'ai_tutor_event.dart';
import 'ai_tutor_state.dart';

/// Manages the state of the AI Tutor chat interface.
@injectable
class AiTutorBloc extends Bloc<AiTutorEvent, AiTutorState> {
  final AskAiTutorUseCase _askAiTutorUseCase;

  AiTutorBloc(this._askAiTutorUseCase) : super(AiTutorInitial()) {
    on<AiTutorMessageSent>(_onMessageSent);
  }

  Future<void> _onMessageSent(
    AiTutorMessageSent event,
    Emitter<AiTutorState> emit,
  ) async {
    debugPrint(
      'AiTutorBloc: Received message - "${event.message}" for model ${event.model.name}',
    );
    // Prevent multiple requests at once
    if (state is AiTutorLoading || state is AiTutorResponseStreaming) return;

    emit(AiTutorLoading());

    try {
      debugPrint('AiTutorBloc: Calling AskAiTutorUseCase...');
      final responseStream = _askAiTutorUseCase.execute(
        userMessage: event.message,
        currentLesson: event.currentLesson,
        currentContent: event.currentContent,
        model: event.model,
      );

      final buffer = StringBuffer();

      // Listen to the stream and emit chunks sequentially
      await emit.forEach<String>(
        responseStream,
        onData: (chunk) {
          buffer.write(chunk);
          return AiTutorResponseStreaming(partialResponse: buffer.toString());
        },
        onError: (error, stackTrace) {
          debugPrint('AiTutorBloc: Error during stream - $error');
          if (error is Failure) {
            return AiTutorError(message: error.message);
          }
          return const AiTutorError(
            message:
                'An unexpected error occurred while communicating with the AI Tutor.',
          );
        },
      );

      debugPrint('AiTutorBloc: Stream completed successfully.');

      // Once the stream completes without error, emit the final state
      emit(AiTutorResponseComplete(fullResponse: buffer.toString()));
    } catch (e) {
      if (e is Failure) {
        emit(AiTutorError(message: e.message));
      } else {
        emit(
          const AiTutorError(
            message: 'An unexpected error occurred. Please try again.',
          ),
        );
      }
    }
  }
}
