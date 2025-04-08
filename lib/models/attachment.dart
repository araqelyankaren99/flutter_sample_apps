class Attachment {
  Attachment({this.downloadLink, this.uploadLink});

  factory Attachment.fromJson(List json) {
    final downloads = <Map<String, String>>[];
    final uploads = <Map<String, String>>[];
    // ignore: avoid_function_literals_in_foreach_calls
    json.forEach((value) {
      downloads.add({value['name'] as String: value['downloadLink'] as String});
      uploads.add({value['name'] as String: value['uploadLink'] as String});
    });
    return Attachment(downloadLink: downloads, uploadLink: uploads);
  }

  List<Map<String, String>>? uploadLink;
  List<Map<String, String>>? downloadLink;
}
