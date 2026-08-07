import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/error/app_exception.dart';
import '../../../domain/models/ai_model.dart';
import 'ai_remote_data_source.dart';

/// Remote data source responsible for communicating with the OpenAI API via Dio.
@Injectable(as: AiRemoteDataSource)
@Named('openai')
class OpenAiDataSourceImpl implements AiRemoteDataSource {
  final Dio _dio;

  const OpenAiDataSourceImpl(this._dio);

  @override
  Stream<String> sendMessage({
    required String systemPrompt,
    required String userMessage,
    required AiModel model,
  }) async* {
    final apiKey = dotenv.env['CHATGPT_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw const AiTutorException(StringConstants.missingOpenAiKey);
    }

    try {
      final response = await _dio.post<ResponseBody>(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
        data: {
          'model': model.modelName,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'stream': true,
        },
      );

      final stream = response.data?.stream;
      if (stream == null) {
        throw const NetworkException('Failed to receive stream from OpenAI API.');
      }

      await for (final rawData in stream) {
        final chunkStr = utf8.decode(rawData);
        final lines = chunkStr.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ') && line != 'data: [DONE]') {
            final jsonStr = line.substring(6);
            if (jsonStr.trim().isEmpty) continue;

            try {
              final parsed = jsonDecode(jsonStr);
              final choices = parsed['choices'] as List<dynamic>?;
              if (choices != null && choices.isNotEmpty) {
                final delta = choices.first['delta'] as Map<String, dynamic>?;
                final content = delta?['content'] as String?;
                if (content != null && content.isNotEmpty) {
                  yield content;
                }
              }
            } catch (_) {
              // Ignore parse errors for malformed chunks
            }
          }
        }
      }
    } on DioException catch (e) {
      throw NetworkException('OpenAI API Error: ${e.message}', e);
    } catch (e) {
      throw NetworkException('An unexpected error occurred while communicating with OpenAI.', e);
    }
  }
}
