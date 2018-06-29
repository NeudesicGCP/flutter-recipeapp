import 'package:flutter/material.dart';

class ListCell<T extends State<StatefulWidget>> extends StatefulWidget {
  @override
  ListCell({Key key, this.title, this.body, this.state}) : super(key: key);

  final String title;
  final Widget body;
  final T state;
  
  @override
  T createState() => state;
}