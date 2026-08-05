import 'package:injectable/injectable.dart';

import '../../domain/models/lesson.dart';
import '../constants/ai_constants.dart';
import '../constants/app_constants.dart';

/// Pure Dart utility for assembling the complete system prompt for the Gemini AI.
@singleton
class AiContextBuilder {
  /// Assembles the final system prompt by combining guardrails, meta-context,
  /// current lesson context, and historical completed lessons context.
  String buildSystemPrompt({
    required Lesson currentLesson,
    required List<Lesson> historicalLessons,
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
    buffer.writeln('- Day ${currentLesson.dayNumber}: ${currentLesson.title}');
    buffer.writeln('- Category: ${currentLesson.category}');
    buffer.writeln('- Technologies Taught: ${currentLesson.taughtTechnologies.join(', ')}');
    buffer.writeln('- Summary: ${currentLesson.contentSummary}');
    buffer.writeln();

    // 4. Historical Lesson Context (If any match the user query)
    if (historicalLessons.isNotEmpty) {
      buffer.writeln(AiConstants.kHistoricalContextHeader);
      for (final lesson in historicalLessons) {
        buffer.writeln('- Day ${lesson.dayNumber}: ${lesson.title}');
        buffer.writeln('  Technologies: ${lesson.taughtTechnologies.join(', ')}');
        buffer.writeln('  Summary: ${lesson.contentSummary}');
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
