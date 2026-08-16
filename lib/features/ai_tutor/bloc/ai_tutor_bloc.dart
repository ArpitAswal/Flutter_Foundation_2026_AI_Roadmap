import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/error/failure.dart';
import '../../../domain/usecases/ask_ai_tutor_use_case.dart';
import '../models/chat_message.dart';
import 'ai_tutor_event.dart';
import 'ai_tutor_state.dart';

/// Manages the state of the AI Tutor chat interface.
@LazySingleton()
class AiTutorBloc extends Bloc<AiTutorEvent, AiTutorState> {
  final AskAiTutorUseCase _askAiTutorUseCase;

  AiTutorBloc(this._askAiTutorUseCase) : super(const AiTutorInitial([])) {
    on<AiTutorInitialized>(_onInitialized);
    on<AiTutorMessageSent>(_onMessageSent);
  }

  void _onInitialized(AiTutorInitialized event, Emitter<AiTutorState> emit) {
    if (state.messages.isEmpty) {
      final text = event.contextText != null
          ? StringConstants.aiTutorGreetingContext.replaceAll(
              '{context}',
              event.contextText!,
            )
          : StringConstants.aiTutorGreetingGeneric;

      final messages = [
        ChatMessage(text: text, isUser: false, suggestions: event.suggestions),
      ];
      emit(AiTutorInitial(messages));
    }
  }

  Future<void> _onMessageSent(
    AiTutorMessageSent event,
    Emitter<AiTutorState> emit,
  ) async {
    // Prevent multiple requests at once
    if (state is AiTutorLoading || state is AiTutorResponseStreaming) return;

    // Add user message and a placeholder for AI
    final currentMessages = List<ChatMessage>.from(state.messages);
    currentMessages.add(ChatMessage(text: event.message, isUser: true));
    currentMessages.add(
      const ChatMessage(text: '', isUser: false, isLoading: true),
    );
    emit(AiTutorLoading(currentMessages));

    try {
      final responseStream = _askAiTutorUseCase.execute(
        userMessage: event.message,
        currentLesson: event.currentLesson,
        currentContent: event.currentContent,
        model: event.model,
      );

      final buffer = StringBuffer();

      bool hasError = false;

      // Listen to the stream and emit chunks sequentially
      await emit.forEach<String>(
        responseStream,
        onData: (chunk) {
          buffer.write(chunk);

          final messages = List<ChatMessage>.from(state.messages);
          if (messages.isNotEmpty) {
            messages.last = ChatMessage(text: buffer.toString(), isUser: false);
          }

          return AiTutorResponseStreaming(
            messages,
            partialResponse: buffer.toString(),
          );
        },
        onError: (error, stackTrace) {
          hasError = true;
          debugPrint('AiTutorBloc: Error during stream - $error');
          final messages = List<ChatMessage>.from(state.messages);

          // Determine if the error is a known Failure (e.g. AppException mapping) or a generic error.
          final errorMessage = error is Failure
              ? error.message
              : StringConstants.aiTutorUnexpectedError;

          if (messages.isNotEmpty) {
            final currentText = messages.last.text;
            // Append the error string to the current chunk state and mark it as an error message.
            messages.last = ChatMessage(
              text: currentText.isEmpty
                  ? errorMessage
                  : '$currentText\n\n**Error:** $errorMessage',
              isUser: false,
              isError: true,
            );
          }

          return AiTutorError(messages, message: errorMessage);
        },
      );

      if (!hasError) {
        final finalMessages = List<ChatMessage>.from(state.messages);
        if (finalMessages.isNotEmpty) {
          finalMessages.last = ChatMessage(
            text: buffer.toString(),
            isUser: false,
          );
        }

        // Once the stream completes without error, emit the final state
        emit(
          AiTutorResponseComplete(
            finalMessages,
            fullResponse: buffer.toString(),
          ),
        );
      }
    } catch (e) {
      final messages = List<ChatMessage>.from(state.messages);

      // Catch all other unexpected initialization errors.
      final errorMessage = e is Failure
          ? e.message
          : StringConstants.aiTutorGenericError;

      if (messages.isNotEmpty) {
        final currentText = messages.last.text;
        // Inject the error message directly into the chat UI so the user can read it.
        messages.last = ChatMessage(
          text: currentText.isEmpty
              ? errorMessage
              : '$currentText\n\n**Error:** $errorMessage',
          isUser: false,
          isError: true,
        );
      }

      emit(AiTutorError(messages, message: errorMessage));
    }
  }
}
