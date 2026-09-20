import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/error/app_exception.dart';
import '../../../domain/models/ai_chat_turn.dart';
import '../../../domain/models/ai_model.dart';
import '../../../domain/models/key_validation_result.dart';
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
    List<ChatTurn> history = const [],
  }) async* {
    final apiKey = await _settingsLocalDataSource.readProviderKey(model);
    if (apiKey == null || apiKey.isEmpty) {
      throw const AiTutorException(StringConstants.missingAnthropicKey);
    }

    try {
      final messages = <Map<String, String>>[];
      for (final turn in history) {
        final role = turn.role == ChatRole.assistant ? 'assistant' : 'user';
        messages.add({'role': role, 'content': turn.text});
      }
      messages.add({'role': 'user', 'content': userMessage});

      final response = await _dio.post<ResponseBody>(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
        data: {
          'model': model.modelName,
          'max_tokens': 1024,
          'system': systemPrompt,
          'messages': messages,
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
  Future<KeyValidationResult> validateKey(String apiKey, AiModel model) async {
    try {
      final response = await _dio.post(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
          validateStatus: (status) => true,
        ),
        data: {
          'model': model.modelName,
          'max_tokens': 1,
          'messages': [
            {'role': 'user', 'content': 'test'},
          ],
        },
      );

      final status = response.statusCode ?? 0;
      if (status == 200) {
        return KeyValidationResult.valid;
      } else if (status == 401) {
        return KeyValidationResult.unauthorized;
      } else if (status == 429) {
        return KeyValidationResult.rateLimited;
      } else if (status == 403 || status == 404) {
        return KeyValidationResult.modelUnavailable;
      }
      return KeyValidationResult.unauthorized;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return KeyValidationResult.networkUnavailable;
      }
      final status = e.response?.statusCode;
      if (status == 401) return KeyValidationResult.unauthorized;
      if (status == 429) return KeyValidationResult.rateLimited;
      return KeyValidationResult.unknown;
    } catch (_) {
      return KeyValidationResult.unknown;
    }
  }
}
