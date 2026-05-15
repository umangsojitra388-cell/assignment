import '../models/bank_details.dart';
import '../utils/name_filter.dart';
import '../utils/text_cleaner.dart';

class PassbookParser {
  static final _ifscPattern = RegExp(
    r'\b([A-Za-z]{4})\s*0\s*([A-Za-z0-9]{6})\b',
  );
  static final _accountKeyword = RegExp(
    r'AC\s*NO|A/C|ACCOUNT',
    caseSensitive: false,
  );
  static final _accountAfterKeyword = RegExp(
    r'(?:AC\s*NO|A/C|ACCOUNT)\s*(?:NO\.?|NUMBER)?\s*[:\-]?\s*([\d\s]{9,24})',
    caseSensitive: false,
  );
  static final _digitRuns = RegExp(r'\d[\d\s]{7,22}\d|\d{9,18}');
  static final _ignoredNameWords = {
    'BANK',
    'BRANCH',
    'IFSC',
    'ACCOUNT',
    'PASSBOOK',
    'CUSTOMER',
    'CODE',
    'MICR',
    'RTGS',
    'NEFT',
  };

  BankDetails parse(String rawText) {
    final lines = TextCleaner.normalize(rawText)
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final fullText = lines.join('\n');
    final ifsc = _extractIfsc(fullText);

    return BankDetails(
      accountHolderName: _extractAccountHolderName(lines),
      accountNumber: _extractAccountNumber(lines, ifsc),
      ifscCode: ifsc,
    );
  }

  String? _extractIfsc(String text) {
    final match = _ifscPattern.firstMatch(text);
    if (match == null) {
      return null;
    }

    final branch = TextCleaner.fixDigitConfusion(match.group(2)!.toUpperCase());
    return '${match.group(1)!.toUpperCase()}0$branch';
  }

  String? _extractAccountNumber(List<String> lines, String? ifsc) {
    final candidates = <_ScoredValue>[];
    final seen = <String>{};

    void addCandidate(String digits, int score) {
      if (seen.contains(digits)) return;
      if (!_isValidAccountNumber(digits, ifsc)) return;
      seen.add(digits);
      candidates.add(_ScoredValue(digits, score));
    }

    for (final line in lines) {
      if (_ifscPattern.hasMatch(line)) continue;

      final hasKeyword = _accountKeyword.hasMatch(line);
      final digitLine = TextCleaner.fixDigitConfusion(line);
      var score = hasKeyword ? 100 : 0;

      for (final match in _accountAfterKeyword.allMatches(digitLine)) {
        addCandidate(_digitsOnly(match.group(1)!), score + 60);
      }

      if (hasKeyword) {
        for (final match in _digitRuns.allMatches(digitLine)) {
          addCandidate(_digitsOnly(match.group(0)!), score + 40);
        }
      }
    }

    for (final line in lines) {
      if (_ifscPattern.hasMatch(line) || _accountKeyword.hasMatch(line)) {
        continue;
      }

      final digitLine = TextCleaner.fixDigitConfusion(line);
      for (final match in _digitRuns.allMatches(digitLine)) {
        addCandidate(_digitsOnly(match.group(0)!), 10);
      }
    }

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates.first.value;
  }

  String? _extractAccountHolderName(List<String> lines) {
    String? bestName;
    var bestScore = -1;

    for (final line in lines) {
      if (RegExp(r'\d').hasMatch(line)) continue;
      if (NameFilter.containsBlockedWord(line, _ignoredNameWords)) continue;
      if (!NameFilter.looksLikePersonName(line)) continue;

      final score = NameFilter.scoreLine(line);
      if (score > bestScore) {
        bestScore = score;
        bestName = line;
      }
    }
    return bestName;
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  bool _isValidAccountNumber(String digits, String? ifsc) {
    if (digits.length < 9 || digits.length > 18) {
      return false;
    }
    if (_isPhoneNumber(digits)) {
      return false;
    }
    if (_isRepeatingDigits(digits)) {
      return false;
    }
    if (ifsc != null && (ifsc.contains(digits) || digits == ifsc.substring(4))) {
      return false;
    }
    return true;
  }

  bool _isRepeatingDigits(String digits) {
    return digits.split('').toSet().length == 1;
  }

  bool _isPhoneNumber(String digits) {
    if (digits.length == 10 && RegExp(r'^[6-9]').hasMatch(digits)) {
      return true;
    }
    if (digits.length == 12 &&
        digits.startsWith('91') &&
        RegExp(r'^91[6-9]').hasMatch(digits)) {
      return true;
    }
    if (digits.length == 11 && digits.startsWith('0')) {
      return true;
    }
    return false;
  }
}

class _ScoredValue {
  const _ScoredValue(this.value, this.score);

  final String value;
  final int score;
}
