import 'package:injectable/injectable.dart';

import '../../core/utils/ai_context_builder.dart';
import '../models/curriculum/lesson_day.dart';
import '../models/gemini_model.dart';
import '../repositories/ai_tutor_repository.dart';

/// Orchestrates the process of querying the AI Tutor with context injection.
@injectable
class AskAiTutorUseCase {
  final AiTutorRepository _aiTutorRepository;
  final AiContextBuilder _aiContextBuilder;

  const AskAiTutorUseCase(this._aiTutorRepository, this._aiContextBuilder);

  /// Executes the context pipeline and returns a streamed response from Gemini.
  Stream<String> execute({
    required String userMessage,
    required LessonDay currentLesson,
    GeminiModel model = GeminiModel.flash,
  }) async* {
    // 2. Assemble the final system prompt (no historical context for now)
    final systemPrompt = _aiContextBuilder.buildSystemPrompt(
      currentLesson: currentLesson,
      historicalLessons: [],
    );

    // 4. Stream the response from the repository using the selected model
    yield* _aiTutorRepository.askQuestion(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      model: model,
    );
  }
}
