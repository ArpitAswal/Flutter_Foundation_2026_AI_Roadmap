import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';

/// A styled code block widget for displaying Dart/Flutter code snippets.
///
/// Features:
/// - Dark navy background (#1E1E2E — standard dark IDE theme)
/// - Filename label in the top-left
/// - Copy-to-clipboard icon button in the top-right
/// - Monospace font with soft white text
/// - AI sparkle button placeholder (bottom-right) for future AI Tutor integration
///
/// Usage:
/// ```dart
/// CodeBlockWidget(
///   code: 'void main() { runApp(const MyApp()); }',
///   fileName: 'main.dart',
/// )
/// ```
class CodeBlockWidget extends StatelessWidget {
  final String code;
  final String? fileName;

  const CodeBlockWidget({super.key, required this.code, this.fileName});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: fileName != null ? 'Code block: ${fileName!}' : 'Code block',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_buildTopBar(context), _buildCodeContent()],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A3E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Filename label
          Text(
            fileName?.toUpperCase() ?? 'DART',
            style: const TextStyle(
              color: Color(0xFF8B8B9E),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              fontFamily: 'monospace',
            ),
          ),
          // Copy button
          _CopyButton(code: code),
        ],
      ),
    );
  }

  Widget _buildCodeContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: HighlightView(
          code,
          language: 'dart',
          theme: atomOneDarkTheme,
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(
            fontSize: 13,
            height: 1.7,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

/// Copy-to-clipboard button with visual feedback.
class _CopyButton extends StatefulWidget {
  final String code;

  const _CopyButton({required this.code});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _copy,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _copied
            ? const Icon(
                Icons.check,
                key: ValueKey('check'),
                color: Color(0xFFA6E3A1),
                size: 18,
              )
            : const Icon(
                Icons.copy_rounded,
                key: ValueKey('copy'),
                color: Color(0xFF8B8B9E),
                size: 18,
              ),
      ),
    );
  }
}
