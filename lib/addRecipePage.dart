import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'Controls/nCheckbox.dart';
import 'Util/nColor.dart';
import 'Util/nDB.dart';
import 'Util/utils.dart';
import 'package:recipes/recipe.dart';
import 'user.dart';
import 'ensure_visible.dart';
import 'cameraPage.dart';
import 'package:flutter/services.dart';

//import 'package:http/http.dart' as http;

class AddRecipePage extends StatefulWidget {
  @override
  AddRecipePage({Key key, this.title, this.categoryID})
      : super(key: key) {
    this.recipe = new Recipe();
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
  AddRecipeState createState() => new AddRecipeState();
}

class AddRecipeState extends State<AddRecipePage>
    with SingleTickerProviderStateMixin {
  List<bool> ingredientsChecked = [];
  List<bool> preparationChecked = [];
  List<bool> cookingChecked = [];
  String favoriteIcon = 'images/heartOff.png';
  Firebase userDB = new Firebase(table: FirebaseTables.users);
  List<Container> dietaryImages = [];
  AddRecipeState state;
  bool tappitytap = false;
  double rating = 0.0;
  Map<DietaryFlag, bool> dietaryFlagsSelected = {};
  String currentlyAddingIngrentient;
  String currentlyAddingPreparation;
  String currentlyAddingCooking;
  String measuringCupImagePath = 'images/measuring-cup-light';
  var ingredientTextFieldController = new TextEditingController();
  var preparationTextFieldController = new TextEditingController();
  var cookingTextFieldController = new TextEditingController();
  String localImagePath;
  int imageCount = 0;
  bool makePublicValue = false;

  RecipeState() {
    state = this;
  }

  void setMeasuringCupIcon() {
    measuringCupImagePath = isLightColor() ? 'images/measuring-cup-light.png' : 'images/measuring-cup.png';
  }

  //Firebase storage
  final StorageReference storageRef =
      FirebaseStorage.instance.ref().child("icons");

  initState() {
    super.initState();
    initRecipe();
    setMeasuringCupIcon();
  }

  void initRecipe() async {
    var reference = new Firebase(table: FirebaseTables.categories);
    int latestRecipeID = await reference.highestRecipeID(categoryID: widget.categoryID) as int;
    print("Highest recipeID: $latestRecipeID, for categoryID: ${widget.categoryID}");
    latestRecipeID++;
    widget.recipe = new Recipe(recipeID: latestRecipeID);
  }

  void setRating(double newVal) {
    rating = newVal;
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
    return widget.recipe.theme.primaryColor.computeLuminance() <= 0.5
        ? Colors.white
        : Colors.black;
  }

  Color hintColor() {
    if (isLightColor()) {
      return NeuColor.changeLuminence(textColor(), amount: -30);
    }
    else {
      return NeuColor.changeLuminence(textColor(), amount: 30);
    }
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

  void setDietaryFlags() async {
    List<Widget> dietaryFlagItems = [];

    //12 dietary flags
    for (int i = 0; i < 12; i++) {
      DietaryFlag flag = Recipe.intToDietaryFlag(i);
      if (dietaryFlagsSelected[flag] == null)
        dietaryFlagsSelected.addAll({ flag : false});
      var item = new ListTile(
        leading: new Container(
          width: 40.0,
          height: 40.0,
          child: new NCheckbox(
            endTransitionColor: Colors.white,
            value: dietaryFlagsSelected[flag],
            onChanged: () {
              setState(() {
                dietaryFlagsSelected[flag] = !dietaryFlagsSelected[flag];
              });
            },
          ),
        ),
        title: new Text(Recipe.dietaryFlagToTitle(Recipe.intToDietaryFlag(i))),
      );

      dietaryFlagItems.add(item);
    }

    await showDialog(
      context: context,
      child: new SimpleDialog(
        title: const Text('Select Dietary Restrictions'),
        children: dietaryFlagItems
      ),
    );
  }

  int _selectedQuanityIndex = 0;
  int _selectedFractionIndex = 0;
  int _selectedUnitIndex = 0;
  double _kPickerSheetHeight = 216.0;
  double _kPickerItemHeight = 32.0;

  List<String> fractions = [
    " ",
    "1/16",
    "1/8",
    "1/4",
    "1/3",
    "3/8",
    "1/2",
    "5/8",
    "2/3",
    "3/4",
    "7/8"
  ];

  List<String> getAvailableUnits() {
    List<String> items = [];
    for (int i = 0; i < 13; i++) {
      items.add(Ingredient.convertIntToUnitString(i));
    }
    return items;
  }

  Widget _buildUnitPicker() {
    final FixedExtentScrollController scrollController = new FixedExtentScrollController(initialItem: _selectedQuanityIndex);
    final FixedExtentScrollController fractionScrollController = new FixedExtentScrollController(initialItem: _selectedFractionIndex);
    final FixedExtentScrollController unitScrollController = new FixedExtentScrollController(initialItem: _selectedUnitIndex);

    return new Container(
      height: _kPickerSheetHeight,
      width: 300.0,
      color: CupertinoColors.white,
      child: new DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: new GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: new Center(
            child:new Row(
              children: <Widget>[
                new Flexible(
                  flex: 1,
                  child: new Container(
                    color: Colors.red[200],
                      child: new CupertinoPicker(
                        scrollController: scrollController,
                        itemExtent: _kPickerItemHeight,
                        backgroundColor: CupertinoColors.white,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _selectedQuanityIndex = index;
                          });
                        },
                        children: new List<Widget>.generate(11, (int index) {
                          return new Center(child:
                            new Text(index == 0 ? ' ' : '$index'),
                          );
                        }),
                      ),
                  )
                ),
                new Flexible(
                  flex: 1,
                  child: new Container(
                      child: new CupertinoPicker(
                        scrollController: fractionScrollController,
                        itemExtent: _kPickerItemHeight,
                        backgroundColor: CupertinoColors.white,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _selectedFractionIndex = index;
                          });
                        },
                        children: new List<Widget>.generate(fractions.length, (int index) {
                          return new Center(child:
                            new Text('${fractions[index]}'),
                          );
                        }),
                      ),
                  ),
                ),
                new Flexible(
                  flex: 1,
                  child: new Container(
                      child: new CupertinoPicker(
                        scrollController: unitScrollController,
                        itemExtent: _kPickerItemHeight,
                        backgroundColor: CupertinoColors.white,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _selectedUnitIndex = index;
                          });
                        },
                        children: new List<Widget>.generate(getAvailableUnits().length, (int index) {
                          return new Center(child:
                            new Text('${getAvailableUnits()[index]}'),
                          );
                        }),
                      ),
                  ),
                )
              ],
            )
          )
        ),
      ),
    );
  }

  showIngredientPicker(BuildContext context) {
    showDialog(
      context: context,
      child: new SimpleDialog(
        title: new Text("Select quanity and units"),
        children: <Widget>[
          _buildUnitPicker(),
          new FlatButton(
            child: new Text("Done"),
            onPressed: () { 
              setState(() {
                measuringCupImagePath = 'images/measuring-cup-green.png';
              });
              Navigator.pop(context, 0);
            }
          ),
        ],
      )
    );
  }

  showCamera(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
          return new CameraExampleHome(imageCapturedListener: (value) {
            print("Returned Image Path: $value"); 
            imageCache.clear();
            setState(() {           
              localImagePath = null;
              localImagePath = value;
              print("set new image...");
            });
            
          });
      },
    );
    return;
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
    bool blankRow = widget.recipe.dietaryFlags?.length ?? 0 == 0 && widget.recipe.calories < 0 || widget.recipe.servings < 1;
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
  Widget cellBuilder(int index, {BuildContext context}) {
    var newImage = localImagePath != null ? new FadeInImage(image: new FileImage(new File(localImagePath)), placeholder: new AssetImage('images/loading.png'), fit: BoxFit.cover,) : new Text("Loading...");// Image.file(new File(localImagePath), fit: BoxFit.cover),

    switch (indexBuilder(index)) {
      case 0:
        // Image Row
        return new FractionallySizedBox(
          widthFactor: 1.0,
          child: new Container(
              height: 200.0,
              decoration: new BoxDecoration(color: Colors.grey[850]),
              child: new Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  new Stack(
                    fit: StackFit.expand,
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      localImagePath != null && localImagePath != '' ?
                        new GestureDetector(
                          child: newImage,
                          onTap: () {
                            showCamera(context);
                          }
                        ) :
                        new IconButton(
                          icon: new Icon(Icons.add_a_photo, color: Colors.white,), 
                          color: Colors.white,
                          onPressed: () {
                            showCamera(context);
                          },
                        )
                    ],
                  )
                ],
              )
            )
          );
        break;
      case 1:
        // Title Row
        var recipeTitleController = new TextEditingController(text: widget.recipe.title);
        return new Container(
            padding: new EdgeInsets.all(20.0),
            decoration: new BoxDecoration(
                color: widget.recipe.theme.primaryColor),
            child: new Align(
              widthFactor: 0.9,
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    flex: 2,
                    child: new EnsureVisible(
                      builder: (BuildContext context, FocusNode node) {
                        return new TextField(
                          focusNode: node,
                          decoration: new InputDecoration.collapsed(
                            hintText: "Enter Recipe Title", 
                            hintStyle: new TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: hintColor()
                            )
                          ), 
                          style: new TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: textColor()
                          ),
                          onChanged: (value) {
                            widget.recipe.title = value;
                            print("new recipe title: ${widget.recipe.title}");
                          },
                          controller: recipeTitleController,
                        );
                      } ,
                    )
                  ),
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
                            color: intensity()),
                      ),
                      child: new Container(
                        alignment: AlignmentDirectional.center,
                        child: new TextField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: new InputDecoration.collapsed(hintText: ' Min'),
                          style: new TextStyle(
                            fontSize: 16.0, color: Colors.black),
                          onChanged: (value) {
                            try
                            {
                              setState(() {
                                int newVal = int.parse(value);
                                widget.recipe.minutes = newVal;
                              });
                            }
                            catch (e)
                            {
                              
                            }
                          },
                        )
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
        var calorieController = new TextEditingController(text: '${widget.recipe.calories == 0 ? '' : widget.recipe.calories}');
        var servingsController = new TextEditingController(text: '${widget.recipe.servings == 1 ? '' : widget.recipe.servings}');
        if (widget.recipe.calories >= 0) {
          calorieServings.add(
            new Row(
              children: <Widget>[
                new Flexible(
                  flex: 1,
                  child: new Container(
                    width: 45.0,
                    child: new EnsureVisible(builder: (BuildContext context, FocusNode node) {
                      return new TextField(
                        keyboardType: TextInputType.number, 
                        focusNode: node, 
                        textAlign: TextAlign.right, 
                        decoration: new InputDecoration.collapsed(
                          hintText: "Enter", 
                          hintStyle: new TextStyle(
                            color: hintColor()
                            )
                        ), 
                        style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: textColor()
                        ),
                        controller: calorieController,
                        onChanged: (value) {
                          try
                          {
                            widget.recipe.calories = int.parse(value);
                          }
                          catch (e)
                          {
                            print("Error storing calorie input");
                          }
                        },
                      );
                    }),
                  ),
                ),
                new Text(" kCal per serving", style: new TextStyle(color: textColor()))
              ],
            )
          );
        }
        if (widget.recipe.calories >= 0 && widget.recipe.servings >= 1) {
          calorieServings.add(new Row(children: <Widget>[ new Container(height: 10.0)],));
        }
        if (widget.recipe.servings >= 1) {
          calorieServings.add(
            new Row(
              children: <Widget>[
                new Flexible(
                  child: new Container(
                    width: 45.0,
                    child: new EnsureVisible(builder: (BuildContext context, FocusNode node) {
                      return new TextField(
                        keyboardType: TextInputType.number, 
                        focusNode: node, 
                        textAlign: TextAlign.right, 
                        decoration: new InputDecoration.collapsed(
                          hintText: "Enter", 
                          hintStyle: new TextStyle(
                            color: hintColor()
                          )
                        ), 
                        style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: textColor()
                        ),
                        controller: servingsController,
                        onChanged: (value) {
                          try
                          {
                            widget.recipe.servings = int.parse(value);
                          }
                          catch (e)
                          {
                            print("Error storing servings input");
                          }
                        },
                      );
                    }),
                  ),
                ),
                new Text(" servings", style: new TextStyle(color: textColor()))
              ],
            )
          );
        }

        //Public
        calorieServings.add(
          new Row(
            children: <Widget>[
              new Text("Make Public:", style: new TextStyle(color: textColor())),
              new Flexible(
                child: new Container(
                  width: 70.0,
                  child: new EnsureVisible(builder: (BuildContext context, FocusNode node) {
                    return new Switch(
                      value: makePublicValue, 
                      activeColor: Colors.green,
                      onChanged: (v) {
                        
                      }
                    );
                  }),
                ),
              )
            ],
          )
        );

        print("dietaryLength: ${dietaryImages.length}, calories: ${widget.recipe.calories}, servings: ${widget.recipe.servings}");
        if (dietaryImages.length > 0 || widget.recipe.calories >= 0 || widget.recipe.servings >= 1) {
        print('here');
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
                                  new EdgeInsets.only(top: 15.0, bottom: 15.0),
                              margin: new EdgeInsets.only(left: 0.0),
                              child: new Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: calorieServings,
                              )),
                        ),
                        new Container(
                          alignment: AlignmentDirectional.centerEnd,
                          padding: new EdgeInsets.only(
                              left: 0.0, right: 0.0, top: 10.0, bottom: 10.0),
                          child: new FlatButton.icon(
                            color: NeuColor.changeLuminence(widget.recipe.theme.primaryColor, amount: isLightColor() ? -20 : 20),
                            label: new Text("Diet", style: new TextStyle(color: textColor())),
                            icon: new Icon(Icons.fastfood, color: textColor()),
                            onPressed: () {
                             setDietaryFlags(); 
                            },
                          )
                        )
                      ],
                    ),
                  ),
                  new Divider(color: separatorColor(), height: 1.0,)
                ],
              )
            );
        }
        break;
      case 3:
        // Ingredients Row
        
          print("Ingredients: ${widget.recipe.ingredients}");
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
              title: new RichText(
                  text: new TextSpan(children: <TextSpan>[
                    new TextSpan(
                        text: "${widget.recipe.ingredients[i].humanReadableQuantity()}",
                        style: new TextStyle(
                            color: textColor(),
                            fontWeight: FontWeight.bold)),
                    new TextSpan(
                        text: "  ${widget.recipe.ingredients[i].unitToString()}",
                        style: new TextStyle(
                            color: textColor(),
                            fontWeight: FontWeight.w300)),
                    new TextSpan(
                        text: "  ${widget.recipe.ingredients[i].type}",
                        style: new TextStyle(
                            color: textColor(),
                            fontWeight: FontWeight.bold)),
                  ]
                )
              ),
              trailing: new IconButton(
                icon: new Icon(Icons.delete, color: Colors.red[300]),
                onPressed: () {
                  print("Delete item");
                  setState(() {
                    print("removing item ${widget.recipe.ingredients[i]}");
                    widget.recipe.ingredients.removeAt(i);
                  });
                },
              ),
              onTap: () {
                setState(() {
                  ingredientsChecked[i] = !ingredientsChecked[i];
                });
              },
            ));
          }
          
          TextField addIngredientTextField;
          ingredientsList.add(new Container(
            padding: new EdgeInsets.only(left: 20.0, right: 20.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: new EnsureVisible(
                    builder: (BuildContext context, FocusNode node) {
                      addIngredientTextField = new TextField(
                        focusNode: node,
                        decoration: new InputDecoration(hintText: "Add Ingredient", hintStyle: new TextStyle(color: hintColor())), style: new TextStyle(color: textColor()),
                        onChanged: (value) {
                          currentlyAddingIngrentient = value;
                        },
                        controller: ingredientTextFieldController,
                      ); 
                      return addIngredientTextField;
                    },
                  )
                ),
                new IconButton(
                  icon: new Image.asset(measuringCupImagePath,
                  height: 20.0,
                  width: 20.0),
                  onPressed: () {
                    print("measuring amount pressed"); 
                    showIngredientPicker(context);
                  },
                ),
                new IconButton(
                  icon: new Icon(Icons.add, color: textColor(),),
                  onPressed: () {
                    print("Add new recipe");
                    setState(() {
                      //calculate quantity
                      if (currentlyAddingIngrentient != null && currentlyAddingIngrentient != '') {
                        double quantity = _selectedQuanityIndex.toDouble();
                        if (_selectedFractionIndex != 0) {
                          var parts = fractions[_selectedFractionIndex].split('/');
                          double partOne = double.parse(parts[0]);
                          double partTwo = double.parse(parts[1]);
                          double result = partOne / partTwo;
                          quantity += result;
                        }

                        var ingredient = new Ingredient();
                        ingredient.type = currentlyAddingIngrentient;
                        ingredient.quantity = quantity;
                        ingredient.unit = Ingredient.stringToUnit(Ingredient.convertIntToUnitString(_selectedUnitIndex));
                        widget.recipe.ingredients.add(ingredient);
                        setMeasuringCupIcon();
                        _selectedFractionIndex = 0;
                        _selectedQuanityIndex = 0;
                        _selectedUnitIndex = 0;
                        ingredientTextFieldController.clear();
                        addIngredientTextField.focusNode.unfocus();
                        currentlyAddingIngrentient = '';
                      }
                    });
                  },
                )
              ],
            )
          ));
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
                  fontWeight: FontWeight.bold, color: textColor()),
            ))
          ];

          for (int i = 0;
              i < widget.recipe.preparationInstructions.length;
              i++) {
            preparationChecked.add(false);
            preparationList.add(new ListTile(
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
              trailing: new IconButton(
                icon: new Icon(Icons.delete, color: Colors.red[300]),
                onPressed: () {
                  setState(() {
                    print("removing item ${widget.recipe.preparationInstructions[i]}");
                    widget.recipe.preparationInstructions.removeAt(i);
                  });
                },
              )
            ));
          }
          TextField addPreparationTextField;
          preparationList.add(new Container(
            padding: new EdgeInsets.only(left: 20.0, right: 20.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: new EnsureVisible(
                    builder: (BuildContext context, FocusNode node) {
                      addPreparationTextField = new TextField(
                        focusNode: node,
                        decoration: new InputDecoration(
                          hintText: "Add Preparation Instruction", 
                          hintStyle: new TextStyle(
                            color: hintColor()
                          )
                        ), 
                        style: new TextStyle(
                          color: textColor()
                        ),
                        onChanged: (value) {
                          currentlyAddingPreparation = value;
                        },
                        controller: preparationTextFieldController,
                      ); 
                      return addPreparationTextField;
                    },
                  )
                ),
                new IconButton(
                  icon: new Icon(Icons.add, color: textColor(),),
                  onPressed: () {
                    setState(() {
                      if (currentlyAddingPreparation != null && currentlyAddingPreparation != '') {
                        widget.recipe.preparationInstructions.add(currentlyAddingPreparation);
                        preparationTextFieldController.clear();
                        addPreparationTextField.focusNode.unfocus();
                        currentlyAddingPreparation = '';
                      }
                    });
                  },
                )
              ],
            )
          ));
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
                  fontWeight: FontWeight.bold, color: textColor()),
            ))
          ];

          for (int i = 0; i < widget.recipe.cookingInstructions.length; i++) {
            cookingChecked.add(false);
            cookingList.add(new ListTile(
              title: new Row(
                children: <Widget>[
                  new Flexible(
                      child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text("${widget.recipe.cookingInstructions[i]}",
                          textAlign: TextAlign.left,
                          style: new TextStyle(color: textColor()))
                    ],
                  ))
                ],
              ),
              trailing: new IconButton(
                icon: new Icon(Icons.delete, color: Colors.red[300]),
                onPressed: () {
                  print("Delete item");
                  setState(() {
                    print("removing item ${widget.recipe.cookingInstructions[i]}");
                    widget.recipe.cookingInstructions.removeAt(i);
                  });
                },
              ),
              onTap: () {
                setState(() {
                  cookingChecked[i] = !cookingChecked[i];
                });
              },
            ));
          }
          TextField addCookingTextField;
          cookingList.add(new Container(
            padding: new EdgeInsets.only(left: 20.0, right: 20.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: new EnsureVisible(
                    builder: (BuildContext context, FocusNode node) {
                      addCookingTextField = new TextField(
                        focusNode: node,
                        decoration: new InputDecoration(
                          hintText: "Add Cooking Instruction", 
                          hintStyle: new TextStyle(
                            color: hintColor()
                          )
                        ), 
                        style: new TextStyle(
                          color: textColor()
                        ),
                        onChanged: (value) {
                          currentlyAddingCooking = value;
                        },
                        controller: cookingTextFieldController,
                      );
                      return addCookingTextField;
                    },
                  )
                ),
                new IconButton(
                  icon: new Icon(Icons.add, color: textColor(),),
                  onPressed: () {
                    setState(() {
                      if (currentlyAddingCooking != null && currentlyAddingCooking != '') {
                        widget.recipe.cookingInstructions.add(currentlyAddingCooking);
                        cookingTextFieldController.clear();
                        addCookingTextField.focusNode.unfocus();
                        currentlyAddingCooking = '';
                      }
                    });
                  },
                )
              ],
            )
          ));

          return new Container(
              decoration:
                  new BoxDecoration(color: widget.recipe.theme.primaryColor),
              padding: new EdgeInsets.only(bottom: 16.0),
              child: new Column(
                children: cookingList,
              ));
        } else {
          return new Container(
            height: 1.0,
          );
        }
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
        backgroundColor: widget.recipe.theme.primaryColor,
        appBar: new AppBar(
          title: new Text(widget.title),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.save),
              onPressed: () {
                print("Save new recipe with local image path: $localImagePath");
                widget.recipe.imageURL = localImagePath;
                new Firebase(table: FirebaseTables.categories).createNewRecipeForUser(userID: User.idToken, recipe: widget.recipe, categoryID: widget.categoryID);
                Utils.alert(context: context, title: "Recipe Has Been Saved!", content: "Let's start cooking!");
              },
            )
          ],
        ),
        body: new Builder(
          builder: (BuildContext context) {
            return new ListView.builder(
              padding: new EdgeInsets.only(top: 0.0),
              itemBuilder: (_, int index) =>
                  cellBuilder(index, context: context),
              itemCount: 6,
              shrinkWrap: true,
            );
          },
        ));
  }
}