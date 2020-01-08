import 'dart:async';

import 'package:flutter/services.dart';

typedef void Callback();

class IosBackgroundTimer {
  static int _nextCallbackId = 0;
  static Map<int, Callback> _callbacksById = new Map ();

  static const MethodChannel _channel =
      const MethodChannel('ios_background_timer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> runBackgroundTimer(int delay, {Callback callback}) async {
    int currentId = _nextCallbackId++;
    _callbacksById[currentId] = callback ?? null;
    _channel.setMethodCallHandler(_methodCallHandler);
    
    if (_callbacksById[currentId] != null) {
      _callbacksById[currentId]();
    }

    await _channel.invokeMethod('runBackgroundTimer', {'delay': delay});

    return () {
      stopBackgroundTimer ();
      _callbacksById.remove(currentId);
    };
  }

  static Future<void> stopBackgroundTimer() async {
    _channel.invokeMethod('stopBackgroundTimer');
  }

  static Future<void> _methodCallHandler(MethodCall call) async {
    if (call.method == 'callback') {
      if (_callbacksById[call.arguments["id"]] != null) {
        _callbacksById[call.arguments["id"]]();
      }
    } else if (call.method == 'runBackgroundTimerAck') {
      print("runBackgroundTimerAck arrived from Plugin");
    } else if (call.method == 'stopBackgroundTimerAck') {
      print("stopBackgroundTimerAck arrived from Plugin");
    }
  }
}
