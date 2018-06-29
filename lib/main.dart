import 'package:flutter/material.dart';
import 'homePage.dart';
import 'recipePage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  MaterialColor blackColor = const MaterialColor(0xFFFFFF,
      const {
        50  : const Color(0xFFFFFF),
        100 : const Color(0xFFFFFF),
        200 : const Color(0xFFFFFF),
        300 : const Color(0xFFFFFF),
        400 : const Color(0xFFFFFF),
        500 : const Color(0xFFFFFF),
        600 : const Color(0xFFFFFF),
        700 : const Color(0xFFFFFF),
        800 : const Color(0xFFFFFF),
        900 : const Color(0xFFFFFF)});

  static const _blackPrimaryValue = 0xFF000000;

  static const MaterialColor black = const MaterialColor(
    _blackPrimaryValue,
    const <int, Color>{
      50:  const Color(0xFFe0e0e0),
      100: const Color(0xFFb3b3b3),
      200: const Color(0xFF808080),
      300: const Color(0xFF4d4d4d),
      400: const Color(0xFF262626),
      500: const Color(_blackPrimaryValue),
      600: const Color(0xFF000000),
      700: const Color(0xFF000000),
      800: const Color(0xFF000000),
      900: const Color(0xFF000000),
    },
  );

  @override
  Widget build(BuildContext context) {
    
    //DB.initialize(true);

    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: black
      ),
      routes: <String, WidgetBuilder> {
      '/recipePage': (BuildContext context) => new RecipePage(),
    },
      home: new HomePage(title: 'Recipes'),
    );
  }
}
