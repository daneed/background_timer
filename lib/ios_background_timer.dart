import 'dart:async';

import 'package:flutter/services.dart';

class IosBackgroundTimer {
  static const MethodChannel _channel =
      const MethodChannel('ios_background_timer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> runBackgroundTimer(int delay) async {
    _channel.invokeMethod('runBackgroundTimer', {'delay': delay});
  }

  static Future<void> stopBackgroundTimer() async {
    _channel.invokeMethod('stopBackgroundTimer');
  }
}
