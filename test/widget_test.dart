import 'package:assignment/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots to home', (tester) async {
    await tester.pumpWidget(const OcrScannerApp());
    await tester.pumpAndSettle();
    expect(find.text('OCR Scanner'), findsOneWidget);
  });
}
