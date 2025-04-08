import 'dart:async';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

typedef OnTimerFinished = void Function(bool);

class TimerPage extends StatefulWidget {
  const TimerPage(
      {required this.onTimerFinished,
      this.textStyle = const TextStyle(color: redColor),
      this.duration = const Duration(minutes: 2),});

  final OnTimerFinished onTimerFinished;
  final TextStyle? textStyle;
  final Duration duration;

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Duration currentDuration = Duration.zero;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _parseTime(currentDuration),
      style: widget.textStyle,
    );
  }

  ///This function launches timer
  void _startTimer() {
    setState(() => currentDuration = widget.duration);
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _addTime());
  }

  ///This function changes timer value
  void _addTime() {
    setState(() {
      final currentSecond = currentDuration.inSeconds - 1;
      if (currentSecond >= 0) {
        currentDuration = Duration(seconds: currentSecond);
      }
      if (currentSecond == 0) {
        _stopTimer();
      }
    });
  }

  //This function stopped timer
  void _stopTimer() {
    widget.onTimerFinished(true);
    setState(() {
      timer.cancel();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  ///This function formates time
  String _parseTime(Duration duration) {
    final minutes = _addZeroValue(duration.inMinutes % 60);
    final seconds = _addZeroValue(duration.inSeconds % 60);
    return '$minutes:$seconds';
  }

  ///If digit is single add zero preffix
  String _addZeroValue(int value) => value < 10 ? '0$value' : '$value';
}
