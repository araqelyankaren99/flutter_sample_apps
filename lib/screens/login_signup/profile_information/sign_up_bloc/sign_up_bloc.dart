import 'dart:async';
import 'package:flutter_sample_apps/constants.dart';
import 'package:flutter_sample_apps/middlewares/repositories/driver_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/image_repository.dart';
import 'package:flutter_sample_apps/models/attachment.dart';
import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/models/image_item.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/sign_up_bloc/sign_up_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/sign_up_bloc/sign_up_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(SignUpInitialState());
  final _graphQlRepository = GraphQlRepository();
  final _imageRepository = ImageRepository();
  final _driverRepository = DriverRepository();
  StreamSubscription? _subscription;
  int _isUploadedCount = 0;

  @override
  Stream<SignUpState> mapEventToState(SignUpEvent event) async* {
    if (event is CreateDriverEvent) {
      yield* createDriverEventToState(event);
    }
    if (event is ListenDriverActivationEvent) {
      yield* listenDriverActivationEventToState(event);
    }
    if (event is DriverActivationChangeEvent) {
      yield event.state;
    }
    if (event is DriverIsAlreadyCreatedEvent) {
      final id = event.driver.id;
      if (id != null) {
        yield DriverCreatedState(id: id);
      }
    }
  }

  Stream<SignUpState> createDriverEventToState(
    CreateDriverEvent event,
  ) async* {
    yield SignUpLoadingState();
    try {
      final driver = event.driver
        ..phone = await _driverRepository.getPhoneNumber();
      final token = await _driverRepository.getToken();
      final queryResult = await _graphQlRepository.createDriverProfile(
          token: token, driver: driver,);

      yield* _uploadImages(driver: driver);
      if (_isUploadedCount == driverImagesCount) {
        final data = queryResult.data;
        if (data != null) {
          final id = data['createDriverProfile']['id'] as String;
          yield DriverCreatedState(id: id, firstTimeCreated: true);
          return;
        }
      }
    } catch (e) {
      yield DriverCreateErrorState(message: e.toString());
    }
  }

  Stream<SignUpState> _uploadImages({required Driver driver}) async* {
    final profileImage = driver.profileImage;
    final drivingLicenseImage = driver.drivingLicensePhotos;

    if (profileImage != null && drivingLicenseImage != null) {
      final drivingLicenseImageFront =
          drivingLicenseImage[PhotoType.driverLicenseFront.typeName()];
      final drivingLicenseImageBack =
          drivingLicenseImage[PhotoType.driverLicenseBack.typeName()];

      final images = [
        ImageItem(file: profileImage, type: PhotoType.profile),
        ImageItem(
            file: drivingLicenseImageFront,
            type: PhotoType.driverLicenseFront,),
        ImageItem(
            file: drivingLicenseImageBack, type: PhotoType.driverLicenseBack,),
      ];
      final attachment = Attachment(uploadLink: [], downloadLink: []);
      for (final image in images) {
        final isUploaded = await _imageRepository.uploadImage(
            image: image, attachment: attachment,);
        {
          if (isUploaded) {
            _isUploadedCount++;
            yield LoadingIndicatorState(
                percent: oneImagePercentage * _isUploadedCount,);
          }
        }
      }
      driver.attachment = attachment;
    }
  }

  Stream<SignUpState> listenDriverActivationEventToState(
      ListenDriverActivationEvent event,) async* {
    await _subscription?.cancel();
    final token = await _driverRepository.getToken();
    _subscription =
        _graphQlRepository.subscribeToDriverActivation(token: token).listen((
      result,
    ) {
      if (result.hasException) {
        return;
      }
      if (result.isLoading) {
        return;
      }
      final data = result.data;
      if (data != null) {
        final driverStatusChanged = data['driverStatusChanged'];
        final isActive = driverStatusChanged['isActivated'] as bool;
        final isProve = driverStatusChanged['isProved'] as bool;
        SignUpState state = DriverIsNotActivateState();
        if (isActive) {
          state = DriverIsActivateState();
          _subscription?.cancel();
        } else if (isProve) {
          state = DriverIsEditableState();
          _subscription?.cancel();
        }
        add(DriverActivationChangeEvent(state: state));
      }
    }, onDone: () async => await _subscription?.cancel(),);
  }
}
