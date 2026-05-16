import 'dart:io';

import 'package:equatable/equatable.dart';

import '../models/bank_details.dart';

sealed class PassbookScannerState extends Equatable {
  const PassbookScannerState();

  @override
  List<Object?> get props => [];
}

class PassbookScannerInitial extends PassbookScannerState {
  const PassbookScannerInitial();
}

class PassbookScannerLoading extends PassbookScannerState {
  const PassbookScannerLoading();
}

class PassbookScannerSuccess extends PassbookScannerState {
  const PassbookScannerSuccess({
    required this.details,
    required this.image,
    required this.isPartial,
  });

  final BankDetails details;
  final File image;
  final bool isPartial;

  @override
  List<Object?> get props => [details, image.path, isPartial];
}

class PassbookScannerFailure extends PassbookScannerState {
  const PassbookScannerFailure(this.message, {this.attemptedImage});

  final String message;
  final File? attemptedImage;

  @override
  List<Object?> get props => [message, attemptedImage?.path];
}
