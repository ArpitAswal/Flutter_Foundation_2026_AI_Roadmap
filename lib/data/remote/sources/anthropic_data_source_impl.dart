import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/error/app_exception.dart';
import '../../../domain/models/ai_model.dart';
import '../../local/sources/ai_assistant_settings_local_data_source.dart';
import 'ai_remote_data_source.dart';

/// Remote data source responsible for communicating with the Anthropic API via Dio.
@Injectable(as: AiRemoteDataSource)
@Named('anthropic')
class AnthropicDataSourceImpl implements AiRemoteDataSource {
  final Dio _dio;
  final AiAssistantSettingsLocalDataSource _settingsLocalDataSource;

  const AnthropicDataSourceImpl(this._dio, this._settingsLocalDataSource);

  @override
  Stream<String> sendMessage({
    required String systemPrompt,
    required String userMessage,
    required AiModel model,
  }) async* {
    final apiKey = await _settingsLocalDataSource.readProviderKey(model);
    if (apiKey == null || apiKey.isEmpty) {
      throw const AiTutorException(StringConstants.missingAnthropicKey);
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
              "cache_control": {"type": "ephemeral"},
            },
          ],
          'messages': [
            {'role': 'user', 'content': userMessage},
          ],
          'stream': true,
        },
      );

      final stream = response.data?.stream;
      if (stream == null) {
        throw const NetworkException(
          'Failed to receive stream from Anthropic API.',
        );
      }

      var eventBuffer = '';

      await for (final rawData in stream) {
        eventBuffer += utf8.decode(rawData, allowMalformed: true);

        while (true) {
          final newlineIndex = eventBuffer.indexOf('\n');
          if (newlineIndex == -1) {
            break;
          }

          final line = eventBuffer.substring(0, newlineIndex).trimRight();
          eventBuffer = eventBuffer.substring(newlineIndex + 1);

          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr.isEmpty) continue;

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
              // Ignore parse errors for malformed chunks.
            }
          }
        }
      }
    } on DioException catch (e) {
      throw NetworkException('Anthropic API Error: ${e.message}', e);
    } catch (e) {
      throw NetworkException(
        'An unexpected error occurred while communicating with Claude.',
        e,
      );
    }
  }

  @override
  Future<bool> isValidKey(String apiKey, AiModel model) async {
    try {
      final response = await _dio.post(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
        ),
        data: {
          'model': model.modelName,
          'max_tokens': 1,
          'messages': [
            {'role': 'user', 'content': 'test'},
          ],
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      // If it throws DioException for 401 Unauthorized, it's invalid.
      // Other errors might indicate network issues, but for simplicity we return false.
      return false;
    }
  }
}
