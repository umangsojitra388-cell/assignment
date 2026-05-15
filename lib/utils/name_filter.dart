/// Shared heuristics for person-name lines in OCR output.
class NameFilter {
  NameFilter._();

  static bool looksLikePersonName(String line) {
    final trimmed = line.trim();
    if (trimmed.length < 3 || trimmed.length > 40) {
      return false;
    }
    if (!RegExp(r"^[A-Za-z][A-Za-z\s.\-']*$").hasMatch(trimmed)) {
      return false;
    }

    final words =
        trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length < 2 || words.length > 5) {
      return false;
    }
    if (words.where((w) => w.length == 1).length > 1) {
      return false;
    }

    return _letterRatio(trimmed) >= 0.85;
  }

  static bool containsBlockedWord(String line, Set<String> blockedWords) {
    final upper = line.toUpperCase();
    for (final word in blockedWords) {
      if (RegExp(r'\b' + RegExp.escape(word) + r'\b').hasMatch(upper)) {
        return true;
      }
    }
    return false;
  }

  static int scoreLine(String line) {
    var uppercaseLetters = 0;
    var letters = 0;

    for (final char in line.runes) {
      final value = String.fromCharCode(char);
      if (RegExp(r'[A-Za-z]').hasMatch(value)) {
        letters++;
        if (value == value.toUpperCase() && value != value.toLowerCase()) {
          uppercaseLetters++;
        }
      }
    }

    if (letters == 0) return 0;

    final uppercaseRatio = uppercaseLetters / letters;
    final allUppercaseBonus = line == line.toUpperCase() ? 100 : 0;
    return allUppercaseBonus + (uppercaseRatio * 50).round();
  }

  static double _letterRatio(String value) {
    var letters = 0;
    for (final char in value.runes) {
      if (RegExp(r'[A-Za-z]').hasMatch(String.fromCharCode(char))) {
        letters++;
      }
    }
    return letters / value.replaceAll(RegExp(r'\s'), '').length;
  }
}
