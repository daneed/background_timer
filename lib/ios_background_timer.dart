import 'dart:async';

import 'package:flutter/services.dart';

typedef void Callback();

class IosBackgroundTimer {
  static Timer myTimer;
  static int _nextCallbackId = 0;
  static Map<int, Callback> _callbacksById = new Map ();

  static const MethodChannel _channel =
      const MethodChannel('ios_background_timer');

  static Future<void> periodic(int delay, Callback callback) async {
    bool isActiveVal = await isActive;
    if (!isActiveVal) {
      if (!await _channel.invokeMethod('lowLevelHandlingEnabled')) {
        myTimer = Timer.periodic(Duration (milliseconds: delay), (Timer t) {callback ();});
      } else {
        int currentId = _nextCallbackId++;
        _callbacksById[currentId] = callback;
        _channel.setMethodCallHandler(_methodCallHandler);

        await _channel.invokeMethod('runBackgroundTimer', {'id' : currentId, 'delay': delay});

        return () {
          cancel ();
          _callbacksById.remove(currentId);
        };
      }
    }
  }

  static Future<void> cancel() async {
    bool isActiveVal = await isActive;
    if (isActiveVal) {
      if (!await _channel.invokeMethod('lowLevelHandlingEnabled')) {
        myTimer.cancel();
        myTimer = null;
      } else {
        await _channel.invokeMethod('stopBackgroundTimer');
      }
    }
  }

  static Future<bool> get isActive async {
    if (!await _channel.invokeMethod('lowLevelHandlingEnabled')) {
      return myTimer != null && myTimer.isActive;
    } else {
       final bool retval = await _channel.invokeMethod('isBackgroundTimerRunning');
       return retval;
    }
  }

  static Future<void> _methodCallHandler(MethodCall call) async {
    if (call.method == 'callback') {
      if (_callbacksById[call.arguments["id"]] != null) {
        _callbacksById[call.arguments["id"]]();
      }
    } else if (call.method == 'IosBackgroundTimerAck') {
      if (call.arguments["msg"] != null) {
        print("runBackgroundTimerAck arrived from Plugin, msg: " + call.arguments["msg"]);
      }
    }
  }
}
