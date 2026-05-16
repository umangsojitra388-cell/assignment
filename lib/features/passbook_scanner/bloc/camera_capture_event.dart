import 'package:equatable/equatable.dart';

sealed class CameraCaptureEvent extends Equatable {
  const CameraCaptureEvent();

  @override
  List<Object?> get props => [];
}

class CameraCaptureStarted extends CameraCaptureEvent {
  const CameraCaptureStarted();
}

class CameraCaptureShutterPressed extends CameraCaptureEvent {
  const CameraCaptureShutterPressed();
}
