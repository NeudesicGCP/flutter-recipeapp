import 'package:flutter/material.dart';
import 'util/utils.dart';
import 'recipePage.dart';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:async';

class RecipeCell extends StatelessWidget {
  RecipeCell({Key key, this.snapshot, this.animation, this.categoryID}) : super(key: key);

  final DataSnapshot snapshot;
  final Animation<double> animation;
  final int categoryID;

  Future<Null> showPreview(BuildContext context, {String url}) async {
    await showDialog(
    context: context,
    builder: (BuildContext context) {
      return new SimpleDialog(
        contentPadding: EdgeInsets.zero,
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Container(
                color: Colors.red,
                padding: new EdgeInsets.all(10.0),
                child: new Text(
                  "This recipe is currently locked. Purchase this recipe for \$0.99 for the goodies inside",
                  style: new TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300
                  ),
                ),
              ),
              new Container(
                child: new FadeInImage.memoryNetwork(
                  width: MediaQuery.of(context).size.width,
                  placeholder: kTransparentImage,
                  image: url,
                  fit: BoxFit.cover,
                )
              ),
              new GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: new Container(
                  color: Colors.white,
                  alignment: AlignmentDirectional.center,
                  padding: new EdgeInsets.all(20.0),
                  child: new Container(
                    child: new Text(
                      "Ok", style: new TextStyle(fontWeight: FontWeight.bold)
                    )
                  )
                )
              )
            ],
          )
        ],
      );
    }
  );
}

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.grey[850];

    void removeCurrentSnackbar() async {
      Scaffold.of(context).removeCurrentSnackBar();
    }

    return new Column(
      children: <Widget>[
        new Container(
          color: backgroundColor,
          height: 175.0,
          child: new GestureDetector(
            onTap: () {
              print("Tap recipe");
              if (!snapshot.value["locked"])
              {
                Navigation.push(context, new RecipePage(title: "${snapshot.value['title']}", snapshot: snapshot, categoryID: categoryID,));
                removeCurrentSnackbar();
              }
              else {
                showPreview(context, url: snapshot.value['imageURL']);
              }
            },
            child: new Stack(
              fit: StackFit.loose,
              children: <Widget>[
                new Container(
                  color: Colors.white,
                  margin: EdgeInsets.zero,
                  alignment: AlignmentDirectional.center,
                  child: new FadeInImage.memoryNetwork(
                    width: MediaQuery.of(context).size.width,
                    placeholder: kTransparentImage,
                    image: snapshot.value['imageURL'],
                    fit: BoxFit.cover,
                  ),
                ),
                new Container(
                  color: new Color.fromRGBO(255, 255, 255, 0.2),
                  constraints: new BoxConstraints(
                    minWidth: 100.0,
                    minHeight: 250.0
                  ),
                ),
                new ClipRect(
                  child: new BackdropFilter(
                    filter: new ImageFilter.blur(sigmaX: snapshot.value["locked"] ? 1.0 : 0.5, sigmaY: snapshot.value["locked"] ? 1.0 : 0.5),
                    child: new Container(
                      alignment: AlignmentDirectional.center,
                      decoration: new BoxDecoration(
                        gradient: new LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color> [
                            Colors.grey.shade200.withOpacity(0.5),
                            Colors.grey.shade200.withOpacity(0.5),
                            Colors.grey.shade200.withOpacity(0.25),
                            Colors.grey.shade200.withOpacity(0.1),
                            Colors.grey.shade200.withOpacity(0.3),
                          ]
                        ),
                      ),
                      child: new Container(
                        alignment: AlignmentDirectional.topStart,
                        padding: new EdgeInsets.only(left: 10.0, top: 10.0),
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              alignment: AlignmentDirectional.topStart,
                              child: new Text(snapshot.value["title"], textAlign: TextAlign.left, style: new TextStyle( fontSize: 28.0, fontWeight: FontWeight.w300, color: Colors.black))
                            ),
                            new Expanded(
                              child: new Container(
                                padding: new EdgeInsets.only(bottom: 10.0),
                                alignment: AlignmentDirectional.bottomStart,
                                child: new Text(
                                  "Rating: ${snapshot.value["rating"] != 0 ? snapshot.value["rating"] : 'No Ratings Yet'}",
                                  style: new TextStyle(
                                    fontSize: 15.0
                                  ),
                                ),
                              ),
                            )
                            
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                new Container(
                  alignment: AlignmentDirectional.topEnd,
                  child: new SizedBox(
                    width: 45.0,
                    height: 45.0,
                    child: snapshot.value["locked"] ? new Image.asset("images/corner-lock-blue.png") : (snapshot.value["date"] != null && (new DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch((snapshot.value["date"] as int))).inDays <= 30)) ? new Image.asset("images/corner-new-orange.png") : null,
                  ),
                )
              ],
            )
          )
        ),
        new Divider(color: Colors.black26, height: 0.1)
      ],
    );
  }
}