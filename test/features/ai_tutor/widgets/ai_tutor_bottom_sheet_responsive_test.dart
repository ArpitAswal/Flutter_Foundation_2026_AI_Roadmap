import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundation/core/di/injection.dart';
import 'package:flutter_foundation/domain/models/ai_model.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_assistant_settings_cubit.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_assistant_settings_state.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_tutor_bloc.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_tutor_event.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_tutor_state.dart';
import 'package:flutter_foundation/features/ai_tutor/models/chat_message.dart';
import 'package:flutter_foundation/features/ai_tutor/widgets/ai_tutor_bottom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAiTutorBloc extends Bloc<AiTutorEvent, AiTutorState>
    implements AiTutorBloc {
  _FakeAiTutorBloc([AiTutorState? initialState])
      : super(initialState ?? const AiTutorInitial([])) {
    on<AiTutorInitialized>((event, emit) {});
    on<AiTutorMessageSent>((event, emit) {});
    on<AiTutorNewChatRequested>((event, emit) {});
    on<AiTutorStopRequested>((event, emit) {});
    on<AiTutorRetryRequested>((event, emit) {});
  }
}

class _FakeAiAssistantSettingsCubit extends Cubit<AiAssistantSettingsState>
    implements AiAssistantSettingsCubit {
  _FakeAiAssistantSettingsCubit([AiAssistantSettingsState? initialState])
      : super(initialState ?? AiAssistantSettingsState.initial());

  @override
  Future<void> loadSettings() async {}

  @override
  Future<void> selectModel(AiModel model) async {}

  @override
  Future<void> saveProviderKey(AiModel model, String key) async {}

  @override
  Future<void> deleteProviderKey(AiModel model) async {}
}

void main() {
  late _FakeAiTutorBloc fakeTutorBloc;
  late _FakeAiAssistantSettingsCubit fakeSettingsCubit;

  setUp(() {
    fakeTutorBloc = _FakeAiTutorBloc();
    fakeSettingsCubit = _FakeAiAssistantSettingsCubit();

    if (getIt.isRegistered<AiTutorBloc>()) {
      getIt.unregister<AiTutorBloc>();
    }
    if (getIt.isRegistered<AiAssistantSettingsCubit>()) {
      getIt.unregister<AiAssistantSettingsCubit>();
    }

    getIt.registerFactory<AiTutorBloc>(() => fakeTutorBloc);
    getIt.registerFactory<AiAssistantSettingsCubit>(() => fakeSettingsCubit);
  });

  tearDown(() {
    if (getIt.isRegistered<AiTutorBloc>()) {
      getIt.unregister<AiTutorBloc>();
    }
    if (getIt.isRegistered<AiAssistantSettingsCubit>()) {
      getIt.unregister<AiAssistantSettingsCubit>();
    }
  });

  Widget buildBottomSheetUnderTest({Size size = const Size(375, 667)}) {
    return MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(size: size),
          child: const AiTutorBottomSheet(contextTitle: 'Dart Basics'),
        ),
      ),
    );
  }

  group('AiTutorBottomSheet Responsive - Locked State', () {
    testWidgets('Renders locked state on mobile (375x667) without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildBottomSheetUnderTest(size: const Size(375, 667)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('Renders locked state on tablet (768x1024) without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildBottomSheetUnderTest(size: const Size(768, 1024)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('Renders locked state on desktop (1200x800) without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildBottomSheetUnderTest(size: const Size(1200, 800)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });
  });

  group('AiTutorBottomSheet Responsive - Unlocked Chat State', () {
    final unlockedState = const AiAssistantSettingsState(
      isLoading: false,
      isSavingModel: false,
      savingKeyModel: null,
      selectedModel: AiModel.geminiFlash,
      keyAvailability: {
        AiModel.geminiFlash: true,
        AiModel.gpt5Mini: false,
        AiModel.claudeHaiku: false,
      },
      savedKeys: {
        AiModel.geminiFlash: 'AIzaSyFakeKey12345',
        AiModel.gpt5Mini: '',
        AiModel.claudeHaiku: '',
      },
      errorMessage: null,
    );

    final chatState = const AiTutorResponseComplete(
      [
        ChatMessage(
          text: 'Can you explain Dart null safety?',
          isUser: true,
        ),
        ChatMessage(
          text:
              'Null safety prevents errors caused by unintentional access of null variables.\n```dart\nString? name;\n```',
          isUser: false,
          suggestions: ['More examples', 'Soundness'],
        ),
      ],
      fullResponse:
          'Null safety prevents errors caused by unintentional access of null variables.',
    );

    testWidgets(
      'Renders chat conversation on mobile (375x667) without overflow',
      (tester) async {
        fakeSettingsCubit = _FakeAiAssistantSettingsCubit(unlockedState);
        fakeTutorBloc = _FakeAiTutorBloc(chatState);
        getIt.unregister<AiAssistantSettingsCubit>();
        getIt.unregister<AiTutorBloc>();
        getIt.registerFactory<AiAssistantSettingsCubit>(
          () => fakeSettingsCubit,
        );
        getIt.registerFactory<AiTutorBloc>(() => fakeTutorBloc);

        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildBottomSheetUnderTest(size: const Size(375, 667)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Can you explain Dart null safety?'), findsOneWidget);
        expect(find.text('More examples'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'Renders chat conversation on tablet (768x1024) without overflow',
      (tester) async {
        fakeSettingsCubit = _FakeAiAssistantSettingsCubit(unlockedState);
        fakeTutorBloc = _FakeAiTutorBloc(chatState);
        getIt.unregister<AiAssistantSettingsCubit>();
        getIt.unregister<AiTutorBloc>();
        getIt.registerFactory<AiAssistantSettingsCubit>(
          () => fakeSettingsCubit,
        );
        getIt.registerFactory<AiTutorBloc>(() => fakeTutorBloc);

        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildBottomSheetUnderTest(size: const Size(768, 1024)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Can you explain Dart null safety?'), findsOneWidget);
        expect(find.text('More examples'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'Renders chat conversation on desktop (1200x800) without overflow',
      (tester) async {
        fakeSettingsCubit = _FakeAiAssistantSettingsCubit(unlockedState);
        fakeTutorBloc = _FakeAiTutorBloc(chatState);
        getIt.unregister<AiAssistantSettingsCubit>();
        getIt.unregister<AiTutorBloc>();
        getIt.registerFactory<AiAssistantSettingsCubit>(
          () => fakeSettingsCubit,
        );
        getIt.registerFactory<AiTutorBloc>(() => fakeTutorBloc);

        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildBottomSheetUnderTest(size: const Size(1200, 800)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Can you explain Dart null safety?'), findsOneWidget);
      },
    );
  });
}
