import 'package:equatable/equatable.dart';

import '../../../domain/models/ai_model.dart';

/// State for AI assistant configuration persistence.
class AiAssistantSettingsState extends Equatable {
  final bool isLoading;
  final bool isSavingModel;
  final AiModel? savingKeyModel;
  final AiModel selectedModel;
  final Map<AiModel, bool> keyAvailability;
  final Map<AiModel, String> savedKeys;
  final String? errorMessage;

  const AiAssistantSettingsState({
    required this.isLoading,
    required this.isSavingModel,
    this.savingKeyModel,
    required this.selectedModel,
    required this.keyAvailability,
    required this.savedKeys,
    required this.errorMessage,
  });

  factory AiAssistantSettingsState.initial() {
    return const AiAssistantSettingsState(
      isLoading: true,
      isSavingModel: false,
      savingKeyModel: null,
      selectedModel: AiModel.geminiFlash,
      keyAvailability: {
        AiModel.geminiFlash: false,
        AiModel.gpt4oMini: false,
        AiModel.claudeHaiku: false,
      },
      savedKeys: {
        AiModel.geminiFlash: '',
        AiModel.gpt4oMini: '',
        AiModel.claudeHaiku: '',
      },
      errorMessage: null,
    );
  }

  bool get hasAnyConfiguredKey => keyAvailability.values.any((value) => value);

  bool get hasSelectedModelKey => keyAvailability[selectedModel] ?? false;

  bool get isAssistantLocked => !hasAnyConfiguredKey;

  bool get isSelectedModelLocked => !hasSelectedModelKey;

  AiAssistantSettingsState copyWith({
    bool? isLoading,
    bool? isSavingModel,
    AiModel? savingKeyModel,
    bool clearSavingKeyModel = false,
    AiModel? selectedModel,
    Map<AiModel, bool>? keyAvailability,
    Map<AiModel, String>? savedKeys,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AiAssistantSettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSavingModel: isSavingModel ?? this.isSavingModel,
      savingKeyModel: clearSavingKeyModel
          ? null
          : (savingKeyModel ?? this.savingKeyModel),
      selectedModel: selectedModel ?? this.selectedModel,
      keyAvailability: keyAvailability ?? this.keyAvailability,
      savedKeys: savedKeys ?? this.savedKeys,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSavingModel,
    savingKeyModel,
    selectedModel,
    keyAvailability,
    savedKeys,
    errorMessage,
  ];
}
