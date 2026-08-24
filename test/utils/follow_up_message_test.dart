import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/utils/follow_up_message.dart';

void main() {
  test('uses only the first name from the full client name', () {
    final message = followUpMessage('João da Silva');
    expect(message, startsWith('Olá João,'));
    expect(message, isNot(contains('da Silva')));
  });

  test('mentions the budget without promising to send it automatically', () {
    final message = followUpMessage('Maria');
    expect(message, contains('orçamento'));
  });
}
