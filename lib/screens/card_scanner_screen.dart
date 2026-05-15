import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_strings.dart';
import '../models/card_details.dart';
import '../services/card_scan_service.dart';
import '../utils/card_mask.dart';

class CardScannerScreen extends StatefulWidget {
  const CardScannerScreen({super.key});

  @override
  State<CardScannerScreen> createState() => _CardScannerScreenState();
}

class _CardScannerScreenState extends State<CardScannerScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final CardScanService _cardScanService = CardScanService();

  File? _imageFile;
  CardDetails? _cardDetails;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cardScanService.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _imageFile = File(picked.path);
      _cardDetails = null;
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
      final details = await _cardScanService.scan(image);

      if (!mounted) return;

      if (_cardScanService.isValidCard(details)) {
        setState(() {
          _cardDetails = details;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _cardDetails = null;
          _errorMessage = AppStrings.noValidCardDetected;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cardDetails = null;
        _errorMessage = AppStrings.couldNotReadCard;
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
        title: const Text(AppStrings.scanCardTitle),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ImagePreview(imageFile: _imageFile),
                const SizedBox(height: 24),
                if (_errorMessage != null) _ErrorBanner(message: _errorMessage!),
                if (_cardDetails != null) _CardDetailsView(details: _cardDetails!),
              ],
            ),
          ),
          if (_isProcessing) const _LoadingOverlay(),
        ],
      ),
      floatingActionButton: _isProcessing
          ? null
          : FloatingActionButton.extended(
              onPressed: _captureFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: Text(
                _imageFile == null ? AppStrings.capture : AppStrings.retake,
              ),
            ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageFile});

  final File? imageFile;

  @override
  Widget build(BuildContext context) {
    if (imageFile == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          AppStrings.noImageCaptured,
          style: Theme.of(context).textTheme.bodyLarge,
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

class _CardDetailsView extends StatelessWidget {
  const _CardDetailsView({required this.details});

  final CardDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.cardDetails, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _DetailRow(
              label: AppStrings.cardNumber,
              value: maskCardNumber(details.cardNumber!),
            ),
            _DetailRow(
              label: AppStrings.expiry,
              value: details.expiryDate ?? AppStrings.notAvailable,
            ),
            _DetailRow(
              label: AppStrings.cardholder,
              value: details.cardHolderName ?? AppStrings.notAvailable,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
            width: 100,
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

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
                Text(AppStrings.processingCard),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
