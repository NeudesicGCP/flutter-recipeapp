import 'package:flutter/material.dart';

class CreditPage extends StatelessWidget {
  @override
  CreditPage({Key key}) : super(key: key);

  Color headerColor = Colors.amber[300];
  Color bodyColor = Colors.amber[100];

  Widget header(String text) {
    return new Container(
        decoration: new BoxDecoration(
          color: headerColor,
          boxShadow: <BoxShadow> [
            new BoxShadow(
              color: Colors.black26,
              blurRadius: 1.0,
              offset: new Offset(0.0, 3.0),
              spreadRadius: -1.75
            )
          ]
        ),
        alignment: AlignmentDirectional.centerStart,
        padding: new EdgeInsets.all(7.0),
        margin: new EdgeInsets.only(bottom: 5.0),
        child: new Text(
          text,
          style: new TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
      );
  }

  Widget subHeader(String text) {
    return new Container(
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(
            color: Colors.black26,
            width: 1.0
          )
        )
      ),
      alignment: AlignmentDirectional.centerStart,
      child: new Text("$text"),
    );
  }

  Widget listItem(String text) {
    return new Container(
      alignment: AlignmentDirectional.centerStart,
      padding: new EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: new Row(
        children: <Widget>[
          new Container(
            alignment: AlignmentDirectional.topStart,
            padding: new EdgeInsets.only(right: 5.0),
            child: new Text(
              "•"
            )
          ),
          new Flexible(
            child: new Container(
              alignment: AlignmentDirectional.topStart,
              child: new Text(
                "$text",
                softWrap: true,
                textAlign: TextAlign.left,
                style: new TextStyle(
                  fontSize: 10.0,
                ),
              ),
            ),
          )
        ], 
      ),
    );
  }

  Widget imagesSection() {
    return new Column(
      children: <Widget>[
        header("Images"),
        new Container(
          alignment: AlignmentDirectional.centerStart,
          padding: new EdgeInsets.all(5.0),
          margin: new EdgeInsets.only(left: 10.0),
          child: new Column(
            children: <Widget>[
              new Column(
                children: <Widget>[
                  subHeader("Categories"),
                  new Container(
                    alignment: AlignmentDirectional.centerStart,
                    padding: new EdgeInsets.all(5.0),
                    margin: new EdgeInsets.only(left: 5.0),
                    child: new Column(
                      children: <Widget>[
                        listItem("https://nutritiouslife.com/wp-content/uploads/2016/05/go_vegan.jpg"),
                        listItem("https://cdn.foodism.co.uk/gallery/5a8acaa1db5e1.jpeg"),
                        listItem("https://cdn.foodism.co.uk/gallery/5a8acae3d1764.jpeg"),
                        listItem("https://www.eyecandypopper.com/wp-content/uploads/2013/06/10-min-Summer-Couscous-Salad-3.jpg"),
                        listItem("https://annetravelfoodie.com/wp-content/uploads/2016/10/vegan-restaurant-Loff-Breda.jpg"),
                      ],
                    ),
                  )
                ],
              ),
              new Column(
                children: <Widget>[
                  subHeader("Recipes"),
                  new Container(
                    alignment: AlignmentDirectional.centerStart,
                    padding: new EdgeInsets.all(5.0),
                    margin: new EdgeInsets.only(left: 5.0),
                    child: new Column(
                      children: <Widget>[
                        listItem("https://nutritiouslife.com/wp-content/uploads/2016/05/go_vegan.jpg"),
                        listItem("https://cdn.foodism.co.uk/gallery/5a8acaa1db5e1.jpeg"),
                        listItem("https://thumbs.dreamstime.com/b/plate-avocado-toast-kale-radish-marble-background-whole-grain-bread-top-view-85868415.jpg"),
                        listItem("https://www.eyecandypopper.com/wp-content/uploads/2017/02/Savory-Cauliflower-Cake-10.jpg"),
                        listItem("https://www.eyecandypopper.com/wp-content/uploads/2013/10/Vegan-Pesto-3.jpg"),
                        listItem("https://img.taste.com.au/UHXBGP9m/taste/2016/11/basil-pesto-3733-1.jpeg"),
                        listItem("https://www.eyecandypopper.com/wp-content/uploads/2013/06/10-min-Summer-Couscous-Salad-3.jpg"),
                        listItem("https://asideofsweet.com/wp-content/uploads/2018/02/How-Make-DIY-Fake-Marble-Photography-Backdrop.jpg"),
                        listItem("https://firebasestorage.googleapis.com/v0/b/recipes-39796.appspot.com/o/recipeImages%2F1527644258542.jpg?alt=media&token=871e5142-ff0c-40d8-a3bb-e01c97e13884"),
                        listItem("https://foodrevolution.org/wp-content/uploads/2018/01/blog-featured-veganism1-20180117-1430.jpg"),
                        listItem("https://annetravelfoodie.com/wp-content/uploads/2016/10/vegan-restaurant-Loff-Breda.jpg"),
                        listItem("https://media1.popsugar-assets.com/files/thumbor/hP_O5sLNU3Sskp5LWkk3ZNGPaXY/fit-in/1024x1024/filters:format_auto-!!-:strip_icc-!!-/2015/11/06/971/n/1922398/b2fcdf2bf0356b9d_IMG_59011-1024x802.jpg"),
                        listItem("https://s.abcnews.com/images/Travel/ht_Mango_Stir_Fry_Silver_Diner_BWI_Airport_ll_131113_16x9_992.jpg"),
                        listItem("http://www.vegkitchen.com/wp-content/uploads/2017/07/Farro-Stuffed-peppers3.jpg"),
                        listItem("http://www.tasteloveandnourish.com/wp-content/uploads/2017/02/Vegetable-Jambalaya-2-500x500.jpg"),
                        listItem("https://www.bbcgoodfood.com/sites/default/files/recipe-collections/collection-image/2013/05/slow-cooker-vegetable-curry_1.jpg"),
                        listItem("http://img1.cookinglight.timeinc.net/sites/default/files/styles/4_3_horizontal_-_1200x900/public/image/2017/03/main/beer-brushed-tofu-skewers-barley-1705p105.jpg?itok=OdHLIfLx"),
                      ],
                    ),
                  )
                ],
              ),
            ],
          )
        ),
      ],
    );
  }

  Widget iconsSection() {
    return new Column(
      children: <Widget>[
        header("Icons"),
        new Container(
          alignment: AlignmentDirectional.centerStart,
          padding: new EdgeInsets.all(5.0),
          margin: new EdgeInsets.only(left: 10.0),
          child: new Column(
            children: <Widget>[
              new Column(
                children: <Widget>[
                  subHeader("All"),
                  new Container(
                    alignment: AlignmentDirectional.centerStart,
                    padding: new EdgeInsets.all(5.0),
                    margin: new EdgeInsets.only(left: 5.0),
                    child: new Column(
                      children: <Widget>[
                        listItem("https://www.iconfinder.com/icons/309042/group_people_users_icon#size=256"),
                        listItem("https://www.iconfinder.com/icons/299094/filter_icon#size=256"),
                        listItem("https://www.iconfinder.com/icons/285646/lock_icon#size=256"),
                        listItem("https://www.flaticon.com/packs/nutrition"),
                        listItem("https://icons8.com/icon/3381/vegan-symbol"),
                        listItem("https://thenounproject.com/term/measuring-cup/35440/")
                      ],
                    ),
                  )
                ],
              )
            ],
          )
        )
      ],
    );
  }

  Widget librariesSection() {
    return new Column(
      children: <Widget>[
        header("Libraries"),
        new Container(
          alignment: AlignmentDirectional.centerStart,
          padding: new EdgeInsets.all(5.0),
          margin: new EdgeInsets.only(left: 10.0),
          child: new Column(
            children: <Widget>[
              new Column(
                children: <Widget>[
                  subHeader("Flutter"),
                  new Container(
                    alignment: AlignmentDirectional.centerStart,
                    padding: new EdgeInsets.all(5.0),
                    margin: new EdgeInsets.only(left: 5.0),
                    child: new Column(
                      children: <Widget>[
                        listItem("url_launcher"),
                        listItem("connectivity")
                      ],
                    ),
                  )
                ],
              )
            ],
          )
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Credits"),
      ),
      body: new Container(
        alignment: AlignmentDirectional.centerStart,
        color: bodyColor,
        padding: EdgeInsets.zero,
        child: new ListView.builder(
          itemCount: 3,
          itemBuilder: (context, i) {
            return cellBuilder(i);
          }
        ),
      )
    );
  }

  Widget cellBuilder(int index) {
    switch(index) {
      case 0:
        return imagesSection();
        break;
      case 1:
        return iconsSection();
        break;
      case 2:
        return librariesSection();
        break;
      default:
        return new Container();
    }
  }
}