import 'package:flutter_sample_apps/middlewares/repositories/api_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/driver_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/models/attachment.dart';
import 'package:flutter_sample_apps/models/image_item.dart';

class ImageRepository {
  final _apiRepository = ApiRepository();
  final _driverRepository = DriverRepository();
  final _graphQlRepository = GraphQlRepository();
  Future<bool> uploadImage(
      {required ImageItem image, required Attachment attachment,}) async {
    _setType(image: image);
    await _setAttachment(image: image);
    final isEmpty = _chekImage(image: image);
    if (!isEmpty) {
      final isUploaded =
          await _uploadImageToServer(image: image, attachment: attachment);
      if (isUploaded) {
        return true;
      }
    }
    return false;
  }

  Future<bool> _uploadImageToServer(
      {required ImageItem image, required Attachment attachment,}) async {
    final _attachment = image.attachment;
    final type = image.type;
    if (_attachment != null && type != null) {
      final downloadLink = _attachment['downloadLink'];
      final uploadUrl = _attachment['uploadLink'];
      final contentType = image.mimeType;
      final imageFile = image.file;
      final name = type.typeName();
      if (downloadLink != null &&
          uploadUrl != null &&
          contentType != null &&
          imageFile != null) {
        final isUploaded = await _apiRepository.uploadImageToServer(
            downloadUrl: downloadLink,
            uploadUrl: uploadUrl,
            contentType: contentType,
            imageFile: imageFile,
            name: name,
            attachment: attachment,);
        if (!isUploaded) {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }

    return true;
  }

  void _setType({required ImageItem image}) {
    image.setMimoType();
  }

  bool _chekImage({required ImageItem image}) {
    if (image.isEmpty()) {
      return true;
    }
    return false;
  }

  Future<void> _setAttachment({required ImageItem image}) async {
    final token = await _driverRepository.getToken();
    await image.setAttachment(
        graphQlRepository: _graphQlRepository, token: token,);
  }
}
