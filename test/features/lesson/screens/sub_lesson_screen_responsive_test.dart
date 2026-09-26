import 'package:flutter/material.dart';
import 'package:flutter_foundation/core/di/injection.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_content.dart';
import 'package:flutter_foundation/domain/usecases/get_day_content_use_case.dart';
import 'package:flutter_foundation/features/lesson/screens/sub_lesson_screen.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGetDayContentUseCase implements GetDayContentUseCase {
  final LessonContent? content;
  final bool shouldThrow;

  _FakeGetDayContentUseCase({this.content, this.shouldThrow = false});

  @override
  Future<LessonContent> call(String contentPath) async {
    if (shouldThrow) {
      throw Exception('Failed to load sub-lesson content');
    }
    return content!;
  }
}

void main() {
  const sampleContent = LessonContent(
    theory:
        '# State Management in BLoC\n\nBLoC separates business logic from UI.',
    prerequisites: 'Flutter fundamentals\nStreams and Sinks in Dart',
    lastUpdated: '2026-03-01',
    implementation: '### Implementation details\n\nCreate a bloc with events.',
    architecture: '### Architecture\n\nEvents in, States out.',
    comparisons: '### Comparisons\n\nBLoC vs Provider vs GetX.',
    optimization: '### Optimization\n\nUse buildWhen to filter rebuilds.',
    commonMistakes: '### Common Mistakes\n\nDo not emit after closing bloc.',
    interviewQuestions: '### Questions\n\n1. What is an event transformer?',
  );

  tearDown(() async {
    if (getIt.isRegistered<GetDayContentUseCase>()) {
      getIt.unregister<GetDayContentUseCase>();
    }
  });

  Widget createWidgetUnderTest({Size size = const Size(375, 667)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: const SubLessonScreen(
          assetPath: 'assets/curriculum/phase3/module2/day29/bloc.json',
          parentTitle: 'State Management Overview',
        ),
      ),
    );
  }

  testWidgets('Renders SubLessonScreen on mobile (375px) without overflow', (
    tester,
  ) async {
    getIt.registerFactory<GetDayContentUseCase>(
      () => _FakeGetDayContentUseCase(content: sampleContent),
    );

    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      createWidgetUnderTest(size: const Size(375, 667)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AppBar), findsOneWidget);
    // Heading label
    expect(find.text('BLoC'), findsWidgets);
    expect(find.text('Prerequisites'), findsOneWidget);
  });

  testWidgets(
    'Renders SubLessonScreen on tablet portrait (768px) without overflow',
    (tester) async {
      getIt.registerFactory<GetDayContentUseCase>(
        () => _FakeGetDayContentUseCase(content: sampleContent),
      );

      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createWidgetUnderTest(size: const Size(768, 1024)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Prerequisites'), findsOneWidget);
      expect(find.text('Practical Implementation'), findsOneWidget);
    },
  );

  testWidgets(
    'Renders SubLessonScreen on wide desktop (1200px) with centered clamped width',
    (tester) async {
      getIt.registerFactory<GetDayContentUseCase>(
        () => _FakeGetDayContentUseCase(content: sampleContent),
      );

      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createWidgetUnderTest(size: const Size(1200, 800)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AppBar), findsOneWidget);

      // Verify the ListView padding centers content to max 860px
      // (1200 - 860) / 2 + 24 = 194.0
      final listView = tester.widget<ListView>(find.byType(ListView));
      final padding = listView.padding as EdgeInsets;
      expect(padding.left, equals(194.0));
      expect(padding.right, equals(194.0));
    },
  );

  testWidgets(
    'Renders SubLessonScreen error view with constrained width on desktop',
    (tester) async {
      getIt.registerFactory<GetDayContentUseCase>(
        () => _FakeGetDayContentUseCase(shouldThrow: true),
      );

      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createWidgetUnderTest(size: const Size(1200, 800)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Lesson Unavailable'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);

      // Verify error box is constrained
      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final errorBox = constrainedBoxes.firstWhere(
        (b) => b.constraints.maxWidth == 480.0,
      );
      expect(errorBox, isNotNull);
    },
  );
}
