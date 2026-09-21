import 'package:flutter_foundation/core/di/injection.dart';
import 'package:flutter_foundation/domain/services/conversation_context_builder.dart';
import 'package:flutter_foundation/domain/services/question_scope_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dependency Injection Tests', () {
    setUp(() async {
      await getIt.reset();
    });

    tearDown(() async {
      await getIt.reset();
    });

    test('configureDependencies initializes without type int or missing dependency errors', () async {
      await configureDependencies();

      // Verify that ConversationContextBuilder resolves without requiring int registrations
      final conversationBuilder = getIt<ConversationContextBuilder>();
      expect(conversationBuilder, isNotNull);
      expect(conversationBuilder.maxTurns, equals(6));
      expect(conversationBuilder.maxCharacters, equals(4000));

      // Verify that QuestionScopePolicy resolves
      final scopePolicy = getIt<QuestionScopePolicy>();
      expect(scopePolicy, isNotNull);
    });
  });
}
