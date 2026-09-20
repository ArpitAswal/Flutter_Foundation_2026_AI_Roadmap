import 'package:injectable/injectable.dart';

import '../../core/constants/string_constants.dart';
import '../../core/utils/ai_context_builder.dart';
import '../models/ai_chat_turn.dart';
import '../models/ai_model.dart';
import '../models/curriculum/lesson_content.dart';
import '../models/curriculum/lesson_day.dart';
import '../repositories/ai_tutor_repository.dart';
import '../services/conversation_context_builder.dart';
import '../services/question_scope_policy.dart';
import 'get_completed_lesson_ids_use_case.dart';
import 'get_phases_use_case.dart';

/// Orchestrates the process of querying the AI Tutor with deterministic scope evaluation,
/// prioritized learning context, and bounded conversational continuity.
@injectable
class AskAiTutorUseCase {
  final AiTutorRepository _aiTutorRepository;
  final AiContextBuilder _aiContextBuilder;
  final QuestionScopePolicy _scopePolicy;
  final ConversationContextBuilder _conversationContextBuilder;
  final GetPhasesUseCase _getPhasesUseCase;
  final GetCompletedLessonIdsUseCase _getCompletedLessonIdsUseCase;

  const AskAiTutorUseCase(
    this._aiTutorRepository,
    this._aiContextBuilder,
    this._scopePolicy,
    this._conversationContextBuilder,
    this._getPhasesUseCase,
    this._getCompletedLessonIdsUseCase,
  );

  /// Executes the scope policy and context pipeline, returning a streamed response.
  Stream<String> execute({
    required String userMessage,
    LessonDay? currentLesson,
    LessonContent? currentContent,
    AiModel model = AiModel.geminiFlash,
    List<ChatTurn> history = const [],
  }) async* {
    // 1. Evaluate deterministic scope policy before calling any external provider
    final scopeResult = _scopePolicy.evaluate(userMessage);

    if (scopeResult == QuestionScopeResult.refused) {
      yield StringConstants.aiTutorRefusalMessage;
      return;
    }

    if (scopeResult == QuestionScopeResult.clarificationNeeded) {
      yield StringConstants.aiTutorClarificationMessage;
      return;
    }

    // 2. Fetch the global roadmap skeleton
    final phases = await _getPhasesUseCase();

    // 3. Fetch user's exact progress state
    final completedIds = _getCompletedLessonIdsUseCase();

    // 4. Assemble prioritized system prompt
    final systemPrompt = _aiContextBuilder.buildSystemPrompt(
      phases: phases,
      completedLessonIds: completedIds,
      currentLesson: currentLesson,
      currentContent: currentContent,
      historicalLessons: const [],
    );

    // 5. Build bounded conversation window
    final boundedWindow = _conversationContextBuilder.buildWindow(
      history: history,
      activeQuestion: userMessage,
      currentLessonId: currentLesson?.lessonId,
    );

    // 6. Stream the response from the repository using the selected model and bounded history
    yield* _aiTutorRepository.askQuestion(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      model: model,
      history: boundedWindow,
    );
  }
}
