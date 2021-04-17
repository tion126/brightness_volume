import 'dart:async';

import 'package:flutter/services.dart';

class BVUtils {
  static const MethodChannel _channel =
      const MethodChannel('brightness_volume');

  static Future<double> get brightness async =>
      (await _channel.invokeMethod('brightness')) as double;

  static Future setBrightness(double brightness) =>
      _channel.invokeMethod('setBrightness', {"brightness": brightness});

  static Future<bool> get isKeptOn async =>
      (await _channel.invokeMethod('isKeptOn')) as bool;

  static Future keepOn(bool on) => _channel.invokeMethod('keepOn', {"on": on});

  static Future<double> get volume async => (await _channel.invokeMethod('volume')) as double;

  static Future setVolume(double volume) => _channel.invokeMethod('setVolume', {"volume" : volume});

}
