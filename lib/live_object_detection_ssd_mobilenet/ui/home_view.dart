import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/live_object_detection_ssd_mobilenet/models/screen_params.dart';
import 'package:flutter_sample_apps/live_object_detection_ssd_mobilenet/ui/detector_widget.dart';

/// [HomeView] stacks [DetectorWidget]
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenParams.screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: const DetectorWidget(),
    );
  }
}