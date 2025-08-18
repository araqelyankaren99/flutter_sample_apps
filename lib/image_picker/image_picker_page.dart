import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/open_cv/doc_detector_interface.dart';
import 'package:flutter_sample_apps/result_screen.dart';
import 'package:flutter_sample_apps/utils/util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({super.key});

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  late String _appTempDirectoryPath;
  bool _isLoading = true;

  Future<void> _init() async {
    final directory = await getTemporaryDirectory();
    _appTempDirectoryPath = directory.path;
    _isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _onTap,
                  child: Text('Get media library image'),
                ),
      ),
    );
  }

  Future<void> _onTap() async {
    try {
      _isLoading = true;
      setState(() {});
      final permissionStatus = await Permission.mediaLibrary.request();
      if (!permissionStatus.isGranted) {
        return;
      }
      final captureImageFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      final captureImageFilePath = captureImageFile?.path;
      if (captureImageFilePath == null) {
        return;
      }
      if (!mounted || captureImageFilePath.isEmpty) {
        return;
      }

      imageCache.clear();
      final tempFilePath = '$_appTempDirectoryPath/temp.jpeg';
      final edgeDetectionResult = await OpenCvEdgeDetector()
          .detectDocumentEdgesTest(captureImageFilePath, tempFilePath);
      if (edgeDetectionResult == null) {
        return;
      }
      if (!mounted) {
        return;
      }
      await rotateImage(File(tempFilePath), angle: 270);
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultScreen(croppedFilePath: tempFilePath),
        ),
      );
    }
    finally {
      _isLoading = false;
      setState(() {});
    }
  }
}
