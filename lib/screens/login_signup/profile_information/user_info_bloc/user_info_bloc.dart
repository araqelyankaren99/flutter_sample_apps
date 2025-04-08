import 'dart:async';
import 'dart:io';

import 'package:flutter_sample_apps/middlewares/repositories/driver_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/validation_repository.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_state.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/profile_information/photo_information.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as join;
import 'package:path_provider/path_provider.dart';

class UserInfoBloc extends Bloc<UserInfoEvent, UserInfoState> {
  UserInfoBloc() : super(UserInfoInitialState());
  final ValidationRepository _validationRepository = ValidationRepository();
  final GraphQlRepository _graphQlRepository = GraphQlRepository();
  final DriverRepository _driverRepository = DriverRepository();
  List _cities = [];
  File image = File('');
  StreamSubscription? _subscription;
  bool _selectImage = false;
  String? _adminPhoneNumber = '';
  String? get adminPhoneNumber => _adminPhoneNumber;

  @override
  Stream<UserInfoState> mapEventToState(UserInfoEvent event) async* {
    if (event is UserInfoInitialEvent) {
      yield UserInfoInitialState();
    }
    if (event is AddBirthDateEvent) {
      yield AddingBirthDateState();
    }
    if (event is ChooseBirthDateEvent) {
      yield AddedBirthDateState(birthDate: event.birthDate);
    }
    if (event is DriverValidationEvent) {
      yield* driverValidationEventToState(event);
    }
    if (event is AddPhotoEvent) {
      yield AddingPhotoState();
    }
    if (event is ChoosePhotoEvent) {
      yield* choosePhotoEventToState(event);
    }
    if (event is LoadUserCityEvent) {
      yield* loadUserCityEventToState(event);
    }
    if (event is ChoosingUserCityEvent) {
      yield CityIsChoosedState(city: event.city);
      yield UserInfoInitialState();
    }
    if (event is PhotoIsAdded) {
      yield AddedPhotoState(image: image);
    }
    if (event is LoadCitiesEvent) {
      await _loadCities();
    }
    if (event is UnselectedImageEvent) {
      if (!_selectImage) {
        yield UnselectedImageState();
      }
    }

    if (event is DownLoadImage) {
      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File(join.join(documentDirectory.path, 'document.png'))
        ..writeAsBytesSync(event.bytes);
      yield AddedPhotoState(image: file, isDownLoaded: true);
    }
    if (event is GetAdminPhoneNumberEvent) {
      yield* getAdminPhoneNumberEventToState(event);
    }
  }

  Stream<UserInfoState> driverValidationEventToState(
      DriverValidationEvent event,) async* {
    yield UserInfoLoadingState();
    var errorMessages = <String, String>{};
    final driver = event.driver;

    if (!_validationRepository.isFilled(driver.firstName)) {
      errorMessages['firstName'] = 'First name must not be empty ';
    }
    if (!_validationRepository.isFilled(driver.lastName)) {
      errorMessages['lastName'] = 'Last name must not be empty';
    }

    if (!_validationRepository.isFilledBirthDate(driver.birthDate)) {
      errorMessages['birthDate'] = 'Birthday must not be empty';
    }
    if (!_validationRepository.isEmail(driver.email)) {
      errorMessages['email'] = 'Incorrect email';
    }
    if ((driver.city ?? '').isEmpty) {
      errorMessages['city'] = 'City must not be empty';
    }
    if (driver.profileImage == null) {
      errorMessages['photo'] = 'Photo must not be empty';
    }
    if (!_validationRepository.isDocumnetsIsUploaded(driver)) {
      errorMessages['driverLicense'] = 'Please upload your documents';
    }

    if (errorMessages.isNotEmpty) {
      yield DriverInvalidState(error: errorMessages);
      errorMessages = <String, String>{};
      return;
    }

    yield DriverValidState();
  }

  Stream<UserInfoState> choosePhotoEventToState(ChoosePhotoEvent event) async* {
    if (event.direction == PhotoDirection.camera) {
      await _subscription?.cancel();
      _subscription = await _addPhoto(ImageSource.camera);
    } else {
      await _subscription?.cancel();
      _subscription = await _addPhoto(ImageSource.gallery);
    }
  }

  Stream<UserInfoState> getAdminPhoneNumberEventToState(
      GetAdminPhoneNumberEvent event,) async* {
    try {
      _adminPhoneNumber = await _graphQlRepository.getAdminPhoneNumber();
      yield GetAdminPhoneNumberState();
    } catch (e) {
      yield GetPhoneNumberErrorState();
    }
  }

  Stream<UserInfoState> loadUserCityEventToState(
      LoadUserCityEvent event,) async* {
    yield UserFieldLoadingState();
    if (_cities.isEmpty) {
      await _loadCities();
    }
    yield AddingUserCityState(cities: _cities);
  }

  Future<void> _loadCities() async {
    try {
      final queryResult = await _graphQlRepository.getCitiesByCountry(
          token: await _driverRepository.getToken(),
          country: 'United States of America',);

      final citiesData = queryResult.data;
      if (citiesData != null) {
        final citiesList = citiesData['getCountry'][0]['city'] as List<dynamic>;
        _cities = citiesList;
      }
    } catch (e) {
      return;
    }
  }

  ///  This function open camera or gallery for adding image
  Future<StreamSubscription<dynamic>>? _addPhoto(ImageSource source) async {
    return ImagePicker()
        .pickImage(source: source, imageQuality: 25)
        .asStream()
        .listen((photos) async {
      final photo = photos;
      if (photo != null) {
        image = await _cropImage(File(photo.path));
        _subscription?.cancel();
      }
      if (_selectImage) {
        add(PhotoIsAdded());
      }
    });
  }

  ///This function crop image
  Future<File> _cropImage(File cropFile) async {
    _selectImage = false;
    final croppedFile = await ImageCropper().cropImage(
        sourcePath: cropFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        // aspectRatioPresets: const [CropAspectRatioPreset.square],
    );
    if (croppedFile != null) {
      _selectImage = true;
    }
    return File(croppedFile!.path);
  }
}
