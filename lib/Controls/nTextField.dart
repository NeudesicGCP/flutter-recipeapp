import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:recipes/settings.dart';

class NTextField extends TextField {
  @override
  NTextField({
    Key key, 
    String text,
    bool autocorrect,
    bool autofocus,
    TextEditingController controller,
    InputDecoration decoration,
    FocusNode focusNode,
    List<TextInputFormatter> inputFormatters,
    TextInputType keyboardType,
    int maxLength,
    bool maxLengthEnforced,
    int maxLines,
    bool obscureText,
    ValueChanged<String> onChaged,
    ValueChanged<String> onSubmitted,
    TextStyle style,
    TextAlign textAlign,
    String hint
    }) : 
  
  super(
    key: key,
    autocorrect: autocorrect ?? true,
    autofocus: autofocus ?? false,
    controller: controller,
    decoration: decoration ?? (Device.iOSBuild() ? 
      new InputDecoration(
        hintText: hint,
        border: new OutlineInputBorder(
          borderSide: new BorderSide(color: Colors.grey, width: 0.8, style: BorderStyle.solid),
          borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
          gapPadding: 0.0),
        contentPadding: new EdgeInsets.all(8.0)
      ) : 
      new InputDecoration(
        hintText: hint,
        border: new UnderlineInputBorder(
          borderSide: new BorderSide(color: Colors.grey, width: 1.0, style: BorderStyle.solid))
      )),
    focusNode: focusNode,
    inputFormatters: inputFormatters,
    keyboardType: keyboardType ?? TextInputType.text,
    maxLength: maxLength,
    maxLengthEnforced: maxLengthEnforced ?? true,
    maxLines: maxLines ?? 1,
    obscureText: obscureText ?? false,
    onChanged: onChaged,
    onSubmitted: onSubmitted,
    style: style,
    textAlign: textAlign ?? TextAlign.start
  );
}