import 'dart:io';

import 'mlkit_ocr_data_source.dart';
import '../models/bank_details.dart';
import '../parser/passbook_parser.dart';

class PassbookScanRepository {
  PassbookScanRepository({
    MlKitOcrDataSource? ocrDataSource,
    PassbookParser? parser,
  })  : _ocr = ocrDataSource ?? MlKitOcrDataSource(),
        _parser = parser ?? PassbookParser();

  final MlKitOcrDataSource _ocr;
  final PassbookParser _parser;

  Future<BankDetails> scan(File image) async {
    final rawText = await _ocr.recognize(image);
    return _parser.parse(rawText);
  }

  bool hasMeaningfulDetails(BankDetails details) => details.hasAny;

  Future<void> dispose() => _ocr.dispose();
}
