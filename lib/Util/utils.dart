import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/cupertino.dart';

class Utils {

  /// Creates a dialog with the given title and content
  static Future<Null> dialog({@required BuildContext context, String title, String content}) async {
    await showDialog(
      context: context,
      child: new SimpleDialog(
        title: new Text('$title'),
        children: <Widget>[
          new SimpleDialogOption(
            onPressed: () { Navigator.pop(context, null); },
            child: new Text('$content'),
          )
        ],
      ),
    );
  }

  /// Create an alert with the given title and content
  static Future<Null> alert({@required BuildContext context, String title, String content}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      child: new AlertDialog(
        title: new Text('$title'),
        content: new Text('$content'),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Ok"),
            onPressed: () {
              Navigator.of(context).pop();
            }
          )
        ], 
      ),
    );
  }
}

class Navigation {
  /// Push a new page on the navigation stack
  static void push(BuildContext context, Widget page) async {
    await Navigator.of(context).push(new CupertinoPageRoute<bool>(
      builder: (BuildContext context) {
        return page;
      }
    ));
  }
}

class Vectors {
  static Vector3 vector3(double x, double y, double z) {
    return new Vector3(x, y, z);
  }

  static Matrix3 matrix3() {
    return new Matrix3.rotationX(1.4);
  }
}

class Email {
  /// Send a native email. If the device is unable to send an email, and alert is shown
  static sendEmail({String subject, String content, String to, BuildContext context}) async {
    String url = 'mailto:$to?subject=$subject&body=$content';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (content != null) {
        Utils.alert(context: context, title: "We've hit a snag", content: "We were unable to send an email on this device, please ensure you have an email client installed then try again \n\nOr email us at: grenadier89@gmail.com");
      }
    }
  }
}

class StringHelper {
  static String initialsForName(String name) {
    var components = name.split(' ');
    if (components.length == 1) {
      if (components[0].length >= 2) 
        return components[0].substring(0, 2);
      else
        return components[0].substring(0, 1);
    }
    else if (components.length == 2) {
      String first = components[0].substring(0, 1);
      String second = components[1].substring(0, 1);
      return '$first$second';
    }
    else if (components.length > 2) {
      String first = components[0].substring(0, 1);
      String second = components[components.length-1].substring(0, 1);
      return '$first$second';
    }
    return '...';
  }
}