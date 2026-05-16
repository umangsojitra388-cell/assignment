import 'package:equatable/equatable.dart';

import '../models/card_details.dart';

sealed class CardScannerState extends Equatable {
  const CardScannerState();

  @override
  List<Object?> get props => [];
}

class CardScannerInitial extends CardScannerState {
  const CardScannerInitial();
}

class CardScannerLoading extends CardScannerState {
  const CardScannerLoading();
}

class CardScannerSuccess extends CardScannerState {
  const CardScannerSuccess(this.details);

  final CardDetails details;

  @override
  List<Object?> get props => [details];
}

class CardScannerFailure extends CardScannerState {
  const CardScannerFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
