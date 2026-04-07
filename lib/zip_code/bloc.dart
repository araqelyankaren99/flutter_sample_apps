import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/zip_code/event.dart';
import 'package:flutter_sample_apps/zip_code/state.dart';

class ZipCodeBloc extends Bloc<ZipCodeEvent, ZipCodeState> {
  ZipCodeBloc({
    required this.zipCodeValidationRepository,
  }) : super(const ZipCodeInitial()) {
    on<ChangeZipCodeEvent>(_onChangeZipCodeEventToState);
    on<ChangeCityEvent>(_onChangeCityEventToState);
    on<ChangeAddressStateEvent>(_onChangeAddressStateEventToState);
    on<CheckZipCodeEvent>(_onCheckZipCodeEventToState);
    on<ZipCodeResultNotExistingEvent>(_onZipCodeResultNotExistingEventToState);
    on<CheckCityEvent>(_onCheckCityEventToState);
    on<CheckStateEvent>(_onCheckStateEventToState);
    on<ClearZipCodeDataEvent>(_onClearZipCodeDataEventToState);
  }

  final ZipCodeValidationRepository zipCodeValidationRepository;

  String _zipCode = '';

  Future<void> _onChangeZipCodeEventToState(
    ChangeZipCodeEvent event,
    Emitter<ZipCodeState> emit,
  ) async {
    final zipCode = event.zipCode;
    final deletingLastSymbol =
        !zipCodeValidationRepository.isZipCode(zipCode) &&
            zipCodeValidationRepository.isZipCode(_zipCode);
    if (deletingLastSymbol) {
      add(const ClearZipCodeDataEvent());
    }
    _zipCode = zipCode;
    emit(ZipCodeChangedState(zipCode: zipCode));
    if (zipCodeValidationRepository.isZipCode(zipCode)) {
      add(CheckZipCodeEvent(zipCode: zipCode));
    }
  }

  Future<void> _onChangeCityEventToState(
    ChangeCityEvent event,
    Emitter<ZipCodeState> emit,
  ) async {
    final city = event.city;
    emit(CityChangedState(city: city));
  }

  Future<void> _onChangeAddressStateEventToState(
    ChangeAddressStateEvent event,
    Emitter<ZipCodeState> emit,
  ) async {
    final addressState = event.addressState;
    emit(AddressStateChangedState(addressState: addressState));
  }

  Future<void> _onCheckZipCodeEventToState(
    CheckZipCodeEvent event,
    Emitter<ZipCodeState> emit,
  ) async {
    try {
      final zipcode = event.zipCode;
      emit(const ZipCodeLoadingState());
      final city = 'city';
      final addressState = 'state';
      add(CheckCityEvent(city: city));
      add(
        CheckStateEvent(addressState: addressState),
      );
    } on Exception catch (error, stackTrace) {
      add(const ZipCodeResultNotExistingEvent());
      throw Error.throwWithStackTrace(error, stackTrace);
    } finally {
      emit(const ZipRequestFinishedState());
    }
  }

  Future<void> _onZipCodeResultNotExistingEventToState(
    ZipCodeResultNotExistingEvent event,
    Emitter<ZipCodeState> emit,
  ) async {
    emit(const CityEnabledState());
    emit(const CityClearedState());
    emit(const StateEnabledState());
    emit(const StateClearedState());
  }

  Future<void> _onCheckCityEventToState(
    CheckCityEvent event,
    Emitter<ZipCodeState> emit,
  ) async {
    final city = event.city;
    if (city == null) {
      emit(const CityEnabledState());
      return;
    }
    if (city.isEmpty) {
      emit(const CityEnabledState());
      return;
    }

    emit(const CityDisabledState());
    emit(CityUpdatedState(city: city));
  }

  Future<void> _onCheckStateEventToState(
    CheckStateEvent event,
    Emitter<ZipCodeState> emit,
  ) async {
    final addressState = event.addressState;
    if (addressState == null) {
      emit(const StateEnabledState());
      return;
    }

    if (addressState.isEmpty) {
      emit(const StateEnabledState());
      return;
    }

    emit(const StateDisabledState());
    emit(StateChangedState(addressState: addressState));
  }

  Future<void> _onClearZipCodeDataEventToState(
    ClearZipCodeDataEvent event,
    Emitter<ZipCodeState> emit,
  ) async {
    emit(const CityDisabledState());
    emit(const StateDisabledState());
    emit(const CityClearedState());
    emit(const StateClearedState());
  }
}

class ZipCodeValidationRepository {
  const ZipCodeValidationRepository();

  bool isZipCode(String zipCode) => zipCode.length == 5;
}
