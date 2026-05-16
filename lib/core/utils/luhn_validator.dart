class LuhnValidator {
  LuhnValidator._();

  static bool isValid(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) {
      return false;
    }
    if (!RegExp(r'^\d+$').hasMatch(digits)) {
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
