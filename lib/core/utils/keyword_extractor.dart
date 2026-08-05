import 'package:injectable/injectable.dart';

/// Pure Dart utility for extracting relevant Flutter/Dart keywords from a user's prompt.
///
/// Avoids sending the entire prompt to the local database for querying. Instead,
/// it tokenizes the prompt, strips punctuation and stop words, and matches against
/// a curated dictionary of framework terms.
@singleton
class KeywordExtractor {
  /// Curated set of critical Flutter/Dart terms to match against.
  /// (This would normally be loaded from an asset or constant file, but kept here for simplicity).
  static const Set<String> _flutterKeywords = {
    'flutter', 'dart', 'widget', 'stateless', 'stateful', 'buildcontext', 'context',
    'state', 'setstate', 'bloc', 'cubit', 'provider', 'riverpod', 'hive', 'isar',
    'sqflite', 'drift', 'dio', 'http', 'navigation', 'router', 'gorouter', 'layout',
    'column', 'row', 'container', 'scaffold', 'appbar', 'listview', 'gridview',
    'future', 'stream', 'async', 'await', 'isolate', 'oop', 'solid', 'clean architecture',
    'repository', 'usecase', 'model', 'dto', 'json', 'serialization', 'animation'
  };

  /// Common stop words to ignore during tokenization.
  static const Set<String> _stopWords = {
    'how', 'what', 'why', 'when', 'where', 'who', 'do', 'i', 'a', 'an', 'the',
    'and', 'or', 'but', 'is', 'are', 'was', 'were', 'in', 'on', 'at', 'to', 'for',
    'with', 'about', 'can', 'you', 'help', 'me', 'build', 'make', 'create', 'use'
  };

  /// Extracts matched keywords from the [prompt].
  List<String> extract(String prompt) {
    if (prompt.trim().isEmpty) return [];

    // Remove basic punctuation and convert to lowercase
    final cleanPrompt = prompt.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase();
    
    // Tokenize by whitespace
    final tokens = cleanPrompt.split(RegExp(r'\s+'));

    // Filter tokens against the curated set, ignoring stop words
    final matchedKeywords = tokens
        .where((token) => !_stopWords.contains(token))
        .where((token) => _flutterKeywords.contains(token))
        .toSet() // Deduplicate
        .toList();

    return matchedKeywords;
  }
}
