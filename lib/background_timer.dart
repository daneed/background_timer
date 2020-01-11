import 'dart:async';

import 'package:flutter/services.dart';

typedef void Callback();

class BackgroundTimer {
  static Timer _myTimer;
  static int _nextCallbackId = 0;
  static Map<int, Callback> _callbacksById = new Map ();
  static bool _isActive = false;

  static const MethodChannel _channel =
      const MethodChannel('background_timer');

  static Future<void> periodic(int delay, Callback callback) async {
    if (!isActive) {
      if (!await _channel.invokeMethod('lowLevelHandlingEnabled')) {
        _isActive = true;
        _myTimer = Timer.periodic(Duration (milliseconds: delay), (Timer t) {
          callback ();
        });
      } else {
        int currentId = _nextCallbackId++;
        _callbacksById[currentId] = callback;
        _channel.setMethodCallHandler(_methodCallHandler);
        _isActive = true;
        await _channel.invokeMethod('runBackgroundTimer', {'id' : currentId, 'delay': delay});
        return () {
          cancel ();
          _callbacksById.remove(currentId);
        };
      }
    }
  }

  static Future<void> cancel() async {
    if (isActive) {
      if (!await _channel.invokeMethod('lowLevelHandlingEnabled')) {
        _myTimer.cancel();
        _myTimer = null;
        _isActive = false;
      } else {
        await _channel.invokeMethod('stopBackgroundTimer');
        _isActive = false;
      }
    }
  }

  static bool get isActive {
    return _isActive;
  }

  static int counter = 0;

  static Future<void> _methodCallHandler(MethodCall call) async {
    if (call.method == 'callback') {
      if (_callbacksById[call.arguments["id"]] != null) {
        print ("BackgroundTimer : callback arrived from Plugin, counter: " + counter.toString());
        ++counter;
        _callbacksById[call.arguments["id"]]();
      }
    } else if (call.method == 'BackgroundTimerAck') {
      if (call.arguments["msg"] != null) {
        print("BackgroundTimer : runBackgroundTimerAck arrived from Plugin, msg: " + call.arguments["msg"]);
        counter = 0;
      }
    }
  }
}
