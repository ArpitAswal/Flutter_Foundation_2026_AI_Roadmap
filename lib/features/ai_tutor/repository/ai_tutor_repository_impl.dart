import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

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
      debugPrint("ask Question...");
      final dataSource = _dataSourceFactory.getDataSource(model);
      yield* dataSource.sendMessage(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        model: model,
      );
    } on NetworkException catch (e) {
      throw AiTutorFailure(e.message);
    } catch (e) {
      throw const AiTutorFailure(
        'An unexpected error occurred while communicating with the AI Tutor.',
      );
    }
  }
}
