import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';

class NCheckbox extends StatefulWidget {
  bool value;
  final EdgeInsetsGeometry padding;
  final Function onChanged;
  final String title;
  final Color endTransitionColor;
  //final double width;

  double effectWidth = 0.0;
  Color backgroundColor = Colors.green;

  @override
  NCheckbox({
      Key key, 
      this.value = false,
      this.padding,
      this.endTransitionColor = Colors.white,
      this.onChanged
    }) : super(key: key);

    @override
    NCheckboxState createState() => new NCheckboxState();
}

class NCheckboxState extends State<NCheckbox> {
  final int effectDuration = 2500;
  final double height = 8.0;
  Color color1 = Colors.red;
  Color color2 = Colors.orange;
  Color color3 = Colors.green;
  Color color4 = Colors.blue;

  Timer startTimeout([int milliseconds]) {
    print("timer starting");
    return new Timer(new Duration(milliseconds: 350), handleTimeout);
  }

  void handleTimeout() {
    print("updated!");
    setState(() {
      widget.effectWidth = 0.0;
    });
  }

  void updateValues() {
    if (widget.value) {
      widget.effectWidth = 0.0;
      color1 = Colors.red;
      color2 = Colors.orange;
      color3 = Colors.green;
      color4 = Colors.blue;
    }
    else {
      widget.effectWidth = 80.0;
      color1 = widget.endTransitionColor;
      color2 = widget.endTransitionColor;
      color3 = widget.endTransitionColor;
      color4 = widget.endTransitionColor;
      startTimeout();
    }
    widget.value = !widget.value; 
  }


  @override
  Widget build(BuildContext context) {
    return new Stack(
      alignment: Alignment.center,
      children: <Widget>[
        new AnimatedContainer(
          decoration: new BoxDecoration(
            color: color1,
          ),
          alignment: FractionalOffset.center,          
          curve: Curves.easeOut,
          width: height,
          height: widget.effectWidth,
          duration: new Duration(milliseconds: 350),
          child: new Transform(
            alignment: Alignment.center,
            transform: new Matrix4.rotationZ(0.785398),
            child: new AnimatedContainer(
              duration: new Duration(milliseconds: 350),
              curve: Curves.easeOut,  
              decoration: new BoxDecoration(
                color: color2,
              )
            ),
          ),
        ),
        new AnimatedContainer(
          decoration: new BoxDecoration(
            color: color4,
          ),       
          curve: Curves.easeOut,
          width: widget.effectWidth,
          height: height,
          duration: new Duration(milliseconds: 350),
          child: new Transform(
            alignment: Alignment.center,
            transform: new Matrix4.rotationZ(0.785398),
            child: new AnimatedContainer(
              duration: new Duration(milliseconds: 350),
              curve: Curves.easeOut,
              decoration: new BoxDecoration(
                color: color3,
              )
            ),
          ),
        ),
        new Checkbox(
          value: widget.value,
          onChanged: (bool value) {
            setState(() {
              updateValues();
              if (widget.onChanged != null)
                widget.onChanged();
            });
          },
        ),
      ],
    );
  }
}