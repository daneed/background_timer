import 'dart:async';

import 'package:flutter/services.dart';

class IosBackgroundTimer {
  static const MethodChannel _channel =
      const MethodChannel('ios_background_timer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
