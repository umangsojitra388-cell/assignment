import 'dart:io';

import '../models/card_details.dart';
import '../parsers/card_parser.dart';
import 'ocr_service.dart';

/// Runs OCR on a card image and parses [CardDetails].
class CardScanService {
  CardScanService({
    OCRService? ocrService,
    CardParser? cardParser,
  })  : _ocrService = ocrService ?? OCRService(),
        _cardParser = cardParser ?? CardParser();

  final OCRService _ocrService;
  final CardParser _cardParser;

  Future<CardDetails> scan(File image) async {
    final rawText = await _ocrService.extractText(image);
    return _cardParser.parse(rawText);
  }

  bool isValidCard(CardDetails details) => details.cardNumber != null;

  Future<void> dispose() => _ocrService.dispose();
}
