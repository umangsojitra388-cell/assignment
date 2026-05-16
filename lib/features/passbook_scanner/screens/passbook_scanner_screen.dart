import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/detail_tile.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/scanner_preview_card.dart';
import '../bloc/passbook_scanner_bloc.dart';
import '../bloc/passbook_scanner_event.dart';
import '../bloc/passbook_scanner_state.dart';
import '../data/passbook_scan_repository.dart';
import 'camera_capture_screen.dart';

class PassbookScannerScreen extends StatelessWidget {
  const PassbookScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PassbookScannerBloc(
        repository: PassbookScanRepository(),
      ),
      child: const _PassbookScannerView(),
    );
  }
}

class _PassbookScannerView extends StatelessWidget {
  const _PassbookScannerView();

  Future<void> _openCamera(BuildContext context) async {
    final file = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        builder: (_) => const CameraCaptureScreen(),
      ),
    );
    if (!context.mounted || file == null) {
      return;
    }
    context.read<PassbookScannerBloc>().add(PassbookScanRequested(file));
  }

  Future<void> _openGallery(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );
    if (!context.mounted || picked == null) {
      return;
    }
    context
        .read<PassbookScannerBloc>()
        .add(PassbookScanRequested(File(picked.path)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PassbookScannerBloc, PassbookScannerState>(
      listenWhen: (previous, current) =>
          current is PassbookScannerSuccess && current.isPartial,
      listener: (context, state) {
        if (state is PassbookScannerSuccess && state.isPartial) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Some fields could not be detected. Verify values manually.',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final previewFile = switch (state) {
          PassbookScannerSuccess(:final image) => image,
          PassbookScannerFailure(:final attemptedImage) => attemptedImage,
          _ => null,
        };

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.scanPassbookTitle),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScannerPreviewCard(
                      imageFile: previewFile,
                      placeholderIcon: Icons.menu_book_outlined,
                      placeholderText: previewFile == null &&
                              state is PassbookScannerInitial
                          ? AppStrings.noImageSelected
                          : null,
                    ),
                    const SizedBox(height: 16),
                    if (state is PassbookScannerInitial)
                      Text(
                        AppStrings.passbookEmptyStateHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    if (state is PassbookScannerFailure) ...[
                      const SizedBox(height: 12),
                      ErrorView(message: state.message),
                    ],
                    if (state is PassbookScannerSuccess) ...[
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.bankDetails,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DetailTile(
                                label: AppStrings.accountHolder,
                                value: state.details.accountHolderName ??
                                    AppStrings.notAvailable,
                              ),
                              DetailTile(
                                label: AppStrings.accountNumber,
                                value: state.details.accountNumber ??
                                    AppStrings.notAvailable,
                              ),
                              DetailTile(
                                label: AppStrings.ifscCode,
                                value: state.details.ifscCode ??
                                    AppStrings.notAvailable,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: AppStrings.clear,
                        useOutlined: true,
                        onPressed: () => context
                            .read<PassbookScannerBloc>()
                            .add(const PassbookScannerReset()),
                      ),
                    ],
                  ],
                ),
              ),
              if (state is PassbookScannerLoading)
                const ColoredBox(
                  color: Color(0x66000000),
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(AppStrings.readingPassbook),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: AppStrings.camera,
                      icon: Icons.camera_alt_outlined,
                      isLoading: state is PassbookScannerLoading,
                      onPressed: state is PassbookScannerLoading
                          ? null
                          : () => _openCamera(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: AppStrings.gallery,
                      icon: Icons.photo_library_outlined,
                      useOutlined: true,
                      isLoading: state is PassbookScannerLoading,
                      onPressed: state is PassbookScannerLoading
                          ? null
                          : () => _openGallery(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
