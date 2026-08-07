import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../core/di/injection.dart';
import '../bloc/ai_tutor_bloc.dart';
import '../bloc/ai_tutor_event.dart';
import '../bloc/ai_tutor_state.dart';
import '../models/chat_message.dart';
import '../../../domain/models/ai_model.dart';
import '../../../domain/models/curriculum/lesson_content.dart';
import '../../../domain/models/curriculum/lesson_day.dart';

class AiTutorBottomSheet extends StatefulWidget {
  final LessonDay? contextLesson;
  final LessonContent? contextContent;

  const AiTutorBottomSheet({
    super.key,
    this.contextLesson,
    this.contextContent,
  });

  @override
  State<AiTutorBottomSheet> createState() => _AiTutorBottomSheetState();
}

class _AiTutorBottomSheetState extends State<AiTutorBottomSheet> {
  AiModel _selectedModel = AiModel.geminiFlash;
  final List<AiModel> _models = AiModel.values;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final contextText = widget.contextLesson?.title ?? 'the curriculum';
    getIt<AiTutorBloc>().add(AiTutorInitialized(contextText: contextText));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AiTutorBloc>(),
      child: Builder(
        builder: (context) {
          return SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  Expanded(child: _buildChatBody(context)),
                  _buildInputArea(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Tutor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
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
                    const Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AiModel>(
                value: _selectedModel,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                isDense: true,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                items: _models.map((AiModel model) {
                  return DropdownMenuItem<AiModel>(
                    value: model,
                    child: Text('Model: ${model.label}'),
                  );
                }).toList(),
                onChanged: (AiModel? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedModel = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBody(BuildContext context) {
    return BlocConsumer<AiTutorBloc, AiTutorState>(
      listener: (context, state) {
        _scrollToBottom();
      },
      builder: (context, state) {
        // Prepare the message list
        final messages = List<ChatMessage>.from(state.messages);

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ).copyWith(bottom: 16.0),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            if (message.isUser) {
              return Align(
                alignment: Alignment.centerRight,
                child: _buildUserMessage(message.text),
              );
            } else if (message.isLoading) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SpinKitThreeBounce(
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.0,
                  ),
                ],
              );
            } else {
              return Align(
                alignment: Alignment.centerLeft,
                child: _buildAiMessage(message.text, isError: message.isError),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildUserMessage(String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsetsGeometry.only(top: 16.0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(4),
              ),
              border: Border.all(color: colorScheme.onPrimary),
            ),
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 10,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMessage(String text, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsetsGeometry.only(top: 16.0),
            padding: const EdgeInsets.all(16),
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
                p: TextStyle(
                  fontSize: 14,
                  color: isError ? colorScheme.error : colorScheme.onSurface,
                  height: 1.5,
                ),
                code: TextStyle(
                  backgroundColor: colorScheme.surface,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isError ? colorScheme.error : colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 18,
                color: isError ? colorScheme.onError : colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: colorScheme.surfaceContainerHighest,
            width: 3,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Ask a question...',
                  hintStyle: TextStyle(
                    color: Colors.black38,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(context),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => _sendMessage(context),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();

    context.read<AiTutorBloc>().add(
      AiTutorMessageSent(
        message: text,
        model: _selectedModel,
        currentLesson: widget.contextLesson,
        currentContent: widget.contextContent,
      ),
    );
  }
}
