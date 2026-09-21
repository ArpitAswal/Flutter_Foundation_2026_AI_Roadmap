import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_foundation/domain/services/question_scope_policy.dart';

void main() {
  late QuestionScopePolicy policy;

  setUp(() {
    policy = const QuestionScopePolicy();
  });

  group('QuestionScopePolicy Tests', () {
    test('allows standard Flutter & Dart curriculum queries', () {
      expect(
        policy.evaluate('How does setState work in a StatefulWidget?'),
        equals(QuestionScopeResult.allowed),
      );
      expect(
        policy.evaluate('Explain BLoC state management in Flutter'),
        equals(QuestionScopeResult.allowed),
      );
      expect(
        policy.evaluate('What are Dart extension methods?'),
        equals(QuestionScopeResult.allowed),
      );
      expect(
        policy.evaluate('How do I configure Hive local storage in Flutter?'),
        equals(QuestionScopeResult.allowed),
      );
    });

    test('classifies Flutter vs native comparisons as allowedComparison', () {
      expect(
        policy.evaluate('How does Flutter TLS certificate pinning compare to native Android and iOS?'),
        equals(QuestionScopeResult.allowedComparison),
      );
      expect(
        policy.evaluate('Flutter vs React Native performance comparison'),
        equals(QuestionScopeResult.allowedComparison),
      );
      expect(
        policy.evaluate('Difference between Flutter platform channels and Kotlin native code'),
        equals(QuestionScopeResult.allowedComparison),
      );
    });

    test('refuses standalone native tutorials', () {
      expect(
        policy.evaluate('Teach me Kotlin from zero'),
        equals(QuestionScopeResult.refused),
      );
      expect(
        policy.evaluate('Swift tutorial for beginners'),
        equals(QuestionScopeResult.refused),
      );
      expect(
        policy.evaluate('How to code in Swift without Flutter'),
        equals(QuestionScopeResult.refused),
      );
      expect(
        policy.evaluate('Jetpack compose tutorial'),
        equals(QuestionScopeResult.refused),
      );
    });

    test('refuses off-topic non-programming queries', () {
      expect(
        policy.evaluate('Give me a recipe for chocolate pizza'),
        equals(QuestionScopeResult.refused),
      );
      expect(
        policy.evaluate('Who won the presidential election?'),
        equals(QuestionScopeResult.refused),
      );
      expect(
        policy.evaluate('What are the symptoms of common flu and medical advice?'),
        equals(QuestionScopeResult.refused),
      );
      expect(
        policy.evaluate('Tell me a movie summary for Hollywood film'),
        equals(QuestionScopeResult.refused),
      );
    });

    test('refuses unrelated non-mobile technologies', () {
      expect(
        policy.evaluate('How to configure WordPress with PHP and MySQL?'),
        equals(QuestionScopeResult.refused),
      );
      expect(
        policy.evaluate('Build a web backend with Django and Ruby on Rails'),
        equals(QuestionScopeResult.refused),
      );
    });

    test('flags ambiguous or under-specified queries for clarification', () {
      expect(
        policy.evaluate('is it secure?'),
        equals(QuestionScopeResult.clarificationNeeded),
      );
      expect(
        policy.evaluate('how to fix?'),
        equals(QuestionScopeResult.clarificationNeeded),
      );
      expect(
        policy.evaluate(''),
        equals(QuestionScopeResult.clarificationNeeded),
      );
    });
  });
}
