import 'dart:async';
import 'package:flutter_foundation/core/error/failure.dart';
import 'package:flutter_foundation/domain/models/ai_chat_turn.dart';
import 'package:flutter_foundation/domain/models/ai_model.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_content.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_day.dart';
import 'package:flutter_foundation/domain/usecases/ask_ai_tutor_use_case.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_tutor_bloc.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_tutor_event.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_tutor_state.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAskAiTutorUseCase implements AskAiTutorUseCase {
  Stream<String> Function({
    required String userMessage,
    LessonDay? currentLesson,
    LessonContent? currentContent,
    AiModel model,
    List<ChatTurn> history,
  })? onExecute;

  @override
  Stream<String> execute({
    required String userMessage,
    LessonDay? currentLesson,
    LessonContent? currentContent,
    AiModel model = AiModel.geminiFlash,
    List<ChatTurn> history = const [],
  }) {
    if (onExecute != null) {
      return onExecute!(
        userMessage: userMessage,
        currentLesson: currentLesson,
        currentContent: currentContent,
        model: model,
        history: history,
      );
    }
    return Stream.value('Mock response');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AiTutorBloc Tests', () {
    late FakeAskAiTutorUseCase fakeUseCase;
    late AiTutorBloc bloc;

    setUp(() {
      fakeUseCase = FakeAskAiTutorUseCase();
      bloc = AiTutorBloc(fakeUseCase);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has empty messages', () {
      expect(bloc.state, const AiTutorInitial([]));
      expect(bloc.state.messages, isEmpty);
      expect(bloc.state.isStreaming, isFalse);
    });

    test('AiTutorInitialized adds contextual greeting and suggestions', () async {
      bloc.add(
        const AiTutorInitialized(
          contextText: 'Day 1: Dart Basics',
          suggestions: ['Explain variables', 'Give an example'],
        ),
      );

      await expectLater(
        bloc.stream,
        emits(
          isA<AiTutorInitial>().having(
            (s) => s.messages.first.text,
            'greeting text',
            contains('Day 1: Dart Basics'),
          ).having(
            (s) => s.messages.first.suggestions,
            'suggestions',
            ['Explain variables', 'Give an example'],
          ),
        ),
      );
    });

    test('AiTutorMessageSent appends user message, streams chunks, and completes', () async {
      final controller = StreamController<String>();
      fakeUseCase.onExecute = ({
        required userMessage,
        currentLesson,
        currentContent,
        model = AiModel.geminiFlash,
        history = const [],
      }) {
        return controller.stream;
      };

      bloc.add(
        const AiTutorMessageSent(
          message: 'What is a Widget?',
          model: AiModel.geminiFlash,
        ),
      );

      // Allow event handler to process initial loading state
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AiTutorLoading>());
      expect(bloc.state.messages.length, 2);
      expect(bloc.state.messages[0].text, 'What is a Widget?');
      expect(bloc.state.messages[0].isUser, isTrue);
      expect(bloc.state.messages[1].isLoading, isTrue);
      expect(bloc.state.isStreaming, isTrue);

      // Yield streamed token chunk
      controller.add('Widgets are ');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state, isA<AiTutorResponseStreaming>());
      final streamingState = bloc.state as AiTutorResponseStreaming;
      expect(streamingState.partialResponse, 'Widgets are ');

      // Complete stream
      await controller.close();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<AiTutorResponseComplete>());
      final completeState = bloc.state as AiTutorResponseComplete;
      expect(completeState.fullResponse, 'Widgets are ');
      expect(bloc.state.isStreaming, isFalse);
    });

    test('AiTutorMessageSent handles AiTutorFailure error correctly', () async {
      fakeUseCase.onExecute = ({
        required userMessage,
        currentLesson,
        currentContent,
        model = AiModel.geminiFlash,
        history = const [],
      }) {
        return Stream<String>.error(const AiTutorFailure('Invalid API Key (401)'));
      };

      bloc.add(
        const AiTutorMessageSent(
          message: 'Hello',
          model: AiModel.geminiFlash,
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AiTutorLoading>(),
          isA<AiTutorError>().having(
            (s) => s.message,
            'error message',
            'Invalid API Key (401)',
          ),
        ]),
      );

      expect(bloc.state.messages.last.isError, isTrue);
      expect(bloc.state.messages.last.text, 'Invalid API Key (401)');
      expect(bloc.state.lastUserMessage, 'Hello');
    });

    test('AiTutorStopRequested halts active stream without crashing', () async {
      final controller = StreamController<String>();
      fakeUseCase.onExecute = ({
        required userMessage,
        currentLesson,
        currentContent,
        model = AiModel.geminiFlash,
        history = const [],
      }) {
        return controller.stream;
      };

      bloc.add(
        const AiTutorMessageSent(
          message: 'Explain async',
          model: AiModel.geminiFlash,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));
      controller.add('Partial text');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // User taps Stop
      bloc.add(const AiTutorStopRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AiTutorResponseComplete>());
      expect(bloc.state.messages.last.isLoading, isFalse);
      expect(bloc.state.messages.last.text, 'Partial text');

      await controller.close();
    });

    test('AiTutorNewChatRequested clears messages and resets greeting and suggestions', () async {
      bloc.add(
        const AiTutorInitialized(
          contextText: 'Module 1',
          suggestions: ['Chip 1'],
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(
        const AiTutorNewChatRequested(
          contextText: 'Module 2',
          suggestions: ['Chip 2', 'Chip 3'],
        ),
      );

      await expectLater(
        bloc.stream,
        emits(
          isA<AiTutorInitial>().having(
            (s) => s.messages.first.text,
            'greeting',
            contains('Module 2'),
          ).having(
            (s) => s.messages.first.suggestions,
            'suggestions',
            ['Chip 2', 'Chip 3'],
          ),
        ),
      );
    });

    test('AiTutorRetryRequested resends lastUserMessage', () async {
      var callCount = 0;
      fakeUseCase.onExecute = ({
        required userMessage,
        currentLesson,
        currentContent,
        model = AiModel.geminiFlash,
        history = const [],
      }) {
        callCount++;
        if (callCount == 1) {
          return Stream.error(const NetworkFailure('Network down'));
        }
        return Stream.value('Success on retry');
      };

      bloc.add(
        const AiTutorMessageSent(
          message: 'Test retry query',
          model: AiModel.geminiFlash,
        ),
      );

      // Wait for error state
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state, isA<AiTutorError>());
      expect(bloc.state.lastUserMessage, 'Test retry query');

      // Tap Retry
      bloc.add(const AiTutorRetryRequested(model: AiModel.geminiFlash));

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(bloc.state, isA<AiTutorResponseComplete>());
      expect(bloc.state.messages.last.text, 'Success on retry');
    });
  });
}
