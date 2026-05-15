# Flutter OCR Scanner

A Flutter assignment app that captures document images, runs on-device OCR, and extracts structured data from **payment cards** and **bank passbooks**.

## Project Overview

This project demonstrates an end-to-end OCR pipeline: image capture → text recognition (Google ML Kit) → preprocessing → regex/manual parsing → validated UI output. Business logic is separated from UI layers to keep the codebase maintainable and testable.

## Features

### Card Scanner
- Capture card images via camera
- On-device OCR with ML Kit
- Parse card number, expiry date, and cardholder name
- Luhn validation for card numbers
- Masked card number display (`XXXX XXXX XXXX 1234`)

### Passbook Scanner
- Capture via camera or upload from gallery
- Extract account holder name, account number, and IFSC code
- Heuristics to reduce false positives (phones, labels, IFSC overlap)

### Shared
- OCR text normalization (spacing, common digit misreads)
- Material 3 UI with loading and error states
- Unit tests for validator and parsers

## Folder Structure

```
lib/
├── main.dart
├── models/
│   ├── card_details.dart
│   └── bank_details.dart
├── services/
│   ├── ocr_service.dart
│   ├── card_scan_service.dart
│   └── passbook_scan_service.dart
├── parsers/
│   ├── card_parser.dart
│   └── passbook_parser.dart
├── validators/
│   └── luhn_validator.dart
├── utils/
│   ├── text_cleaner.dart
│   ├── name_filter.dart
│   └── card_mask.dart
└── screens/
    ├── home_screen.dart
    ├── card_scanner_screen.dart
    └── passbook_scanner_screen.dart

test/
├── luhn_validator_test.dart
├── card_parser_test.dart
└── passbook_parser_test.dart
```

## Packages Used

| Package | Purpose |
|---------|---------|
| [google_mlkit_text_recognition](https://pub.dev/packages/google_mlkit_text_recognition) | On-device OCR |
| [image_picker](https://pub.dev/packages/image_picker) | Camera and gallery image capture |
| flutter_test | Unit testing (dev) |
| flutter_lints | Static analysis (dev) |

## How to Run

### Prerequisites
- Flutter SDK (3.11+)
- Android Studio / Xcode for mobile builds
- A **physical device** is recommended (camera + ML Kit)

### Steps

```bash
# Install dependencies
flutter pub get

# Run on a connected device
flutter run
```

**Android:** Camera permission is declared in `AndroidManifest.xml`.  
**iOS:** Camera and photo library usage descriptions are in `Info.plist`.

## Assumptions

- OCR input is a reasonably clear photo of a card or passbook page
- Card numbers follow common 13–19 digit formats (often 16 digits, grouped or continuous)
- Expiry dates use `MM/YY`, `MM-YY`, or compact `MMYY` on non-card lines
- IFSC codes follow the Indian format: 4 letters + `0` + 6 alphanumeric characters
- Indian passbook conventions (`ACCOUNT`, `A/C`, `AC NO`) for account number hints
- Parsing uses regex and manual rules only (no cloud APIs or ML-based field extraction)

## Limitations

- OCR accuracy depends on lighting, blur, glare, and font quality
- Digit correction (`O`/`0`, `I`/`1`, etc.) is applied only in numeric contexts; unusual layouts may still misparse
- Cardholder/name detection uses heuristics and may miss or mis-rank names on noisy scans
- Passbook layouts vary by bank; generic keyword heuristics may not cover all formats
- ML Kit text recognition is not supported on all platforms (e.g. desktop/web)
- No persistent storage, authentication, or backend integration

## Future Improvements

- Live camera preview with scan region overlay
- Confidence scores per extracted field
- Bank-specific passbook parsing templates
- Expanded unit/integration test coverage with fixture images
- User-editable fields before confirmation
- Localization and accessibility audit

## Testing

Run all parser and validator tests:

```bash
flutter test test/luhn_validator_test.dart test/card_parser_test.dart test/passbook_parser_test.dart
```

Run the full test suite:

```bash
flutter test
```

Tests cover valid and invalid cases for the Luhn validator, card parser, and passbook parser using `flutter_test`.

---

Built as a Flutter OCR scanning assignment. For development and evaluation purposes.
