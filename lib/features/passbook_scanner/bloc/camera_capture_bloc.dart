import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import 'camera_capture_event.dart';
import 'camera_capture_state.dart';

class CameraCaptureBloc extends Bloc<CameraCaptureEvent, CameraCaptureState> {
  CameraCaptureBloc() : super(const CameraCaptureInitial()) {
    on<CameraCaptureStarted>(_onStarted);
    on<CameraCaptureShutterPressed>(_onShutter);
  }

  CameraController? _controller;

  Future<void> _onStarted(
    CameraCaptureStarted event,
    Emitter<CameraCaptureState> emit,
  ) async {
    emit(const CameraCaptureLoading());
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(const CameraCaptureFailure(AppStrings.noCameraHardware));
        return;
      }

      CameraDescription? selected;
      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          selected = camera;
          break;
        }
      }
      selected ??= cameras.first;

      _controller = CameraController(
        selected,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      emit(CameraCapturePreviewReady(_controller!));
    } catch (_) {
      await _disposeController();
      emit(const CameraCaptureFailure(AppStrings.cameraInitFailed));
    }
  }

  Future<void> _onShutter(
    CameraCaptureShutterPressed event,
    Emitter<CameraCaptureState> emit,
  ) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    try {
      final shot = await controller.takePicture();
      emit(CameraCaptureCompleted(File(shot.path)));
    } catch (_) {
      emit(const CameraCaptureFailure(AppStrings.couldNotReadPassbook));
    }
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }

  @override
  Future<void> close() async {
    await _disposeController();
    return super.close();
  }
}
