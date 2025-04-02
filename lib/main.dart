import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/screens/example_1_map_rendering.dart';
import 'package:flutter_sample_apps/screens/example_2_custom_markers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: const [
              _Example1RenderingButton(),
              _Example2CustomMarkersButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Example1RenderingButton extends StatelessWidget {
  const _Example1RenderingButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Map Rendering'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example1MapRenderingScreen()));
  }
}

class _Example2CustomMarkersButton extends StatelessWidget {
  const _Example2CustomMarkersButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Custom Markers'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example2CustomMarkersScreen()));
  }
}


