import 'package:flutter/material.dart';

import 'live_location/live_location_receiver_screen.dart';
import 'live_location/live_location_sender_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Location',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Location')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            FilledButton.icon(
              onPressed: () => _open(context, const LiveLocationSenderScreen()),
              icon: const Icon(Icons.share_location),
              label: const Text('Share my location'),
            ),
            OutlinedButton.icon(
              onPressed: () => _open(context, const LiveLocationReceiverScreen()),
              icon: const Icon(Icons.location_searching),
              label: const Text('Track a location'),
            ),
          ],
        ),
      ),
    );
  }
}
