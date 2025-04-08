import 'dart:io';
import 'package:flutter_sample_apps/models/attachment.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ApiRepository {
  /// This function return true , if the image is uploaded
  Future<bool> uploadImageToServer(
      {required String downloadUrl,
      required String uploadUrl,
      required String contentType,
      required File imageFile,
      required String name,
      required Attachment attachment,}) async {
    final image = imageFile;
    try {
      final response = await http.put(Uri.parse(uploadUrl),
          headers: {'Content-Type': contentType},
          body: image.readAsBytesSync(),);
      if (response.statusCode == 200) {
        attachment.downloadLink?.add({name: downloadUrl});
        attachment.uploadLink?.add({name: uploadUrl});
        return true;
      }
      return false;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return false;
    }
  }

  /// This function download files from server
  Future<File?> download(Map<String, String> link) async {
    try {
      final _link = link.values.first;
      final url = Uri.parse(_link);
      final client = HttpClient();
      final request = await client.getUrl(url);
      request.persistentConnection = false;
      final response = await request.close();
      final responseBytes = (await response.toList()).expand((x) => x).toList();
      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File(join(documentDirectory.path, '${link.keys.first}.png'))
        ..writeAsBytesSync(responseBytes);
      client.close();
      return file;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return null;
    }
  }
}
