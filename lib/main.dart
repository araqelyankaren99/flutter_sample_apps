import 'package:flutter/material.dart';
import 'package:rive/rive.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await RiveNative.init();
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
  static const _riveUrl = 'assets/login_animation.riv';
  late final FileLoader _fileLoader = FileLoader.fromAsset(_riveUrl, riveFactory: Factory.rive);
  TriggerInput? _failTrigger;
  TriggerInput? _successTrigger;
  BooleanInput? _isHandsUp;
  BooleanInput? _isChecking;
  NumberInput? _lookNumber;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_rebuild);
    _passwordController.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  void _onRiveLoaded(RiveLoaded state) {
    final dynamicStateMachine = state.controller.stateMachine;

    _isChecking = dynamicStateMachine.boolean('isChecking') as BooleanInput?;
    _isHandsUp = dynamicStateMachine.boolean('isHandsUp') as BooleanInput?;
    _successTrigger =
        dynamicStateMachine.trigger('trigSuccess') as TriggerInput?;
    _failTrigger = dynamicStateMachine.trigger('trigFail') as TriggerInput?;
    _lookNumber = dynamicStateMachine.number('numLook') as NumberInput?;
  }

  void _lookAround() {
    _isChecking?.value = true;
    _isHandsUp?.value = false;
    _lookNumber?.value = 0;
  }

  void _moveEyes(String value) {
    _lookNumber?.value = value.length.toDouble();
  }

  void _handsUpOnEyes() {
    _isHandsUp?.value = true;
    _isChecking?.value = false;
  }

  void _loginClick() {
    _isChecking?.value = false;
    _isHandsUp?.value = false;
    if (_emailController.text == 'email' &&
        _passwordController.text == 'password') {
      _successTrigger?.fire();
    } else {
      _failTrigger?.fire();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fileLoader.dispose();
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
            RiveWidgetBuilder(
              fileLoader: _fileLoader,
              stateMachineSelector: const StateMachineNamed('Login Machine'),
              onLoaded: _onRiveLoaded,
              builder: (context, state) => switch (state) {
                RiveLoaded() => SizedBox(
                    height: 300,
                    width: 500,
                    child: RiveWidget(controller: state.controller),
                  ),
                RiveLoading() || RiveFailed() => const SizedBox.shrink(),
              },
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
                    labelText: _emailController.text.isEmpty ? 'Email' : null,
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
                      labelText:
                          _passwordController.text.isEmpty ? 'Password' : null,
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
