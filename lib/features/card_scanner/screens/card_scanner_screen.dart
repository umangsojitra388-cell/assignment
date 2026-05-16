import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/card_mask.dart';
import '../../../core/widgets/detail_tile.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/scanner_preview_card.dart';
import '../data/card_scan_repository.dart';
import '../bloc/card_scanner_bloc.dart';
import '../bloc/card_scanner_event.dart';
import '../bloc/card_scanner_state.dart';

class CardScannerScreen extends StatelessWidget {
  const CardScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CardScannerBloc(
        repository: CardScanRepository(),
      ),
      child: const _CardScannerView(),
    );
  }
}

class _CardScannerView extends StatelessWidget {
  const _CardScannerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scanCardTitle),
      ),
      body: BlocBuilder<CardScannerBloc, CardScannerState>(
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScannerPreviewCard(
                      imageFile: null,
                      placeholderIcon: Icons.credit_card,
                      placeholderText: AppStrings.cardPreviewHint,
                    ),
                    const SizedBox(height: 24),
                    if (state is CardScannerFailure)
                      ErrorView(message: state.message),
                    if (state is CardScannerSuccess) ...[
                      Text(
                        AppStrings.cardDetails,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DetailTile(
                                label: AppStrings.cardNumber,
                                value: maskCardNumber(state.details.cardNumber!),
                              ),
                              DetailTile(
                                label: AppStrings.expiry,
                                value: state.details.expiryDate ??
                                    AppStrings.notAvailable,
                              ),
                              DetailTile(
                                label: AppStrings.cardholder,
                                value: state.details.cardHolderName ??
                                    AppStrings.notAvailable,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (state is CardScannerLoading)
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
                            Text(AppStrings.processingCard),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<CardScannerBloc, CardScannerState>(
            builder: (context, state) {
              final loading = state is CardScannerLoading;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    label: AppStrings.scanCardCta,
                    icon: Icons.document_scanner_outlined,
                    isLoading: loading,
                    onPressed: loading
                        ? null
                        : () => context
                            .read<CardScannerBloc>()
                            .add(const CardScannerStarted()),
                  ),
                  if (state is CardScannerSuccess ||
                      state is CardScannerFailure) ...[
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: AppStrings.clear,
                      useOutlined: true,
                      onPressed: loading
                          ? null
                          : () => context
                              .read<CardScannerBloc>()
                              .add(const CardScannerReset()),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
