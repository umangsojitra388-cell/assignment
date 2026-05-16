import 'dart:io';

import 'package:flutter/material.dart';

class ScannerPreviewCard extends StatelessWidget {
  const ScannerPreviewCard({
    super.key,
    this.imageFile,
    this.placeholderIcon = Icons.image_outlined,
    this.placeholderText,
    this.height = 220,
  });

  final File? imageFile;
  final IconData placeholderIcon;
  final String? placeholderText;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          imageFile!,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.35),
            scheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: scheme.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(placeholderIcon, size: 48, color: scheme.onSurfaceVariant),
          if (placeholderText != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                placeholderText!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
