import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/object_detection_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.mediaLibrary.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ObjectDetectionScreen(),
    );
  }
}

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  State<ObjectDetectionScreen> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  final _imagePicker = ImagePicker();
  String? _imagePath;
  @override
  void initState() {
    super.initState();
    _handleImage();
  }

  Future<void> _handleImage() async{
   final galleryImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    if(galleryImage == null){
      return;
    }
   final directory = await getTemporaryDirectory();
   final appTempDirectoryPath = directory.path;
   final tempFilePath = '$appTempDirectoryPath/temp.jpeg';
   final objectDetector = MyObjectDetector();
   await objectDetector.loadModel();
   final edgeDetectionResult = await objectDetector.detectAndCropImage(galleryImage.path, tempFilePath);
   print('edgeDetectionResult = $edgeDetectionResult');
   setState(() {
     _imagePath = tempFilePath;
   });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _imagePath == null ? SizedBox.shrink() :
        Image.file(File(_imagePath ?? '')),
      ),
    );
  }
}
