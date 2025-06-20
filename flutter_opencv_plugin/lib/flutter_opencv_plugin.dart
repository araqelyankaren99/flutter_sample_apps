
import 'flutter_opencv_plugin_platform_interface.dart';

class FlutterOpencvPlugin {
  Future<String?> getPlatformVersion() {
    return FlutterOpencvPluginPlatform.instance.getPlatformVersion();
  }
}
