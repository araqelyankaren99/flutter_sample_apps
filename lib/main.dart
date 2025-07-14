import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      builder: (_, child) => TopNotificationManagerWidget(child: child),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showOverlay,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void showOverlay() {
    final text = Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(child: Text('The lecture has been added'),),
    );
    context.read<TopNotificationManager>().show('Hello my friend');
  }
}

class TopNotificationOverlayWidget extends StatefulWidget {
  const TopNotificationOverlayWidget({super.key});

  @override
  State<TopNotificationOverlayWidget> createState() =>
      TopNotificationOverlayWidgetState();
}

class TopNotificationOverlayWidgetState
    extends State<TopNotificationOverlayWidget> {
  static const _showedOffset = Offset(0, 0);
  static const _hidedOffset = Offset(0, -1);

  Timer? _timer;
  var _text = "";
  var _offset = _hidedOffset;
  final List<String> _textsQueue = <String>[];

  bool get isHidien => _offset == _hidedOffset;

  void show(String text) {
    if (!isHidien) {
      _timer?.cancel();
      _timer = null;
      _textsQueue.add(text);
      _hideWidget();
    } else {
      _showWidget(text);
    }
  }

  void _showWidget(String text) {
    setState(() {
      _text = text;
      _offset = _showedOffset;
    });
    _timer = Timer(const Duration(seconds: 5), () {
      _timer = null;
      _hideWidget();
    });
  }

  void _hideWidget() {
    setState(() {
      _offset = _hidedOffset;
    });
  }

  void _onAnimationEnd() {
    if (_textsQueue.isEmpty || !isHidien) {
      return;
    }
    final text = _textsQueue.first;
    _textsQueue.removeAt(0);
    _showWidget(text);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 150),
        offset: _offset,
        onEnd: _onAnimationEnd,
        child: Material(
          child: Container(
            padding: EdgeInsets.only(top: topPadding),
            color: Colors.green,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Text(
                  _text,
                  style :TextStyle(color: Colors.black),
                  maxLines: null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract class TopNotificationManager {
  void show(String text);
}

class TopNotificationManagerWidget extends StatefulWidget {
  final Widget? child;
  const TopNotificationManagerWidget({
    super.key,
    this.child,
  });

  @override
  State<TopNotificationManagerWidget> createState() => _TopNotificationManagerWidgetState();
}

class _TopNotificationManagerWidgetState
    extends State<TopNotificationManagerWidget>
    implements TopNotificationManager {
  final _topNotificationOverlayKey =
  GlobalKey<TopNotificationOverlayWidgetState>();
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    final child = widget.child;
    if (child != null) {
      children.add(child);
    }
    final topNotificationOverlayWidget = TopNotificationOverlayWidget(
      key: _topNotificationOverlayKey,
    );
    children.add(topNotificationOverlayWidget);
    return Provider<TopNotificationManager>.value(
      value: this,
      child: Stack(
        children: children,
      ),
    );
  }

  @override
  void show(String text) {
    _topNotificationOverlayKey.currentState?.show(text);
  }
}