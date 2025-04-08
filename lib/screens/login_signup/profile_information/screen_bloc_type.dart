enum ScreenBlocType {
  signUpBloc,
  profileInformationBloc,
}

extension ScreenBlocTypeExtension on ScreenBlocType {
  String nextButtonText() {
    switch (this) {
      case ScreenBlocType.signUpBloc:
        return 'Next';
      case ScreenBlocType.profileInformationBloc:
        return 'Save';
    }
  }
}
