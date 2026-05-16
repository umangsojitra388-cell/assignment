import 'dart:io';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

sealed class CameraCaptureState extends Equatable {
  const CameraCaptureState();

  @override
  List<Object?> get props => [];
}

class CameraCaptureInitial extends CameraCaptureState {
  const CameraCaptureInitial();
}

class CameraCaptureLoading extends CameraCaptureState {
  const CameraCaptureLoading();
}

class CameraCapturePreviewReady extends CameraCaptureState {
  const CameraCapturePreviewReady(this.controller);

  final CameraController controller;

  @override
  List<Object?> get props => [];
}

class CameraCaptureFailure extends CameraCaptureState {
  const CameraCaptureFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class CameraCaptureCompleted extends CameraCaptureState {
  const CameraCaptureCompleted(this.file);

  final File file;

  @override
  List<Object?> get props => [file.path];
}
