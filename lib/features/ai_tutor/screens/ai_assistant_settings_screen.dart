import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:no_screenshot/no_screenshot.dart';

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

  final NoScreenshot _noScreenshot = NoScreenshot.instance;
  late final AiAssistantSettingsCubit _settingsCubit;

  @override
  void initState() {
    super.initState();
    // Enable screenshot prevention for security on the settings screen.
    _noScreenshot.screenshotOff();
    _settingsCubit = getIt<AiAssistantSettingsCubit>();
    _settingsCubit.loadSettings();
  }

  @override
  void dispose() {
    // Re-enable screenshots when leaving the settings screen.
    _noScreenshot.screenshotOn();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _maskApiKey(String key) {
    final trimmed = key.trim();
    if (trimmed.length <= 8) {
      return '••••••••';
    }
    final firstFour = trimmed.substring(0, 4);
    final lastFour = trimmed.substring(trimmed.length - 4);
    return '$firstFour••••••••$lastFour';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BlocProvider.value(
      value: _settingsCubit,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            StringConstants.settingsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          surfaceTintColor: Colors.transparent,
          leadingWidth: 56.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocConsumer<AiAssistantSettingsCubit, AiAssistantSettingsState>(
            listenWhen: (previous, current) =>
                (previous.errorMessage != current.errorMessage &&
                    current.errorMessage != null) ||
                previous.savedKeys != current.savedKeys ||
                (previous.isLoading && !current.isLoading),
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.errorContainer,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              }

              // Populate text controllers with saved key values when loaded or updated
              for (final model in AiModel.values) {
                final savedKey = state.savedKeys[model] ?? '';
                final hasKey = state.keyAvailability[model] ?? false;
                if (hasKey && savedKey.isNotEmpty) {
                  // Only update if text is currently empty or was cleared
                  if (_controllers[model]!.text.isEmpty) {
                    _controllers[model]!.text = savedKey;
                  }
                } else if (!hasKey) {
                  _controllers[model]!.clear();
                }
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return Center(
                  child: SpinKitThreeBounce(
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth > 680.0
                      ? (constraints.maxWidth - 680.0) / 2 + 16.0
                      : 16.0;

                  return ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 16.0,
                    ),
                    children: [
                      _buildHeroCard(context, state),
                      const SizedBox(height: 16.0),
                      _buildModelSection(context, state),
                      const SizedBox(height: 16.0),
                      _buildProviderSection(
                        context,
                        state,
                        model: AiModel.geminiFlash,
                      ),
                      const SizedBox(height: 16.0),
                      _buildProviderSection(
                        context,
                        state,
                        model: AiModel.gpt5Mini,
                      ),
                      const SizedBox(height: 16.0),
                      _buildProviderSection(
                        context,
                        state,
                        model: AiModel.claudeHaiku,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, AiAssistantSettingsState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              state.isAssistantLocked ? Icons.lock_rounded : Icons.key_rounded,
              color: colorScheme.onPrimary,
              size: 26,
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // Show description corresponding to the lock state.
                  state.isAssistantLocked
                      ? StringConstants.settingsUnlockPrompt
                      : StringConstants.settingsKeysSaved,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    height: 1.4,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConstants.settingsDefaultModelTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            StringConstants.settingsDefaultModelDesc,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 14.0),
          DropdownButtonFormField<AiModel>(
            initialValue: state.selectedModel,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            items: AiModel.values
                .map(
                  (model) => DropdownMenuItem<AiModel>(
                    value: model,
                    child: Text(
                      model.label,
                      style: theme.textTheme.bodyMedium,
                    ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasKey = state.keyAvailability[model] ?? false;
    final savedKey = state.savedKeys[model] ?? '';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusChip(context, hasKey),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            StringConstants.settingsSecureStorageDesc,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 14.0),
          // If a key is saved, display the masked key string box and ONLY the Remove button.
          if (hasKey && savedKey.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _maskApiKey(savedKey),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 1.1,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.verified_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14.0),
            OutlinedButton.icon(
              onPressed: state.savingKeyModel == model
                  ? null
                  : () async {
                      if (state.savingKeyModel != null) return;
                      // Remove the key and clear controller.
                      await context
                          .read<AiAssistantSettingsCubit>()
                          .deleteProviderKey(model);
                      _controllers[model]!.clear();
                    },
              icon: state.savingKeyModel == model
                  ? const SizedBox.shrink()
                  : const Icon(
                      Icons.key_off_outlined,
                      size: 18,
                    ),
              label: state.savingKeyModel == model
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      StringConstants.settingsRemoveBtn,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ] else ...[
            // If key is NOT saved, display the text input field and ONLY the Save button.
            TextFormField(
              controller: _controllers[model],
              obscureText: _obscureText[model] ?? true,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                labelText:
                    '${model.label} ${StringConstants.settingsApiKeySuffix}',
                hintText: StringConstants.settingsPasteHint,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    (_obscureText[model] ?? true)
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText[model] = !(_obscureText[model] ?? true);
                    });
                  },
                ),
              ),
              enableSuggestions: false,
              autocorrect: false,
            ),
            const SizedBox(height: 14.0),

            FilledButton.icon(
              onPressed: state.savingKeyModel == model
                  ? null
                  : () async {
                      if (state.savingKeyModel != null) return;

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

                      // Save the key through the cubit.
                      await context
                          .read<AiAssistantSettingsCubit>()
                          .saveProviderKey(model, key);
                    },
              icon: state.savingKeyModel == model
                  ? const SizedBox.shrink()
                  : const Icon(Icons.save_outlined, size: 18),
              label: state.savingKeyModel == model
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      StringConstants.settingsSaveKeyBtn,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, bool hasKey) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
        style: theme.textTheme.labelSmall?.copyWith(
          color: hasKey ? colorScheme.onPrimaryContainer : colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
