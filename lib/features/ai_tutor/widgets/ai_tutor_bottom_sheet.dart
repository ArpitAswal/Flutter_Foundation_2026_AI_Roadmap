import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';
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
        child: Container(
          constraints: BoxConstraints(
            maxHeight: (mediaQuery.size.height * 0.88) - bottomInset,
            maxWidth: mediaQuery.size.width,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.isTablet ? 40 : 24),
            ),
          ),
          child:
              BlocBuilder<AiAssistantSettingsCubit, AiAssistantSettingsState>(
                builder: (context, settingsState) {
                  return (settingsState.isAssistantLocked)
                      ? _buildLockState(context)
                      : Padding(
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: context.isTablet ? 24 : 16,
                            vertical: context.isTablet ? 18 : 12,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeader(context, settingsState),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: const Divider(
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
                                child: _buildInputArea(context, settingsState),
                              ),
                            ],
                          ),
                        );
                },
              ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AiAssistantSettingsState settingsState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: context.isTablet
                  ? 80
                  : (context.isSmallPhone)
                  ? 30
                  : 40,
              height: context.isTablet
                  ? 80
                  : (context.isSmallPhone)
                  ? 30
                  : 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primaryContainer],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: context.isTablet
                    ? 50
                    : context.isSmallPhone
                    ? 20
                    : 25,
              ),
            ),
            SizedBox(width: context.screenWidth * 0.02),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StringConstants.bottomSheetTitle,
                    style: context.responsiveTextTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: context.isTablet ? 16 : 8,
                        height: context.isTablet ? 16 : 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        StringConstants.bottomSheetOnline,
                        style: context.responsiveTextTheme.labelMedium
                            ?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: context.screenWidth * 0.02),
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
              icon: Icon(
                Icons.add_comment_outlined,
                size: context.isTablet
                    ? 40
                    : context.isSmallPhone
                    ? 16
                    : 22,
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              tooltip: StringConstants.bottomSheetTooltipSettings,
              onPressed: () {
                context.pushNamed('aiAssistantSettings');
              },
              icon: Icon(
                Icons.settings_outlined,
                size: context.isTablet
                    ? 40
                    : context.isSmallPhone
                    ? 16
                    : 22,
              ),
            ),
          ],
        ),
        SizedBox(height: (context.isTablet) ? 20.0 : 8.0),
        Wrap(
          spacing: 12,
          runSpacing: 12,
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
    return Container(
      padding: context.responsivePadding(14, 8).padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AiModel>(
          value: settingsState.selectedModel,
          isDense: true,
          borderRadius: BorderRadius.circular(16),
          iconSize: context.isTablet ? 40 : 21,
          padding: EdgeInsets.zero,
          items: _models
              .map(
                (model) => DropdownMenuItem<AiModel>(
                  value: model,
                  child: Text(
                    model.label,
                    style: context.responsiveTextTheme.labelLarge,
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
    final colorScheme = Theme.of(context).colorScheme;
    final chipColor = settingsState.isSelectedModelLocked
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    final chipForeground = settingsState.isSelectedModelLocked
        ? colorScheme.error
        : colorScheme.onPrimaryContainer;

    return Container(
      padding: context.responsivePadding(12, 8).padding,
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        settingsState.isSelectedModelLocked
            ? StringConstants.bottomSheetKeyMissing
            : StringConstants.bottomSheetReady,
        style: context.responsiveTextTheme.labelSmall?.copyWith(
          color: chipForeground,
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

        return ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          scrollCacheExtent: const ScrollCacheExtent.pixels(1000.0),
          itemCount: messages.length,
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
  }

  Widget _buildUserMessage(String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: context.responsivePadding(14, 8).padding,
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
              style: context.responsiveTextTheme.bodyMedium?.copyWith(
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
              width: context.isTablet ? 38 : 26,
              height: context.isTablet ? 38 : 26,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                size: context.isTablet ? 24 : 16,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: context.responsivePadding(14, 8).padding,
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
                    p: context.responsiveTextTheme.bodyMedium?.copyWith(
                      color: isError
                          ? colorScheme.error
                          : colorScheme.onSurface,
                      height: 1.5,
                    ),
                    code: TextStyle(
                      fontSize:
                          context.responsiveTextTheme.bodyMedium?.fontSize,
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
                  width: context.isTablet ? 38 : 26,
                  height: context.isTablet ? 38 : 26,
                  decoration: BoxDecoration(
                    color: isError ? colorScheme.error : colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    size: context.isTablet ? 24 : 16,
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
                  radius: context.isTablet
                      ? 16
                      : context.isSmallPhone
                      ? 10
                      : 12,
                  backgroundColor: colorScheme.outlineVariant,
                  child: Icon(
                    Icons.refresh_rounded,
                    size: context.responsiveTextTheme.bodySmall?.fontSize,
                  ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDisabled =
        settingsState.isSelectedModelLocked || settingsState.isSavingModel;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        border: const Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: EdgeInsetsGeometry.only(
        top: context.responsiveHeightSpace(0.015),
      ),
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
                  style: context.responsiveTextTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                    hintText: settingsState.isSelectedModelLocked
                        ? StringConstants.bottomSheetHintLocked
                        : StringConstants.bottomSheetHintAsk,
                    hintStyle: context.responsiveTextTheme.titleSmall?.copyWith(
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
                  // onSubmitted: (_) => _sendMessage(context, settingsState),
                ),
              ),
              SizedBox(width: 4),
              BlocBuilder<AiTutorBloc, AiTutorState>(
                builder: (context, tutorState) {
                  final isStreaming = tutorState.isStreaming;

                  return Container(
                    height: context.isTablet ? 54 : 32,
                    width: context.isTablet ? 54 : 32,
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
                        size: context.isTablet ? 38 : 20,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: context.responsivePadding(20, 30).padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.isTablet
                ? 120
                : (context.isSmallPhone)
                ? 44
                : 64,
            height: context.isTablet
                ? 120
                : (context.isSmallPhone)
                ? 44
                : 64,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              size: context.isTablet
                  ? 90
                  : context.isSmallPhone
                  ? 28
                  : 44,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            StringConstants.bottomSheetLockTitle,
            textAlign: TextAlign.center,
            style: context.responsiveTextTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            StringConstants.bottomSheetLockDesc,
            textAlign: TextAlign.center,
            style: context.responsiveTextTheme.bodyMedium,
          ),
          SizedBox(height: context.responsiveHeightSpace(0.02)),
          FilledButton.icon(
            onPressed: () => _openSettings(context),
            icon: Icon(
              Icons.settings_outlined,
              size: context.isTablet
                  ? 36
                  : context.isSmallPhone
                  ? 16
                  : 20,
            ),
            label: Text(
              StringConstants.bottomSheetOpenSettings,
              style: context.responsiveTextTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
              foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
              padding: WidgetStatePropertyAll(
                context.responsivePadding(16, 8).padding,
              ),
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
