import 'package:injectable/injectable.dart';

/// The scope evaluation outcome for a learner's prompt.
enum QuestionScopeResult {
  /// Allowed Flutter, Dart, or mobile engineering question.
  allowed,

  /// Allowed cross-platform comparison (Flutter vs Android/iOS/React Native).
  /// Must be answered from a Flutter-centred perspective.
  allowedComparison,

  /// The question is too vague or ambiguous to answer accurately without clarification.
  clarificationNeeded,

  /// Out of scope: off-topic general chat or standalone native tutorial requests.
  refused,
}

/// Pure Dart domain service responsible for classifying learner questions
/// before calling any external AI provider.
@singleton
class QuestionScopePolicy {
  const QuestionScopePolicy();

  /// Evaluates the [rawQuery] and determines whether it is in scope,
  /// a comparison, requires clarification, or should be refused.
  QuestionScopeResult evaluate(String rawQuery) {
    final query = rawQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return QuestionScopeResult.clarificationNeeded;
    }

    // 1. Check for standalone native learning requests (Refused)
    if (_isStandaloneNativeRequest(query)) {
      return QuestionScopeResult.refused;
    }

    // 2. Check for off-topic non-programming domains (Refused)
    if (_isClearlyOffTopic(query)) {
      return QuestionScopeResult.refused;
    }

    // 3. Check for unrelated non-mobile tech domains (Refused)
    if (_isUnrelatedTech(query)) {
      return QuestionScopeResult.refused;
    }

    // 4. Check for comparison questions between Flutter and other frameworks/native (Allowed Comparison)
    if (_isComparisonRequest(query)) {
      return QuestionScopeResult.allowedComparison;
    }

    // 5. Check for ambiguous / under-specified short prompts (Clarification Needed)
    if (_isAmbiguousQuery(query)) {
      return QuestionScopeResult.clarificationNeeded;
    }

    // Default to allowed for legitimate software engineering / Flutter curriculum queries
    return QuestionScopeResult.allowed;
  }

  bool _isStandaloneNativeRequest(String query) {
    // Ignore exclusion phrases when checking if the query is actually about Flutter
    final strippedOfExclusions = query
        .replaceAll('without flutter', '')
        .replaceAll('not flutter', '')
        .replaceAll('instead of flutter', '')
        .replaceAll('without dart', '');

    final hasFlutterOrDart =
        strippedOfExclusions.contains('flutter') || strippedOfExclusions.contains('dart');
    if (hasFlutterOrDart) {
      return false;
    }

    final nativeKeywords = [
      'kotlin', 'swift', 'swiftui', 'jetpack compose', 'compose', 'objective-c',
    ];

    final learningActionPhrases = [
      'teach me', 'learn', 'guide me', 'tutorial', 'course', 'roadmap',
      'basics', 'for beginners', 'from scratch', 'from zero',
      'how to code in', 'how to program in', 'how to develop in',
      'how to build in', 'without flutter',
    ];

    final hasNativeKeyword = nativeKeywords.any((k) => query.contains(k));
    final hasLearningAction = learningActionPhrases.any((phrase) => query.contains(phrase));

    return hasNativeKeyword && hasLearningAction;
  }

  bool _isClearlyOffTopic(String query) {
    final offTopicKeywords = [
      'recipe', 'cook', 'bake', 'pizza', 'pasta', 'dinner',
      'president', 'election', 'politics', 'senate', 'parliament',
      'movie', 'actor', 'hollywood', 'netflix', 'song', 'lyrics',
      'horoscope', 'zodiac', 'astrology',
      'medical advice', 'symptom', 'doctor', 'medicine', 'prescription',
      'crypto trading', 'stock pick', 'forex signal',
    ];

    for (final keyword in offTopicKeywords) {
      final regex = RegExp('\\b${RegExp.escape(keyword)}\\b');
      if (regex.hasMatch(query)) {
        // Exception if query also specifically discusses programming
        if (!query.contains('flutter') && !query.contains('dart') && !query.contains('app')) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isUnrelatedTech(String query) {
    final unrelatedTechKeywords = [
      'django', 'ruby on rails', 'laravel', 'wordpress', 'php',
      'angularjs', 'vuejs', 'vue 3', 'svelte',
      'unity 3d', 'unreal engine', 'godot',
      'solidity', 'smart contract', 'web3',
    ];

    final hasFlutterOrDart = query.contains('flutter') || query.contains('dart');
    if (hasFlutterOrDart) {
      return false;
    }

    for (final tech in unrelatedTechKeywords) {
      final regex = RegExp('\\b${RegExp.escape(tech)}\\b');
      if (regex.hasMatch(query)) {
        return true;
      }
    }

    return false;
  }

  bool _isComparisonRequest(String query) {
    final comparisonMarkers = [
      ' vs ', ' versus ', 'compare', 'comparison', 'difference between',
      'better than', 'advantages of', 'pros and cons', 'how does flutter compare',
      'in native', 'native alternative',
    ];

    final targetPlatforms = [
      'android', 'ios', 'native', 'kotlin', 'swift', 'react native', 'compose', 'swiftui',
    ];

    final hasComparison = comparisonMarkers.any((marker) => query.contains(marker));
    final hasTarget = targetPlatforms.any((platform) => query.contains(platform));

    return hasComparison && hasTarget;
  }

  bool _isAmbiguousQuery(String query) {
    final trimmed = query.trim();

    // Very short ambiguous expressions without clear context
    final ambiguousPhrases = [
      'is it secure?',
      'is it safe?',
      'how to fix?',
      'why?',
      'what is best?',
      'help me',
      'error',
      'explain',
      'which one?',
      'how?',
    ];

    if (ambiguousPhrases.contains(trimmed)) {
      return true;
    }

    if (trimmed.length < 12 && !trimmed.contains(' ') && !trimmed.contains('flutter') && !trimmed.contains('dart')) {
      return true;
    }

    return false;
  }
}
