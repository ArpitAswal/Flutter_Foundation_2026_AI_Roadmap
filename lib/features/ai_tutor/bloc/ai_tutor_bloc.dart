import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/error/failure.dart';
import '../../../domain/models/ai_chat_turn.dart';
import '../../../domain/usecases/ask_ai_tutor_use_case.dart';
import '../models/chat_message.dart';
import 'ai_tutor_event.dart';
import 'ai_tutor_state.dart';

/// Manages the state of the AI Tutor chat interface.
///
/// Scoped as an app-lifecycle @LazySingleton so that conversations are preserved
/// in-memory across different screens during the app session without database persistence.
@LazySingleton()
class AiTutorBloc extends Bloc<AiTutorEvent, AiTutorState> {
  final AskAiTutorUseCase _askAiTutorUseCase;
  StreamSubscription<String>? _streamSubscription;

  AiTutorBloc(this._askAiTutorUseCase) : super(const AiTutorInitial([])) {
    on<AiTutorInitialized>(_onInitialized);
    on<AiTutorMessageSent>(_onMessageSent);
    on<AiTutorStopRequested>(_onStopRequested);
    on<AiTutorNewChatRequested>(_onNewChatRequested);
    on<AiTutorRetryRequested>(_onRetryRequested);
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
    // Prevent overlapping requests
    if (state.isStreaming) return;

    // Convert existing completed messages to domain ChatTurns for bounded context
    final history = <ChatTurn>[];
    for (int i = 0; i < state.messages.length; i++) {
      final msg = state.messages[i];
      if (msg.text.trim().isNotEmpty && !msg.isLoading) {
        history.add(
          ChatTurn(
            id: 'turn_$i',
            role: msg.isUser ? ChatRole.user : ChatRole.assistant,
            text: msg.text,
            timestamp: DateTime.now(),
            isError: msg.isError,
          ),
        );
      }
    }

    // Add user message and placeholder for assistant
    final currentMessages = List<ChatMessage>.from(state.messages);
    currentMessages.add(ChatMessage(text: event.message, isUser: true));
    currentMessages.add(
      const ChatMessage(text: '', isUser: false, isLoading: true),
    );

    emit(AiTutorLoading(currentMessages, lastUserMessage: event.message));

    final buffer = StringBuffer();
    final completer = Completer<void>();
    DateTime lastEmitTime = DateTime.fromMillisecondsSinceEpoch(0);
    bool hasError = false;

    try {
      final responseStream = _askAiTutorUseCase.execute(
        userMessage: event.message,
        currentLesson: event.currentLesson,
        currentContent: event.currentContent,
        model: event.model,
        history: history,
      );

      _streamSubscription?.cancel();
      _streamSubscription = responseStream.listen(
        (chunk) {
          buffer.write(chunk);
          final now = DateTime.now();

          // Throttle UI emissions to 80ms interval to keep frame rate smooth
          if (now.difference(lastEmitTime).inMilliseconds >= 80) {
            lastEmitTime = now;
            final partial = buffer.toString();
            final messages = List<ChatMessage>.from(state.messages);
            if (messages.isNotEmpty) {
              messages.last = ChatMessage(text: partial, isUser: false);
            }
            emit(
              AiTutorResponseStreaming(
                messages,
                partialResponse: partial,
                lastUserMessage: event.message,
              ),
            );
          }
        },
        onError: (error, stackTrace) {
          hasError = true;
          debugPrint('AiTutorBloc stream error: $error');
          final messages = List<ChatMessage>.from(state.messages);

          final errorMessage = error is Failure
              ? error.message
              : StringConstants.aiTutorUnexpectedError;

          if (messages.isNotEmpty) {
            final currentText = messages.last.text;
            messages.last = ChatMessage(
              text: currentText.isEmpty
                  ? errorMessage
                  : '$currentText\n\n**Error:** $errorMessage',
              isUser: false,
              isError: true,
            );
          }

          emit(
            AiTutorError(
              messages,
              message: errorMessage,
              lastUserMessage: event.message,
            ),
          );
          completer.complete();
        },
        onDone: () {
          if (!hasError && !completer.isCompleted) {
            final fullText = buffer.toString();
            final messages = List<ChatMessage>.from(state.messages);
            if (messages.isNotEmpty) {
              messages.last = ChatMessage(text: fullText, isUser: false);
            }
            emit(
              AiTutorResponseComplete(
                messages,
                fullResponse: fullText,
                lastUserMessage: event.message,
              ),
            );
            completer.complete();
          }
        },
        cancelOnError: true,
      );

      await completer.future;
    } catch (e) {
      final messages = List<ChatMessage>.from(state.messages);
      final errorMessage = e is Failure
          ? e.message
          : StringConstants.aiTutorGenericError;

      if (messages.isNotEmpty) {
        final currentText = messages.last.text;
        messages.last = ChatMessage(
          text: currentText.isEmpty
              ? errorMessage
              : '$currentText\n\n**Error:** $errorMessage',
          isUser: false,
          isError: true,
        );
      }

      emit(
        AiTutorError(
          messages,
          message: errorMessage,
          lastUserMessage: event.message,
        ),
      );
    }
  }

  void _onStopRequested(
    AiTutorStopRequested event,
    Emitter<AiTutorState> emit,
  ) {
    if (_streamSubscription != null) {
      _streamSubscription?.cancel();
      _streamSubscription = null;

      // Finalize the partial response as complete
      final messages = List<ChatMessage>.from(state.messages);
      if (messages.isNotEmpty) {
        if (messages.last.isLoading) {
          if (messages.last.text.trim().isNotEmpty) {
            messages.last = ChatMessage(
              text: messages.last.text,
              isUser: false,
            );
          } else {
            messages.removeLast();
          }
        }
      }
      emit(
        AiTutorResponseComplete(
          messages,
          fullResponse: messages.isNotEmpty ? messages.last.text : '',
          lastUserMessage: state.lastUserMessage,
        ),
      );
    }
  }

  void _onNewChatRequested(
    AiTutorNewChatRequested event,
    Emitter<AiTutorState> emit,
  ) {
    _streamSubscription?.cancel();
    _streamSubscription = null;

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

  void _onRetryRequested(
    AiTutorRetryRequested event,
    Emitter<AiTutorState> emit,
  ) {
    final lastMessage = state.lastUserMessage;
    if (lastMessage == null || lastMessage.isEmpty) return;

    // Remove the trailing error/loading message
    final messages = List<ChatMessage>.from(state.messages);
    if (messages.isNotEmpty &&
        (messages.last.isError || messages.last.isLoading)) {
      messages.removeLast();
    }
    // Also remove the previous user question bubble because _onMessageSent will re-add it
    if (messages.isNotEmpty && messages.last.isUser) {
      messages.removeLast();
    }

    emit(AiTutorInitial(messages));

    add(
      AiTutorMessageSent(
        message: lastMessage,
        currentLesson: event.currentLesson,
        currentContent: event.currentContent,
        model: event.model,
      ),
    );
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
