import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'code_block_widget.dart';

class CodeElementBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  CodeElementBuilder(this.context);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String language = '';

    // In markdown, fenced code blocks are parsed as <pre><code>...</code></pre>
    if (element.children != null && element.children!.isNotEmpty) {
      final child = element.children!.first;
      if (child is md.Element && child.attributes['class'] != null) {
        String lg = child.attributes['class'] as String;
        if (lg.startsWith('language-')) {
          language = lg.substring(9);
        }
      }
    }

    final textContent = element.textContent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CodeBlockWidget(
        code: textContent.trimRight(),
        fileName: language.isNotEmpty ? language.toUpperCase() : 'CODE',
      ),
    );
  }
}
