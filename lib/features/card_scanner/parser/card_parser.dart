import '../../../core/helpers/name_filter.dart';
import '../../../core/utils/luhn_validator.dart';
import '../../../core/utils/text_cleaner.dart';
import '../models/card_details.dart';

class CardParser {
  static final _cardGrouped = RegExp(r'(?:\d{4}[\s\-]){3}\d{4}');
  static final _cardContinuous = RegExp(r'\b\d{13,19}\b');
  static final _expirySeparated = RegExp(
    r'\b(0[1-9]|1[0-2])\s*[/\-]\s*(\d{2})\b',
  );
  static final _expiryCompact = RegExp(
    r'(?<![0-9])(0[1-9]|1[0-2])(\d{2})(?![0-9])',
  );
  static final _ignoredWords = {
    'VISA',
    'VALID',
    'CARD',
    'THRU',
    'FROM',
    'DEBIT',
    'CREDIT',
    'MASTERCARD',
    'AMEX',
    'PLATINUM',
    'GOLD',
    'WORLD',
    'MEMBER',
    'SINCE',
    'BANK',
  };

  CardDetails parse(String rawText) {
    final text = TextCleaner.normalize(rawText);
    final digitText = TextCleaner.fixDigitConfusion(text);

    return CardDetails(
      cardNumber: _extractCardNumber(digitText),
      expiryDate: _extractExpiry(digitText, text),
      cardHolderName: _extractCardHolderName(text),
    );
  }

  String? _extractCardNumber(String digitText) {
    final seen = <String>{};
    final candidates = <String>[];

    void addCandidate(String raw) {
      final digits = TextCleaner.digitsOnly(raw);
      if (digits.length < 13 || digits.length > 19 || seen.contains(digits)) {
        return;
      }
      seen.add(digits);
      candidates.add(digits);
    }

    for (final match in _cardGrouped.allMatches(digitText)) {
      addCandidate(match.group(0)!);
    }
    for (final match in _cardContinuous.allMatches(digitText)) {
      addCandidate(match.group(0)!);
    }

    candidates.sort((a, b) {
      final aValid = LuhnValidator.isValid(a);
      final bValid = LuhnValidator.isValid(b);
      if (aValid != bValid) return aValid ? -1 : 1;
      final aSixteen = a.length == 16 ? 1 : 0;
      final bSixteen = b.length == 16 ? 1 : 0;
      return bSixteen.compareTo(aSixteen);
    });

    for (final digits in candidates) {
      if (LuhnValidator.isValid(digits)) {
        return digits;
      }
    }
    return null;
  }

  String? _extractExpiry(String digitText, String plainText) {
    for (final match in _expirySeparated.allMatches(digitText)) {
      final formatted = '${match.group(1)}/${match.group(2)}';
      if (_isPlausibleExpiry(formatted)) {
        return formatted;
      }
    }

    for (final line in plainText.split('\n')) {
      final trimmed = line.trim();
      if (_lineLooksLikeCardNumber(trimmed)) continue;

      final lineDigits = TextCleaner.fixDigitConfusion(trimmed);
      for (final match in _expiryCompact.allMatches(lineDigits)) {
        final formatted = '${match.group(1)}/${match.group(2)}';
        if (_isPlausibleExpiry(formatted)) {
          return formatted;
        }
      }
    }
    return null;
  }

  bool _isPlausibleExpiry(String value) {
    final parts = value.split('/');
    if (parts.length != 2) return false;

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null) return false;

    return month >= 1 && month <= 12 && year >= 20 && year <= 45;
  }

  bool _lineLooksLikeCardNumber(String line) {
    final digits = TextCleaner.digitsOnly(line);
    return digits.length >= 13;
  }

  String? _extractCardHolderName(String text) {
    final lines = text.split('\n');
    String? bestName;
    var bestScore = -1;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (RegExp(r'\d').hasMatch(trimmed)) continue;
      if (NameFilter.containsBlockedWord(trimmed, _ignoredWords)) continue;
      if (!NameFilter.looksLikePersonName(trimmed)) continue;

      final score = NameFilter.scoreLine(trimmed);
      if (score > bestScore) {
        bestScore = score;
        bestName = trimmed;
      }
    }
    return bestName;
  }
}
