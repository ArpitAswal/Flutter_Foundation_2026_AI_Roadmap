import 'package:injectable/injectable.dart';

import '../../domain/models/curriculum/lesson_day.dart';
import '../constants/ai_constants.dart';
import '../constants/app_constants.dart';

/// Pure Dart utility for assembling the complete system prompt for the Gemini AI.
@singleton
class AiContextBuilder {
  /// Assembles the final system prompt by combining guardrails, meta-context,
  /// current lesson context, and historical completed lessons context.
  String buildSystemPrompt({
    required LessonDay currentLesson,
    required List<LessonDay> historicalLessons,
  }) {
    final buffer = StringBuffer();

    // 1. System Guardrails
    buffer.writeln(AiConstants.kSystemGuardrails);
    buffer.writeln();

    // 2. Application Meta-Context (How the app is built)
    buffer.writeln(AiConstants.kAppMetaContext);
    buffer.writeln();

    // 3. Current Lesson Context (What the user is learning right now)
    buffer.writeln(AiConstants.kLessonContextHeader);
    buffer.writeln('- Day ${currentLesson.day}: ${currentLesson.title}');
    buffer.writeln(
      '- Summary: ${currentLesson.content.theory.isNotEmpty ? "Available" : "None"}',
    );
    buffer.writeln();

    // 4. Historical Lesson Context (If any match the user query)
    if (historicalLessons.isNotEmpty) {
      buffer.writeln(AiConstants.kHistoricalContextHeader);
      for (final lesson in historicalLessons) {
        buffer.writeln('- Day ${lesson.day}: ${lesson.title}');
        buffer.writeln(
          '  Summary: ${lesson.content.theory.isNotEmpty ? "Available" : "None"}',
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
