import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MlKitOcrDataSource {
  MlKitOcrDataSource({TextRecognizer? recognizer})
      : _recognizer = recognizer ??
            TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;
  bool _disposed = false;

  Future<String> recognize(File image) async {
    if (_disposed) {
      throw StateError('MlKitOcrDataSource already disposed.');
    }
    final inputImage = InputImage.fromFile(image);
    final recognizedText = await _recognizer.processImage(inputImage);
    return recognizedText.text;
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await _recognizer.close();
  }
}
