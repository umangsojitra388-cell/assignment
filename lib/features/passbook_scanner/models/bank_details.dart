import 'package:equatable/equatable.dart';

class BankDetails extends Equatable {
  const BankDetails({
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
  });

  final String? accountHolderName;
  final String? accountNumber;
  final String? ifscCode;

  bool get hasAny =>
      accountHolderName != null ||
      accountNumber != null ||
      ifscCode != null;

  @override
  List<Object?> get props => [accountHolderName, accountNumber, ifscCode];
}
