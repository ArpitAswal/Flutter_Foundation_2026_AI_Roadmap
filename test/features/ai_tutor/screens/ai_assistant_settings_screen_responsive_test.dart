import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundation/core/constants/string_constants.dart';
import 'package:flutter_foundation/core/di/injection.dart';
import 'package:flutter_foundation/domain/models/ai_model.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_assistant_settings_cubit.dart';
import 'package:flutter_foundation/features/ai_tutor/bloc/ai_assistant_settings_state.dart';
import 'package:flutter_foundation/features/ai_tutor/screens/ai_assistant_settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAiAssistantSettingsCubit extends Cubit<AiAssistantSettingsState>
    implements AiAssistantSettingsCubit {
  _FakeAiAssistantSettingsCubit([AiAssistantSettingsState? initialState])
      : super(
          initialState ??
              AiAssistantSettingsState.initial().copyWith(isLoading: false),
        );

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
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAiAssistantSettingsCubit fakeSettingsCubit;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('no_screenshot'), (
          MethodCall methodCall,
        ) async {
          return true;
        });

    fakeSettingsCubit = _FakeAiAssistantSettingsCubit();

    if (getIt.isRegistered<AiAssistantSettingsCubit>()) {
      getIt.unregister<AiAssistantSettingsCubit>();
    }
    getIt.registerFactory<AiAssistantSettingsCubit>(() => fakeSettingsCubit);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('no_screenshot'), null);

    if (getIt.isRegistered<AiAssistantSettingsCubit>()) {
      getIt.unregister<AiAssistantSettingsCubit>();
    }
  });

  Widget buildSettingsScreenUnderTest({Size size = const Size(375, 667)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: const AiAssistantSettingsScreen(),
      ),
    );
  }

  group('AiAssistantSettingsScreen Responsive Tests', () {
    testWidgets(
      'Renders locked state on mobile (375x667) without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildSettingsScreenUnderTest(size: const Size(375, 667)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text(StringConstants.settingsTitle), findsOneWidget);
        expect(find.text(StringConstants.settingsAssistantLocked), findsOneWidget);
        expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'Renders locked state on tablet (768x1024) without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildSettingsScreenUnderTest(size: const Size(768, 1024)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text(StringConstants.settingsTitle), findsOneWidget);
        expect(find.text(StringConstants.settingsAssistantLocked), findsOneWidget);
      },
    );

    testWidgets(
      'Renders locked state on desktop (1200x800) without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildSettingsScreenUnderTest(size: const Size(1200, 800)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text(StringConstants.settingsTitle), findsOneWidget);
        expect(find.text(StringConstants.settingsAssistantLocked), findsOneWidget);
      },
    );

    testWidgets(
      'Renders configured keys state on mobile (375x667) without overflow',
      (tester) async {
        final configuredState = const AiAssistantSettingsState(
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

        fakeSettingsCubit = _FakeAiAssistantSettingsCubit(configuredState);
        getIt.unregister<AiAssistantSettingsCubit>();
        getIt.registerFactory<AiAssistantSettingsCubit>(
          () => fakeSettingsCubit,
        );

        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildSettingsScreenUnderTest(size: const Size(375, 667)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.key_rounded), findsOneWidget);
        expect(find.text(StringConstants.settingsAssistantReady), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
      },
    );

    testWidgets(
      'Renders configured keys state on tablet (768x1024) without overflow',
      (tester) async {
        final configuredState = const AiAssistantSettingsState(
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

        fakeSettingsCubit = _FakeAiAssistantSettingsCubit(configuredState);
        getIt.unregister<AiAssistantSettingsCubit>();
        getIt.registerFactory<AiAssistantSettingsCubit>(
          () => fakeSettingsCubit,
        );

        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildSettingsScreenUnderTest(size: const Size(768, 1024)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text(StringConstants.settingsAssistantReady), findsOneWidget);
      },
    );
  });
}
