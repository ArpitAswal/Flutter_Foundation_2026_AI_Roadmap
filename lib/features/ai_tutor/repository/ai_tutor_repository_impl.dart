import 'package:injectable/injectable.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/failure.dart';
import '../../../data/remote/sources/gemini_remote_data_source.dart';
import '../../../domain/models/gemini_model.dart';
import '../../../domain/repositories/ai_tutor_repository.dart';

/// Implementation of [AiTutorRepository] that coordinates with the Gemini API.
@Injectable(as: AiTutorRepository)
class AiTutorRepositoryImpl implements AiTutorRepository {
  final GeminiRemoteDataSource _remoteDataSource;

  const AiTutorRepositoryImpl(this._remoteDataSource);

  @override
  Stream<String> askQuestion({
    required String systemPrompt,
    required String userMessage,
    GeminiModel model = GeminiModel.flash,
  }) async* {
    try {
      yield* _remoteDataSource.sendMessage(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        model: model,
      );
    } on NetworkException catch (e) {
      throw AiTutorFailure(e.message);
    } catch (e) {
      throw const AiTutorFailure('An unexpected error occurred while communicating with the AI Tutor.');
    }
  }
}
