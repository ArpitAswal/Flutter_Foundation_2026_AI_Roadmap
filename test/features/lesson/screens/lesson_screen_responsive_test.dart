import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundation/core/di/injection.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_content.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_day.dart';
import 'package:flutter_foundation/features/curriculum/bloc/curriculum_bloc.dart';
import 'package:flutter_foundation/features/lesson/bloc/lesson_bloc.dart';
import 'package:flutter_foundation/features/lesson/screens/lesson_screen.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLessonBloc extends Bloc<LessonEvent, LessonState>
    implements LessonBloc {
  _FakeLessonBloc(super.initialState) {
    on<LessonLoadRequested>((event, emit) {});
  }
}

class _FakeCurriculumBloc extends Bloc<CurriculumEvent, CurriculumState>
    implements CurriculumBloc {
  _FakeCurriculumBloc(super.initialState);
}

void main() {
  const sampleLesson = LessonDay(
    phase: 1,
    module: 1,
    day: 1,
    title: 'Introduction to Dart',
    description: 'Learn the fundamentals of Dart language',
    tags: ['Dart', 'Basics'],
    contentPath: 'assets/curriculum/phase1/module1/day1.json',
    customRoute: ['bloc', 'provider'],
  );

  const sampleContent = LessonContent(
    theory:
        '# Dart Basics\n\nDart is an approachable, portable, high-performance language.',
    prerequisites: 'Basic programming knowledge\nUnderstanding of variables',
    lastUpdated: '2026-03-01',
    implementation: '### Implementation details\n\nStep by step guide.',
    architecture: '### Architecture\n\nHow components interact.',
    comparisons: '### Comparisons\n\nBLoC vs Provider.',
    optimization: '### Optimization\n\nBest practices for speed.',
    commonMistakes: '### Common Mistakes\n\nAvoid mutating state directly.',
    interviewQuestions: '### Questions\n\n1. What is Dart?',
  );

  late _FakeCurriculumBloc fakeCurriculumBloc;
  late _FakeLessonBloc fakeLessonBloc;

  setUp(() {
    fakeCurriculumBloc = _FakeCurriculumBloc(
      CurriculumLoaded(phases: [], completedLessonIds: {}),
    );
  });

  tearDown(() async {
    if (getIt.isRegistered<LessonBloc>()) {
      getIt.unregister<LessonBloc>();
    }
  });

  Widget createWidgetUnderTest({Size size = const Size(375, 667)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: BlocProvider<CurriculumBloc>.value(
          value: fakeCurriculumBloc,
          child: const LessonScreen(phaseId: 1, moduleId: 1, day: 1),
        ),
      ),
    );
  }

  testWidgets('Renders lesson screen on mobile (375px) without overflow', (
    tester,
  ) async {
    fakeLessonBloc = _FakeLessonBloc(
      LessonLoaded(
        lesson: sampleLesson,
        content: sampleContent,
        isComplete: false,
      ),
    );
    getIt.registerFactory<LessonBloc>(() => fakeLessonBloc);

    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      createWidgetUnderTest(size: const Size(375, 667)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Introduction to Dart'), findsWidgets);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('Basics'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets(
    'Renders lesson screen on tablet portrait (768px) without overflow',
    (tester) async {
      fakeLessonBloc = _FakeLessonBloc(
        LessonLoaded(
          lesson: sampleLesson,
          content: sampleContent,
          isComplete: false,
        ),
      );
      getIt.registerFactory<LessonBloc>(() => fakeLessonBloc);

      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createWidgetUnderTest(size: const Size(768, 1024)),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Introduction to Dart'), findsWidgets);
      expect(find.text('Prerequisites'), findsOneWidget);
    },
  );

  testWidgets(
    'Renders lesson screen on wide desktop (1200px) with centered clamped width',
    (tester) async {
      fakeLessonBloc = _FakeLessonBloc(
        LessonLoaded(
          lesson: sampleLesson,
          content: sampleContent,
          isComplete: false,
        ),
      );
      getIt.registerFactory<LessonBloc>(() => fakeLessonBloc);

      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createWidgetUnderTest(size: const Size(1200, 800)),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Introduction to Dart'), findsWidgets);

      // Verify the ListView padding centers content to max 860px
      // (1200 - 860) / 2 + 24 = 194.0
      final listView = tester.widget<ListView>(find.byType(ListView));
      final padding = listView.padding as EdgeInsets;
      expect(padding.left, equals(194.0));
      expect(padding.right, equals(194.0));
    },
  );

  testWidgets('Renders error view with constrained width on mobile and desktop', (
    tester,
  ) async {
    fakeLessonBloc = _FakeLessonBloc(
      LessonError('Failed to load lesson'),
    );
    getIt.registerFactory<LessonBloc>(() => fakeLessonBloc);

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
  });
}
