import 'package:equatable/equatable.dart';

import '../../../domain/models/ai_model.dart';

/// State for AI assistant configuration persistence.
class AiAssistantSettingsState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final AiModel selectedModel;
  final Map<AiModel, bool> keyAvailability;
  final String? errorMessage;

  const AiAssistantSettingsState({
    required this.isLoading,
    required this.isSaving,
    required this.selectedModel,
    required this.keyAvailability,
    required this.errorMessage,
  });

  factory AiAssistantSettingsState.initial() {
    return const AiAssistantSettingsState(
      isLoading: true,
      isSaving: false,
      selectedModel: AiModel.geminiFlash,
      keyAvailability: {
        AiModel.geminiFlash: false,
        AiModel.gpt4oMini: false,
        AiModel.claudeHaiku: false,
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
    bool? isSaving,
    AiModel? selectedModel,
    Map<AiModel, bool>? keyAvailability,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AiAssistantSettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      selectedModel: selectedModel ?? this.selectedModel,
      keyAvailability: keyAvailability ?? this.keyAvailability,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    selectedModel,
    keyAvailability,
    errorMessage,
  ];
}
