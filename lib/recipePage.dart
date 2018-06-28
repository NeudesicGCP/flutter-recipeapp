import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:transparent_image/transparent_image.dart';

import 'Controls/nCheckbox.dart';
import 'Util/nColor.dart';
import 'Util/nDB.dart';
import 'Util/utils.dart';
import 'ratingsWidet.dart';
import 'recipe.dart';
import 'reviewPage.dart';
import 'user.dart';
import 'dart:math';

class RecipePage extends StatefulWidget {
  @override
  RecipePage({Key key, this.title, this.snapshot, this.categoryID})
      : super(key: key) {
    this.recipe = new Recipe.fromSnapshot(snapshot);
    selectedServings = recipe.servings;
    rows = 7;
  }

  final String title;
  Recipe recipe;
  int rows = 6;
  final DataSnapshot snapshot;
  final int categoryID;
  int selectedServings;

  @override
  RecipeState createState() => new RecipeState();
}

class RecipeState extends State<RecipePage>
    with SingleTickerProviderStateMixin {
  List<bool> ingredientsChecked = [];
  List<bool> preparationChecked = [];
  List<bool> cookingChecked = [];
  String favoriteIcon = 'images/heartOff.png';
  Firebase userDB = new Firebase(table: FirebaseTables.users);
  List<Container> dietaryImages = [];
  AnimationController _expandAnimationController;
  Animation<Size> _bottomBarSize;
  Animation<Size> _reviewContainerSize;
  ScrollController controller = new ScrollController();
  bool _reviewVisible = false;
  RecipeState state;
  FocusNode _focusNode = new FocusNode();
  TextEditingController _controller = new TextEditingController();
  bool tappitytap = false;
  double rating = 0.0;
  String newReviewText = '';
  RatingsWidget ratingsWidget;
  Color reviewButtonColor = Colors.grey[850];

  RecipeState() {
    state = this;
  }

  //Firebase storage
  final StorageReference storageRef =
      FirebaseStorage.instance.ref().child("icons");

  initState() {
    super.initState();
    retrieveFavorite();
    buildDietaryImageList();
    _expandAnimationController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bottomBarSize = new SizeTween(
      begin: new Size.fromHeight(0.0),
      end: new Size.fromHeight(175.0),
    ).animate(new CurvedAnimation(
      parent: _expandAnimationController,
      curve: Curves.linear,
    ));
    _reviewContainerSize = new SizeTween(
      begin: new Size.fromHeight(0.0),
      end: new Size.fromHeight(140.0),
    ).animate(new CurvedAnimation(
      parent: _expandAnimationController,
      curve: Curves.linear,
    ));

    _controller.addListener(() {
      String currentText = _controller.text;

      if (currentText.isNotEmpty) {
        int code = currentText.codeUnitAt(currentText.length - 1);

        if (code == 10 /* the code for the return key */) {
          // remove the last character, and unfocus.
          _controller.text = currentText.substring(0, currentText.length - 1);
          _focusNode.unfocus();
        }
      }
    });

    ratingsWidget = new RatingsWidget(
      interactive: true,
      categoryID: widget.categoryID,
      recipeID: widget.recipe.recipeID,
      pageState: this,
    );
  }

  void setRating(double newVal) {
    rating = newVal;
  }

  void showReview() {
    setState(() {
      if (_reviewVisible == true) 
        return;

      _reviewVisible = true;
      showReviewWorker();
    });
  }

  Future<void> showReviewWorker() async {
    await _expandAnimationController.forward();
    await controller.animateTo(MediaQuery.of(context).size.height + 1000,
            duration: new Duration(milliseconds: 200), curve: Curves.linear);
  }

  Future<void> setReview() async {
    await new Firebase(table: FirebaseTables.ratings).createRecipeReviewForUser(categoryID: widget.categoryID, recipeID: widget.recipe.recipeID, review: newReviewText, rating: ratingsWidget.getRating);
    setState(() {
      //hide ratings
      _reviewVisible = false;
      _bottomBarSize = new SizeTween(
      begin: new Size.fromHeight(175.0),
      end: new Size.fromHeight(0.0),
    ).animate(new CurvedAnimation(
      parent: _expandAnimationController,
      curve: Curves.linear,
    ));
    _reviewContainerSize = new SizeTween(
        begin: new Size.fromHeight(140.0),
        end: new Size.fromHeight(0.0),
      ).animate(new CurvedAnimation(
        parent: _expandAnimationController,
        curve: Curves.linear,
      ));
      _expandAnimationController.forward();
    });
  }

  ///Build list of dietary restriction images
  void buildDietaryImageList() {
    for (DietaryFlag flag in widget.recipe.dietaryFlags) {
      dietaryImages.add(new Container(
          width: 20.0,
          height: 20.0,
          margin: new EdgeInsets.only(left: 10.0),
          child: downloadURLForDietaryFlag(flag: flag)));
    }
  }

  ///Retreive whether this recipe is a favorite or not
  void retrieveFavorite() async {
    if (User.isSignedIn()) {
      var f = await userDB.isFavorite(
          userID: User.idToken,
          categoryID: widget.categoryID,
          recipeID: widget.recipe.recipeID);
      setState(() {
        widget.recipe.favorite = f;
        _setCurrentFavoriteIcon();
      });
    }
  }

  /// Set the favorites icon based on whethor the recipe is a favorite or not
  void _setCurrentFavoriteIcon() {
    if (widget.recipe.favorite) {
      favoriteIcon = 'images/heartOn.png';
    } else {
      favoriteIcon = 'images/heartOff.png';
    }
  }

  /// Color of the minute circle
  Color intensity() {
    if (widget.recipe.minutes > 60)
      return Colors.red;
    else if (widget.recipe.minutes > 45)
      return Colors.yellow;
    else
      return Colors.green;
  }

  /// Color of the minute circle border
  Color intensityInner() {
    if (widget.recipe.minutes > 60)
      return Colors.red[100];
    else if (widget.recipe.minutes > 45)
      return Colors.yellow[100];
    else
      return Colors.green[100];
  }

  /// The color of the text based off the primary color
  Color textColor() {
    var a = widget.recipe.theme.primaryColor.computeLuminance();
    return widget.recipe.theme.primaryColor.computeLuminance() <= 0.5
        ? Colors.white
        : Colors.black;
  }

  bool isLightColor() {
    return widget.recipe.theme.primaryColor.computeLuminance() <= 0.5;
  }

  /// The color of the separator based off the primary color
  Color separatorColor() {
    return widget.recipe.theme.primaryColor.computeLuminance() <= 0.5
        ? NeuColor.changeLuminence(widget.recipe.theme.primaryColor, amount: 40)
        : NeuColor.changeLuminence(widget.recipe.theme.primaryColor,
            amount: -40);
  }

  void setNumberOfPeople() async {
    await showDialog(
      context: context,
      child: new SimpleDialog(
        title: const Text('Select how many servings you need'),
        children: <Widget>[
          new SimpleDialogOption(
            onPressed: () { 
              setState(() {
                widget.selectedServings = 1;
                widget.recipe.adjustQuantityForServings(newServings:  widget.selectedServings);            
              });
              Navigator.pop(context, null); 
            },
            child: const Text('1 serving'),
          ),
          new SimpleDialogOption(
            onPressed: () { 
              setState(() {
                widget.selectedServings = 2;
                widget.recipe.adjustQuantityForServings(newServings:  widget.selectedServings);    
              });
              Navigator.pop(context, null); 
            },
            child: const Text('2 servings'),
          ),
          new SimpleDialogOption(
            onPressed: () { 
              setState(() {
                widget.selectedServings = 3;
                widget.recipe.adjustQuantityForServings(newServings:  widget.selectedServings); 
              });
              Navigator.pop(context, null); 
            },
            child: const Text('3 servings'),
          ),
          new SimpleDialogOption(
            onPressed: () { 
              setState(() {
                widget.selectedServings = 4;
                widget.recipe.adjustQuantityForServings(newServings:  widget.selectedServings); 
              });
              Navigator.pop(context, null); 
            },
            child: const Text('4 servings'),
          ),
        ],
      ),
    );
  }

  /// Set the recipe as a favorite for the user, if logged in. If the user is not logged in, a dialog will be shown
  void setFavorite({BuildContext context}) {
    if (User.isSignedIn()) {
      widget.recipe.favorite = !widget.recipe.favorite;
      _setCurrentFavoriteIcon();
      userDB.setFavorite(
          userID: User.idToken,
          categoryID: widget.categoryID,
          recipeID: widget.recipe.recipeID);
    } else {
      Utils.alert(
          context: context,
          title: "Login Required",
          content:
              "Please login with your Google account in order to save this recipe as your favorite!");
    }
  }

  /// Create image from Firebase image. While waiting, a circular progress indicator is shown
  /// - [flag]: the dietary flag you want to load
  FutureBuilder<Widget> downloadURLForDietaryFlag(
      {@required DietaryFlag flag}) {
    return new FutureBuilder<Widget>(
      future: dietaryImage(flag: flag),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new CircularProgressIndicator();
          case ConnectionState.waiting:
            return new CircularProgressIndicator();
          default:
            if (snapshot.hasError)
              return new Text('N/A');
            else
              return snapshot.data;
        }
      },
    );
  }

  /// Obtains the downloadURL from the requested image from Firebase Storage
  ///
  /// Returns a `FadeInImage.memoryNetwork` with the Firebase Storage URL
  Future<Widget> dietaryImage({@required DietaryFlag flag}) async {
    String url = await storageRef
        .child(Recipe.dietaryFlagToImageFile(flag, light: isLightColor()))
        .getDownloadURL();
    if (url != null) {
      return new FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: url,
        alignment: AlignmentDirectional.center,
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  /// Determine what index to give the row, if a row should be left out or not
  int indexBuilder(int index) {
    bool blankRow = widget.recipe.dietaryFlags.length == 0 && widget.recipe.calories < 0 || widget.recipe.servings < 1;
    switch (index) {
      case 0:
        return index;
        break;
      case 1:
        return index;
        break;
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
        if (blankRow) return index + 1;
        break;
      default:
        return index;
        break;
    }
    return index;
  }

  /// Build each row based on the given index of the row
  Widget cellBuilder(int index, {BuildContext context, BoxConstraints constraints}) {
    final double smallestDimension = min(
        constraints.maxWidth,
        constraints.maxHeight,
      );

      final bool isTabletLayout = smallestDimension >= 600;

    switch (indexBuilder(index)) {
      case 0:
        // Image Row
        return new FractionallySizedBox(
            widthFactor: 1.0,
            child: new Container(
                height: isTabletLayout ? 400.0 : 200.0,
                decoration: new BoxDecoration(),
                child: new Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    new CircularProgressIndicator(),
                    new Stack(
                      fit: StackFit.expand,
                      alignment: AlignmentDirectional.center,
                      children: <Widget>[
                        new FadeInImage.memoryNetwork(
                          image: widget?.recipe?.imageURL ??
                              'https://foodrevolution.org/wp-content/uploads/2018/01/blog-featured-veganism1-20180117-1430.jpg',
                          placeholder: kTransparentImage,
                          alignment: AlignmentDirectional.center,
                          fit: BoxFit.cover,
                        )
                      ],
                    )
                  ],
                )));
        break;
      case 1:
        // Title Row
        return new Container(
            padding: new EdgeInsets.all(20.0),
            decoration: new BoxDecoration(
              color: widget.recipe.theme.primaryColor
            ),
            child: new Align(
              widthFactor: 0.9,
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    flex: 2,
                    child: new Text(widget.recipe.title,
                      style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w300,
                        color: textColor()
                      )
                    ),
                  ),
                  new Container(
                      width: 30.0,
                      height: 30.0,
                      margin: new EdgeInsets.only(right: 15.0),
                      child: new Stack(
                        children: <Widget>[
                          new Image.asset('images/group${isLightColor() ? '_light' : ''}.png'),
                          new GestureDetector(onTap: () {
                            setNumberOfPeople();
                          }),
                        ],
                      )),
                  new Container(
                      width: 25.0,
                      height: 25.0,
                      margin: new EdgeInsets.only(right: 15.0),
                      child: new Stack(
                        children: <Widget>[
                          new Image.asset('$favoriteIcon'),
                          new GestureDetector(onTap: () {
                            setState(() {
                              setFavorite(context: context);
                            });
                          }),
                        ],
                      )),
                  new Container(
                    width: 35.0,
                    height: 35.0,
                    child: new DecoratedBox(
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: intensityInner(),
                        border: new Border.all(
                          style: BorderStyle.solid,
                          width: 1.5,
                          color: intensity()
                        ),
                      ),
                      child: new Container(
                        alignment: AlignmentDirectional.center,
                        child: new Text("${widget.recipe.minutes}",
                          textAlign: TextAlign.right,
                          style: new TextStyle(
                            fontSize: 16.0, color: Colors.black
                          )
                        ),
                      )
                    )
                  )
                ],
              ),
            ));
        break;
      case 2:
        // Dietary Flags Row
        List<Widget> calorieServings = [];

        if (widget.recipe.calories >= 0) {
          calorieServings.add(new RichText(
            text: new TextSpan(children: <TextSpan>[
              new TextSpan(
                text: "${widget.recipe.calories}",
                style: new TextStyle(
                  color: textColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0
                )
              ),
              new TextSpan(
                text: " kCal per serving",
                style: new TextStyle(
                  color: textColor(),
                  fontWeight: FontWeight.w200
                )
              ),
            ])
          ));
        }
        if (widget.recipe.calories >= 0 && widget.recipe.servings >= 1) {
          calorieServings.add(Container(height: 5.0));
        }
        if (widget.recipe.servings >= 1) {
          calorieServings.add(new RichText(
            text: new TextSpan(children: <TextSpan>[
              new TextSpan(
                text: "${widget.selectedServings}",
                style: new TextStyle(
                  color: textColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0
                )
              ),
              new TextSpan(
                text: " servings",
                style: new TextStyle(
                  color: textColor(),
                  fontWeight: FontWeight.w200
                )
              ),
            ])));
        }

        print("dietaryLength: ${dietaryImages.length}, calories: ${widget.recipe.calories}, servings: ${widget.recipe.servings}");
        if (dietaryImages.length > 0 || widget.recipe.calories >= 0 || widget.recipe.servings >= 1) {
          return new Container(
            decoration: new BoxDecoration(
              color: NeuColor.changeLuminence(
                widget.recipe.theme.primaryColor,
                amount: 20)
              ),
              child: new Column(
                children: <Widget>[
                  new Divider(color: separatorColor(), height: 1.0),
                  new Container(
                    padding: new EdgeInsets.only(left: 20.0, right: 20.0),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Container(
                            padding:
                              new EdgeInsets.only(top: 10.0, bottom: 10.0),
                            margin: new EdgeInsets.only(left: 0.0),
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: calorieServings,
                            )
                          ),
                        ),
                        new Container(
                          alignment: AlignmentDirectional.centerEnd,
                          padding: new EdgeInsets.only(
                            left: 0.0, right: 0.0, top: 10.0, bottom: 10.0),
                          child: new Row(children: dietaryImages),
                        )
                      ],
                    ),
                  ),
                  new Divider(color: separatorColor(), height: 1.0)
                ],
              )
            );
        }
        break;
      case 3:
        // Ingredients Row
        if (widget.recipe.ingredients != null) {
          List<Widget> ingredientsList = [
            new ListTile(
                title: new Text(
              "INGREDIENTS",
              style: new TextStyle(
                  fontWeight: FontWeight.bold, color: textColor()),
            ))
          ];

          for (int i = 0; i < widget.recipe.ingredients.length; i++) {
            ingredientsChecked.add(false);
            ingredientsList.add(new ListTile(
              leading: new Container(
                width: 40.0,
                height: 40.0,
                child: new NCheckbox(
                  endTransitionColor: widget.recipe.theme.primaryColor,
                  value: ingredientsChecked[i],
                  onChanged: () {
                    ingredientsChecked[i] = !ingredientsChecked[i];
                  }
                )
              ),
              title: new RichText(
                  text: new TextSpan(children: <TextSpan>[
                    new TextSpan(
                      text: "${widget.recipe.ingredients[i].humanReadableQuantity()}",
                      style: new TextStyle(
                        color: textColor(),
                        fontWeight: FontWeight.bold
                      )
                    ),
                    new TextSpan(
                      text: "  ${widget.recipe.ingredients[i].unitToString()}",
                      style: new TextStyle(
                        color: textColor(),
                        fontWeight: FontWeight.w300
                      )
                    ),
                    new TextSpan(
                      text: "  ${widget.recipe.ingredients[i].type}",
                      style: new TextStyle(
                        color: textColor(),
                        fontWeight: FontWeight.bold
                      )
                    )
                  ]
                )
              ),
              onTap: () {
                setState(() {
                  ingredientsChecked[i] = !ingredientsChecked[i];
                });
              },
            ));
          }
          ingredientsList.add(new Divider(color: separatorColor()));

          return new Container(
            decoration:
              new BoxDecoration(color: widget.recipe.theme.primaryColor),
            child: new Column(children: ingredientsList));
        } else {
          return new Container(
            height: 1.0,
          );
        }
        break;
      case 4:
        // Preparation Row
        if (widget.recipe.preparationInstructions != null) {
          List<Widget> preparationList = [
            new ListTile(
              title: new Text(
                "PREPARATION",
                style: new TextStyle(
                  fontWeight: FontWeight.bold, color: textColor()
                ),
              )
            )
          ];

          for (int i = 0;
              i < widget.recipe.preparationInstructions.length;
              i++) {
            preparationChecked.add(false);
            preparationList.add(new Container(
              padding: new EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: ListTile(
                leading: new Container(
                  width: 40.0,
                  height: 40.0,
                  child: new NCheckbox(
                    endTransitionColor: widget.recipe.theme.primaryColor,
                    value: preparationChecked[i],
                    onChanged: () {
                      preparationChecked[i] = !preparationChecked[i];
                    },
                  ),
                ),
                title: new Row(
                  children: <Widget>[
                    new Flexible(
                        child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text("${widget.recipe.preparationInstructions[i]}",
                            textAlign: TextAlign.left,
                            style: new TextStyle(color: textColor()))
                      ],
                    ))
                  ],
                ),
                onTap: () {
                  setState(() {
                    preparationChecked[i] = !preparationChecked[i];
                  });
                },
              ))
            );
          }
          preparationList.add(new Divider(color: separatorColor()));

          return new Container(
            decoration:
              new BoxDecoration(color: widget.recipe.theme.primaryColor),
            child: new Column(
              children: preparationList,
            ));
        } else {
          return new Container(
            height: 1.0,
          );
        }
        break;
      case 5:
        // Cooking Row
        if (widget.recipe.cookingInstructions != null) {
          List<Widget> cookingList = [
            new ListTile(
              title: new Text(
                "COOKING",
                style: new TextStyle(
                  fontWeight: FontWeight.bold, color: textColor()
                ),
              )
            )
          ];

          for (int i = 0; i < widget.recipe.cookingInstructions.length; i++) {
            cookingChecked.add(false);
            cookingList.add(new Container(
              padding: new EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: new ListTile(
                leading: new Container(
                  width: 40.0,
                  height: 40.0,
                  child: new NCheckbox(
                    endTransitionColor: widget.recipe.theme.primaryColor,
                    value: cookingChecked[i],
                    onChanged: () {
                      cookingChecked[i] = !cookingChecked[i];
                    },
                  ),
                ),
                title: new Row(
                  children: <Widget>[
                    new Flexible(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text("${widget.recipe.cookingInstructions[i]}",
                            textAlign: TextAlign.left,
                            style: new TextStyle(color: textColor())
                          )
                        ],
                      )
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    cookingChecked[i] = !cookingChecked[i];
                  });
                },
              ))
            );
          }

          return new Container(
            decoration:
              new BoxDecoration(color: widget.recipe.theme.primaryColor),
            padding: new EdgeInsets.only(bottom: 16.0),
            child: new Column(
              children: cookingList,
            )
          );
        } else {
          return new Container(
            height: 1.0,
          );
        }
        break;
      case 6:
        // Rating Row
        return new Column(children: <Widget>[
          new Divider(
            color: widget.recipe.theme.primaryColor.computeLuminance() <= 0.5
              ? Colors.white
              : Colors.black,
            height: 1.0,
          ),
          new Stack(
            alignment: new Alignment(0.0, 0.3),
            children: <Widget>[
              new Container(
                decoration: new BoxDecoration(color: Colors.grey[850]),
                child: new Column(
                  children: <Widget>[
                    new ListTile(
                      title: new Row(
                        children: <Widget>[
                          new Expanded(
                            child: new Text(
                              "RATE THIS RECIPE",
                              style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),
                          ),
                          new GestureDetector(
                              onTapDown: (v) {
                                setState(() {
                                  reviewButtonColor = Colors.grey[900];
                                });
                              },
                              onTapUp: (v) {
                                setState(() {
                                  reviewButtonColor = Colors.grey[850];
                                });
                              },
                              onVerticalDragStart: (v) {
                                setState(() {
                                  reviewButtonColor = Colors.grey[850];
                                });
                              },
                              onHorizontalDragStart: (v) {
                                setState(() {
                                  reviewButtonColor = Colors.grey[850];
                                });
                              },
                              onTap: () => Navigation.push(
                                context,
                                new ReviewPage(
                                  title: "Reviews of ${widget.title}",
                                  recipeID: widget.recipe.recipeID,
                                  categoryID: widget.categoryID,
                                  rating: widget.recipe.rating
                                )
                              ),
                              child: new Container(
                                decoration: new BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: reviewButtonColor,
                                  borderRadius: new BorderRadius.circular(4.0),
                                  border: new Border.all(
                                    style: BorderStyle.solid,
                                    width: 1.0,
                                    color: Colors.grey[800]),
                                ),
                                padding: new EdgeInsets.only(top: 5.0, bottom: 5.0, left: 14.0, right: 14.0),
                                child: Text(
                                  "READ REVIEWS",
                                  style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                  ),
                                ),
                              )
                            ),
                        ],
                      ),
                    ),
                    new Container(
                      padding: new EdgeInsets.only(top: 10.0, bottom: 45.0),
                      alignment: AlignmentDirectional.center,
                      child: ratingsWidget,
                    ),
                    new AnimatedBuilder(
                      animation: _bottomBarSize,
                      builder: (BuildContext context, Widget child) {
                        return new Container(
                            color: widget.recipe.theme.primaryColor,
                            height: _bottomBarSize.value.height,
                            width: MediaQuery.of(context).size.width,
                            child: _reviewVisible
                                ? new GestureDetector(
                                    onTapDown: (tapDownDetails) => setState(() {
                                      tappitytap = true;
                                    }),
                                    onTapUp: (tapDownDetails) => setState(() {
                                      tappitytap = false;
                                      //Send review
                                      setReview();
                                    }),
                                    child: new Container(
                                      color: widget.recipe.theme.primaryColor,
                                      padding: new EdgeInsets.only(
                                        left: 10.0, right: 10.0, top: 100.0
                                      ),
                                      child: new Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Text(
                                            "Send Review",
                                            style: new TextStyle(
                                              color: tappitytap
                                                ? Colors.grey
                                                : textColor(),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                            textAlign: TextAlign.center,
                                          ),
                                          new Padding(
                                            padding: new EdgeInsets.only(
                                              left: 10.0
                                            ),
                                            child: new Icon(
                                              Icons.send,
                                              color: tappitytap
                                                ? Colors.grey
                                                : textColor(),
                                            )
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : null);
                      },
                    ),
                  ],
                ),
              ),
              new AnimatedBuilder(
                  animation: _reviewContainerSize,
                  builder: (BuildContext context, Widget child) {
                    return _reviewVisible ? new Container(
                      decoration: new BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: new BorderRadius.all(
                          new Radius.circular(5.0)
                        )
                      ),
                      height: _reviewContainerSize.value.height,
                      width: MediaQuery.of(context).size.width - 20,
                      child: new Padding(
                        padding: new EdgeInsets.all(10.0),
                        child: new EnsureVisibleWhenFocused(
                          focusNode: _focusNode,
                          child: new TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            maxLines: 3,
                            keyboardType: TextInputType.text,
                            decoration: new InputDecoration(
                              border: InputBorder.none,
                              hintStyle: new TextStyle(
                                color: Colors.black,
                                fontStyle: FontStyle.italic
                              ),
                              hintText: "Your review goes here..."),
                            onChanged: (value) {
                              newReviewText = value;
                            },
                          ),
                        ),
                      )
                    )
                    : new Container();
                  }),
            ],
          )
        ]);
        break;
      default:
        return new Container(
          height: 1.0,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.grey[850],
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new LayoutBuilder(
          builder: (BuildContext context, constraints) {
            return new ListView.builder(
              padding: new EdgeInsets.only(top: 0.0),
              controller: controller,
              itemBuilder: (_, int index) =>
                cellBuilder(index, context: context, constraints: constraints),
              itemCount: 7,
              shrinkWrap: true,
            );
          },
        ));
  }
}

/// A widget that ensures it is always visible when focused.
class EnsureVisibleWhenFocused extends StatefulWidget {
  const EnsureVisibleWhenFocused({
    Key key,
    @required this.child,
    @required this.focusNode,
    this.curve: Curves.ease,
    this.duration: const Duration(milliseconds: 100),
  }) : super(key: key);

  /// The node we will monitor to determine if the child is focused
  final FocusNode focusNode;

  /// The child widget that we are wrapping
  final Widget child;

  /// The curve we will use to scroll ourselves into view.
  ///
  /// Defaults to Curves.ease.
  final Curve curve;

  /// The duration we will use to scroll ourselves into view
  ///
  /// Defaults to 100 milliseconds.
  final Duration duration;

  EnsureVisibleWhenFocusedState createState() =>
      new EnsureVisibleWhenFocusedState();
}

class EnsureVisibleWhenFocusedState extends State<EnsureVisibleWhenFocused> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_ensureVisible);
  }

  @override
  void dispose() {
    super.dispose();
    widget.focusNode.removeListener(_ensureVisible);
  }

  Future<Null> _ensureVisible() async {
    // Wait for the keyboard to come into view
    // TODO: position doesn't seem to notify listeners when metrics change,
    // perhaps a NotificationListener around the scrollable could avoid
    // the need insert a delay here.
    await new Future.delayed(const Duration(milliseconds: 500));

    if (!widget.focusNode.hasFocus) return;

    final RenderObject object = context.findRenderObject();
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(object);
    assert(viewport != null);

    ScrollableState scrollableState = Scrollable.of(context);
    assert(scrollableState != null);

    ScrollPosition position = scrollableState.position;
    double alignment;
    if (position.pixels > viewport.getOffsetToReveal(object, 0.0)) {
      // Move down to the top of the viewport
      alignment = 0.0;
    } else if (position.pixels < viewport.getOffsetToReveal(object, 1.0)) {
      // Move up to the bottom of the viewport
      alignment = 1.0;
    } else {
      // No scrolling is necessary to reveal the child
      return;
    }
    position.ensureVisible(
      object,
      alignment: alignment,
      duration: widget.duration,
      curve: widget.curve,
    );
  }

  Widget build(BuildContext context) => widget.child;
}
