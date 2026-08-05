import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  const CodeBlockWidget({
    super.key,
    required this.code,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: fileName != null
          ? 'Code block: ${fileName!}'
          : 'Code block',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(context),
            _buildCodeContent(),
          ],
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
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              code,
              style: const TextStyle(
                color: Color(0xFFCDD6F4),
                fontSize: 13,
                height: 1.7,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        // AI Tutor sparkle button — placeholder for future integration
        Positioned(
          bottom: 10,
          right: 12,
          child: _AiSparkleButton(),
        ),
      ],
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

/// AI Tutor shortcut button — placeholder for future deep integration.
class _AiSparkleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI Tutor integration coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
