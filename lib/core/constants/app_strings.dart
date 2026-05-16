abstract final class AppStrings {
  static const String ocrScanner = 'OCR Scanner';

  static const String scanCard = 'Card Scanner';
  static const String scanPassbook = 'Passbook Scanner';

  static const String scanCardTitle = 'Card Scanner';
  static const String scanCardCta = 'Scan with camera';
  static const String cardDetails = 'Extracted details';
  static const String cardNumber = 'Card number';
  static const String expiry = 'Expiry';
  static const String cardholder = 'Cardholder';
  static const String processingCard = 'Processing card…';
  static const String noValidCardDetected =
      'No valid card number (Luhn) was found. Try again with better lighting.';
  static const String couldNotReadCard =
      'Something went wrong while reading the card.';
  static const String scanCancelled =
      'Scan was cancelled before a card was captured.';
  static const String cardPreviewHint =
      'The native scanner validates the card visually; no preview image is returned.';

  static const String scanPassbookTitle = 'Passbook Scanner';
  static const String camera = 'Camera';
  static const String gallery = 'Gallery';
  static const String noImageSelected = 'No image selected';
  static const String passbookEmptyStateHint =
      'Capture a passbook page or pick a photo from your gallery.';
  static const String bankDetails = 'Extracted details';
  static const String accountHolder = 'Account holder';
  static const String accountNumber = 'Account number';
  static const String ifscCode = 'IFSC code';
  static const String readingPassbook = 'Reading passbook…';
  static const String noPassbookDetailsFound =
      'Could not confidently extract account details. Try a sharper, well-lit photo.';
  static const String couldNotReadPassbook =
      'Could not read the image. Please try again.';
  static const String cameraInitFailed =
      'Could not start the camera. Check permissions and try again.';
  static const String noCameraHardware = 'No camera is available on this device.';

  static const String notAvailable = '—';
  static const String retry = 'Retry';
  static const String clear = 'Clear';
}
