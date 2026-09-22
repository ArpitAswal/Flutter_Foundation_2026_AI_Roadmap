import 'dart:convert';
import 'dart:io';

import 'package:flutter_foundation/domain/models/curriculum/phase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Curriculum Index Integrity', () {
    test('curriculum_index.json parses all phases and days successfully', () {
      final file = File('assets/curriculum/curriculum_index.json');
      expect(file.existsSync(), isTrue);

      final jsonStr = file.readAsStringSync();
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      final phasesJson = data['phases'] as List;

      final phases = phasesJson
          .map((p) => Phase.fromJson(p as Map<String, dynamic>))
          .toList();

      expect(phases, isNotEmpty);

      int totalDays = 0;
      int subLessonDays = 0;

      for (final phase in phases) {
        for (final module in phase.modules) {
          for (final day in module.days) {
            totalDays++;
            // Verify main content_path file exists
            final contentFile = File(day.contentPath);
            expect(
              contentFile.existsSync(),
              isTrue,
              reason: 'Missing file: ${day.contentPath}',
            );

            // If day has sub-lessons, verify each sub-lesson file exists
            if (day.hasSubLessons) {
              subLessonDays++;
              for (final subPath in day.customRoute!) {
                final subFile = File(subPath);
                expect(
                  subFile.existsSync(),
                  isTrue,
                  reason: 'Missing sub-lesson file: $subPath',
                );

                // Verify each sub-lesson parses as valid JSON with LessonContent keys
                final subContent = jsonDecode(subFile.readAsStringSync()) as Map<String, dynamic>;
                expect(subContent.containsKey('theory'), isTrue);
              }
            }
          }
        }
      }

      expect(totalDays, equals(32));
      expect(subLessonDays, equals(2));
    });
  });
}
