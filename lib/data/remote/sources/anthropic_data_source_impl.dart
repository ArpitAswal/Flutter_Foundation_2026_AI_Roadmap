import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/models/ai_model.dart';
import 'ai_remote_data_source.dart';

/// Remote data source responsible for communicating with the Anthropic API via Dio.
@Injectable(as: AiRemoteDataSource)
@Named('anthropic')
class AnthropicDataSourceImpl implements AiRemoteDataSource {
  final Dio _dio;

  const AnthropicDataSourceImpl(this._dio);

  @override
  Stream<String> sendMessage({
    required String systemPrompt,
    required String userMessage,
    required AiModel model,
  }) async* {
    final apiKey = dotenv.env['CLAUDE_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw const AiTutorException('CLAUDE_API_KEY is not set in the .env file.');
    }

    try {
      final response = await _dio.post<ResponseBody>(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'anthropic-beta': 'prompt-caching-2024-07-31',
            'content-type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
        data: {
          'model': model.modelName,
          'max_tokens': 1024,
          'system': [
            {
              "type": "text",
              "text": systemPrompt,
              "cache_control": {"type": "ephemeral"}
            }
          ],
          'messages': [
            {'role': 'user', 'content': userMessage},
          ],
          'stream': true,
        },
      );

      final stream = response.data?.stream;
      if (stream == null) {
        throw const NetworkException('Failed to receive stream from Anthropic API.');
      }

      await for (final rawData in stream) {
        final chunkStr = utf8.decode(rawData);
        final lines = chunkStr.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);
            if (jsonStr.trim().isEmpty) continue;

            try {
              final parsed = jsonDecode(jsonStr);
              final type = parsed['type'] as String?;
              
              if (type == 'content_block_delta') {
                final delta = parsed['delta'] as Map<String, dynamic>?;
                final text = delta?['text'] as String?;
                if (text != null && text.isNotEmpty) {
                  yield text;
                }
              }
            } catch (_) {
              // Ignore parse errors for malformed chunks
            }
          }
        }
      }
    } on DioException catch (e) {
      throw NetworkException('Anthropic API Error: ${e.message}', e);
    } catch (e) {
      throw NetworkException('An unexpected error occurred while communicating with Claude.', e);
    }
  }
}
