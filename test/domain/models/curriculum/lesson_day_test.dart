import 'package:flutter_foundation/domain/models/curriculum/lesson_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LessonDay', () {
    test('fromJson parses custom_route as List<String>', () {
      final json = {
        'phase': 3,
        'module': 2,
        'day': 29,
        'title': 'GetX: Micro-Framework Reactive State Management',
        'description': 'Learn GetX reactivity',
        'tags': ['Flutter', 'GetX'],
        'content_path': 'assets/curriculum/phase3/module2/day29.json',
        'custom_route': [
          'assets/curriculum/phase3/module2/day29/getx.json',
          'assets/curriculum/phase3/module2/day29/provider.json',
        ],
      };

      final lesson = LessonDay.fromJson(json);

      expect(lesson.phase, 3);
      expect(lesson.module, 2);
      expect(lesson.day, 29);
      expect(lesson.hasSubLessons, isTrue);
      expect(lesson.customRoute, hasLength(2));
      expect(
        lesson.customRoute,
        contains('assets/curriculum/phase3/module2/day29/getx.json'),
      );
    });

    test('fromJson handles null custom_route', () {
      final json = {
        'phase': 1,
        'module': 1,
        'day': 1,
        'title': 'Dart Variables',
        'description': 'Learn variables',
        'tags': ['Dart'],
        'content_path': 'assets/curriculum/phase1/module1/day1.json',
        'custom_route': null,
      };

      final lesson = LessonDay.fromJson(json);

      expect(lesson.customRoute, isNull);
      expect(lesson.hasSubLessons, isFalse);
    });

    test('hasSubLessons returns false for empty list', () {
      const lesson = LessonDay(
        phase: 1,
        module: 1,
        day: 1,
        title: 'Title',
        description: 'Desc',
        tags: [],
        contentPath: 'path',
        customRoute: [],
      );

      expect(lesson.hasSubLessons, isFalse);
    });

    group('subLessonLabel', () {
      test('correctly formats special cases', () {
        expect(
          LessonDay.subLessonLabel('assets/curriculum/phase3/module2/day29/getx.json'),
          'GetX',
        );
        expect(
          LessonDay.subLessonLabel('assets/curriculum/phase3/module3/day30/bloc.json'),
          'BLoC',
        );
        expect(
          LessonDay.subLessonLabel('assets/curriculum/phase3/module3/day30/cubit.json'),
          'Cubit',
        );
        expect(
          LessonDay.subLessonLabel(
            'assets/curriculum/phase2/module2/day19/inherited_model.json',
          ),
          'InheritedModel',
        );
        expect(
          LessonDay.subLessonLabel(
            'assets/curriculum/phase3/module3/day33/state_management_matrix.json',
          ),
          'State Management Matrix',
        );
      });

      test('formats generic snake_case filenames to Title Case', () {
        expect(
          LessonDay.subLessonLabel('path/to/custom_feature_guide.json'),
          'Custom Feature Guide',
        );
      });
    });
  });
}
