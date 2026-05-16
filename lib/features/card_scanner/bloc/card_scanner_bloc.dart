import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../data/card_scan_repository.dart' show CardScanCancelledException, CardScanRepository;
import '../../../core/utils/luhn_validator.dart';
import 'card_scanner_event.dart';
import 'card_scanner_state.dart';

class CardScannerBloc extends Bloc<CardScannerEvent, CardScannerState> {
  CardScannerBloc({required CardScanRepository repository})
      : _repository = repository,
        super(const CardScannerInitial()) {
    on<CardScannerStarted>(_onStarted);
    on<CardScannerReset>(_onReset);
  }

  final CardScanRepository _repository;

  Future<void> _onStarted(
    CardScannerStarted event,
    Emitter<CardScannerState> emit,
  ) async {
    emit(const CardScannerLoading());
    try {
      final details = await _repository.scanDebitOrCreditCard();
      final number = details.cardNumber;
      if (number == null || !LuhnValidator.isValid(number)) {
        emit(const CardScannerFailure(AppStrings.noValidCardDetected));
        return;
      }
      emit(CardScannerSuccess(details));
    } on CardScanCancelledException {
      emit(const CardScannerFailure(AppStrings.scanCancelled));
    } catch (_) {
      emit(const CardScannerFailure(AppStrings.couldNotReadCard));
    }
  }

  void _onReset(
    CardScannerReset event,
    Emitter<CardScannerState> emit,
  ) {
    emit(const CardScannerInitial());
  }
}
