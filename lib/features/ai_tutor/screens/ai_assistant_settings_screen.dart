import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/di/injection.dart';
import '../../../domain/models/ai_model.dart';
import '../bloc/ai_assistant_settings_cubit.dart';
import '../bloc/ai_assistant_settings_state.dart';

/// Dedicated settings screen for AI assistant model selection and provider keys.
class AiAssistantSettingsScreen extends StatefulWidget {
  const AiAssistantSettingsScreen({super.key});

  @override
  State<AiAssistantSettingsScreen> createState() =>
      _AiAssistantSettingsScreenState();
}

class _AiAssistantSettingsScreenState extends State<AiAssistantSettingsScreen> {
  final Map<AiModel, TextEditingController> _controllers = {
    for (final model in AiModel.values) model: TextEditingController(),
  };
  final Map<AiModel, bool> _obscureText = {
    for (final model in AiModel.values) model: true,
  };

  late final AiAssistantSettingsCubit _settingsCubit;

  @override
  void initState() {
    super.initState();
    _settingsCubit = getIt<AiAssistantSettingsCubit>();
    _settingsCubit.loadSettings();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _settingsCubit,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text(StringConstants.settingsTitle),
          centerTitle: false,
        ),
        body: SafeArea(
          child:
              BlocBuilder<AiAssistantSettingsCubit, AiAssistantSettingsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildHeroCard(context, state),
                      const SizedBox(height: 20),
                      _buildModelSection(context, state),
                      const SizedBox(height: 20),
                      _buildProviderSection(
                        context,
                        state,
                        model: AiModel.geminiFlash,
                      ),
                      const SizedBox(height: 16),
                      _buildProviderSection(
                        context,
                        state,
                        model: AiModel.gpt4oMini,
                      ),
                      const SizedBox(height: 16),
                      _buildProviderSection(
                        context,
                        state,
                        model: AiModel.claudeHaiku,
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 20),
                        _buildErrorBanner(context, state.errorMessage!),
                      ],
                    ],
                  );
                },
              ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, AiAssistantSettingsState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              state.isAssistantLocked ? Icons.lock_rounded : Icons.key_rounded,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Show locked state text if no keys are available.
                  state.isAssistantLocked
                      ? StringConstants.settingsAssistantLocked
                      : StringConstants.settingsAssistantReady,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  // Show description corresponding to the lock state.
                  state.isAssistantLocked
                      ? StringConstants.settingsUnlockPrompt
                      : StringConstants.settingsKeysSaved,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelSection(
    BuildContext context,
    AiAssistantSettingsState state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConstants.settingsDefaultModelTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            StringConstants.settingsDefaultModelDesc,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<AiModel>(
            initialValue: state.selectedModel,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: AiModel.values
                .map(
                  (model) => DropdownMenuItem<AiModel>(
                    value: model,
                    child: Text(model.label),
                  ),
                )
                .toList(),
            onChanged: (model) {
              if (model != null) {
                context.read<AiAssistantSettingsCubit>().selectModel(model);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSection(
    BuildContext context,
    AiAssistantSettingsState state, {
    required AiModel model,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasKey = state.keyAvailability[model] ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  model.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _buildStatusChip(context, hasKey),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            StringConstants.settingsSecureStorageDesc,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controllers[model],
            // Use obscure text by default to hide the API key from plain sight.
            obscureText: _obscureText[model] ?? true,
            decoration: InputDecoration(
              labelText:
                  '${model.label} ${StringConstants.settingsApiKeySuffix}',
              hintText: StringConstants.settingsPasteHint,
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      (_obscureText[model] ?? true)
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText[model] = !(_obscureText[model] ?? true);
                      });
                    },
                  ),
                ],
              ),
            ),
            enableSuggestions: false,
            autocorrect: false,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: state.isSaving
                    ? null
                    : () async {
                        final key = _controllers[model]!.text;
                        if (key.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                StringConstants.settingsEnterKeyFirst,
                              ),
                            ),
                          );
                          return;
                        }

                        // Save the key through the cubit and clear the input field on success.
                        await context
                            .read<AiAssistantSettingsCubit>()
                            .saveProviderKey(model, key);
                        _controllers[model]!.clear();
                      },
                child: const Text(StringConstants.settingsSaveKeyBtn),
              ),
              OutlinedButton(
                onPressed: state.isSaving || !hasKey
                    ? null
                    : () async {
                        // Delete the key and let the cubit update the state.
                        await context
                            .read<AiAssistantSettingsCubit>()
                            .deleteProviderKey(model);
                      },
                child: const Text(StringConstants.settingsRemoveBtn),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, bool hasKey) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: hasKey
            ? colorScheme.primaryContainer
            : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        hasKey
            ? StringConstants.settingsSavedChip
            : StringConstants.settingsMissingChip,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: hasKey ? colorScheme.onPrimaryContainer : colorScheme.error,
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, style: TextStyle(color: colorScheme.error)),
    );
  }
}
