import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'live_object_detection_ssd_mobilenet/ui/home_view.dart';

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
      home: const HomeView(),
    );
  }
}
