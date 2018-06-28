import 'package:flutter/material.dart';
import 'recipe.dart';
import 'recipeCell.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'Util/nDB.dart';
import 'Util/utils.dart';
import 'addRecipePage.dart';
import 'user.dart';

class RecipeListPage extends StatelessWidget {
  @override
  RecipeListPage({Key key, this.title, this.categoryID, this.categoryIndex}) : super(key: key);

  final String title;
  final List<Recipe> recipes;
  final int categoryID;
  final int categoryIndex;

  @override
  Widget build(BuildContext context) {
    Firebase db = new Firebase(table: FirebaseTables.categories);

    var f = db.reference.child('$categoryIndex').child('recipes');

    return new Scaffold(
      backgroundColor: Colors.black,
      appBar: new AppBar(
        title: new Text(title),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.add),
            onPressed: () {
              print("Add new recipe");
              if (User.isSignedIn())
                Navigation.push(context, new AddRecipePage(title: "Add Recipe", categoryID: categoryID));
              else
                Utils.alert(context: context, title: "Sign In Required", content: "You must be signed in to save this recipe");
            },
          )
        ],
      ),
      body: new Column(
        children: <Widget>[
          new Flexible(
            child: new FirebaseAnimatedList(
              query: f,
              sort: (a, b) => a.value["mintes"] > b.value["mintes"] ? 1 : 0,
              reverse: false,
              itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, int a) {
                return new RecipeCell(snapshot: snapshot, animation: animation, categoryID: categoryID);
              },
            ),
          )
        ]
      )
    );
  }
}