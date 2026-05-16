import 'dart:io';

import 'package:equatable/equatable.dart';

sealed class PassbookScannerEvent extends Equatable {
  const PassbookScannerEvent();

  @override
  List<Object?> get props => [];
}

class PassbookScannerReset extends PassbookScannerEvent {
  const PassbookScannerReset();
}

class PassbookScanRequested extends PassbookScannerEvent {
  const PassbookScanRequested(this.image);

  final File image;

  @override
  List<Object?> get props => [image.path];
}
