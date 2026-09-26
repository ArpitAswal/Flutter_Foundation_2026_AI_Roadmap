import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_day.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_module.dart';
import 'package:flutter_foundation/domain/models/curriculum/phase.dart';
import 'package:flutter_foundation/features/curriculum/bloc/curriculum_bloc.dart';
import 'package:flutter_foundation/features/curriculum/screens/modules_screen.dart';
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
      title: 'Day 1',
      description: 'First Day',
      tags: ['intro'],
      contentPath: 'assets/curriculum/phase1/module1/day1.json',
    ),
    const LessonDay(
      phase: 1,
      module: 1,
      day: 2,
      title: 'Day 2',
      description: 'Second Day',
      tags: ['intro'],
      contentPath: 'assets/curriculum/phase1/module1/day2.json',
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
      LessonModule(
        id: 2,
        title: 'Module 2: Advanced Basics',
        subtitle: 'Going deeper',
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
          child: const ModulesScreen(phaseId: 1),
        ),
      ),
    );
  }

  testWidgets('Renders single-column list on mobile width (375px)', (tester) async {
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

    expect(find.text('Phase 1: Foundations'), findsOneWidget);
    expect(find.text('Module 1: Introduction'), findsOneWidget);
    expect(find.text('Module 2: Advanced Basics'), findsOneWidget);
    // On mobile, CurriculumGridBuilder is not rendered (single column is used)
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

    expect(find.text('Phase 1: Foundations'), findsOneWidget);
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

    expect(find.text('Phase 1: Foundations'), findsOneWidget);
    final gridFinder = find.byType(CurriculumGridBuilder);
    expect(gridFinder, findsOneWidget);
    final grid = tester.widget<CurriculumGridBuilder>(gridFinder);
    expect(grid.crossAxisCount, 3);
  });
}
