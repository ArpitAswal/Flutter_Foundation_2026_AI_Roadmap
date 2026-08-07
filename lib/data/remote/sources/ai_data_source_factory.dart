import 'package:injectable/injectable.dart';

import '../../../domain/models/ai_model.dart';
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
      case AiModel.gpt4oMini:
        return _openAiDataSource;
      case AiModel.claudeHaiku:
        return _anthropicDataSource;
    }
  }
}
