import 'dart:io';

import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:mime/mime.dart';

class ImageItem {
  ImageItem({this.file, this.type, this.mimeType, this.attachment});
  File? file;
  PhotoType? type;
  String? mimeType;
  Map<String, String>? attachment;
  void setMimoType() {
    final _file = file;
    if (file != null) {
      mimeType = lookupMimeType(_file!.path);
    }
  }

  /// Return false if at least one field is null
  bool isEmpty() {
    return file == null &&
        type == null &&
        mimeType == null &&
        attachment == null;
  }

  /// Set upload and download links for this image
  Future<void> setAttachment(
      {required GraphQlRepository graphQlRepository,
      required String token,}) async {
    final contentType = mimeType;
    if (contentType != null) {
      final _type = type;
      if (_type != null) {
        try {
          final queryResult = await graphQlRepository.getLinks(
              token: token, contentType: contentType, name: _type.typeName(),);

          final data = queryResult.data;
          if (data != null) {
            final createAttachment = data['createAttachment'];
            attachment = {
              'uploadLink': createAttachment['uploadLink'] as String,
              'downloadLink': createAttachment['downloadLink'] as String
            };
          }
        } catch (e) {
          return;
        }
      }
    }
  }
}

enum PhotoType { profile, driverLicenseFront, driverLicenseBack }

extension PhotoTypeAddition on PhotoType {
  String typeName() {
    switch (this) {
      case PhotoType.profile:
        return 'profileImage';
      case PhotoType.driverLicenseFront:
        return 'driverLicenseFront';
      case PhotoType.driverLicenseBack:
        return 'driverLicenseBack';
    }
  }

  String uiName() {
    switch (this) {
      case PhotoType.profile:
        return 'Profile';
      case PhotoType.driverLicenseFront:
        return 'Front Side';
      case PhotoType.driverLicenseBack:
        return 'Back Side';
    }
  }
}
