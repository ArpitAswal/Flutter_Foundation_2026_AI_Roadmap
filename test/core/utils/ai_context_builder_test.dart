import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_foundation/core/utils/ai_context_builder.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_content.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_day.dart';
import 'package:flutter_foundation/domain/models/curriculum/lesson_module.dart';
import 'package:flutter_foundation/domain/models/curriculum/phase.dart';

void main() {
  group('AiContextBuilder Tests', () {
    late AiContextBuilder builder;

    setUp(() {
      builder = AiContextBuilder();
    });

    final testPhases = [
      const Phase(
        id: 1,
        title: 'Dart Basics',
        description: 'Learn Dart',
        modules: [
          LessonModule(
            id: 1,
            title: 'Introduction',
            subtitle: 'Intro to Dart',
            days: [
              LessonDay(
                phase: 1,
                module: 1,
                day: 1,
                title: 'Variables',
                description: 'Variables in Dart',
                tags: ['variables', 'dart', 'types'],
                contentPath: 'assets/day1.json',
              ),
              LessonDay(
                phase: 1,
                module: 1,
                day: 2,
                title: 'Data Types',
                description: 'Data types in Dart',
                tags: ['types', 'primitives'],
                contentPath: 'assets/day2.json',
              ),
              LessonDay(
                phase: 1,
                module: 1,
                day: 3,
                title: 'Functions',
                description: 'Functions in Dart',
                tags: ['functions', 'methods'],
                contentPath: 'assets/day3.json',
              ),
            ],
          ),
        ],
      ),
    ];

    test('includes guardrails, disclaimer, meta-context, and active lesson context', () {
      const currentLesson = LessonDay(
        phase: 1,
        module: 1,
        day: 1,
        title: 'Variables',
        description: 'Variables in Dart',
        tags: ['variables', 'dart', 'types'],
        contentPath: 'assets/day1.json',
      );

      const currentContent = LessonContent(
        prerequisites: 'Basic programming knowledge',
        theory: 'Variables in Dart are type-safe.',
      );

      final prompt = builder.buildSystemPrompt(
        phases: testPhases,
        completedLessonIds: {'p1_m1_d1'},
        currentLesson: currentLesson,
        currentContent: currentContent,
      );

      expect(prompt, contains('SCOPE RESTRICTIONS & CURRICULUM GUIDANCE'));
      expect(prompt, contains('TEACHING DISCLAIMER & ACCURACY GUIDELINES'));
      expect(prompt, contains("In this roadmap"));
      expect(prompt, contains('APPLICATION META-CONTEXT'));
      expect(prompt, contains('GLOBAL CURRICULUM ROADMAP'));
      expect(prompt, contains('Phase 1: Dart Basics'));
      expect(prompt, contains('Module 1: Introduction'));
      expect(prompt, contains('Day 1: Variables'));
      expect(prompt, contains('CURRENT LESSON CONTEXT'));
      expect(prompt, contains('Variables in Dart are type-safe.'));
      expect(prompt, contains('RELEVANT ROADMAP LESSONS'));
      expect(prompt, contains('Data Types')); // matched tag 'types'
    });

    test('uses explicitly passed roadmapSkeleton when provided', () {
      const customSkeleton = 'Phase 99: Custom Phase\n  Module 1: Custom Module\n    Day 1: Custom Day';

      final prompt = builder.buildSystemPrompt(
        phases: testPhases,
        roadmapSkeleton: customSkeleton,
        completedLessonIds: {},
      );

      expect(prompt, contains('GLOBAL CURRICULUM ROADMAP'));
      expect(prompt, contains('Phase 99: Custom Phase'));
      expect(prompt, contains('Day 1: Custom Day'));
    });
  });
}
