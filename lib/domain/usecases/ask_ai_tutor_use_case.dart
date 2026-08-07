import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../core/utils/ai_context_builder.dart';
import '../models/curriculum/lesson_content.dart';
import '../models/curriculum/lesson_day.dart';
import '../models/ai_model.dart';
import '../repositories/ai_tutor_repository.dart';
import 'get_phases_use_case.dart';
import 'get_completed_lesson_ids_use_case.dart';

/// Orchestrates the process of querying the AI Tutor with context injection.
@injectable
class AskAiTutorUseCase {
  final AiTutorRepository _aiTutorRepository;
  final AiContextBuilder _aiContextBuilder;
  final GetPhasesUseCase _getPhasesUseCase;
  final GetCompletedLessonIdsUseCase _getCompletedLessonIdsUseCase;

  const AskAiTutorUseCase(
    this._aiTutorRepository,
    this._aiContextBuilder,
    this._getPhasesUseCase,
    this._getCompletedLessonIdsUseCase,
  );

  /// Executes the context pipeline and returns a streamed response from the AI.
  ///
  /// [currentLesson] and [currentContent] are optional so the AI Tutor can
  /// work globally from high-level curriculum screens (Phase/Module).
  Stream<String> execute({
    required String userMessage,
    LessonDay? currentLesson,
    LessonContent? currentContent,
    AiModel model = AiModel.geminiFlash,
  }) async* {
    debugPrint('AskAiTutorUseCase: Fetching phases...');
    // 1. Fetch the global roadmap skeleton
    final phases = await _getPhasesUseCase();

    // 2. Fetch user's exact progress state
    final completedIds = _getCompletedLessonIdsUseCase();

    // 3. Assemble the final system prompt with global + local context
    final systemPrompt = _aiContextBuilder.buildSystemPrompt(
      phases: phases,
      completedLessonIds: completedIds,
      currentLesson: currentLesson,
      currentContent: currentContent,
      historicalLessons: [],
    );

    debugPrint(
      'AskAiTutorUseCase: System Prompt length: ${systemPrompt.length} chars. Asking repository...',
    );

    // 4. Stream the response from the repository using the selected model
    yield* _aiTutorRepository.askQuestion(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      model: model,
    );
  }
}
