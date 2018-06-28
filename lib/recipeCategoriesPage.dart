import 'package:flutter/material.dart';
import 'recipeCategoryCell.dart';
import 'recipe.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'Util/nDB.dart';
import 'dart:async';
import 'package:connectivity/connectivity.dart';

class RecipeCategoriesPage extends StatefulWidget {
  @override
  RecipeCategoriesPage({Key key, this.title, this.categories}) : super(key: key);

  final String title;
  final List<RecipeCategory> categories;

  @override
  RecipeCategoriesPageState createState() => new RecipeCategoriesPageState();
}

class RecipeCategoriesPageState extends State<RecipeCategoriesPage> {

  Firebase db = new Firebase(table: FirebaseTables.categories);
  ConnectivityResult connection = ConnectivityResult.none;

  @override
  initState() {
    super.initState();
    checkNetworkConnection();
  }

  Future<ConnectivityResult> checkNetworkConnection() async {
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      print("Connected to mobile");
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      print("Connected to wifi");
    }
    setState(() {
          connection = connectivityResult;
      });
    return connectivityResult;
  }

  @override
  Widget build(BuildContext context) {
    if (connection == ConnectivityResult.mobile || connection == ConnectivityResult.wifi) {
      return new Column(
        children: <Widget>[
          new Flexible(
            child: new FirebaseAnimatedList(
              query: db.reference,
              sort: (a, b) => a.key.compareTo(b.key),
              padding: new EdgeInsets.only(top: 0.0, bottom: 0.0),
              reverse: false,
              itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, int a) {
                return new RecipeCategoryCell(snapshot: snapshot, animation: animation,);
              },
            )
          )
        ],
      );
    }
    else {
      return new Center(
        child: new Container(
          alignment: AlignmentDirectional.center,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Container(
                alignment: AlignmentDirectional.center,
                child: new Text(
                  "Internet Connection Required", 
                  style: new TextStyle(
                    color: Colors.white, 
                    fontSize: 20.0, 
                    decoration: TextDecoration.none, 
                    decorationStyle: TextDecorationStyle.solid
                  ), 
                  textAlign: TextAlign.center
                ),
              ),
              new Divider(color: Colors.black),
              new RaisedButton(
                child: new Text("Refresh"),
                onPressed: () {
                  checkNetworkConnection();
                }
              )
            ],
          ),
        )
      );
    }
  }
}