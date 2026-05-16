import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../bloc/camera_capture_bloc.dart';
import '../bloc/camera_capture_event.dart';
import '../bloc/camera_capture_state.dart';

class CameraCaptureScreen extends StatelessWidget {
  const CameraCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CameraCaptureBloc()..add(const CameraCaptureStarted()),
      child: BlocListener<CameraCaptureBloc, CameraCaptureState>(
        listenWhen: (previous, current) => current is CameraCaptureCompleted,
        listener: (context, state) {
          final file = (state as CameraCaptureCompleted).file;
          Navigator.of(context).pop(file);
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.camera),
          ),
          body: BlocBuilder<CameraCaptureBloc, CameraCaptureState>(
            builder: (context, state) {
              if (state is CameraCaptureLoading ||
                  state is CameraCaptureInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CameraCaptureFailure) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ErrorView(message: state.message),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: AppStrings.retry,
                        onPressed: () => context
                            .read<CameraCaptureBloc>()
                            .add(const CameraCaptureStarted()),
                      ),
                    ],
                  ),
                );
              }
              if (state is CameraCapturePreviewReady) {
                final ratio = state.controller.value.aspectRatio;
                return Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: ratio,
                            child: CameraPreview(state.controller),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: PrimaryButton(
                        label: AppStrings.camera,
                        icon: Icons.camera,
                        onPressed: () => context
                            .read<CameraCaptureBloc>()
                            .add(const CameraCaptureShutterPressed()),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
