class TextCleaner {
  TextCleaner._();

  static String normalize(String text) {
    var result = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    result = result.replaceAll(RegExp(r'[ \t]+'), ' ');
    result = result.replaceAll(RegExp(r'\n[ \t]+'), '\n');
    result = result.replaceAll(RegExp(r'[ \t]+\n'), '\n');
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return result.trim();
  }

  static String fixDigitConfusion(String value) {
    return value
        .replaceAll('O', '0')
        .replaceAll('o', '0')
        .replaceAll('I', '1')
        .replaceAll('i', '1')
        .replaceAll('l', '1')
        .replaceAll('S', '5')
        .replaceAll('s', '5');
  }

  static String digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }
}
