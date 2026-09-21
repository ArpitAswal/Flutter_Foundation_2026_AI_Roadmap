import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_foundation/domain/models/ai_chat_turn.dart';
import 'package:flutter_foundation/domain/services/conversation_context_builder.dart';

void main() {
  group('ConversationContextBuilder Tests', () {
    const builder = ConversationContextBuilder(maxTurns: 4, maxCharacters: 100);

    test('includes recent turns and appends active question', () {
      final history = [
        ChatTurn(
          id: '1',
          role: ChatRole.user,
          text: 'Hello',
          timestamp: DateTime.now(),
        ),
        ChatTurn(
          id: '2',
          role: ChatRole.assistant,
          text: 'Hi there! How can I help with Flutter?',
          timestamp: DateTime.now(),
        ),
      ];

      final window = builder.buildWindow(
        history: history,
        activeQuestion: 'Show an example',
      );

      expect(window.length, equals(3));
      expect(window.last.text, equals('Show an example'));
      expect(window.last.role, equals(ChatRole.user));
    });

    test('filters out errors, empty turns, and system roles', () {
      final history = [
        ChatTurn(
          id: '1',
          role: ChatRole.system,
          text: 'System diagnostic',
          timestamp: DateTime.now(),
        ),
        ChatTurn(
          id: '2',
          role: ChatRole.user,
          text: 'Valid question',
          timestamp: DateTime.now(),
        ),
        ChatTurn(
          id: '3',
          role: ChatRole.assistant,
          text: 'An error occurred',
          isError: true,
          timestamp: DateTime.now(),
        ),
        ChatTurn(
          id: '4',
          role: ChatRole.assistant,
          text: '   ',
          timestamp: DateTime.now(),
        ),
      ];

      final window = builder.buildWindow(
        history: history,
        activeQuestion: 'Follow up',
      );

      expect(window.length, equals(2));
      expect(window.first.text, equals('Valid question'));
      expect(window.last.text, equals('Follow up'));
    });

    test('enforces maxTurns limit by keeping newest turns', () {
      final history = List.generate(
        10,
        (i) => ChatTurn(
          id: '$i',
          role: i.isEven ? ChatRole.user : ChatRole.assistant,
          text: 'Turn $i',
          timestamp: DateTime.now(),
        ),
      );

      // maxTurns is 4, plus active question = 5 total max
      final window = builder.buildWindow(
        history: history,
        activeQuestion: 'Active',
      );

      expect(window.length, equals(5));
      expect(window.first.text, equals('Turn 6'));
      expect(window.last.text, equals('Active'));
    });

    test('trims oldest turns when character budget is exceeded', () {
      const smallBudgetBuilder = ConversationContextBuilder(
        maxTurns: 4,
        maxCharacters: 30,
      );

      final history = [
        ChatTurn(
          id: '1',
          role: ChatRole.user,
          text: 'This is a long message that takes up characters',
          timestamp: DateTime.now(),
        ),
        ChatTurn(
          id: '2',
          role: ChatRole.assistant,
          text: 'Short reply',
          timestamp: DateTime.now(),
        ),
      ];

      final window = smallBudgetBuilder.buildWindow(
        history: history,
        activeQuestion: 'Another query',
      );

      // The first long message should be pruned to respect budget
      expect(window.length, equals(2));
      expect(window.first.text, equals('Short reply'));
      expect(window.last.text, equals('Another query'));
    });
  });
}
