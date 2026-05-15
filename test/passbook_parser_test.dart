import 'package:assignment/parsers/passbook_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PassbookParser parser;

  setUp(() {
    parser = PassbookParser();
  });

  group('PassbookParser', () {
    test('parses passbook details from OCR text', () {
      const rawText = '''
STATE BANK
JANE DOE
ACCOUNT NO: 123456789012
IFSC HDFC0001234
''';

      final details = parser.parse(rawText);

      expect(details.accountHolderName, 'JANE DOE');
      expect(details.accountNumber, '123456789012');
      expect(details.ifscCode, 'HDFC0001234');
    });

    test('returns null fields when passbook details are missing', () {
      const rawText = '''
BANK BRANCH
CUSTOMER CARE
9876543210
''';

      final details = parser.parse(rawText);

      expect(details.accountNumber, isNull);
      expect(details.ifscCode, isNull);
      expect(details.accountHolderName, isNull);
    });
  });
}
