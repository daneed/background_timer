import 'package:flutter/material.dart';

import 'package:background_timer/background_timer.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int  _time = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: buildPage ()
        ),
      ),
    );
  }

  Widget buildPage () {
    return Column (
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton (
              child: Text ("START"),
              onPressed: runTimer
            ),
            FlatButton (
              child: Text ("STOP"),
              onPressed: stopTimer
            )
          ],
        ),
        Container (
          child: Text ("Time:" + _time.toString())
        )
      ],
    );
  }

  void runTimer () async {
    await BackgroundTimer.periodic(1000, () {
      setState(() {
        _time++;
        print("TICK, " + _time.toString() + " s");
      });
    });
  }

  void stopTimer () async {
    await BackgroundTimer.cancel(null);
    setState(() {
      _time = 0;
    });
  }
}
