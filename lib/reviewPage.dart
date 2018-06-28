import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';
import 'Util/nDB.dart';
import 'Util/utils.dart';
import 'ratingsWidet.dart';
import 'dart:async';
import 'Util/nColor.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';
import 'dart:collection';

//import 'package:http/http.dart' as http;

class Review
{
  Review({this.userID, this.review, this.rating, this.date, this.displayName});
  String userID;
  String review;
  double rating;
  DateTime date;
  String displayName;
}

class ReviewPage extends StatefulWidget {
  @override
  ReviewPage({Key key, this.title, this.recipeID, this.categoryID, this.rating = 0.0})
      : super(key: key);

  final String title;
  final int recipeID;
  final int categoryID;
  final double rating;

  @override
  ReviewState createState() => new ReviewState();
}

class ReviewState extends State<ReviewPage> with TickerProviderStateMixin {

  GlobalKey stickyKey = new GlobalKey();
  ScrollController controller = new ScrollController();
  double height = 125.0;
  var width = 0.0;
  var originalWidth = 0.0;
  var top = 50.0;
  bool firstLoad = true;
  Animation<double> _scaleFactor;
  AnimationController _scaleController;
  double end = 1.0;
  double endAmount = 1.0;
  double opacity = 0.6;
  double ratingsHeight = 25.0;
  List<Review> reviews = [];

  double randNumber() {
    var rng = new Random();
    return rng.nextDouble() * 5;
  }

  /// This guarentees that the ratings animation resets to initial state once scrolled to the top
  void executeEndScrollFunction() {
    if (controller.offset < 10) {
      height = 125.0;
      width = originalWidth;
      top = (height * 0.50) - (ratingsHeight / 2);
      _scaleFactor = new Tween<double>(
        begin: 1.0,
        end: 1.0,
      ).animate(_scaleController);
      _scaleController.forward();
      opacity = 0.6;
    }
    else {
      var newRatingsHeight = ratingsHeight * endAmount;
      var heightLimit = 60;
      height = 125.0 - heightLimit;
    
        width = 100.0;
      var newTop = (height * 0.50) - (newRatingsHeight / 2);
      if (newTop >= 10)
        top = newTop;
      _scaleFactor = new Tween<double>(
        begin: 1.7,
        end: 1.7,
      ).animate(_scaleController);
      _scaleController.forward();
      opacity = 0.0;
    }
  }

  initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        var newRatingsHeight = ratingsHeight * endAmount;
        var a = controller.offset;
        if (controller.offset <= 60) {
          height = 125.0 - a;
          var newWidth = originalWidth * ((80 - a) / 80);
          if (newWidth >= 100)
            width = newWidth;
          var newTop = (height * 0.50) - (newRatingsHeight / 2);
          if (newTop >= 10)
            top = newTop;
          var prevEndAmount = endAmount;
          endAmount = 1 + (0.7 * (a / 60));
          _scaleController.forward();
          _scaleFactor = new Tween<double>(
            begin: prevEndAmount,
            end: endAmount,
          ).animate(_scaleController);
          opacity = 0.6 * (1 - (a / 60));
        }
        else if (a < 80) {
          //Default to compact view in case user scrolls to quickly
          var heightLimit = 60;
          height = 125.0 - heightLimit;
          var newWidth = originalWidth * ((80 - a) / 80);
          if (newWidth >= 100)
            width = newWidth;
          var newTop = (height * 0.50) - (newRatingsHeight / 2);
          if (newTop >= 10)
            top = newTop;
          _scaleFactor = new Tween<double>(
            begin: 1.7,
            end: 1.7,
          ).animate(_scaleController);
          _scaleController.forward();
          opacity = 0.0;
        }
        else
          width = 100.0;
      });
    });

    _scaleController = new AnimationController(vsync: this, duration: new Duration(milliseconds: 25));
    _scaleFactor = new Tween<double>(
      begin: 1.0,
      end: endAmount,
    ).animate(_scaleController);
  }

  List<bool> collapsed = [];


  Widget cellBuilder(int index, {BuildContext context}) {
    collapsed.add(true);
    Color imageColor = Color.fromRGBO(min(index % 2 == 0 ? (index * 40) : (index * 5), 255), min(index % 3 == 0 ? index * 60 : index * 10, 255), min(index % 2 == 0 ? index * 80 : index * 60, 255), 1.0);
    return new Container(
      width: 400.0,
      padding: new EdgeInsets.only(left: 10.0, top: 10.0, right: 5.0),
      margin: new EdgeInsets.only(top: index == 0 ? 0.0 : 10.0),
      color: Colors.white,
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            new Container(
              width: 35.0,
              height: 35.0,
              child: new DecoratedBox(
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: imageColor,
                  border: new Border.all(
                    style: BorderStyle.solid,
                    width: 1.5,
                    color: NeuColor.changeLuminence(imageColor, amount: -10)),
                ),
                child: new Container(
                  alignment: AlignmentDirectional.center,
                  child: new Text(
                    StringHelper.initialsForName(reviews[index].displayName),
                    textAlign: TextAlign.right,
                    style: new TextStyle(
                      fontSize: 16.0, color: NeuColor.isLightColor(imageColor) ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                )
              )
            ),
            new Flexible(
                child: new Padding(
              padding: new EdgeInsets.only(left: 10.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Text(reviews[index].displayName),
                  new Padding(
                    padding: new EdgeInsets.only(bottom: 15.0),
                    child: new RatingsWidget(
                      interactive: false,
                      rating: reviews[index].rating,
                    ),
                  ),
                  new Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      new Text(
                          reviews[index].review,
                          maxLines: collapsed[index] ? 2 : 200,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start)
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new FlatButton(
                        child: new Text(
                            collapsed[index] ? "Read more" : "Show Less",
                            style: new TextStyle(color: Colors.blue)),
                        onPressed: () {
                          setState(() {
                            collapsed[index] = !collapsed[index];
                          });
                        },
                      ),
                    ],
                  ),
                  new Padding(
                      padding: new EdgeInsets.only(bottom: 3.0),
                      child: new Text(
                        "${reviews[index].date.month}/${reviews[index].date.day}/${reviews[index].date.year}",
                        style: new TextStyle(color: Colors.grey[300]),
                      )),
                ],
              ),
            )),
          ]),
    );
  }

  
  Future<bool> getReviews() async {
    print("Getting reviews for categoryID: ${widget.categoryID} and recipeID: ${widget.recipeID}");
    var db = new Firebase(table: FirebaseTables.ratings);
    var _reviews = await db.getRecipeReviews(categoryID: widget.categoryID, recipeID: widget.recipeID) as LinkedHashMap<dynamic, dynamic>;
    if (_reviews != null) {
      for (var value in _reviews.keys) {
        print('${_reviews[value]} - ${_reviews[value]["rating"]}');
        var date = _reviews[value]["date"] != null ? new DateTime.fromMillisecondsSinceEpoch(_reviews[value]["date"]) : new DateTime.now();
        String displayName = await new Firebase(table: FirebaseTables.users).getDisplayName(userID: value);
        print("Display Name: $displayName");
        var review = new Review(userID: value, review: _reviews[value]["review"], rating: double.parse(_reviews[value]["rating"].toString()), date: date, displayName: displayName);
        reviews.add(review);
      }
    }
    return true;
  }

  Widget reviewList() {
    firstLoad = false;
    if (reviews.length > 0) {
      return new Column(
        children: <Widget>[
          new Stack(
            children: <Widget>[
              new Container(
                  alignment: AlignmentDirectional.centerStart,
                  child: new AnimatedContainer(
                    padding: EdgeInsets.only(top: 16.0),
                    alignment: AlignmentDirectional.topCenter,
                    height: height,
                    child: new Text("${widget.rating}",
                        style: new TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    width: width,
                    duration: new Duration(milliseconds: 10),
                  )),
              new Positioned(
                bottom: 10.0,
                child: new Container(
                    width: originalWidth,
                    alignment: AlignmentDirectional.center,
                    child: new Text("Based on ${reviews.length} review${reviews.length > 1 ? 's' : ''}",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            color:
                                new Color.fromRGBO(255, 255, 255, opacity)))),
              ),
              new Positioned.directional(
                  textDirection: TextDirection.ltr,
                  top: top,
                  child: new Container(
                    alignment: AlignmentDirectional.center,
                    width: originalWidth,
                    child: new ScaleTransition(
                      scale: _scaleFactor,
                      child: new RatingsWidget(key: stickyKey, rating: widget.rating),
                    ),
                  )),
            ],
          ),
          new Expanded(
            child: new Builder(
              builder: (BuildContext context) {
                return new NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (notification is ScrollStartNotification) {
                      print('scroll-start');
                    } else if (notification is ScrollEndNotification) {
                      print('scroll-end');
                      executeEndScrollFunction();
                    }
                    return false;
                  },
                  child: new ListView.builder(
                    padding: new EdgeInsets.only(top: 0.0),
                    controller: controller,
                    itemBuilder: (_, int index) =>
                        cellBuilder(index, context: context),
                    itemCount: reviews.length,
                    shrinkWrap: true,
                  )
                );
              },
            ),
          )
        ],
      );
    }
    else {
      return new Center(
        child: new Text(
          "No Reviews Yet",
          style: new TextStyle(
            color: Colors.white30,
            fontSize: 20.0
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (firstLoad) {
      width = MediaQuery.of(context).size.width;
      top = height * 0.50 - (ratingsHeight / 2);
    }
    originalWidth = MediaQuery.of(context).size.width;
    return new Scaffold(
        appBar: new AppBar(),
        backgroundColor: Colors.grey[850],
        body: firstLoad ? (new FutureBuilder(
          future: getReviews(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none: return new Text('Something went wrong... please try again');
              case ConnectionState.waiting: return new Center(
                  child: new Text(
                    "Loading...",
                    style: new TextStyle(
                      color: Colors.white30,
                      fontSize: 20.0
                    ),
                  ),
                );
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else
                  return reviewList();
            }
          },
        )) :
        reviewList()
      );
  }
}
