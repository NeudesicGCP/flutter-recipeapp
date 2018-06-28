import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'recipe.dart';
import 'recipeCategoriesPage.dart';
import 'accountPage.dart';
import 'recipeFavoritesPage.dart';
import 'user.dart';

class HomePage extends StatefulWidget {

  @override
  HomePage({Key key, this.title}) : super(key: key) {
    if (User.googleSignIn.currentUser == null) {
      User.attemptPreviousLogin();
    }
  }
  final String title;
  List<RecipeCategory> categories;

  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 3,
      child: new Scaffold(
        backgroundColor: Colors.black,
        appBar: new AppBar(
          title: new TabBar(
            indicatorPadding: new EdgeInsets.only(bottom: -19.0),
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.amber,
            indicatorWeight: 4.0,
            tabs: <Widget>[
              new Text("Categories",style: new TextStyle(color: Colors.white, fontSize: 12.5)),
              new Text("Favorites",style: new TextStyle(color: Colors.white, fontSize: 12.5)),
              new Text("Account",style: new TextStyle(color: Colors.white, fontSize: 12.5)),
            ],
          ),
        ),
        body: new TabBarView(
          children: <Widget>[
            new RecipeCategoriesPage(title: "Categories"),
            new RecipeFavoritesPage(title: "Favorites"),
            new AccountPage()
          ],
        )
      )
    );
  }
}

