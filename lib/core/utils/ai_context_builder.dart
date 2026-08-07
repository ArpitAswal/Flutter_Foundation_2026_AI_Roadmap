import 'package:injectable/injectable.dart';

import '../../domain/models/curriculum/lesson_content.dart';
import '../../domain/models/curriculum/lesson_day.dart';
import '../../domain/models/curriculum/phase.dart';
import '../constants/ai_constants.dart';
import '../constants/app_constants.dart';

/// Pure Dart utility for assembling the complete system prompt for the AI Tutor.
@singleton
class AiContextBuilder {
  /// Assembles the final system prompt by combining guardrails, meta-context,
  /// global curriculum roadmap, current lesson context, and historical completed lessons context.
  ///
  /// [currentContent] is the lazily-loaded lesson content; pass null when not yet loaded.
  String buildSystemPrompt({
    required List<Phase> phases,
    required Set<String> completedLessonIds,
    LessonDay? currentLesson,
    LessonContent? currentContent,
    required List<LessonDay> historicalLessons,
  }) {
    final buffer = StringBuffer();

    // 1. System Guardrails
    buffer.writeln(AiConstants.kSystemGuardrails);

    // 2. Application Meta-Context (How the app is built)
    buffer.writeln(AiConstants.kAppMetaContext);

    // 3. Global Curriculum Roadmap (STATIC - Cacheable)
    buffer.writeln(AiConstants.kGlobalCurriculumHeader);
    for (final phase in phases) {
      buffer.writeln('Phase ${phase.id}: ${phase.title}');
      for (final module in phase.modules) {
        buffer.writeln('  Module ${module.id}: ${module.title}');
        for (final day in module.days) {
          buffer.writeln(
            '    - Day ${day.day}: ${day.title} (ID: ${day.lessonId})',
          );
        }
      }
    }
    buffer.writeln();

    // 4. Dynamic User Progress (DYNAMIC)
    buffer.writeln(AiConstants.kUserProgressHeader);
    buffer.writeln('COMPLETED LESSON IDs: [${completedLessonIds.join(", ")}]');

    // Find current lesson id
    String? currentLessonId;
    for (final phase in phases) {
      for (final module in phase.modules) {
        for (final day in module.days) {
          if (!completedLessonIds.contains(day.lessonId)) {
            currentLessonId = day.lessonId;
            break;
          }
        }
        if (currentLessonId != null) break;
      }
      if (currentLessonId != null) break;
    }
    if (currentLessonId != null) {
      buffer.writeln('CURRENT LESSON ID (Unlocked): $currentLessonId');
    }
    buffer.writeln('ALL OTHER IDs: Locked');
    buffer.writeln();
    buffer.writeln();

    // 4. Current Lesson Context (What the user is learning right now)
    if (currentLesson != null) {
      buffer.writeln(AiConstants.kLessonContextHeader);
      buffer.writeln(
        '- Phase ${currentLesson.phase}, Module ${currentLesson.module}, Day ${currentLesson.day}: ${currentLesson.title}',
      );
      if (currentContent != null && currentContent.theory.isNotEmpty) {
        buffer.writeln('THEORY TEXT:');
        buffer.writeln(currentContent.theory);
      }
      buffer.writeln();
    }

    // 5. Historical Lesson Context (If any match the user query)
    if (historicalLessons.isNotEmpty) {
      buffer.writeln(AiConstants.kHistoricalContextHeader);
      for (final lesson in historicalLessons) {
        buffer.writeln(
          '- Phase ${lesson.phase}, Module ${lesson.module}, Day ${lesson.day}: ${lesson.title}',
        );
      }
      buffer.writeln();
    }

    final prompt = buffer.toString();

    // Safety truncate to prevent exceeding context window
    if (prompt.length > AppConstants.maxSystemPromptCharacters) {
      return prompt.substring(0, AppConstants.maxSystemPromptCharacters);
    }

    return prompt;
  }
}
