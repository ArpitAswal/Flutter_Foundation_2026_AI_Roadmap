import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_day.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_module.dart';
import 'package:flutter_foundation/domain/models/curriculum/phase.dart';
import 'package:flutter_foundation/features/curriculum/bloc/curriculum_bloc.dart';
import 'package:flutter_foundation/features/curriculum/screens/days_screen.dart';
import 'package:flutter_foundation/features/curriculum/widgets/curriculum_layouts.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCurriculumBloc extends Bloc<CurriculumEvent, CurriculumState>
    implements CurriculumBloc {
  _FakeCurriculumBloc(super.initialState);
}

void main() {
  final sampleDays = [
    const LessonDay(
      phase: 1,
      module: 1,
      day: 1,
      title: 'Day 1: Variables',
      description: 'Learn variables in Dart',
      tags: ['intro', 'dart'],
      contentPath: 'assets/curriculum/phase1/module1/day1.json',
    ),
    const LessonDay(
      phase: 1,
      module: 1,
      day: 2,
      title: 'Day 2: Control Flow',
      description: 'If statements and loops',
      tags: ['flow', 'dart'],
      contentPath: 'assets/curriculum/phase1/module1/day2.json',
    ),
    const LessonDay(
      phase: 1,
      module: 1,
      day: 3,
      title: 'Day 3: Functions',
      description: 'Understanding functions',
      tags: ['functions', 'dart'],
      contentPath: 'assets/curriculum/phase1/module1/day3.json',
    ),
  ];

  final samplePhase = Phase(
    id: 1,
    title: 'Phase 1: Foundations',
    description: 'Learn the basics',
    modules: [
      LessonModule(
        id: 1,
        title: 'Module 1: Introduction',
        subtitle: 'Getting started',
        days: sampleDays,
      ),
    ],
  );

  Widget createWidgetUnderTest(CurriculumBloc bloc, {Size size = const Size(375, 667)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: BlocProvider<CurriculumBloc>.value(
          value: bloc,
          child: const DaysScreen(phaseId: 1, moduleId: 1),
        ),
      ),
    );
  }

  testWidgets('Renders single-column timeline on mobile width (375px)', (tester) async {
    final bloc = _FakeCurriculumBloc(
      CurriculumLoaded(
        phases: [samplePhase],
        completedLessonIds: const {'p1_m1_d1'},
      ),
    );

    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWidgetUnderTest(bloc, size: const Size(375, 667)));
    await tester.pumpAndSettle();

    expect(find.text('Module 1: Introduction'), findsOneWidget);
    expect(find.text('Day 1: Variables'), findsOneWidget);
    expect(find.text('Day 2: Control Flow'), findsOneWidget);
    expect(find.text('Day 3: Functions'), findsOneWidget);
    // On mobile width, CurriculumGridBuilder is not rendered (single column timeline is used)
    expect(find.byType(CurriculumGridBuilder), findsNothing);
  });

  testWidgets('Renders CurriculumGridBuilder with 2 columns on tablet portrait width (768px)', (tester) async {
    final bloc = _FakeCurriculumBloc(
      CurriculumLoaded(
        phases: [samplePhase],
        completedLessonIds: const {'p1_m1_d1'},
      ),
    );

    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWidgetUnderTest(bloc, size: const Size(768, 1024)));
    await tester.pumpAndSettle();

    expect(find.text('Module 1: Introduction'), findsOneWidget);
    final gridFinder = find.byType(CurriculumGridBuilder);
    expect(gridFinder, findsOneWidget);
    final grid = tester.widget<CurriculumGridBuilder>(gridFinder);
    expect(grid.crossAxisCount, 2);
  });

  testWidgets('Renders CurriculumGridBuilder with 3 columns on wide screen (1200px)', (tester) async {
    final bloc = _FakeCurriculumBloc(
      CurriculumLoaded(
        phases: [samplePhase],
        completedLessonIds: const {'p1_m1_d1'},
      ),
    );

    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWidgetUnderTest(bloc, size: const Size(1200, 800)));
    await tester.pumpAndSettle();

    expect(find.text('Module 1: Introduction'), findsOneWidget);
    final gridFinder = find.byType(CurriculumGridBuilder);
    expect(gridFinder, findsOneWidget);
    final grid = tester.widget<CurriculumGridBuilder>(gridFinder);
    expect(grid.crossAxisCount, 3);
  });
}
