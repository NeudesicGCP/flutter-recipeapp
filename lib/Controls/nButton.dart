import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:recipes/settings.dart';
import 'package:flutter/cupertino.dart';

enum NButtonType {
  raised, flat
}

class NButton extends StatelessWidget {
  
  Widget child;
  Color backgroundColor;
  Brightness colorBrightness;
  Color disabledColor;
  double disabledElevation;
  Color disabledTextColor;
  double elevation;
  Color highlightColor;
  double highlightElevation;
  VoidCallback onPressed;
  EdgeInsetsGeometry padding;
  ShapeBorder shape;
  Color splashColor;
  Color textColor;
  ButtonTextTheme textTheme;
  String text;
  // iOS Specific
  double minSize;
  double pressedOpacity;
  BorderRadius borderRadius;
  NButtonType buttonType;

  @override
  NButton({
      Key key, 
      Widget child,
      this.backgroundColor,
      Brightness colorBrightness,
      Color disabledColor,
      double disabledElevation,
      Color disabledTextColor,
      double elevation,
      Color highlightColor,
      double highlightElevation,
      VoidCallback onPressed,
      EdgeInsetsGeometry padding,
      ShapeBorder shape,
      Color splashColor,
      Color textColor,
      ButtonTextTheme textTheme,
      String text,
      double minSize,
      double pressedOpacity,
      BorderRadius borderRadius,
      NButtonType buttonType = NButtonType.raised
    }) : 
    assert(text != null),
    super(key: key) {
      this.child = child;
      this.backgroundColor = backgroundColor;
      this.colorBrightness = colorBrightness;
      this.disabledColor = disabledColor;
      this.disabledElevation = disabledElevation;
      this.disabledTextColor = disabledTextColor;
      this.elevation = elevation;
      this.highlightColor = highlightColor;
      this.highlightElevation = highlightElevation;
      this.onPressed = onPressed;
      this.padding = padding;
      this.shape = shape;
      this.splashColor = splashColor;
      this.textColor = textColor;
      this.text = text;
      this.minSize = minSize;
      this.pressedOpacity = pressedOpacity;
      this.borderRadius = borderRadius;
      this.buttonType = buttonType;
    }

    @override
  Widget build(BuildContext context) {

    return new Container(
      child: Device.iOSBuild() ? 
        new CupertinoButton(
          child: child ?? new Text(text), 
          padding: padding,
          color: backgroundColor,
          minSize: minSize ?? 44.0,
          pressedOpacity: pressedOpacity ?? 0.1,
          borderRadius: borderRadius ?? const BorderRadius.all(const Radius.circular(8.0)),
          onPressed: onPressed
        ) : 
        buttonType == NButtonType.raised ?
        new RaisedButton(
          key: key,
          child: child ?? new Text(text),
          color: backgroundColor,
          colorBrightness: colorBrightness,
          disabledColor: disabledColor,
          disabledElevation: disabledElevation ?? 0.0,
          disabledTextColor: disabledTextColor,
          elevation: elevation ?? 2.0,
          highlightColor: highlightColor,
          highlightElevation: highlightElevation ?? 8.0,
          onPressed: onPressed, 
          padding: padding,
          shape: shape,
          splashColor: splashColor,
          textColor: textColor
        ) :
        new FlatButton(
          key: key,
          child: child ?? new Text(text),
          color: backgroundColor,
          colorBrightness: colorBrightness,
          disabledColor: disabledColor,
          disabledTextColor: disabledTextColor,
          highlightColor: highlightColor,
          onPressed: onPressed, 
          padding: padding,
          shape: shape,
          splashColor: splashColor,
          textColor: textColor
        )
    );
  }
}