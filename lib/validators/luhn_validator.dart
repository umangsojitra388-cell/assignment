/// Validates payment card numbers with the Luhn (mod 10) checksum.
class LuhnValidator {
  LuhnValidator._();

  /// Returns true when [cardNumber] passes the Luhn check.
  ///
  /// Luhn algorithm:
  /// 1. From the rightmost digit, double every second digit.
  /// 2. If doubling gives a two-digit number, add its digits (e.g. 14 → 1+4 = 5).
  /// 3. Sum all digits; the number is valid if the sum is divisible by 10.
  static bool isValid(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\s'), '');
    if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) {
      return false;
    }

    var sum = 0;
    var doubleDigit = false;

    for (var i = digits.length - 1; i >= 0; i--) {
      var digit = digits.codeUnitAt(i) - 48;

      if (doubleDigit) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      doubleDigit = !doubleDigit;
    }

    return sum % 10 == 0;
  }
}
