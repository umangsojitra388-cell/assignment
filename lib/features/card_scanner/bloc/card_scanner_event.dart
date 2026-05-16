import 'package:equatable/equatable.dart';

sealed class CardScannerEvent extends Equatable {
  const CardScannerEvent();

  @override
  List<Object?> get props => [];
}

class CardScannerStarted extends CardScannerEvent {
  const CardScannerStarted();
}

class CardScannerReset extends CardScannerEvent {
  const CardScannerReset();
}
