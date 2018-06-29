import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Device {
  /// Determine if the current device is iOS or Android
  static bool iOSBuild() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
        return true;
    }
    return false;
  }
}
