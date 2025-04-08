import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionRepository {
  Future<bool> hasConnection() async {
    final isDeviceConnected = await Connectivity().checkConnectivity();
    if (isDeviceConnected != ConnectivityResult.none) {
      return true;
    }
    return false;
  }
}
