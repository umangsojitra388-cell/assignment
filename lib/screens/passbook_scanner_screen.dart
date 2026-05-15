import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_strings.dart';
import '../models/bank_details.dart';
import '../services/passbook_scan_service.dart';

class PassbookScannerScreen extends StatefulWidget {
  const PassbookScannerScreen({super.key});

  @override
  State<PassbookScannerScreen> createState() => _PassbookScannerScreenState();
}

class _PassbookScannerScreenState extends State<PassbookScannerScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final PassbookScanService _passbookScanService = PassbookScanService();

  File? _imageFile;
  BankDetails? _bankDetails;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passbookScanService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _imageFile = File(picked.path);
      _bankDetails = null;
      _errorMessage = null;
    });

    await _runScan(File(picked.path));
  }

  Future<void> _runScan(File image) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final details = await _passbookScanService.scan(image);

      if (!mounted) return;

      if (_passbookScanService.hasPassbookDetails(details)) {
        setState(() {
          _bankDetails = details;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _bankDetails = null;
          _errorMessage = AppStrings.noPassbookDetailsFound;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _bankDetails = null;
        _errorMessage = AppStrings.couldNotReadPassbook;
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scanPassbookTitle),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PassbookImagePreview(imageFile: _imageFile),
                const SizedBox(height: 24),
                if (_imageFile == null && !_isProcessing) const _EmptyStateHint(),
                if (_errorMessage != null) _PassbookErrorBanner(message: _errorMessage!),
                if (_bankDetails != null)
                  _PassbookDetailsView(details: _bankDetails!),
              ],
            ),
          ),
          if (_isProcessing) const _PassbookLoadingOverlay(),
        ],
      ),
      bottomNavigationBar: _isProcessing
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text(AppStrings.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text(AppStrings.gallery),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _PassbookImagePreview extends StatelessWidget {
  const _PassbookImagePreview({required this.imageFile});

  final File? imageFile;

  @override
  Widget build(BuildContext context) {
    if (imageFile == null) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.noImageSelected,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        imageFile!,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _EmptyStateHint extends StatelessWidget {
  const _EmptyStateHint();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.passbookEmptyStateHint,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _PassbookDetailsView extends StatelessWidget {
  const _PassbookDetailsView({required this.details});

  final BankDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.bankDetails, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _PassbookDetailRow(
              label: AppStrings.accountHolder,
              value: details.accountHolderName ?? AppStrings.notAvailable,
            ),
            _PassbookDetailRow(
              label: AppStrings.accountNumber,
              value: details.accountNumber ?? AppStrings.notAvailable,
            ),
            _PassbookDetailRow(
              label: AppStrings.ifscCode,
              value: details.ifscCode ?? AppStrings.notAvailable,
            ),
          ],
        ),
      ),
    );
  }
}

class _PassbookDetailRow extends StatelessWidget {
  const _PassbookDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _PassbookErrorBanner extends StatelessWidget {
  const _PassbookErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassbookLoadingOverlay extends StatelessWidget {
  const _PassbookLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0x88000000),
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
    );
  }
}
