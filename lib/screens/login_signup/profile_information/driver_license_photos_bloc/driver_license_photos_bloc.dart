import 'dart:async';
import 'dart:io';
import 'package:flutter_sample_apps/middlewares/repositories/api_repository.dart';
import 'package:flutter_sample_apps/models/image_item.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/driver_license_photos_bloc/driver_license_photos_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/driver_license_photos_bloc/driver_license_photos_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class DriverLicensePhotoBloc
    extends Bloc<DriverLicensePhotoEvent, DriverLicensePhotoState> {
  DriverLicensePhotoBloc() : super(DriverLicensePhotoInitialState());

  Map<String, File> get licensePhoto => _licensePhoto;

  final Map<String, File> _licensePhoto = {};
  final _apiRepository = ApiRepository();
  StreamSubscription? _subscription;

  @override
  Stream<DriverLicensePhotoState> mapEventToState(
      DriverLicensePhotoEvent event,) async* {
    if (event is OpenCameraEvent) {
      yield* openCameraEventToState(event);
    }
    if (event is DownLoadImagesFromUrlsEvent) {
      yield PhotoIsDownLoading();
      for (final map in event.links) {
        final file = await _apiRepository.download(map);
        if (file != null) {
          if (map.keys.first.contains('driverLicense')) {
            _licensePhoto[map.keys.first] = file;
          }
        }
      }
      yield PhotoIsDownLoadedState();
      yield DriverLicensePhotoInitialState();
    }
    if (event is UnsaveDriverLicenseChangesEvent) {
      _licensePhoto
        ..clear()
        ..addAll(event.driverLicensePhotos);
      yield DriverLicensePhotoInitialState();
    }
    if (event is AddLicensePhotoEvent) {
      yield AddingLicensePhotoState();
      yield DriverLicensePhotoInitialState();
    }
    if (event is DeleteLicensePhotoEvent) {
      _licensePhoto.remove(event.photoType.typeName());
      yield DeletingLicensePhotoState();
      yield DriverLicensePhotoInitialState();
    }
  }

  Stream<DriverLicensePhotoState> openCameraEventToState(
      OpenCameraEvent event,) async* {
    await _subscription?.cancel();
    _subscription = ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50)
        .asStream()
        .listen((photos) {
      final photo = photos;
      if (photo != null) {
        _licensePhoto[event.photoType.typeName()] = File(photo.path);
      }
      add(AddLicensePhotoEvent());
    });
  }
}
