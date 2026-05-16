import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../card_scanner/screens/card_scanner_screen.dart';
import '../../passbook_scanner/screens/passbook_scanner_screen.dart';

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const CardScannerScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.credit_card),
              label: const Text(AppStrings.scanCard),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const PassbookScannerScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text(AppStrings.scanPassbook),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
