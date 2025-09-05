import 'package:dob_autocomplete_field/dob_autocomplete_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final formattersList = <String>[
    'YYMMDD',
    'MMDDYY',
    'YYYYMMDD',
    'DDMMYYYY',
    'DDMMYYYY',
    'MMDDYYYY',
    'DDMMYY',
    'YYMMMDD',
    'DDMMMYY',
    'MMMDDYY',
    'YYYYMMMDD',
    'DDMMMYYYY',
    'MMMDDYYYY',
    'YY/MM/DD',
    'DD/MM/YY',
    'MM/DD/YY',
    'YYYY/MM/DD',
    'DD/MM/YYYY',
    'MM/DD/YYYY',
    'YY/MMM/DD',
    'DD/MMM/DD',
    'MMM/DD/YY',
    'YYYY/MMM/DD',
    'DD/MMM/YY',
    'MMM/DD/YY',
    'YYYY/MMM/DD',
    'DD/MMM/YYYY',
    'MMM/DD/YYYY',
    'MMM/DD/YYYY',
    'YYYY-MM-DD',
    'YYYY-MM',
    'YYYY',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _hideKeyboard,
        child: Center(
          child: ListView(
            children:
              formattersList.indexed.map((entry) {
                final index = entry.$1;
                final formatter = entry.$2;

                return Padding(
                  padding: EdgeInsets.all(10),
                  child: DobAutocompleteField(
                    dobFormatter: formatter,
                    onFilledChanged: (bool isFilled) {
                      debugPrint('DOB field N$index is ${isFilled ? 'filled' : 'not filled'}');
                    },
                    onChanged: (String value) {
                      debugPrint('DOB field N$index changed $value');
                    },
                    onFullyDeleted: () {
                      debugPrint('DOB field N$index is fully deleted');
                    },
                  ),
                );
              }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _hideKeyboard() async{
    FocusScope.of(context).unfocus();
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}