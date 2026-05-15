import 'package:assignment/validators/luhn_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LuhnValidator', () {
    test('returns true for a valid card number', () {
      expect(LuhnValidator.isValid('4111111111111111'), isTrue);
      expect(LuhnValidator.isValid('4111 1111 1111 1111'), isTrue);
    });

    test('returns false for an invalid card number', () {
      expect(LuhnValidator.isValid('1234567890123456'), isFalse);
      expect(LuhnValidator.isValid(''), isFalse);
      expect(LuhnValidator.isValid('abcd'), isFalse);
    });
  });
}
