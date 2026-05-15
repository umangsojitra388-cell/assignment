import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import 'card_scanner_screen.dart';
import 'passbook_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.ocrScanner),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CardScannerScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.credit_card),
              label: const Text(AppStrings.scanCard),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PassbookScannerScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text(AppStrings.scanPassbook),
            ),
          ],
        ),
      ),
    );
  }
}
