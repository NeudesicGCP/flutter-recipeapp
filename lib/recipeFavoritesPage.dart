import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'Util/nDB.dart';
import 'user.dart';
import 'package:meta/meta.dart';
import 'Util/utils.dart';
import 'recipePage.dart';

class RecipeFavoritesPage extends StatefulWidget {
  @override  
  RecipeFavoritesPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  RecipeFavoritesPageState createState() => new RecipeFavoritesPageState();
}

class RecipeFavoritesPageState extends State<RecipeFavoritesPage> {

  void updatePath() {
    dbPath = User.isSignedIn() ? 'users/${User.idToken}/favorites' : '';
    db = new Firebase(path: dbPath);
  }
  
  String googleUserID = User.isSignedIn() ? User.idToken : "NULL";
  static String dbPath = User.isSignedIn() ? 'users/${User.idToken}/favorites' : '';
  Firebase db = new Firebase(path: dbPath);

  Widget noFavoritesWidget() {
    return new Container(
      child: new Container(
        alignment: AlignmentDirectional.center,
        child: new Text("No favorites yet! :(", 
          style: new TextStyle(
            fontSize: 20.0,
            color: Colors.white
          )
        ),
      ),
    );
  }

  Widget favoritesWidget() {
    return new Container(
      decoration: new BoxDecoration(color: Colors.white),
      child: new FirebaseAnimatedList(
        query: db.reference,
        sort: (a, b) => a.key.compareTo(b.key),
        padding: new EdgeInsets.only(top: 0.0, bottom: 0.0),
        reverse: false,
        itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, int a) {
          return new Column(
            children: <Widget>[
              new ExpansionTile(
                title: categoryNameForID(categoryID: int.parse(snapshot.key.split('-')[1])),
                children: buildInnerList(snapshot)
              ),
              new Divider(height: 1.0, color: Colors.grey[400])
            ],
          );
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    updatePath();
    print("FAVORITES PATH: $dbPath with userID: ${User.idToken}");

    if (!User.isSignedIn()) {
      return noFavoritesWidget();
    }
    else {
      return new FutureBuilder<dynamic>(
        future: new Firebase(table: FirebaseTables.users).userHasFavorites(userID: User.idToken),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none: return noFavoritesWidget();
            case ConnectionState.waiting: return new CircularProgressIndicator();
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else if (snapshot.data == true)
                return favoritesWidget();
              else
                return noFavoritesWidget();
          }
        }
      );
    }
  }

  List<Widget> buildInnerList(DataSnapshot snapshot) {
    var favoriteRecipeIDs = snapshot.value["recipeIDs"];
    List<Container> list = [];
    for (int recipeID in favoriteRecipeIDs) {
      list.add(new Container(
        decoration: new BoxDecoration(color: Colors.grey[100]),
        child: new ListTile(
          title: recipeNameForID(categoryID: int.parse(snapshot.key.split('-')[1]), recipeID: recipeID),
          trailing: new Icon(Icons.navigate_next),
          onTap: () async {
            int categoryID = int.parse(snapshot.key.split('-')[1]);
            DataSnapshot recipes = await new Firebase(table: FirebaseTables.categories).recipeForID(categoryID: categoryID, recipeID: recipeID);
            Navigation.push(context, new RecipePage(title: "${recipes.value['title']}", snapshot: recipes, categoryID: categoryID));
          },
        ),
      ));
    }
    return list;
  }

  FutureBuilder<dynamic> recipeNameForID({@required int categoryID, @required int recipeID}) {
    Firebase r = new Firebase(table: FirebaseTables.categories);
    return new FutureBuilder<dynamic>(
      future: r.recipeIDToName(categoryID: categoryID, recipeID: recipeID),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none: return new Text('Something went wrong...');
          case ConnectionState.waiting: return new Text('Awaiting result...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return new Text('${snapshot.data}');
        }
      },
    );
  }

  FutureBuilder<dynamic> categoryNameForID({@required int categoryID}) {
    Firebase r = new Firebase(table: FirebaseTables.categories);
    return new FutureBuilder<dynamic>(
      future: r.categoryIDToName(categoryID: categoryID),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none: return new Text('Something went wrong...');
          case ConnectionState.waiting: return new Text('Awaiting result...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return new Text('${snapshot.data}', style: new TextStyle(fontWeight: FontWeight.bold));
        }
      },
    );
  }
}