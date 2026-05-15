import 'dart:io';

import '../models/bank_details.dart';
import '../parsers/passbook_parser.dart';
import 'ocr_service.dart';

/// Runs OCR on a passbook image and parses [BankDetails].
class PassbookScanService {
  PassbookScanService({
    OCRService? ocrService,
    PassbookParser? passbookParser,
  })  : _ocrService = ocrService ?? OCRService(),
        _passbookParser = passbookParser ?? PassbookParser();

  final OCRService _ocrService;
  final PassbookParser _passbookParser;

  Future<BankDetails> scan(File image) async {
    final rawText = await _ocrService.extractText(image);
    return _passbookParser.parse(rawText);
  }

  bool hasPassbookDetails(BankDetails details) {
    return details.accountNumber != null ||
        details.ifscCode != null ||
        details.accountHolderName != null;
  }

  Future<void> dispose() => _ocrService.dispose();
}
