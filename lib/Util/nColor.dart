import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:core';

class NeuColor {

  ///Change the luminence of the color
  /// - [color]: the color to changem
  /// - [amount]: the amount to change it from `0-255`. Provide negative value to decrease and positive to increase
  static Color changeLuminence(Color color, {@required int amount}) {
    if (amount > 0) {
      return new Color.fromARGB(
        color.alpha, 
        color.red <= 255 - amount ? color.red + amount : 255,
        color.green <= 255 - amount ? color.green + amount : 255,
        color.blue <= 255 - amount ? color.blue + amount : 255);
    }
    else {
      return new Color.fromARGB(
        color.alpha - 0, 
        color.red >= amount.abs() ? color.red + amount : 0,
        color.green >= amount.abs() ? color.green + amount : 0,
        color.blue >= amount.abs() ? color.blue + amount : 0);
    }
  }

  static bool isLightColor(Color color) {
    return color.computeLuminance() <= 0.5;
  }
}