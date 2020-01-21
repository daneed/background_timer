import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

typedef void Callback();

class BackgroundTimer {
  static Timer _myTimer;
  static int _nextCallbackId = 0;
  static Map<int, Callback> _callbacksById = new Map ();

  static ValueNotifier<bool> _isActiveVn = ValueNotifier<bool> (false);
  static ValueNotifier<bool> get isActiveVn => _isActiveVn;
  static bool   get isActive => _isActiveVn.value;
  static        set isActive(bool newValue) => _isActiveVn.value = newValue;

  static const MethodChannel _channel = const MethodChannel('background_timer');

  static Future<void> periodic(int delay, Callback callback) async {
    _channel.setMethodCallHandler(_methodCallHandler);
    if (!isActive) {
      if (!await _channel.invokeMethod('lowLevelHandlingEnabled')) {
        bool result = await _channel.invokeMethod('backgroundTimerWillStart');
        print("BackgroundTimer: backgroundTimerWillStart result: " + result.toString());
        isActive = true;
        _myTimer = Timer.periodic(Duration (milliseconds: delay), (Timer t) {
          callback ();
        });
      } else {
        int currentId = _nextCallbackId++;
        _callbacksById[currentId] = callback;
        isActive = true;
        await _channel.invokeMethod('runBackgroundTimer', {'id' : currentId, 'delay': delay});
        return () {
          cancel (null);
          _callbacksById.remove(currentId);
        };
      }
    }
  }

  static Future<void> cancel(Callback callback) async {
    if (isActive) {
      if (!await _channel.invokeMethod('lowLevelHandlingEnabled')) {
        bool result = await _channel.invokeMethod('backgroundTimerWillEnd');
        print("BackgroundTimer: backgroundTimerWillEnd result: " + result.toString());
        _myTimer.cancel();
        _myTimer = null;
        isActive = false;
      } else {
        await _channel.invokeMethod('stopBackgroundTimer');
        isActive = false;
      }
      if (callback != null) {
        callback();
      }
    }
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
    } else {
      print ("BackgroundTimer, call arrived from method channel, method: " + call.method);
    }
  }
}
