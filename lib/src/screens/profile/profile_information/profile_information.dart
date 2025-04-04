import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter_sample_apps/src/models/user.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/user_info_bloc/user_info_bloc.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/user_info_bloc/user_info_event.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/user_info_bloc/user_info_state.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/shared/profile_information/txt_field_wih_icon.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_information/extension/profile_info_type_enum.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_information/extension/profile_information_extension.dart';
import 'package:flutter_sample_apps/src/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/src/shared/next_button.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProfileInformationClass extends StatefulWidget {
  const ProfileInformationClass({
    Key? key,
    required this.nextButtonText,
    this.loggedInUser,
  }) : super(key: key);
  final User? loggedInUser;
  final String nextButtonText;

  @override
  ProfileInformationClassState createState() => ProfileInformationClassState();
}

class ProfileInformationClassState<T extends ProfileInformationClass>
    extends State<T> with WidgetsBindingObserver {
  String get nextButtonText => widget.nextButtonText;

  double get _screenHeight => MediaQuery.of(context).size.height;

  double get _buttonHeight => 30 * constants.rh(context);

  double get _datePickerHeight => _screenHeight * 1 / 3 + _buttonHeight;
  late UserInfoBloc _userInfoBloc;
  User user = User();
  TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final loggedUser = widget.loggedInUser;
    if (loggedUser != null) {
      user.copy(user: loggedUser);
    }
    final date = ProfileInfoType.date.getInitialValue(user);
    if (date != null) {
      _textEditingController = TextEditingController(
        text: DateFormat('MM/dd/yyyy').format(
          DateTime.parse(date),
        ),
      );
    }
  }

  @override
  void dispose() {
    _userInfoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserInfoBloc>(
      create: (context) => _userInfoBloc = UserInfoBloc(),
      child: BlocListener<UserInfoBloc, UserInfoState>(
        listener: _userInfoBlocListener,
        child: _render(),
      ),
    );
  }

  Widget _render() {
    return WillPopScope(
      onWillPop: () async => true,
      child: BlocBuilder<UserInfoBloc, UserInfoState>(
        builder: (context, state) {
          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                top: false,
                child: _renderFieldOnScreen(state: state),
              ));
        },
      ),
    );
  }

  Widget _renderFieldOnScreen({required UserInfoState state}) {
    return Stack(
      children: [
        Column(
          children: [
            renderAppBarWidget(),
            _renderTextFields(state: state),
          ],
        ),
        renderNextButton(
          state: state,
          text: nextButtonText,
          onPress: () {
            if (state is UserValidState) {
              nextButtonOnPress();
            }
            if (state is UserInvalidState) {
              _nextButtonOnPressedOnInvalidState();
            }
          },
        ),
      ],
    );
  }

  void _nextButtonOnPressedOnInvalidState() {
    final currentState = _formKey.currentState;
    if (currentState != null) {
      currentState.validate();
    }
  }

  Widget renderAppBarWidget() {
    return SafeArea(
      child: AppBarWidget(
        titleText: 'Profile',
        titleStyle: getStyle(weight: FontWeight.w500, fontSize: 22),
      ),
    );
  }

  Widget _renderTextFields({required UserInfoState state}) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            _renderTextField(
              state: state,
              profileInfoType: ProfileInfoType.firstName,
            ),
            _renderTextField(
              state: state,
              profileInfoType: ProfileInfoType.lastName,
            ),
            _renderDatePicker(state: state),
            _renderTextField(
              state: state,
              profileInfoType: ProfileInfoType.email,
              padding: EdgeInsets.symmetric(
                vertical: 10 * constants.rh(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderDatePicker({required UserInfoState state}) {
    return GestureDetector(
      onTap: () {
        _userInfoBloc.add(const AddBirthDateEvent());
        final currentState = _formKey.currentState;
        if (currentState != null && state is UserInvalidState) {
          currentState.reset();
        }
      },
      child: AbsorbPointer(
        child: TxtFieldWithIcon(
          controller: _textEditingController,
          prefixWidgets: ProfileInfoType.date.image(),
          label: ProfileInfoType.date.labeltext(),
          enabled: false,
          validator: (_) =>
              state is UserInvalidState ? state.error['birthDate'] : null,
          padding: EdgeInsets.only(
            top: 10 * constants.rh(context),
          ),
        ),
      ),
    );
  }

  Widget _renderTextField(
      {required UserInfoState state,
      required ProfileInfoType profileInfoType,
      EdgeInsets? padding}) {
    return TxtFieldWithIcon(
      initialValue: profileInfoType.getInitialValue(user),
      prefixWidgets: profileInfoType.image(),
      label: profileInfoType.labeltext(),
      txtType: profileInfoType.textInputText(),
      onTap: () {
        final currentState = _formKey.currentState;
        if (currentState != null && state is UserInvalidState) {
          currentState.reset();
        }
      },
      onEditingComplete: () => onComplete(
          profileInfoType: profileInfoType, userInfoBloc: _userInfoBloc),
      action: inputAction(profileInfoType: profileInfoType),
      onChange: onChange(
          profileInfoType: profileInfoType, userInfoBloc: _userInfoBloc),
      validator: (val) => state is UserInvalidState
          ? state.error[profileInfoType.error()]
          : null,
      padding: padding ??
          EdgeInsets.only(
            top: 10 * constants.rh(context),
          ),
    );
  }

  Widget renderNextButton({
    required String text,
    required Function() onPress,
    required UserInfoState state,
    bool? checkInternet,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15 * constants.rh(context)),
      alignment: Alignment.bottomCenter,
      child: NextButton(
        showLoading: _showLoading(state),
        checkInternet: checkInternet ?? true,
        isActive: state is AddingBirthDateState ||
            state is UserValidState ||
            state is UserInfoLoadingState,
        onPress: onPress,
        text: text,
        textColor: whiteColor,
      ),
    );
  }

  Future<void> _selectDate() async {
    final _dateNow = DateTime.now();

    await showModalBottomSheet<DateTime>(
      isDismissible: false,
      context: context,
      builder: (context) {
        var tempPickedDate = _stringToDate(user.birthDate) ?? _dateNow;
        return SizedBox(
          height: _datePickerHeight,
          child: Column(
            children: <Widget>[
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _stringToDate(user.birthDate) ?? _dateNow,
                  maximumDate: _dateNow,
                  minimumDate: DateTime(_dateNow.year - 101),
                  onDateTimeChanged: (DateTime dateTime) {
                    tempPickedDate = dateTime;
                  },
                ),
              ),
              SafeArea(
                child: renderNextButton(
                  checkInternet: false,
                  state: AddingBirthDateState(),
                  text: 'OK',
                  onPress: () {
                    _userInfoBloc
                        .add(ChooseBirthDateEvent(birthDate: tempPickedDate));
                    FocusManager.instance.primaryFocus?.unfocus();

                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void nextButtonOnPress() {}

  /// This function checks if state is UserInfoLoadingState
  bool _showLoading(UserInfoState state) => state is UserInfoLoadingState;

  void addUserInfoLoadingEvent() {
    _userInfoBloc.add(const UserInfoLoadingEvent());
  }

  void addUserInfoInitialEvent() {
    _userInfoBloc.add(const UserInfoInitialEvent());
  }

  void _userInfoBlocListener(context, state) {
    print(state);
    if (state is AddingBirthDateState) {
      _selectDate();
    }

    if (state is AddedBirthDateState) {
      _textEditingController.text =
          DateFormat('MM/dd/yyyy').format(state.birthDate);
      user.birthDate = state.birthDate.toUtc().toIso8601String();
      _userInfoBloc.add(UserValidationEvent(user: user));
    }
  }

  DateTime? _stringToDate(String? date) {
    if (date == null) {
      return null;
    }
    return DateTime.parse(date);
  }
}
