import 'package:equatable/equatable.dart';

abstract class DriverLicensePhotoState extends Equatable {
  @override
  List<Object> get props => [];
}

class DriverLicensePhotoInitialState extends DriverLicensePhotoState {}

class AddingLicensePhotoState extends DriverLicensePhotoState {}

class DeletingLicensePhotoState extends DriverLicensePhotoState {}

class LicensePhotoIsDeletedState extends DriverLicensePhotoState {}

class PhotoIsDownLoading extends DriverLicensePhotoInitialState {}

class PhotoIsDownLoadedState extends DriverLicensePhotoInitialState {}
