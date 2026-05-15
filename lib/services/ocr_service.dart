import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Runs on-device text recognition via Google ML Kit.
class OCRService {
  OCRService({TextRecognizer? textRecognizer})
      : _textRecognizer =
            textRecognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _textRecognizer;
  bool _isDisposed = false;

  /// Reads [image] and returns the full recognized text (may be empty).
  Future<String> extractText(File image) async {
    _assertActive();
    final inputImage = InputImage.fromFile(image);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Releases the underlying ML Kit recognizer.
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    await _textRecognizer.close();
  }

  void _assertActive() {
    if (_isDisposed) {
      throw StateError('OCRService has already been disposed.');
    }
  }
}
