import 'package:flutter/material.dart';
//import 'package:flutter/services.dart' show rootBundle;
import 'util/utils.dart';
import 'dart:ui';
import 'package:transparent_image/transparent_image.dart';
import 'recipeListPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:collection';


class RecipeCategoryCell extends StatefulWidget {
  @override 
  RecipeCategoryCell({Key key, this.snapshot, this.animation}) : super (key: key);

  final DataSnapshot snapshot;
  final Animation<double> animation;

  @override
  RecipeCategoryCellState createState() => new RecipeCategoryCellState();
}

class RecipeCategoryCellState extends State<RecipeCategoryCell> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      margin: new EdgeInsets.only(top: widget.snapshot.value["categoryID"] == 1 ? 0.0 : 0.4, bottom: 0.4, left: 0.0, right: 0.0),
      height: 250.0,
      child: new Stack(
        alignment: AlignmentDirectional.center,
        fit: StackFit.passthrough,
        children: <Widget>[
          new Center(child: new CircularProgressIndicator()),
          new FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: widget.snapshot.value['imageURL'],
            alignment: AlignmentDirectional.center,
            fit: BoxFit.cover,
          ),
          new Container(
            color: new Color.fromRGBO(255, 255, 255, 0.5),
            constraints: new BoxConstraints(
              minWidth: 100.0,
              minHeight: 250.0
            ),
          ),
          new Container(
            alignment: AlignmentDirectional.center,
            child: new Center(
              child: new ClipRect(
                child: new BackdropFilter(
                  filter: new ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                  child: new Container(
                    height: 150.0,
                    decoration: new BoxDecoration(
                      gradient: new LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color> [
                          Colors.grey.shade200.withOpacity(0.0),
                          Colors.grey.shade200.withOpacity(0.25),
                          Colors.grey.shade200.withOpacity(0.4),
                          Colors.grey.shade200.withOpacity(0.25),
                          Colors.grey.shade200.withOpacity(0.0),
                        ]
                      ),
                    ),
                    child: new Center(
                      child: new Text(
                        widget.snapshot.value["name"] ?? "N/A",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w100,
                          fontSize: 46.0,
                        )
                      ),
                    ),
                  ),
                ),
              ),
            )           
          ),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Container(
                padding: new EdgeInsets.only(left: 10.0, bottom: 10.0),
                child: new Text(
                  "${(widget.snapshot.value["recipes"] as List<dynamic>) != null ? (widget.snapshot.value["recipes"] as List<dynamic>).length + 1 : 0} Items",
                  style: new TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w300
                  ),
                ),
              )
            ],
          ),
          new GestureDetector(
            onTap: () {
              print("Tap category key: ${widget.snapshot.value["categoryID"]}");
              Navigation.push(context, new RecipeListPage(title: widget.snapshot.value["name"], categoryID: widget.snapshot.value["categoryID"], categoryIndex: int.parse(widget.snapshot.key)));
            },
          )
        ],
      )
    );
  }
}