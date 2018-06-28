import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:flutter/rendering.dart';
import 'Util/nDB.dart';
import 'recipePage.dart';
import 'dart:developer';
import 'user.dart';
import 'Util/utils.dart';

class RatingsWidget extends StatefulWidget {
  @override
  RatingsWidget({Key key, this.title, this.rating = 0.0, this.interactive = false, this.categoryID, this.recipeID, this.pageState}) : super (key: key) {
    if (interactive) {
      imageWidth = 25.0;
      imageHeight = 25.0;
      containerWidth = 155.0;
      containerHeight = 25.0;
      containerMargin = new EdgeInsets.only(top: 10.0);
      imagePadding = new EdgeInsets.only(left: 3.0, right: 3.0);
    }
  }
  final RecipeState pageState;
  final int categoryID;
  final int recipeID;
  final String title;
  final double rating;
  final bool interactive;
  double imageWidth = 15.0;
  double imageHeight = 15.0;
  double containerWidth = 75.0;
  double containerHeight = 15.0;
  EdgeInsets imagePadding = EdgeInsets.zero;
  EdgeInsets containerMargin = new EdgeInsets.only(top: 10.0);

  double get getRating{
    return interactive ? pageState.rating : rating;
  }


  RatingsWidgetState createState() => new RatingsWidgetState();
}

class RatingsWidgetState extends State<RatingsWidget> {
  
  List<Widget> stars = [];

  double get rating{
    return widget.interactive ? widget.pageState.rating : widget.rating;
  }

  List<Widget> buildStars() {
    stars = [];
    if (rating > 0 || widget.interactive) {
      double totalIndex = 1.0;
      int ratingFloor = rating.floor();
      for (int i = 1; i <= ratingFloor; i++) {
        stars.add(star(dark: false, index: totalIndex, halfStar: false));
        totalIndex++;
      }
      bool halfStar = rating % 1 != 0.0;
      if (halfStar)
        stars.add(star(dark: false, index: ratingFloor.toDouble(), halfStar: halfStar));
      for (int i = 5-(halfStar ? ratingFloor + 1 : ratingFloor); i > 0; i--) {
          stars.add(star(dark: true, index: totalIndex));
          totalIndex++;
      }
    }
    else
      stars.add(new Container());

    return stars;
  }
  
  Widget star({@required bool dark, double index, bool halfStar = false}) {
    Container container;
    if (dark) {
      container = new Container(
        padding: widget.imagePadding,
        child: new Image.asset("images/gold_star_dark.png", width: widget.imageWidth,)
      );
    }
    else if (halfStar) {
      container = new Container(
        padding: widget.imagePadding,
        child: new Image.asset("images/gold_star_half.png", width: widget.imageWidth,)
      );
    } 
    else {
      container = new Container(
        padding: widget.imagePadding,
        child: new Image.asset("images/gold_star.png", width: widget.imageWidth,)
      );
    }

    if (widget.interactive) {
      return new GestureDetector(
        child: container,
        onTapDown: (tapDownDetails) {
            print("TAPPED");
            if (User.isSignedIn()) {
              setState(() {
                  widget.pageState.setRating(index);
              });

              // TODO: Here is where you need to save the rating to a Database, per your implementation
              Firebase r = new Firebase(table: FirebaseTables.categories);
              r.updateRatingForRecipe(categoryID: widget.categoryID, recipeID: widget.recipeID, rating: rating);
            }
        },
        onTapUp: (tapUpDetails){
          if (User.isSignedIn()) {
            widget.pageState.showReview();
          }
          else {
            showSignInAlert();
          }
        },
      );
    }
    else {
      return container;
    }
  }

  void showSignInAlert() {
    Utils.alert(
          context: context,
          title: "Login Required",
          content:
              "Please login with your Google account in order to rate the recipe");
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new Container(
        margin: widget.containerMargin,
        alignment: AlignmentDirectional.center,
        height: widget.containerHeight,
        width: widget.containerWidth,
        child: new Row(
          children: buildStars(),
        ),
      ),
      onHorizontalDragUpdate: ((dragUpdateDetails) {
        if (User.isSignedIn()) {
          setState(() {
            RenderBox box = context.findRenderObject();
            var percent = (box.globalToLocal(dragUpdateDetails.globalPosition).dx / ((widget.imageWidth + widget.imagePadding.left + widget.imagePadding.right) * 5));
            double place = (percent * 5).floor().toDouble() + (((percent * 5) % 1 < 0.5) ? 0.5 : 1.0);
            if (place >= 0.5 && place <= 5.0)
              widget.pageState.setRating(place);
          });
        }
      }),
      onHorizontalDragEnd: (dragUpdateDetails) {
        if (User.isSignedIn()) {
          widget.pageState.showReview();
        }
      },
    );
  }
}