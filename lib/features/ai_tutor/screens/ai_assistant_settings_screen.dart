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
          title: Text(
            StringConstants.settingsTitle,
            style: context.responsiveTextTheme.headlineMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          surfaceTintColor: Colors.transparent,
          leadingWidth: context.isTablet ? 120.0 : 60.0,
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
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        (context.isTablet &&
                            context.orientation == Orientation.landscape)
                        ? context.screenWidth * 0.75
                        : double.infinity,
                  ),
                  child: ListView(
                    padding: context.responsivePadding(16, 25).padding,
                    children: [
                      _buildHeroCard(context, state),
                      SizedBox(height: context.responsiveHeightSpace(0.02)),
                      _buildModelSection(context, state),
                      SizedBox(height: context.responsiveHeightSpace(0.02)),
                      _buildProviderSection(
                        context,
                        state,
                        model: AiModel.geminiFlash,
                      ),
                      SizedBox(height: context.responsiveHeightSpace(0.02)),

                      _buildProviderSection(
                        context,
                        state,
                        model: AiModel.gpt5Mini,
                      ),
                      SizedBox(height: context.responsiveHeightSpace(0.02)),

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

    return Container(
      padding: context.responsivePadding(12, 12).padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
        borderRadius: context.responsiveCircularRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: context.isTablet ? 120 : 50,
            height: context.isTablet ? 120 : 50,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.16),
              borderRadius: BorderRadiusGeometry.circular(
                context.isTablet ? 18 : 8,
              ),
            ),
            child: Icon(
              state.isAssistantLocked ? Icons.lock_rounded : Icons.key_rounded,
              color: colorScheme.onPrimary,
              size: context.isTablet ? 80 : 30,
            ),
          ),
          SizedBox(width: context.screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Show locked state text if no keys are available.
                  state.isAssistantLocked
                      ? StringConstants.settingsAssistantLocked
                      : StringConstants.settingsAssistantReady,
                  style: context.responsiveTextTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                Text(
                  // Show description corresponding to the lock state.
                  state.isAssistantLocked
                      ? StringConstants.settingsUnlockPrompt
                      : StringConstants.settingsKeysSaved,
                  style: context.responsiveTextTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.7),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: context.responsivePadding(20, 14).padding,
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
            style: context.responsiveTextTheme.titleMedium,
          ),
          SizedBox(height: context.responsiveHeightSpace(0.008)),
          Text(
            StringConstants.settingsDefaultModelDesc,
            style: context.responsiveTextTheme.bodySmall,
          ),
          SizedBox(height: context.responsiveHeightSpace(0.015)),
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
      padding: context.responsivePadding(20, 14).padding,
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
                  style: context.responsiveTextTheme.titleMedium,
                ),
              ),
              _buildStatusChip(context, hasKey),
            ],
          ),
          SizedBox(height: context.responsiveHeightSpace(0.008)),
          Text(
            StringConstants.settingsSecureStorageDesc,
            style: context.responsiveTextTheme.bodySmall,
          ),
          SizedBox(height: context.responsiveHeightSpace(0.015)),
          // If a key is saved, display the masked key string box and ONLY the Remove button.
          if (hasKey && savedKey.isNotEmpty) ...[
            Container(
              padding: context.responsivePadding(14, 12).padding,
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
                      style: context.responsiveTextTheme.bodyMedium?.copyWith(
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
            SizedBox(height: context.responsiveHeightSpace(0.02)),
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
                  : Icon(
                      Icons.key_off_outlined,
                      size: context.isTablet ? 32 : 16,
                    ),
              label: state.savingKeyModel == model
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      StringConstants.settingsRemoveBtn,
                      style: context.responsiveTextTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  colorScheme.onSecondary,
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(context.isTablet ? 36 : 24),
                    ),
                    side: BorderSide(color: colorScheme.primary),
                  ),
                ),
                foregroundColor: WidgetStatePropertyAll(colorScheme.primary),
                padding: WidgetStatePropertyAll(
                  context.responsivePadding(14, 6).padding,
                ),
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
                contentPadding: context.responsivePadding(14, 12).padding,
                suffixIcon: IconButton(
                  icon: Icon(
                    (_obscureText[model] ?? true)
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: context.isTablet ? 32 : 16,
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
            SizedBox(height: context.responsiveHeightSpace(0.02)),

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
                  : Icon(Icons.save_outlined, size: context.isTablet ? 32 : 16),
              label: state.savingKeyModel == model
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      StringConstants.settingsSaveKeyBtn,
                      style: context.responsiveTextTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(
                  context.responsivePadding(14, 6).padding,
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
      padding: context.responsivePadding(14, 6).padding,
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
        style: context.responsiveTextTheme.labelSmall?.copyWith(
          color: hasKey ? colorScheme.onPrimaryContainer : colorScheme.error,
        ),
      ),
    );
  }
}
