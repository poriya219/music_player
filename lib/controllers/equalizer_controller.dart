import 'package:flutter/services.dart';

class EqualizerController {
  static const MethodChannel _channel = MethodChannel('equalizer_channel');

  Future<void> init(int sessionId) async {
    await _channel.invokeMethod('initEqualizer', {'sessionId': sessionId});
  }

  Future<List<int>> getBandLevels() async {
    return List<int>.from(await _channel.invokeMethod('getBandLevels'));
  }

  Future<List<int>> getCenterFrequencies() async {
    return List<int>.from(await _channel.invokeMethod('getCenterFrequencies'));
  }

  Future<List<String>> getPresets() async {
    return List<String>.from(await _channel.invokeMethod('getPresets'));
  }

  Future<void> usePreset(int index) async {
    await _channel.invokeMethod('usePreset', {'index': index});
  }

  Future<void> setBandLevel(int bandIndex, int level) async {
    await _channel.invokeMethod('setBandLevel', {
      'bandIndex': bandIndex,
      'level': level,
    });
  }

  Future<void> setEnabled(bool enabled) async {
    await _channel.invokeMethod('setEnabled', {'enabled': enabled});
  }
}
