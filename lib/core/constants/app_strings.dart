/// Centralized user-facing strings for the app.
abstract final class AppStrings {
  // App
  static const String ocrScanner = 'OCR Scanner';

  // Home
  static const String scanCard = 'Scan Card';
  static const String scanPassbook = 'Scan Passbook';

  // Card scanner
  static const String scanCardTitle = 'Scan Card';
  static const String capture = 'Capture';
  static const String retake = 'Retake';
  static const String noImageCaptured = 'No image captured';
  static const String cardDetails = 'Card details';
  static const String cardNumber = 'Card number';
  static const String expiry = 'Expiry';
  static const String cardholder = 'Cardholder';
  static const String processingCard = 'Processing card...';
  static const String noValidCardDetected =
      'No valid card detected. Please capture a clear image and try again.';
  static const String couldNotReadCard =
      'Could not read the card. Please try again.';

  // Passbook scanner
  static const String scanPassbookTitle = 'Scan Passbook';
  static const String camera = 'Camera';
  static const String gallery = 'Gallery';
  static const String noImageSelected = 'No image selected';
  static const String passbookEmptyStateHint =
      'Use the camera or pick an image from your gallery to scan passbook details.';
  static const String bankDetails = 'Bank details';
  static const String accountHolder = 'Account holder';
  static const String accountNumber = 'Account number';
  static const String ifscCode = 'IFSC code';
  static const String readingPassbook = 'Reading passbook...';
  static const String noPassbookDetailsFound =
      'No passbook details found. Try a clearer photo of the account page.';
  static const String couldNotReadPassbook =
      'Could not read the passbook. Please try again.';

  // Common
  static const String notAvailable = '—';
}
