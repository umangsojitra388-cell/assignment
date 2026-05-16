# OCR Scanner (Flutter)

Interview-ready Flutter sample focused on **clean architecture**, **BLoC-only state management** (no `setState`, no Provider/Riverpod/GetX in app code), and **robust manual parsing** (Luhn, card parser, passbook parser).

## App demo (screen recording)

End-to-end walkthrough on Android: home → **Card Scanner** (native `card_scanner` + Luhn validation + masked PAN) → **Passbook Scanner** (camera / gallery + ML Kit OCR + structured bank fields).

Watch the demo below directly in this README (after you push `assets/demo/app_demo.mp4` to `main`):

<video controls autoplay muted playsinline loop width="100%" style="max-width: 100%; border-radius: 12px;">
  <source src="https://raw.githubusercontent.com/umangsojitra388-cell/assignment/main/assets/demo/app_demo.mp4" type="video/mp4">
  <source src="assets/demo/app_demo.mp4" type="video/mp4">
</video>

| | |
|---|---|
| **Stream in browser** | [Open demo video (MP4)](https://raw.githubusercontent.com/umangsojitra388-cell/assignment/main/assets/demo/app_demo.mp4) |
| **Repo file** | [`assets/demo/app_demo.mp4`](assets/demo/app_demo.mp4) (~12 MB) |

> If the player is empty before your first push, commit and push the video file, then refresh this page on GitHub.

## Features

| Module | What it does |
|--------|----------------|
| **Card Scanner** | Scan debit/credit card via `card_scanner`; extract number, expiry, holder name; mask PAN (`XXXX XXXX XXXX 1234`); validate with manual **Luhn**; handle OCR noise (`O`→`0`, `I`→`1`, separators). |
| **Passbook Scanner** | Capture from **camera** or **gallery**; ML Kit text recognition; parse account holder, account number, IFSC; score candidates; partial / error states with image preview. |

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) **stable** channel (SDK `^3.11.1` in this repo).
- Android device or emulator with **camera** access for both modules.

## Setup

```bash
flutter pub get
flutter run
```

Run tests:

```bash
flutter test
```

### Android

- `CAMERA` permission is declared in `android/app/src/main/AndroidManifest.xml`.
- Ensure **Google Play services** / ML Kit models can download on first OCR use (device network may be required once).

## Libraries

| Package | Role |
|--------|------|
| `card_scanner` | Native debit/credit card scan UI + base fields |
| `google_mlkit_text_recognition` | On-device OCR for passbook images |
| `flutter_bloc` | Events, states, `BlocBuilder` / `BlocListener` |
| `equatable` | Value equality for models & states |
| `image_picker` | Gallery (and optional re-use paths) |
| `camera` | In-app camera capture for passbook flow |

## Architecture

- **`lib/core`**: shared constants, theme, utilities (Luhn, text cleanup, masking), helpers (name heuristics), reusable widgets.
- **`lib/features/card_scanner`**: `data` (repository wrapping `card_scanner` + parser), `parser`, `models`, `bloc`, `screens`.
- **`lib/features/passbook_scanner`**: `data` (ML Kit OCR + repository), `parser`, `models`, `bloc` (including a dedicated `CameraCaptureBloc`), `screens`.
- **`lib/features/home`**: simple module navigation hub.

Business rules stay out of widgets: repositories orchestrate IO/plugins; parsers are pure Dart; BLoCs translate user intents into states.

## Assumptions

- **Card module**: `card_scanner` returns structured strings; we **re-validate** with an in-house **Luhn** implementation and merge with `CardParser` heuristics for OCR-style noise (`O`/`I` confusions, spacing).
- **Passbook module**: Indian-style **IFSC** (`AAAA0XXXXXX`) and **account numbers** (9–18 digits, heuristics to avoid phone numbers / IFSC fragments). Digit OCR fixes (`O`→`0`, etc.) are applied **only on lines that already contain digits**, so holder names like `DOE` are not corrupted.
- **Card preview**: the plugin does **not** return a bitmap; the UI documents this and shows a structured placeholder card.

## Limitations

- OCR quality depends on lighting, focus, and device; **partial scans** may yield incomplete `BankDetails` (surfaced via snack bar + `—` placeholders).
- `card_scanner` relies on native implementations; behavior can vary slightly by OEM/Android version.
- IFSC / account detection uses heuristics — **always confirm** with the physical passbook before production use.

## Future improvements

- Inject repositories via `get_it` / pure `BlocProvider` at root for testing.
- Golden tests for primary screens; integration tests with fake OCR outputs.
- Optional manual correction sheet when parsers return low confidence.
- iOS-specific `Info.plist` camera strings if targeting iOS.

## Project layout

```
assets/
└── demo/
    └── app_demo.mp4          # README screen recording
lib/
├── core/
│   ├── constants/
│   ├── helpers/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── home/
│   ├── card_scanner/
│   └── passbook_scanner/
└── main.dart
```
