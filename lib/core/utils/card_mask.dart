import 'text_cleaner.dart';

String maskCardNumber(String digits) {
  final clean = TextCleaner.digitsOnly(digits);
  if (clean.length <= 4) {
    return clean;
  }
  final last4 = clean.substring(clean.length - 4);
  final prefixLen = clean.length - 4;
  final groupCount = (prefixLen + 3) ~/ 4;
  final groups = List<String>.filled(groupCount, 'XXXX');
  return '${groups.join(' ')} $last4';
}
