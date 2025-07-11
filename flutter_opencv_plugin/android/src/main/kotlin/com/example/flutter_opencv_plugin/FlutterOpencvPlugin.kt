package com.example.flutter_opencv_plugin

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** FlutterOpencvPlugin */
class FlutterOpencvPlugin : FlutterPlugin {
  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    // No method channel setup needed since FFI is used
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    // Cleanup if needed
  }
}