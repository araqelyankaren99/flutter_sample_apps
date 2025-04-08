import 'dart:io';

import 'package:flutter_sample_apps/models/image_item.dart';
import 'package:equatable/equatable.dart';

abstract class DriverLicensePhotoEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AddLicensePhotoEvent extends DriverLicensePhotoEvent {}

class DeleteLicensePhotoEvent extends DriverLicensePhotoEvent {
  DeleteLicensePhotoEvent({required this.photoType});

  final PhotoType photoType;

  @override
  List<Object> get props => [photoType];
}

class OpenCameraEvent extends DriverLicensePhotoEvent {
  OpenCameraEvent({required this.photoType});

  final PhotoType photoType;

  @override
  List<Object> get props => [photoType];
}

class DownLoadImagesFromUrlsEvent extends DriverLicensePhotoEvent {
  DownLoadImagesFromUrlsEvent({required this.links});

  final List<Map<String, String>> links;

  @override
  List<Object> get props => [links];
}

class UnsaveDriverLicenseChangesEvent extends DriverLicensePhotoEvent {
  UnsaveDriverLicenseChangesEvent({required this.driverLicensePhotos});

  final Map<String, File> driverLicensePhotos;

  @override
  List<Object> get props => [driverLicensePhotos];
}
