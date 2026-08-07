import 'package:injectable/injectable.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/failure.dart';
import '../../../data/remote/sources/ai_data_source_factory.dart';
import '../../../domain/models/ai_model.dart';
import '../../../domain/repositories/ai_tutor_repository.dart';

/// Implementation of [AiTutorRepository] that coordinates with the AI APIs.
@Injectable(as: AiTutorRepository)
class AiTutorRepositoryImpl implements AiTutorRepository {
  final AiDataSourceFactory _dataSourceFactory;

  const AiTutorRepositoryImpl(this._dataSourceFactory);

  @override
  Stream<String> askQuestion({
    required String systemPrompt,
    required String userMessage,
    required AiModel model,
  }) async* {
    try {
      final dataSource = _dataSourceFactory.getDataSource(model);
      await for (final chunk in dataSource.sendMessage(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        model: model,
      )) {
        yield chunk;
      }
    } on AppException catch (e) {
      // Map all custom application exceptions (network drops, missing keys, api filters)
      // to the UI-friendly AiTutorFailure so the user sees exactly what went wrong.
      throw AiTutorFailure(e.message);
    } catch (e) {
      // For completely unknown exceptions, fallback to a generic constant error message.
      throw const AiTutorFailure(StringConstants.aiTutorUnexpectedError);
    }
  }
}
