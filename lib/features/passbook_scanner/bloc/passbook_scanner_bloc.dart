import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../data/passbook_scan_repository.dart';
import 'passbook_scanner_event.dart';
import 'passbook_scanner_state.dart';

class PassbookScannerBloc
    extends Bloc<PassbookScannerEvent, PassbookScannerState> {
  PassbookScannerBloc({required PassbookScanRepository repository})
      : _repository = repository,
        super(const PassbookScannerInitial()) {
    on<PassbookScanRequested>(_onScanRequested);
    on<PassbookScannerReset>(_onReset);
  }

  final PassbookScanRepository _repository;

  Future<void> _onScanRequested(
    PassbookScanRequested event,
    Emitter<PassbookScannerState> emit,
  ) async {
    emit(const PassbookScannerLoading());
    try {
      final details = await _repository.scan(event.image);
      if (!_repository.hasMeaningfulDetails(details)) {
        emit(PassbookScannerFailure(
          AppStrings.noPassbookDetailsFound,
          attemptedImage: event.image,
        ));
        return;
      }
      final isPartial = details.accountNumber == null ||
          details.ifscCode == null ||
          details.accountHolderName == null;
      emit(
        PassbookScannerSuccess(
          details: details,
          image: event.image,
          isPartial: isPartial,
        ),
      );
    } catch (_) {
      emit(PassbookScannerFailure(
        AppStrings.couldNotReadPassbook,
        attemptedImage: event.image,
      ));
    }
  }

  void _onReset(
    PassbookScannerReset event,
    Emitter<PassbookScannerState> emit,
  ) {
    emit(const PassbookScannerInitial());
  }

  @override
  Future<void> close() async {
    await _repository.dispose();
    await super.close();
  }
}
