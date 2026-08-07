import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../core/di/injection.dart';
import '../bloc/ai_tutor_bloc.dart';
import '../bloc/ai_tutor_event.dart';
import '../bloc/ai_tutor_state.dart';
import '../../../domain/models/ai_model.dart';
import '../../../domain/models/curriculum/lesson_content.dart';
import '../../../domain/models/curriculum/lesson_day.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final bool isLoading;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    this.isLoading = false,
  });
}

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

  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Add initial greeting message
    final contextText = widget.contextLesson?.title ?? 'the curriculum';
    _messages.add(
      _ChatMessage(
        text: 'I see you are learning about **$contextText**! Any questions?',
        isUser: false,
      ),
    );
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
    return BlocProvider(
      create: (context) => getIt<AiTutorBloc>(),
      child: Builder(
        builder: (context) {
          return Container(
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
        if (state is AiTutorLoading) {
          setState(() {
            // Add a temporary loading message for the AI
            _messages.add(
              _ChatMessage(text: '', isUser: false, isLoading: true),
            );
          });
          _scrollToBottom();
        } else if (state is AiTutorResponseStreaming) {
          setState(() {
            // Update the last AI message
            if (_messages.isNotEmpty && !_messages.last.isUser) {
              _messages.last = _ChatMessage(
                text: state.partialResponse,
                isUser: false,
              );
            }
          });
          _scrollToBottom();
        } else if (state is AiTutorResponseComplete) {
          setState(() {
            if (_messages.isNotEmpty && !_messages.last.isUser) {
              _messages.last = _ChatMessage(
                text: state.fullResponse,
                isUser: false,
              );
            }
          });
          _scrollToBottom();
        } else if (state is AiTutorError) {
          setState(() {
            // Remove the loading message if present
            if (_messages.isNotEmpty && _messages.last.isLoading) {
              _messages.removeLast();
            }
            _messages.add(
              _ChatMessage(text: state.message, isUser: false, isError: true),
            );
          });
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            if (message.isUser) {
              return _buildUserMessage(message.text);
            } else {
              return _buildAiMessage(
                message.text,
                isLoading: message.isLoading,
                isError: message.isError,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildUserMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMessage(
    String text, {
    bool isLoading = false,
    bool isError = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isError ? Colors.red.shade100 : const Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isError ? Icons.error_outline : Icons.smart_toy_outlined,
              size: 18,
              color: isError ? Colors.red : Colors.black54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isError ? Colors.red.shade50 : Colors.white,
                border: Border.all(
                  color: isError
                      ? Colors.red.shade200
                      : const Color(0xFFF0F0F0),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : MarkdownBody(
                      data: text,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: 14,
                          color: isError ? Colors.red.shade900 : Colors.black87,
                          height: 1.5,
                        ),
                        code: const TextStyle(
                          backgroundColor: Color(0xFFF5F5F5),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Ask a question...',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
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

    // Instantly add the user message to UI
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();

    context.read<AiTutorBloc>().add(
      AiTutorMessageSent(
        message: text,
        model: _selectedModel,
        currentLesson: widget.contextLesson,
        currentContent: widget.contextContent,
      ),
    );

    _textController.clear();
  }
}
