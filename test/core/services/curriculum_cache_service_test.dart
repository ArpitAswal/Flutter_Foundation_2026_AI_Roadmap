import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_foundation/core/services/curriculum_cache_service.dart';
import 'package:flutter_foundation/data/local/sources/curriculum_local_data_source.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_day.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_module.dart';
import 'package:flutter_foundation/domain/models/curriculum/phase.dart';

class FakeCurriculumLocalDataSource implements CurriculumLocalDataSource {
  int callCount = 0;
  List<Phase> phasesToReturn = [];

  @override
  Future<List<Phase>> getCurriculumIndex() async {
    callCount++;
    return phasesToReturn;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('CurriculumCacheService Tests', () {
    late FakeCurriculumLocalDataSource fakeDataSource;
    late CurriculumCacheService cacheService;

    final samplePhases = [
      const Phase(
        id: 1,
        title: 'Dart Basics',
        description: 'Learn Dart',
        modules: [
          LessonModule(
            id: 1,
            title: 'Intro Module',
            subtitle: 'Intro Subtitle',
            days: [
              LessonDay(
                phase: 1,
                module: 1,
                day: 1,
                title: 'Variables',
                description: 'Variables in Dart',
                tags: ['variables'],
                contentPath: 'assets/day1.json',
              ),
              LessonDay(
                phase: 1,
                module: 1,
                day: 2,
                title: 'Reactive State',
                description: 'State description',
                tags: ['state'],
                contentPath: 'assets/day2.json',
                customRoute: [
                  'assets/curriculum/phase1/module1/day2/riverpod.json',
                  'assets/curriculum/phase1/module1/day2/getx.json',
                ],
              ),
            ],
          ),
        ],
      ),
    ];

    setUp(() {
      fakeDataSource = FakeCurriculumLocalDataSource();
      fakeDataSource.phasesToReturn = samplePhases;
      cacheService = CurriculumCacheService(fakeDataSource);
    });

    test('initial state is uninitialized', () {
      expect(cacheService.isInitialized, isFalse);
      expect(cacheService.phases, isEmpty);
      expect(cacheService.roadmapSkeleton, isEmpty);
    });

    test('initialize caches phases and builds roadmap skeleton', () async {
      await cacheService.initialize();

      expect(cacheService.isInitialized, isTrue);
      expect(fakeDataSource.callCount, equals(1));
      expect(cacheService.phases.length, equals(1));
      expect(cacheService.phases.first.title, equals('Dart Basics'));

      final skeleton = cacheService.roadmapSkeleton;
      expect(skeleton, contains('Phase 1: Dart Basics'));
      expect(skeleton, contains('Module 1: Intro Module'));
      expect(skeleton, contains('Day 1: Variables'));
      expect(
        skeleton,
        contains('Day 2: Reactive State (Sub-lessons: riverpod, getx)'),
      );
    });

    test('getOrLoadPhases initializes on demand', () async {
      expect(cacheService.isInitialized, isFalse);
      final phases = await cacheService.getOrLoadPhases();
      expect(phases.length, equals(1));
      expect(cacheService.isInitialized, isTrue);
      expect(fakeDataSource.callCount, equals(1));

      // Calling again returns cached data without calling data source
      await cacheService.getOrLoadPhases();
      expect(fakeDataSource.callCount, equals(1));
    });

    test('formatRoadmapSkeleton formats phases and sub-lessons accurately', () {
      final skeleton = CurriculumCacheService.formatRoadmapSkeleton(samplePhases);

      expect(
        skeleton,
        equals(
          'Phase 1: Dart Basics\n'
          '  Module 1: Intro Module\n'
          '    Day 1: Variables\n'
          '    Day 2: Reactive State (Sub-lessons: riverpod, getx)',
        ),
      );
    });
  });
}
