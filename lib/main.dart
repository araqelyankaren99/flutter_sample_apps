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
    // Numeric formats
    'YYMMDD', 'MMDDYY', 'YYYYMMDD', 'DDMMYYYY', 'MMDDYYYY', 'DDMMYY',
    'YYYYMM', 'YYYY', 'YYYY-MM-DD', 'YYYY-MM', 'DD-MM-YYYY', 'MM-DD-YYYY',
    'DD-MM-YY', 'MM-DD-YY', 'YY-MM-DD', 'DD/MM/YYYY', 'MM/DD/YYYY',
    'DD/MM/YY', 'MM/DD/YY', 'YY/MM/DD', 'YYYY/MM/DD', 'YYYY/MM',
    'DD.MM.YYYY', 'MM.DD.YYYY', 'DD.MM.YY', 'MM.DD.YY', 'YY.MM.DD', 'YYYY.MM.DD',

    // Abbreviated month names (MMM)
    'YYMMMDD', 'DDMMMYY', 'MMMDDYY', 'YYYYMMMDD', 'DDMMMYYYY', 'MMMDDYYYY',
    'YY/MMM/DD', 'DD/MMM/YY', 'MMM/DD/YY', 'YYYY/MMM/DD', 'DD/MMM/YYYY', 'MMM/DD/YYYY',
    'YY-MMM-DD', 'DD-MMM-YY', 'MMM-DD-YY', 'YYYY-MMM-DD', 'DD-MMM-YYYY', 'MMM-DD-YYYY',
    'YY MMM DD', 'DD MMM YY', 'MMM DD YY', 'YYYY MMM DD', 'DD MMM YYYY', 'MMM DD YYYY',

    // Abbreviated month lowercase
    'YYmmmDD', 'DDmmmYY', 'mmmDDYY', 'YYYYmmmDD', 'DDmmmYYYY', 'mmmDDYYYY',
    'YY/mmm/DD', 'DD/mmm/YY', 'mmm/DD/YY', 'YYYY/mmm/DD', 'DD/mmm/YYYY', 'mmm/DD/YYYY',
    'YY-mmm-DD', 'DD-mmm-YY', 'mmm-DD-YY', 'YYYY-mmm-DD', 'DD-mmm-YYYY', 'mmm-DD-YYYY',
    'YY mmm DD', 'DD mmm YY', 'mmm DD YY', 'YYYY mmm DD', 'DD mmm YYYY', 'mmm DD YYYY',

    // Abbreviated month uppercase
    'YYMMMDD', 'DDMMMYY', 'MMMDDYY', 'YYYYMMMDD', 'DDMMMYYYY', 'MMMDDYYYY',
    'YY/MMM/DD', 'DD/MMM/YY', 'MMM/DD/YY', 'YYYY/MMM/DD', 'DD/MMM/YYYY', 'MMM/DD/YYYY',
    'YY-MMM-DD', 'DD-MMM-YY', 'MMM-DD-YY', 'YYYY-MMM-DD', 'DD-MMM-YYYY', 'MMM-DD-YYYY',
    'YY MMM DD', 'DD MMM YY', 'MMM DD YY', 'YYYY MMM DD', 'DD MMM YYYY', 'MMM DD YYYY',

    // Full month names (MMMM)
    'YYMMMMDD', 'DDMMMMYY', 'MMMMDDYY', 'YYYYMMMMDD', 'DDMMMMYYYY', 'MMMMDDYYYY',
    'YY/MMMM/DD', 'DD/MMMM/YY', 'MMMM/DD/YY', 'YYYY/MMMM/DD', 'DD/MMMM/YYYY', 'MMMM/DD/YYYY',
    'YY-MMMM-DD', 'DD-MMMM-YY', 'MMMM-DD-YY', 'YYYY-MMMM-DD', 'DD-MMMM-YYYY', 'MMMM-DD-YYYY',
    'YY MMMM DD', 'DD MMMM YY', 'MMMM DD YY', 'YYYY MMMM DD', 'DD MMMM YYYY', 'MMMM DD YYYY',

    // Full month lowercase
    'YYmmmmDD', 'DDmmmmYY', 'mmmmDDYY', 'YYYYmmmmDD', 'DDmmmmYYYY', 'mmmmDDYYYY',
    'YY/mmmm/DD', 'DD/mmmm/YY', 'mmmm/DD/YY', 'YYYY/mmmm/DD', 'DD/mmmm/YYYY', 'mmmm/DD/YYYY',
    'YY-mmmm-DD', 'DD-mmmm-YY', 'mmmm-DD-YY', 'YYYY-mmmm-DD', 'DD-mmmm-YYYY', 'mmmm-DD-YYYY',
    'YY mmmm DD', 'DD mmmm YY', 'mmmm DD YY', 'YYYY mmmm DD', 'DD mmmm YYYY', 'mmmm DD YYYY',

    // Full month uppercase
    'YYMMMMDD', 'DDMMMMYY', 'MMMMDDYY', 'YYYYMMMMDD', 'DDMMMMYYYY', 'MMMMDDYYYY',
    'YY/MMMM/DD', 'DD/MMMM/YY', 'MMMM/DD/YY', 'YYYY/MMMM/DD', 'DD/MMMM/YYYY', 'MMMM/DD/YYYY',
    'YY-MMMM-DD', 'DD-MMMM-YY', 'MMMM-DD-YY', 'YYYY-MMMM-DD', 'DD-MMMM-YYYY', 'MMMM-DD-YYYY',
    'YY MMMM DD', 'DD MMMM YY', 'MMMM DD YY', 'YYYY MMMM DD', 'DD MMMM YYYY', 'MMMM DD YYYY',
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