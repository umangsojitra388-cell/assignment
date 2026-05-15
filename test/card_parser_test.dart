import 'package:assignment/parsers/card_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CardParser parser;

  setUp(() {
    parser = CardParser();
  });

  group('CardParser', () {
    test('parses a valid card from OCR text', () {
      const rawText = '''
VISA
4111 1111 1111 1111
VALID THRU 12/25
JOHN DOE
''';

      final details = parser.parse(rawText);

      expect(details.cardNumber, '4111111111111111');
      expect(details.expiryDate, '12/25');
      expect(details.cardHolderName, 'JOHN DOE');
    });

    test('returns null card number for invalid OCR text', () {
      const rawText = '''
DEBIT CARD
1234 5678 9012 3456
VALID THRU 01/30
''';

      final details = parser.parse(rawText);

      expect(details.cardNumber, isNull);
      expect(details.expiryDate, isNotNull);
    });
  });
}
