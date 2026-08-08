import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/string_constants.dart';
import '../../../domain/models/ai_model.dart';
import '../../../data/local/sources/ai_assistant_settings_local_data_source.dart';
import 'ai_assistant_settings_state.dart';

/// Holds the persisted AI assistant configuration for the chat and settings UI.
@lazySingleton
class AiAssistantSettingsCubit extends Cubit<AiAssistantSettingsState> {
  final AiAssistantSettingsLocalDataSource _localDataSource;

  AiAssistantSettingsCubit(this._localDataSource)
    : super(AiAssistantSettingsState.initial());

  Future<void> loadSettings() async {
    if (!state.isLoading && state.errorMessage == null) {
      return;
    }

    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final selectedModel = await _localDataSource.readSelectedModel();
      final keyAvailability = await _localDataSource.readKeyAvailability();

      emit(
        state.copyWith(
          isLoading: false,
          selectedModel: selectedModel,
          keyAvailability: keyAvailability,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: StringConstants.aiAssistantSettingsLoadError,
        ),
      );
    }
  }

  Future<void> selectModel(AiModel model) async {
    emit(state.copyWith(isSaving: true, clearErrorMessage: true));

    try {
      await _localDataSource.saveSelectedModel(model);
      emit(
        state.copyWith(
          isSaving: false,
          selectedModel: model,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: StringConstants.aiAssistantSettingsSaveError,
        ),
      );
    }
  }

  Future<void> saveProviderKey(AiModel model, String apiKey) async {
    emit(state.copyWith(isSaving: true, clearErrorMessage: true));

    try {
      await _localDataSource.saveProviderKey(model, apiKey);
      await _reloadKeyAvailability();
      emit(state.copyWith(isSaving: false, clearErrorMessage: true));
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: StringConstants.aiAssistantKeySaveError,
        ),
      );
    }
  }

  Future<void> deleteProviderKey(AiModel model) async {
    emit(state.copyWith(isSaving: true, clearErrorMessage: true));

    try {
      await _localDataSource.deleteProviderKey(model);
      await _reloadKeyAvailability();
      emit(state.copyWith(isSaving: false, clearErrorMessage: true));
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: StringConstants.aiAssistantKeyDeleteError,
        ),
      );
    }
  }

  Future<void> _reloadKeyAvailability() async {
    final keyAvailability = await _localDataSource.readKeyAvailability();
    emit(state.copyWith(keyAvailability: keyAvailability));
  }
}
