import 'package:equatable/equatable.dart';

class CardDetails extends Equatable {
  const CardDetails({
    this.cardNumber,
    this.expiryDate,
    this.cardHolderName,
  });

  final String? cardNumber;
  final String? expiryDate;
  final String? cardHolderName;

  bool get hasLuhnValidNumber =>
      cardNumber != null && cardNumber!.length >= 13;

  @override
  List<Object?> get props => [cardNumber, expiryDate, cardHolderName];
}
