import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/loader_widget.dart';
import 'package:loader_overlay/loader_overlay.dart';

void main() {
  runApp(ChangeNotifierProvider(model: ColorNotifier(), child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const Color _overlayColor = Color(0x66636363);

  @override
  Widget build(BuildContext context) {
    final colorNotifier = ChangeNotifierProvider.watch<ColorNotifier>(context);
    final primaryColor = colorNotifier?.primaryColor ?? Color(0xFF000000);
    final secondaryColor = colorNotifier?.secondaryColor ?? Color(0xFF000000);
    return GlobalLoaderOverlay(
      useDefaultLoading: false,
      overlayColor: _overlayColor,
      overlayOpacity: 1,
      overlayWidget: Center(
        child: LoaderWidget(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _HomeScreen(),
      ),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    final overlay = context.loaderOverlay;
                    overlay.show();
                    await Future.delayed(Duration(seconds: 5));
                    if (mounted) {
                      overlay.hide();
                    }
                  },
                  child: Text('Show loader'),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                final primaryColor = _getRandomColor();
                final secondaryColor = _getRandomColor();
                ChangeNotifierProvider.read<ColorNotifier>(context)
                  ?..updatePrimaryColor(primaryColor)
                  ..updateSecondaryColor(secondaryColor);
              },
              child: Text('Update Colors'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}

class ColorNotifier extends ChangeNotifier {
  Color _primaryColor = const Color(0xFF000000);
  Color _secondaryColor = const Color(0xFF000000);

  Color get primaryColor => _primaryColor;

  Color get secondaryColor => _secondaryColor;

  void updatePrimaryColor(Color primaryColor) {
    if (primaryColor == _primaryColor) {
      return;
    }
    _primaryColor = primaryColor;
    notifyListeners();
  }

  void updateSecondaryColor(Color secondaryColor) {
    if (secondaryColor == _secondaryColor) {
      return;
    }
    _secondaryColor = secondaryColor;
    notifyListeners();
  }
}

class ChangeNotifierProvider<T extends ChangeNotifier>
    extends InheritedNotifier<T> {
  const ChangeNotifierProvider({
    super.key,
    required T model,
    required super.child,
  }) : super(notifier: model);

  static T? watch<T extends ChangeNotifier>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ChangeNotifierProvider<T>>()
        ?.notifier;
  }

  static T? read<T extends ChangeNotifier>(BuildContext context) {
    final widget =
        context
            .getElementForInheritedWidgetOfExactType<
            ChangeNotifierProvider<T>
        >()
            ?.widget;
    if (widget is ChangeNotifierProvider<T>) {
      return widget.notifier;
    } else {
      return null;
    }
  }
}