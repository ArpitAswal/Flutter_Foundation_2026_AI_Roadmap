import 'package:injectable/injectable.dart';

import '../../core/utils/ai_context_builder.dart';
import '../../core/utils/keyword_extractor.dart';
import '../../data/local/sources/lesson_local_data_source.dart';
import '../models/gemini_model.dart';
import '../models/lesson.dart';
import '../repositories/ai_tutor_repository.dart';

/// Orchestrates the process of querying the AI Tutor with context injection.
@injectable
class AskAiTutorUseCase {
  final LessonLocalDataSource _lessonLocalDataSource;
  final AiTutorRepository _aiTutorRepository;
  final KeywordExtractor _keywordExtractor;
  final AiContextBuilder _aiContextBuilder;

  const AskAiTutorUseCase(
    this._lessonLocalDataSource,
    this._aiTutorRepository,
    this._keywordExtractor,
    this._aiContextBuilder,
  );

  /// Executes the context pipeline and returns a streamed response from Gemini.
  Stream<String> execute({
    required String userMessage,
    required Lesson currentLesson,
    GeminiModel model = GeminiModel.flash,
  }) async* {
    // 1. Extract keywords from the user's prompt
    final keywords = _keywordExtractor.extract(userMessage);

    // 2. Query local DB for completed lessons matching the keywords
    final historicalRecords = await _lessonLocalDataSource.searchByKeywords(keywords);
    final historicalLessons = historicalRecords.map((r) => r.toDomain()).toList();

    // 3. Assemble the final system prompt
    final systemPrompt = _aiContextBuilder.buildSystemPrompt(
      currentLesson: currentLesson,
      historicalLessons: historicalLessons,
    );

    // 4. Stream the response from the repository using the selected model
    yield* _aiTutorRepository.askQuestion(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      model: model,
    );
  }
}
