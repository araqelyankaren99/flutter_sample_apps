import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/camera_processing_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    this.croppedFilePath,
    this.borderRadius = 10,
    this.borderColor = const Color(0xFF34B6FF),
    this.width = 3,
  });

  final String? croppedFilePath;
  final double borderRadius;
  final Color borderColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      croppedFilePath == null
          ? const SizedBox.shrink()
          : GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CameraProcessingScreen())),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Stack(
                children: [
                  Image.file(File(croppedFilePath!), fit: BoxFit.contain),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(
                          color: borderColor,
                          width: width,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}