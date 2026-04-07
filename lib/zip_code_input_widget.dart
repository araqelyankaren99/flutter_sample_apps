import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/zip_code/bloc.dart';
import 'package:flutter_sample_apps/zip_code/event.dart';
import 'package:flutter_sample_apps/zip_code/state.dart';

import 'custom_input_widget.dart';

class ZipCodeInputWidget extends StatefulWidget {
  const ZipCodeInputWidget({
    Key? key,
    required this.onZipCodeChange,
    required this.hasZipCodeError,
    required this.hasZipCodeEmptyError,
    required this.onCityChanged,
    required this.hasCityError,
    required this.onStateChanged,
    required this.hasStateError,
    required this.hasAddressStateEmptyError,
    this.city,
    this.state,
    this.zipCode,
  }) : super(key: key);

  final OnChanged onZipCodeChange;
  final bool hasZipCodeError;
  final bool hasZipCodeEmptyError;
  final OnChanged onCityChanged;
  final bool hasCityError;
  final OnChanged onStateChanged;
  final bool hasStateError;
  final bool hasAddressStateEmptyError;
  final String? city;
  final String? state;
  final String? zipCode;

  @override
  State<ZipCodeInputWidget> createState() => _ZipCodeInputWidgetState();
}

class _ZipCodeInputWidgetState extends State<ZipCodeInputWidget> {
  late ZipCodeBloc _zipCodeBloc;

  @override
  void didChangeDependencies() {
    _zipCodeBloc = context.read<ZipCodeBloc>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _zipCodeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ZipCodeBloc, ZipCodeState>(
      listener: _listener,
      bloc: _zipCodeBloc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _ZipInputWidget(
                            hasError: widget.hasZipCodeEmptyError ||
                                widget.hasZipCodeError,
                            zipCode: widget.zipCode,
                            zipCodeBloc: _zipCodeBloc,
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _StateInputWidget(
                            hasError: widget.hasAddressStateEmptyError ||
                                widget.hasStateError,
                            state: widget.state,
                            zipCodeBloc: _zipCodeBloc,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _CityInputWidget(
                  hasError: widget.hasCityError,
                  city: widget.city,
                  zipCodeBloc: _zipCodeBloc,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _listener(BuildContext context, ZipCodeState state) {
    if (state is ZipCodeChangedState) {
      widget.onZipCodeChange.call(state.zipCode);
    }

    if (state is CityUpdatedState) {
      widget.onCityChanged.call(state.city);
    }

    if (state is CityChangedState) {
      widget.onCityChanged.call(state.city);
    }
    if (state is StateChangedState) {
      widget.onStateChanged.call(state.addressState);
    }

    if (state is AddressStateChangedState) {
      widget.onStateChanged.call(state.addressState);
    }

    if (state is StateClearedState) {
      widget.onStateChanged.call('');
    }

    if (state is CityClearedState) {
      widget.onCityChanged.call('');
    }
  }
}

class _ZipInputWidget extends StatefulWidget {
  const _ZipInputWidget({
    Key? key,
    required this.hasError,
    required this.zipCodeBloc,
    this.zipCode,
  }) : super(key: key);

  final bool hasError;
  final String? zipCode;
  final ZipCodeBloc zipCodeBloc;

  @override
  State<_ZipInputWidget> createState() => _ZipInputWidgetState();
}

class _ZipInputWidgetState extends State<_ZipInputWidget> {
  var _zipController = TextEditingController();
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    final state = widget.zipCode;
    if (state != null) {
      _zipController = TextEditingController(text: state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ZipCodeBloc, ZipCodeState>(
      listener: _listener,
      bloc: widget.zipCodeBloc,
      child: CustomInputWidget(
        controller: _zipController,
        hintText: 'cZipCodeHintText',
        hasError: widget.hasError,
        textInputType: TextInputType.phone,
        loading: _showLoading,
        enabled: !_showLoading,
        onChanged: (zipCode) => _onChanged(context, zipCode),
      ),
    );
  }

  void _onChanged(BuildContext context, String zipCode) {
    widget.zipCodeBloc.add(ChangeZipCodeEvent(zipCode: zipCode));
  }

  void _listener(BuildContext context, ZipCodeState state) {
    if (state is ZipCodeLoadingState) {
      setState(() {
        _showLoading = true;
      });
    }

    if (state is ZipRequestFinishedState) {
      setState(() {
        _showLoading = false;
      });
    }
  }
}

class _StateInputWidget extends StatefulWidget {
  const _StateInputWidget({
    Key? key,
    required this.hasError,
    this.state,
    required this.zipCodeBloc,
  }) : super(key: key);

  final bool hasError;
  final String? state;
  final ZipCodeBloc zipCodeBloc;

  @override
  State<_StateInputWidget> createState() => _PatientStateInputWidgetState();
}

class _PatientStateInputWidgetState extends State<_StateInputWidget> {
  var _addressStateTextController = TextEditingController();
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    final state = widget.state;
    if (state != null) {
      _addressStateTextController = TextEditingController(text: state);
    }
  }

  @override
  void dispose() {
    _addressStateTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ZipCodeBloc, ZipCodeState>(
      listener: _listener,
      bloc: widget.zipCodeBloc,
      child: CustomInputWidget(
        hintText: 'cAddressStateHintText',
        enabled: _enabled,
        hasError: widget.hasError,
        controller: _addressStateTextController,
        onChanged: _onChanged,
      ),
    );
  }

  void _onChanged(String addressState) {
    widget.zipCodeBloc.add(ChangeAddressStateEvent(addressState: addressState));
  }

  void _listener(BuildContext context, ZipCodeState state) {
    if (state is StateChangedState) {
      _addressStateTextController.text = state.addressState;
    }

    if (state is StateClearedState) {
      _addressStateTextController.clear();
    }

    if (state is CityEnabledState) {
      setState(() {
        _enabled = true;
      });
    }

    if (state is CityDisabledState) {
      setState(() {
        _enabled = false;
      });
    }
  }
}

class _CityInputWidget extends StatefulWidget {
  const _CityInputWidget({
    Key? key,
    required this.hasError,
    this.city,
    required this.zipCodeBloc,
  }) : super(key: key);

  final bool hasError;
  final ZipCodeBloc zipCodeBloc;

  final String? city;

  @override
  State<_CityInputWidget> createState() => _CityInputWidgetState();
}

class _CityInputWidgetState extends State<_CityInputWidget> {
  var _cityTextController = TextEditingController();
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    final city = widget.city;
    if (city != null) {
      _cityTextController = TextEditingController(text: city);
    }
  }

  @override
  void dispose() {
    _cityTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ZipCodeBloc, ZipCodeState>(
      listener: _listener,
      bloc: widget.zipCodeBloc,
      child: CustomInputWidget(
        hasError: widget.hasError,
        enabled: _enabled,
        controller: _cityTextController,
        hintText: 'cCityHintText',
        onChanged: _onChanged,
      ),
    );
  }

  void _onChanged(String city) {
    widget.zipCodeBloc.add(ChangeCityEvent(city: city));
  }

  void _listener(BuildContext context, ZipCodeState state) {
    if (state is CityUpdatedState) {
      _cityTextController.text = state.city;
    }

    if (state is CityClearedState) {
      _cityTextController.clear();
    }

    if (state is StateEnabledState) {
      setState(() {
        _enabled = true;
      });
    }

    if (state is StateDisabledState) {
      setState(() {
        _enabled = false;
      });
    }
  }
}
