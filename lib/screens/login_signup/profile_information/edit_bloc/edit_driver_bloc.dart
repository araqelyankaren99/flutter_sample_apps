import 'dart:async';
import 'package:flutter_sample_apps/constants.dart';
import 'package:flutter_sample_apps/middlewares/repositories/driver_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/image_repository.dart';
import 'package:flutter_sample_apps/models/attachment.dart';
import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/models/image_item.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/edit_bloc/edit_driver_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/edit_bloc/edit_driver_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditDriverBloc extends Bloc<EditDriverEvent, EditDriverState> {
  EditDriverBloc() : super(EditDriverInitialState());
  final _graphQlRepository = GraphQlRepository();
  final _imageRepository = ImageRepository();
  final _driverRepository = DriverRepository();
  int _isUploadedCount = 0;

  @override
  Stream<EditDriverState> mapEventToState(EditDriverEvent event) async* {
    if (event is EditDriver) {
      yield* editDriverEventToState(event);
    }
    if (event is CheckIsProve) {
      final isProve = await isEditable(await _driverRepository.getToken());
      if (isProve != null) {
        yield IsEditableState(isProve: isProve);
      } else {
        yield IsEditableState(isProve: false);
      }
    }
  }

  Stream<EditDriverState> editDriverEventToState(
    EditDriver event,
  ) async* {
    _isUploadedCount = 0;
    yield EditDriverLoadingState();
    final driver = event.driver;
    try {
      final queryResult =
          await _graphQlRepository.editDriverProfile(driver: driver);
      yield* _uploadImages(driver: driver);
      if (_isUploadedCount == driverImagesCount) {
        final data = queryResult.data;
        if (data != null) {
          final id = data['editDriverProfile']['id'] as String;
          yield DriverIsEditedState(id: id);
          return;
        }
      }
    } catch (e) {
      yield DriverEditErrorState(message: e.toString());
    }
  }

  Stream<EditDriverState> _uploadImages({required Driver driver}) async* {
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
            yield EditLoadingIndicator(
                precent: oneImagePercentage * _isUploadedCount,);
          }
        }
      }
      driver.attachment = attachment;
    }
  }

  /// Check is editable driver or not
  Future<bool?> isEditable(String token) async {
    try {
      final queryResult = await _graphQlRepository.driverIsEditable(token);

      final data = queryResult.data;
      if (data != null) {
        if (data['thisDriver'] == null) {
          return null;
        }
        final isEditable = data['thisDriver']['isProved'] as bool;
        return isEditable;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
