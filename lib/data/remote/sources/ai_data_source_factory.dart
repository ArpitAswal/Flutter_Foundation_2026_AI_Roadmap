import 'package:injectable/injectable.dart';

import '../../../domain/models/ai_model.dart';
import '../../../domain/models/key_validation_result.dart';
import 'ai_remote_data_source.dart';

/// Factory responsible for providing the correct data source implementation
/// based on the selected AI model.
@singleton
class AiDataSourceFactory {
  final AiRemoteDataSource _geminiDataSource;
  final AiRemoteDataSource _openAiDataSource;
  final AiRemoteDataSource _anthropicDataSource;

  const AiDataSourceFactory(
    @Named('gemini') this._geminiDataSource,
    @Named('openai') this._openAiDataSource,
    @Named('anthropic') this._anthropicDataSource,
  );

  /// Returns the appropriate data source for the given [model].
  AiRemoteDataSource getDataSource(AiModel model) {
    switch (model) {
      case AiModel.geminiFlash:
        return _geminiDataSource;
      case AiModel.gpt5Mini:
        return _openAiDataSource;
      case AiModel.claudeHaiku:
        return _anthropicDataSource;
    }
  }

  /// Verifies if the [apiKey] is valid for the given [model] and returns a typed [KeyValidationResult].
  Future<KeyValidationResult> validateKey(AiModel model, String apiKey) async {
    final dataSource = getDataSource(model);
    return dataSource.validateKey(apiKey, model);
  }
}
