import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text(StringConstants.settingsTitle),
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: colorScheme.onSurface,
              size: context.screenWidth * (context.isTablet ? 0.03 : 0.06),
            ),
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
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: ListView(
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
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, AiAssistantSettingsState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(
          context.screenWidth * (context.isTablet ? 0.02 : 0.04),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: size.width * (context.isTablet ? 0.08 : 0.15),
            height: size.width * (context.isTablet ? 0.08 : 0.15),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(
                context.screenWidth * (context.isTablet ? 0.01 : 0.02),
              ),
            ),
            child: Icon(
              state.isAssistantLocked ? Icons.lock_rounded : Icons.key_rounded,
              color: colorScheme.onPrimary,
              size: context.screenWidth * (context.isTablet ? 0.06 : 0.1),
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
                const SizedBox(height: 4),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasKey = state.keyAvailability[model] ?? false;
    final savedKey = state.savedKeys[model] ?? '';

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
                child: Text(model.label, style: theme.textTheme.titleMedium),
              ),
              _buildStatusChip(context, hasKey),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            StringConstants.settingsSecureStorageDesc,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // If a key is saved, display the masked key string box and ONLY the Remove button.
          if (hasKey && savedKey.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    size:
                        context.screenHeight * (context.isTablet ? 0.04 : 0.02),
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
                    size:
                        context.screenHeight * (context.isTablet ? 0.04 : 0.02),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                  : const Icon(Icons.key_off_outlined, size: 18),
              label: state.savingKeyModel == model
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(StringConstants.settingsRemoveBtn),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  colorScheme.onSecondary,
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                ),
                foregroundColor: WidgetStatePropertyAll(colorScheme.primary),
              ),
            ),
          ] else ...[
            // If key is NOT saved, display the text input field and ONLY the Save button.
            TextFormField(
              controller: _controllers[model],
              obscureText: _obscureText[model] ?? true,
              decoration: InputDecoration(
                labelText:
                    '${model.label} ${StringConstants.settingsApiKeySuffix}',
                hintText: StringConstants.settingsPasteHint,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
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
              ),
              enableSuggestions: false,
              autocorrect: false,
            ),
            const SizedBox(height: 16),
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
                  : const Text(StringConstants.settingsSaveKeyBtn),
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(
                    horizontal: (context.isTablet) ? 24 : 16,
                    vertical: (context.isTablet) ? 12 : 8,
                  ),
                ),
              ),
            ),
          ],
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
}
