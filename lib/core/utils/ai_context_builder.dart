import 'package:injectable/injectable.dart';

import '../../domain/models/curriculum/lesson_content.dart';
import '../../domain/models/curriculum/lesson_day.dart';
import '../../domain/models/curriculum/phase.dart';
import '../constants/ai_constants.dart';
import '../constants/app_constants.dart';

/// Pure Dart utility for assembling the complete system prompt for the AI Tutor.
@singleton
class AiContextBuilder {
  /// Assembles the final system prompt with prioritized learning context:
  /// 1. Stable tutor guardrails and pedagogical guidelines.
  /// 2. Verification disclaimer and official documentation guidance.
  /// 3. App meta-context (architecture).
  /// 4. Current active lesson summary & bounded theory text.
  /// 5. Up to 3 relevant roadmap items matching active lesson tags/keywords.
  /// 6. Minimal progress summary (completed & current unlocked IDs).
  String buildSystemPrompt({
    required List<Phase> phases,
    required Set<String> completedLessonIds,
    LessonDay? currentLesson,
    LessonContent? currentContent,
    List<LessonDay> historicalLessons = const [],
  }) {
    final buffer = StringBuffer();

    // 1. System Guardrails & Pedagogy
    buffer.writeln(AiConstants.kSystemGuardrails);
    buffer.writeln();

    // 2. Official Documentation & Roadmap Disclaimer
    buffer.writeln('TEACHING DISCLAIMER & ACCURACY GUIDELINES:');
    buffer.writeln(
      "- Project teaching material must be referred to as 'In this roadmap'.",
    );
    buffer.writeln(
      '- Do not claim model output is an official Flutter guarantee.',
    );
    buffer.writeln(
      '- When discussing version-sensitive Flutter/Dart APIs, encourage verification with official documentation at docs.flutter.dev.',
    );
    buffer.writeln();

    // 3. Application Meta-Context (How the app is built)
    buffer.writeln(AiConstants.kAppMetaContext);
    buffer.writeln();

    // 4. Current Lesson Context (Highest priority dynamic context)
    if (currentLesson != null) {
      buffer.writeln(AiConstants.kLessonContextHeader);
      buffer.writeln(
        '- Phase ${currentLesson.phase}, Module ${currentLesson.module}, Day ${currentLesson.day}: ${currentLesson.title} (ID: ${currentLesson.lessonId})',
      );
      if (currentLesson.tags.isNotEmpty) {
        buffer.writeln('  TAGS: ${currentLesson.tags.join(', ')}');
      }
      if (currentContent != null && currentContent.theory.isNotEmpty) {
        // Bound theory to 1500 chars to protect context budget
        final theoryText = currentContent.theory.length > 1500
            ? '${currentContent.theory.substring(0, 1500)}...\n[Truncated for brevity]'
            : currentContent.theory;
        buffer.writeln('LESSON THEORY SUMMARY:');
        buffer.writeln(theoryText);
      }
      buffer.writeln();
    }

    // 5. Relevant Roadmap Items (Priority tags & keyword match, max 3)
    final relevantLessons = _findRelevantLessons(
      phases: phases,
      currentLesson: currentLesson,
      maxItems: 3,
    );

    if (relevantLessons.isNotEmpty) {
      buffer.writeln('RELEVANT ROADMAP LESSONS (In this curriculum):');
      for (final lesson in relevantLessons) {
        buffer.writeln(
          '- Phase ${lesson.phase}, Module ${lesson.module}, Day ${lesson.day}: ${lesson.title} (ID: ${lesson.lessonId})',
        );
      }
      buffer.writeln();
    }

    // 6. Dynamic User Progress Status
    buffer.writeln(AiConstants.kUserProgressHeader);
    buffer.writeln('COMPLETED LESSON IDs: [${completedLessonIds.join(", ")}]');

    // Identify current unlocked lesson
    String? currentUnlockedId;
    for (final phase in phases) {
      for (final module in phase.modules) {
        for (final day in module.days) {
          if (!completedLessonIds.contains(day.lessonId)) {
            currentUnlockedId = day.lessonId;
            break;
          }
        }
        if (currentUnlockedId != null) break;
      }
      if (currentUnlockedId != null) break;
    }
    if (currentUnlockedId != null) {
      buffer.writeln('CURRENT UNLOCKED LESSON ID: $currentUnlockedId');
    }
    buffer.writeln();

    final prompt = buffer.toString();

    // Safety budget truncation
    if (prompt.length > AppConstants.maxSystemPromptCharacters) {
      return prompt.substring(0, AppConstants.maxSystemPromptCharacters);
    }

    return prompt;
  }

  /// Extracts up to [maxItems] lessons related to [currentLesson] based on tag/title overlap.
  List<LessonDay> _findRelevantLessons({
    required List<Phase> phases,
    LessonDay? currentLesson,
    int maxItems = 3,
  }) {
    if (currentLesson == null) return const [];

    final currentTags = currentLesson.tags.map((t) => t.toLowerCase()).toSet();
    final matches = <LessonDay>[];

    for (final phase in phases) {
      for (final module in phase.modules) {
        for (final day in module.days) {
          if (day.lessonId == currentLesson.lessonId) continue;

          final hasTagMatch = day.tags.any(
            (t) => currentTags.contains(t.toLowerCase()),
          );
          if (hasTagMatch) {
            matches.add(day);
            if (matches.length >= maxItems) return matches;
          }
        }
      }
    }

    return matches;
  }
}
