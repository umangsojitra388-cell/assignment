/// Masks a card number, revealing only the last four digits.
///
/// Example: `maskCardNumber('4111111111111234')` → `XXXX XXXX XXXX 1234`
String maskCardNumber(String cardNumber) {
  const fallback = 'XXXX XXXX XXXX XXXX';

  final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty || digits.length < 4) {
    return fallback;
  }

  final lastFour = digits.substring(digits.length - 4);
  final groupCount = (digits.length + 3) ~/ 4;
  final maskedGroups = List<String>.generate(groupCount - 1, (_) => 'XXXX')
    ..add(lastFour);

  return maskedGroups.join(' ');
}
