import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.useOutlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool useOutlined;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    final effectiveOnPressed = isLoading ? null : onPressed;

    if (icon != null) {
      if (useOutlined) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: effectiveOnPressed,
            icon: Icon(icon),
            label: child,
          ),
        );
      }
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: effectiveOnPressed,
          icon: Icon(icon),
          label: child,
        ),
      );
    }

    if (useOutlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
    );
  }
}
