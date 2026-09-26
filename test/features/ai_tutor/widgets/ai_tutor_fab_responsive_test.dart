import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundation/core/di/injection.dart';
import 'package:flutter_foundation/domain/models/ai_model.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_assistant_settings_cubit.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_assistant_settings_state.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_tutor_bloc.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_tutor_event.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_tutor_state.dart';
import 'package:flutter_foundation/features/ai_tutor/widgets/ai_tutor_fab.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAiTutorBloc extends Bloc<AiTutorEvent, AiTutorState>
    implements AiTutorBloc {
  _FakeAiTutorBloc() : super(const AiTutorInitial([])) {
    on<AiTutorInitialized>((event, emit) {});
    on<AiTutorMessageSent>((event, emit) {});
    on<AiTutorNewChatRequested>((event, emit) {});
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

  Widget buildFabUnderTest() {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Test Page')),
        floatingActionButton: AiTutorFab(contextTitle: 'Lesson 1: Intro'),
      ),
    );
  }

  group('AiTutorFab Responsive Tests', () {
    testWidgets('Maintains stable 48x48 touch target on mobile (375x667)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildFabUnderTest());
      await tester.pumpAndSettle();

      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      final size = tester.getSize(fabFinder);
      expect(size.width, equals(48.0));
      expect(size.height, equals(48.0));

      final iconFinder = find.byIcon(Icons.smart_toy_outlined);
      expect(iconFinder, findsOneWidget);
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.size, equals(24.0));
    });

    testWidgets('Maintains stable 48x48 touch target on tablet (768x1024)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildFabUnderTest());
      await tester.pumpAndSettle();

      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      final size = tester.getSize(fabFinder);
      expect(size.width, equals(48.0));
      expect(size.height, equals(48.0));

      final iconFinder = find.byIcon(Icons.smart_toy_outlined);
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.size, equals(24.0));
    });

    testWidgets('Maintains stable 48x48 touch target on desktop (1200x800)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildFabUnderTest());
      await tester.pumpAndSettle();

      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      final size = tester.getSize(fabFinder);
      expect(size.width, equals(48.0));
      expect(size.height, equals(48.0));
    });

    testWidgets('Tapping FAB opens bottom sheet without overflow errors', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildFabUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
