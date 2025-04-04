import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/middlewares/connectivity/internet_notifier.dart';

class ConnectivityWidget extends StatefulWidget {
  const ConnectivityWidget({Key? key}) : super(key: key);

  @override
  State<ConnectivityWidget> createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: InternetNotifier.internetNotifier,
      builder: (context, hasInternet, child) {
        print('haz internet -> $hasInternet');
        return SafeArea(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: Colors.red,
            height: hasInternet ? 0 : 30,
            width: double.infinity,
            child: const Center(
              child: Text('Internet connection not available!'),
            ),
          ),
        );
      },
    );
  }
}
