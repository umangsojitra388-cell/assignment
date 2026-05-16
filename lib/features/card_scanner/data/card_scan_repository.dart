import 'package:card_scanner/card_scanner.dart' as plugin;

import '../../../core/utils/luhn_validator.dart';
import '../../../core/utils/text_cleaner.dart';
import '../models/card_details.dart';
import '../parser/card_parser.dart';

class CardScanCancelledException implements Exception {
  @override
  String toString() => 'CardScanCancelledException';
}

class CardScanRepository {
  CardScanRepository({CardParser? parser}) : _parser = parser ?? CardParser();

  final CardParser _parser;

  Future<CardDetails> scanDebitOrCreditCard() async {
    final plugin.CardDetails? native = await plugin.CardScanner.scanCard(
      scanOptions: plugin.CardScanOptions(
        scanCardHolderName: true,
      ),
    );

    if (native == null) {
      throw CardScanCancelledException();
    }

    final mergedOcrLike = <String>[
      if (native.cardNumber.isNotEmpty) native.cardNumber,
      if (native.expiryDate.isNotEmpty) native.expiryDate,
      if (native.cardHolderName.isNotEmpty) native.cardHolderName,
    ].join('\n');

    final parsed = _parser.parse(mergedOcrLike);

    final cleanedNumber = _cleanCardNumberCandidates(
      pluginNumber: native.cardNumber,
      parsedNumber: parsed.cardNumber,
    );

    final expiry = parsed.expiryDate ??
        _normalizeExpiryFromPlugin(native.expiryDate);

    final holder = (parsed.cardHolderName?.isNotEmpty ?? false)
        ? parsed.cardHolderName
        : (native.cardHolderName.trim().isEmpty
            ? null
            : native.cardHolderName.trim());

    return CardDetails(
      cardNumber: cleanedNumber,
      expiryDate: expiry,
      cardHolderName: holder,
    );
  }

  String? _cleanCardNumberCandidates({
    required String pluginNumber,
    required String? parsedNumber,
  }) {
    final fromParsed = parsedNumber != null
        ? TextCleaner.digitsOnly(TextCleaner.fixDigitConfusion(parsedNumber))
        : null;
    if (fromParsed != null &&
        fromParsed.length >= 13 &&
        LuhnValidator.isValid(fromParsed)) {
      return fromParsed;
    }

    final fromPlugin = TextCleaner.digitsOnly(
      TextCleaner.fixDigitConfusion(pluginNumber),
    );
    if (fromPlugin.length >= 13 && LuhnValidator.isValid(fromPlugin)) {
      return fromPlugin;
    }

    if (fromParsed != null &&
        fromParsed.length >= 13 &&
        fromParsed.length <= 19) {
      return fromParsed;
    }

    return null;
  }

  String? _normalizeExpiryFromPlugin(String raw) {
    if (raw.trim().isEmpty) return null;
    final synthetic = TextCleaner.fixDigitConfusion(raw.trim());
    return _parser.parse(synthetic).expiryDate;
  }
}
