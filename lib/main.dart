import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await RiveNative.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  static const _riveUrl = 'asssets/login_animation.riv';
  SMITrigger? _failTrigger;
  SMITrigger? _successTrigger;
  SMIBool? _isHandsUp;
  SMIBool? _isChecking;
  SMINumber? _lookNumber;
  StateMachineController? _stateMachineController;
  Artboard? _artboard;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _init() async {
    final byteData = await rootBundle.load(_riveUrl);
    final file = RiveFile.import(byteData);
    final art = file.mainArtboard;
    _stateMachineController = StateMachineController.fromArtboard(
        art,
      'Login Machine',
    );

    if(_stateMachineController != null){
      art.addController(_stateMachineController!);
      _stateMachineController.inputs.forEach((element){
        if(element.name == 'isChecking'){
          _isChecking = element as SMIBool;
        }
        else if(element.name == 'isHandsUp'){
        _isHandsUp = element as SMIBool;
        }
        else if(element.name == 'trigSuccess'){
          _successTrigger = element as SMITrigger;
        }
        else if(element.name == 'trigFail'){
          _failTrigger = element as SMITrigger;
        }
        else if(element.name == 'numLook'){
          _lookNumber = element as SMINumber;
        }
      });
      setState(() => _artboard = art);
    }
  }

  void _lookAround() {
    _isChecking.change(true);
    _isHandsUp.change(false);
    _lookNumber.change(0);
  }

  void _moveEyes(String value) {
    _lookNumber.change(value.length.toDouble());
  }

  void _handsUpOnEyes() {
    _isHandsUp.change(true);
    _isChecking.change(false);
  }

  void _loginClick() {
    _isChecking.change(false);
    _isHandsUp.change(false);
    if(_emailController.value == 'email' && _passwordController.value == 'password'){
      _successTrigger?.fire();
    }
    else {
      _failTrigger.fire();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SingleChildScrollView(
        child : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(_artboard != null)
             SizedBox(
               height: 300,
               width: 500,
               child: Rive(artboard : _artboard),
             ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Container(
              alignment: Alignment.center,
              height: 80,
              width: 400,
              padding: EdgeInsets.only(bottom: 10),
              margin: EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Padding(
                  padding: EdgeInsets.all(15),
                child: TextFormField(
                  onChanged: _moveEyes,
                  onTap: _lookAround,
                  controller: _emailController,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Email',
                    focusColor: Colors.white,
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                alignment: Alignment.center,
                height: 80,
                width: 400,
                padding: EdgeInsets.only(bottom: 10),
                margin: EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: TextFormField(
                    onChanged: (value) => {},
                    onTap: _handsUpOnEyes,
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Password',
                      focusColor: Colors.white,
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            MaterialButton(
              onPressed: (){},
              child: const Text(
                'Not having account? Sign up!',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: MaterialButton(
                onPressed: _loginClick,
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ),
            )
          ],
        ),
       ),
      ),
    );
  }
}
