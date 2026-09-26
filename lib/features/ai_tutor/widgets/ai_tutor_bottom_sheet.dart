import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/di/injection.dart';
import '../bloc/ai_assistant_settings_cubit.dart';
import '../bloc/ai_assistant_settings_state.dart';
import '../bloc/ai_tutor_bloc.dart';
import '../bloc/ai_tutor_event.dart';
import '../bloc/ai_tutor_state.dart';
import '../../../domain/models/ai_model.dart';
import '../../../domain/models/curriculum/lesson_content.dart';
import '../../../domain/models/curriculum/lesson_day.dart';

class AiTutorBottomSheet extends StatefulWidget {
  final String? contextTitle;
  final LessonDay? contextLesson;
  final LessonContent? contextContent;

  const AiTutorBottomSheet({
    super.key,
    this.contextTitle,
    this.contextLesson,
    this.contextContent,
  });

  @override
  State<AiTutorBottomSheet> createState() => _AiTutorBottomSheetState();
}

class _AiTutorBottomSheetState extends State<AiTutorBottomSheet> {
  late final AiTutorBloc _aiTutorBloc;
  late final AiAssistantSettingsCubit _settingsCubit;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _scrollDebounce;
  bool _isUserNearBottom = true;

  final List<AiModel> _models = AiModel.values;

  @override
  void initState() {
    super.initState();
    _aiTutorBloc = getIt<AiTutorBloc>();
    _settingsCubit = getIt<AiAssistantSettingsCubit>();

    final contextText = widget.contextTitle ?? widget.contextLesson?.title;
    final suggestions = widget.contextLesson != null
        ? [
            StringConstants.aiTutorSuggestionExample,
            StringConstants.aiTutorSuggestionCompare,
            StringConstants.aiTutorSuggestionQuiz,
          ]
        : widget.contextLesson?.tags;
    _aiTutorBloc.add(
      AiTutorInitialized(contextText: contextText, suggestions: suggestions),
    );
    _settingsCubit.loadSettings();

    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    _isUserNearBottom = _scrollController.position.extentAfter < 160;
  }

  void _scheduleScrollToBottom({required bool animated}) {
    if (!_scrollController.hasClients || !_isUserNearBottom) {
      return;
    }

    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 48), () {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      final targetOffset = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(targetOffset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    if (bottomInset > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduleScrollToBottom(animated: true);
      });
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _settingsCubit),
        BlocProvider.value(value: _aiTutorBloc),
      ],
      child: AnimatedPadding(
        padding: EdgeInsets.only(bottom: bottomInset),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: (mediaQuery.size.height * 0.88) - bottomInset,
              maxWidth: 680.0,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            ),
            child:
                BlocBuilder<AiAssistantSettingsCubit, AiAssistantSettingsState>(
                  builder: (context, settingsState) {
                    return (settingsState.isAssistantLocked)
                        ? _buildLockState(context)
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHeader(context, settingsState),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Divider(
                                    height: 1,
                                    color: Color(0xFFEEEEEE),
                                  ),
                                ),
                                Flexible(
                                  child: _buildChatBody(context, settingsState),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: _buildInputArea(
                                    context,
                                    settingsState,
                                  ),
                                ),
                              ],
                            ),
                          );
                  },
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AiAssistantSettingsState settingsState,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primaryContainer],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StringConstants.bottomSheetTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        StringConstants.bottomSheetOnline,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              padding: EdgeInsets.zero,
              tooltip: StringConstants.aiTutorNewChat,
              onPressed: () {
                final contextText =
                    widget.contextTitle ?? widget.contextLesson?.title;
                final suggestions = widget.contextLesson != null
                    ? [
                        StringConstants.aiTutorSuggestionExample,
                        StringConstants.aiTutorSuggestionCompare,
                        StringConstants.aiTutorSuggestionQuiz,
                      ]
                    : widget.contextLesson?.tags;
                _aiTutorBloc.add(
                  AiTutorNewChatRequested(
                    contextText: contextText,
                    suggestions: suggestions,
                  ),
                );
              },
              icon: const Icon(Icons.add_comment_outlined, size: 22),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              tooltip: StringConstants.bottomSheetTooltipSettings,
              onPressed: () {
                context.pushNamed('aiAssistantSettings');
              },
              icon: const Icon(Icons.settings_outlined, size: 22),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildModelDropdown(context, settingsState),
            _buildStateChip(context, settingsState),
          ],
        ),
      ],
    );
  }

  Widget _buildModelDropdown(
    BuildContext context,
    AiAssistantSettingsState settingsState,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AiModel>(
          value: settingsState.selectedModel,
          isDense: true,
          borderRadius: BorderRadius.circular(16),
          iconSize: 20,
          padding: EdgeInsets.zero,
          items: _models
              .map(
                (model) => DropdownMenuItem<AiModel>(
                  value: model,
                  child: Text(
                    model.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: settingsState.isSavingModel
              ? null
              : (newValue) {
                  if (newValue != null) {
                    context.read<AiAssistantSettingsCubit>().selectModel(
                      newValue,
                    );
                  }
                },
        ),
      ),
    );
  }

  Widget _buildStateChip(
    BuildContext context,
    AiAssistantSettingsState settingsState,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chipColor = settingsState.isSelectedModelLocked
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    final chipForeground = settingsState.isSelectedModelLocked
        ? colorScheme.error
        : colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        settingsState.isSelectedModelLocked
            ? StringConstants.bottomSheetKeyMissing
            : StringConstants.bottomSheetReady,
        style: theme.textTheme.labelSmall?.copyWith(
          color: chipForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChatBody(
    BuildContext context,
    AiAssistantSettingsState settingsState,
  ) {
    return BlocConsumer<AiTutorBloc, AiTutorState>(
      // Schedule scrolling down when there's a new loading chunk or complete response.
      listener: (context, state) {
        _scheduleScrollToBottom(
          animated: state is AiTutorLoading || state is AiTutorResponseComplete,
        );
      },
      builder: (context, state) {
        final messages = state.messages;

        return LayoutBuilder(
          builder: (context, constraints) {
            return ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              scrollCacheExtent: const ScrollCacheExtent.pixels(1000.0),
              itemCount: messages.length,
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: constraints.maxWidth * 0.01,
              ),
              itemBuilder: (context, index) {
                final message = messages[index];

                if (message.isUser) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: _buildUserMessage(message.text),
                  );
                }

                if (message.isLoading) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 60,
                        child: SpinKitThreeBounce(
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                }

                return Align(
                  alignment: Alignment.centerLeft,
                  child: _buildAiMessage(
                    message.text,
                    isError: message.isError,
                    suggestions: message.suggestions,
                    settingsState: settingsState,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUserMessage(String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primaryContainer],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMessage(
    String text, {
    bool isError = false,
    List<String>? suggestions,
    AiAssistantSettingsState? settingsState,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isError
                      ? colorScheme.errorContainer
                      : colorScheme.onPrimary,
                  border: Border.all(
                    color: isError
                        ? colorScheme.errorContainer
                        : colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MarkdownBody(
                  data: text,
                  styleSheet: MarkdownStyleSheet(
                    p: theme.textTheme.bodyMedium?.copyWith(
                      color: isError
                          ? colorScheme.error
                          : colorScheme.onSurface,
                      height: 1.5,
                    ),
                    code: TextStyle(
                      fontSize: theme.textTheme.bodyMedium?.fontSize,
                      backgroundColor: colorScheme.surface,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isError ? colorScheme.error : colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    size: 16,
                    color: isError ? colorScheme.onError : colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isError)
          Align(
            alignment: AlignmentGeometry.topRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
              child: GestureDetector(
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: colorScheme.outlineVariant,
                  child: const Icon(Icons.refresh_rounded, size: 16),
                ),
                onTap: () {
                  final model =
                      settingsState?.selectedModel ??
                      context
                          .read<AiAssistantSettingsCubit>()
                          .state
                          .selectedModel;
                  _aiTutorBloc.add(
                    AiTutorRetryRequested(
                      currentLesson: widget.contextLesson,
                      currentContent: widget.contextContent,
                      model: model,
                    ),
                  );
                },
              ),
            ),
          ),
        if (suggestions != null && suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.map((suggestion) {
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () {
                    if (settingsState != null &&
                        !settingsState.isSelectedModelLocked &&
                        !settingsState.isSavingModel) {
                      _sendMessage(context, settingsState, query: suggestion);
                    }
                  },
                  child: Text(suggestion),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildInputArea(
    BuildContext context,
    AiAssistantSettingsState settingsState,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDisabled =
        settingsState.isSelectedModelLocked || settingsState.isSavingModel;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        border: const Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (settingsState.hasAnyConfiguredKey &&
              settingsState.isSelectedModelLocked)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: colorScheme.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${settingsState.selectedModel.label} ${StringConstants.bottomSheetNotConfigured}',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  enabled: !isDisabled,
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  onTap: () {
                    _scheduleScrollToBottom(animated: true);
                  },
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    hintText: settingsState.isSelectedModelLocked
                        ? StringConstants.bottomSheetHintLocked
                        : StringConstants.bottomSheetHintAsk,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black38,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide(
                        color: colorScheme.surfaceContainerHighest,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide(
                        color: colorScheme.surfaceContainerHighest,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BlocBuilder<AiTutorBloc, AiTutorState>(
                builder: (context, tutorState) {
                  final isStreaming = tutorState.isStreaming;

                  return Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isStreaming
                          ? colorScheme.error
                          : (isDisabled
                                ? colorScheme.outlineVariant
                                : colorScheme.primary),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isStreaming ? Icons.stop_rounded : Icons.arrow_upward,
                        color: Colors.white,
                        size: 20,
                      ),
                      tooltip: isStreaming
                          ? StringConstants.aiTutorStop
                          : StringConstants.bottomSheetHintAsk,
                      onPressed: isStreaming
                          ? () => _aiTutorBloc.add(const AiTutorStopRequested())
                          : (isDisabled
                                ? null
                                : () => _sendMessage(context, settingsState)),
                      padding: EdgeInsets.zero,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLockState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_rounded, size: 36, color: colorScheme.error),
          ),
          const SizedBox(height: 16),
          Text(
            StringConstants.bottomSheetLockTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            StringConstants.bottomSheetLockDesc,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _openSettings(context),
            icon: const Icon(Icons.settings_outlined, size: 20),
            label: Text(
              StringConstants.bottomSheetOpenSettings,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(
    BuildContext context,
    AiAssistantSettingsState settingsState, {
    String? query,
  }) {
    final text = query ?? _textController.text.trim();
    // Do not send if text is empty or the selected model is not configured.
    if (text.isEmpty || settingsState.isSelectedModelLocked) {
      return;
    }

    if (query == null) {
      _textController.clear();
    }

    context.read<AiTutorBloc>().add(
      AiTutorMessageSent(
        message: text,
        model: settingsState.selectedModel,
        currentLesson: widget.contextLesson,
        currentContent: widget.contextContent,
      ),
    );
  }

  void _openSettings(BuildContext context) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.pushNamed('aiAssistantSettings');
    });
  }
}
