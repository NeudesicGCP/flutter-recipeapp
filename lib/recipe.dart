import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:collection';

class RecipeCategory {
  RecipeCategory({this.imageURL, this.title, this.recipes});
  final String imageURL;
  final String title;
  final List<Recipe> recipes;
}

class Constants {
  static ThemeData defaultTheme = new ThemeData(backgroundColor: Colors.white, primaryColor: Colors.deepPurple, brightness: Brightness.light);
}

enum DietaryFlag {
  vegan, vegetarian, glutenFree, heartHealthy, highProtein, hasNuts, organic, seafood, dairy, honey, eggs, raw
}

enum Unit {
  object, tsp, tbsp, cup, quart, pint, gallon, ounce, fluidOunce, pound, can, unit, bag
}

class Ingredient {
  double quantity;
  String type;
  Unit unit;

  Ingredient({LinkedHashMap<dynamic, dynamic> items}) {
    if (items == null)
      return;
    var q = items['qty'];
    if (q is int) {
      quantity = q.toDouble();
    }
    else {
      quantity = q;
    }
    type = items['type'];
    unit = Ingredient.stringToUnit(items["units"]);
    printIngredient();
  }

  void printIngredient() {
    print("Ingredient = quantity: $quantity, type: $type, unit: $unit");
  }

  void adjustQuantityForServing({bool increase, int byAmount, int originalServings}) {
    if (byAmount == 0)
      return;

    if (increase) {
      var newQuantity = quantity + ((quantity/originalServings) * byAmount);
      quantity = newQuantity;
    }
    else {
      var newQuantity = quantity - ((quantity/originalServings) * byAmount);
      quantity = newQuantity;
    }
  }

  String decimalToFraction(double x) {
    double error = 0.001;
    var n = x.floor();
    x -= n;
    if (x < error)
      return "$n";
    else if (1 - error < x)
      return "${n + 1}";

      int lower_n = 0;
      int lower_d = 1;
      int upper_n = 1;
      int upper_d = 1;
      while (true) {
        int middle_n = lower_n + upper_n;
        int middle_d = lower_d + upper_d;
        if (middle_d * (x + error) < middle_n) {
          upper_n = middle_n;
          upper_d = middle_d;
        }
        else if (middle_n < (x - error) * middle_d) {
          lower_n = middle_n;
          lower_d = middle_d;
        }
        else {
          return "${n * middle_d + middle_n}/$middle_d";
        }
      }
  }

  String humanReadableQuantity() {
    String integer = "";
    String newQuantity = '${quantity.toStringAsPrecision(4)}';
    if (quantity > 1) {
      integer = '${quantity.toInt()} & ';
      newQuantity = (quantity % 1).toStringAsPrecision(4);
    }
    double a = (double.parse(newQuantity));
    if (quantity % 1 == 0)
      return '${quantity.toInt()}';
    return '$integer${decimalToFraction(a)}';
  }

  String unitToString() {
    return Ingredient.convertUnitToString(unit);
  }

  static String convertUnitToString(Unit unit) {
    switch (unit) {
      case Unit.object:
        return '';
      case Unit.tsp:
        return 'tsp';
      case Unit.tbsp:
        return 'tbsp';
      case Unit.cup:
        return 'cup';
      case Unit.quart:
        return 'qt';
      case Unit.pint:
        return 'pt';
      case Unit.gallon:
        return 'gal';
      case Unit.ounce:
        return 'oz';
      case Unit.fluidOunce:
        return 'fl oz';
      case Unit.pound:
        return 'lb';
      case Unit.can:
        return 'can';
      case Unit.unit:
        return 'unit';
      case Unit.bag:
        return 'bag';
      default:
        return '';
    }
  }

  static String convertIntToUnitString(int unit) {
    if (unit == Unit.object.index)
      return Ingredient.convertUnitToString(Unit.object);
    if (unit == Unit.tsp.index)
      return Ingredient.convertUnitToString(Unit.tsp);
    else if (unit == Unit.tbsp.index)
      return Ingredient.convertUnitToString(Unit.tbsp);
    else if (unit == Unit.cup.index)
      return Ingredient.convertUnitToString(Unit.cup);
    else if (unit == Unit.quart.index)
      return Ingredient.convertUnitToString(Unit.quart);
    else if (unit == Unit.pint.index)
      return Ingredient.convertUnitToString(Unit.pint);
    else if (unit == Unit.gallon.index)
      return Ingredient.convertUnitToString(Unit.gallon);
    else if (unit == Unit.ounce.index)
      return Ingredient.convertUnitToString(Unit.ounce);
    else if (unit == Unit.fluidOunce.index)
      return Ingredient.convertUnitToString(Unit.fluidOunce);
    else if (unit == Unit.pound.index)
      return Ingredient.convertUnitToString(Unit.pound);
    else if (unit == Unit.can.index)
      return Ingredient.convertUnitToString(Unit.can);
    else if (unit == Unit.unit.index)
      return Ingredient.convertUnitToString(Unit.unit);
    else if (unit == Unit.bag.index)
      return Ingredient.convertUnitToString(Unit.bag);
    return '';
  }

  static Unit stringToUnit(String value) {
      switch (value) {
        case '':
          return Unit.object;
        case 'tsp':
          return Unit.tsp;
          break;
        case 'tbsp':
          return Unit.tbsp;
          break;
        case 'cup':
          return Unit.cup;
          break;
        case 'qt':
          return Unit.quart;
          break;
        case 'pt':
          return Unit.pint;
          break;
        case 'gal':
          return Unit.gallon;
          break;
        case 'oz':
          return Unit.ounce;
          break;
        case 'floz':
          return Unit.fluidOunce;
          break;
        case 'lb':
          return Unit.pound;
        case 'can':
          return Unit.can;
        case 'unit':
          return Unit.unit;
        case 'bag':
          return Unit.bag;
          break;
        default:
          return Unit.tsp;
      }
    }
}

class Recipe {
  Recipe({this.recipeID = -1, this.imageURL, this.title = "", this.minutes = 0, this.ingredients, this.preparationInstructions, this.cookingInstructions, this.theme, this.favorite = false, this.rating = 0.0, this.dietaryFlags, this.locked = false, this.calories = 0, this.servings = 1 }) {
    if (theme == null) {
      this.theme = Constants.defaultTheme;
    }
    if (ingredients == null) {
      this.ingredients = [];
    }
    if (preparationInstructions == null) {
      this.preparationInstructions = [];
    }
    if (cookingInstructions == null) {
      cookingInstructions = [];
    }
  } 
  
  final int recipeID;
  String imageURL;
  String title;
  int minutes;
  List<Ingredient> ingredients = [];
  List<String> preparationInstructions = [];
  List<String> cookingInstructions = [];
  List<DietaryFlag> dietaryFlags = [];
  double rating;
  int calories;
  int servings;
  bool favorite;
  bool locked;
  int date;
  ThemeData theme;

  Recipe.fromSnapshot(DataSnapshot snapshot) : 
    recipeID = snapshot.value["recipeID"], 
    imageURL = snapshot.value["imageURL"], 
    title = snapshot.value["title"],
    minutes = snapshot.value["mintes"],
    ingredients = Recipe._generateIngredientsList(itemsList: snapshot.value["ingredients"] as List<dynamic>),
    preparationInstructions = (snapshot.value["preparationInstructions"] as List<dynamic>).cast<String>(),
    cookingInstructions = (snapshot.value["cookingInstructions"] as List<dynamic>).cast<String>(),
    rating = snapshot.value["rating"] is int ? (snapshot.value["rating"] as int).toDouble() : snapshot.value["rating"] is double ? snapshot.value["rating"] as double : 0.0,
    theme = Recipe._generateTheme(colorString: snapshot.value["themeColor"]),
    calories = snapshot.value["cal"] ?? 0,
    servings = snapshot.value["servings"] ?? 1,
    favorite = false,
    locked = snapshot.value["locked"],
    date = snapshot.value["date"] ?? new DateTime.now().millisecondsSinceEpoch,
    dietaryFlags = Recipe._generateDietaryFlag(flags: (snapshot.value["dietary"] as LinkedHashMap<dynamic, dynamic>));

  static _generateIngredientsList({List<dynamic> itemsList}) {
    List<Ingredient> ingredientsList = [];
    for (LinkedHashMap<dynamic, dynamic> items in itemsList) {
      var i = new Ingredient(items: items);
      ingredientsList.add(i);
    }
    return ingredientsList;
  }
  
  static _generateDietaryFlag({LinkedHashMap<dynamic, dynamic> flags}) {
    List<DietaryFlag> dietaryFlags = [];

    if (flags == null)
      return dietaryFlags;

    try
    {
      for (String flag in flags.keys)
      {
        if (!flags[flag])
          continue;
          
        switch (flag)
        {
          case "v":
            dietaryFlags.add(DietaryFlag.vegan);
            break;
          case "gf":
            dietaryFlags.add(DietaryFlag.glutenFree);
            break;
          case "vg":
            dietaryFlags.add(DietaryFlag.vegetarian);
            break;
          case "hh":
            dietaryFlags.add(DietaryFlag.heartHealthy);
            break;
          case "p":
            dietaryFlags.add(DietaryFlag.highProtein);
            break;
          case "n":
            dietaryFlags.add(DietaryFlag.hasNuts);
            break;
          case "o":
            dietaryFlags.add(DietaryFlag.organic);
            break;
          case "s":
            dietaryFlags.add(DietaryFlag.seafood);
            break;
          case "d":
            dietaryFlags.add(DietaryFlag.dairy);
            break;
          case "h":
            dietaryFlags.add(DietaryFlag.honey);
            break;
          case "e":
            dietaryFlags.add(DietaryFlag.eggs);
            break;
          case "r":
            dietaryFlags.add(DietaryFlag.raw);
            break;
          default:
            break;
        }
      }
    }
    catch (e) { }
    return dietaryFlags;
  }

  static dietaryFlagToImageFile(DietaryFlag flag, {bool light = false}) {
    switch (flag) {
      case DietaryFlag.vegan:
        return "vegan-symbol${light ? '-light' : ''}.png";
        break;
      case DietaryFlag.vegetarian:
        return "vegan-symbol${light ? '-light' : ''}.png";
        break;
      case DietaryFlag.glutenFree:
        return "gluten-free${light ? '-light' : ''}.png";
        break;
      case DietaryFlag.heartHealthy:
        return "cardiogram${light ? '-light' : ''}.png";
        break;
      case DietaryFlag.highProtein:
        return "proteins${light ? '-light' : ''}.png";
        break;
      case DietaryFlag.hasNuts:
        return "peanuts-allergens${light ? '-light' : ''}.png";
        break;
      case DietaryFlag.organic:
        return "organic${light ? '-light' : ''}.png";
        break;
      case DietaryFlag.seafood:
        return "sea-food${light ? '-light' : ''}.png";
        break;
      case DietaryFlag.dairy:
        return "allergens-nilk${light ? '-light' : ''}.png";
        break;
      case DietaryFlag.honey:
        return "honey${light ? '-light' : ''}.png";
        break;
      case DietaryFlag.eggs:
        return "allergens-eggs${light ? '-light' : ''}.png";
        break;
      case DietaryFlag.raw:
        return "raw-food${light ? '-light' : ''}r.png";
        break;
      default:
        break;
    }
    return "null";
  }

  static dietaryFlagToTitle(DietaryFlag flag, {bool light = false}) {
    switch (flag) {
      case DietaryFlag.vegan:
        return "Vegan";
        break;
      case DietaryFlag.vegetarian:
        return "Vegetarian";
        break;
      case DietaryFlag.glutenFree:
        return "Gluten Free";
        break;
      case DietaryFlag.heartHealthy:
        return "Heart Healthy";
        break;
      case DietaryFlag.highProtein:
        return "High Protein";
        break;
      case DietaryFlag.hasNuts:
        return "Contains Nuts";
        break;
      case DietaryFlag.organic:
        return "Organic";
        break;
      case DietaryFlag.seafood:
        return "Contains Seafood";
        break;
      case DietaryFlag.dairy:
        return "Contains Dairy";
        break;
      case DietaryFlag.honey:
        return "Contains Honey";
        break;
      case DietaryFlag.eggs:
        return "Contains Eggs";
        break;
      case DietaryFlag.raw:
        return "Raw";
        break;
      default:
        break;
    }
    return "null";
  }

  static DietaryFlag intToDietaryFlag(int value) {
    if (value == DietaryFlag.vegan.index)
      return DietaryFlag.vegan;
    if (value == DietaryFlag.vegetarian.index)
      return DietaryFlag.vegetarian;
    if (value == DietaryFlag.glutenFree.index)
      return DietaryFlag.glutenFree;
    if (value == DietaryFlag.heartHealthy.index)
      return DietaryFlag.heartHealthy;
    if (value == DietaryFlag.highProtein.index)
      return DietaryFlag.highProtein;
    if (value == DietaryFlag.hasNuts.index)
      return DietaryFlag.hasNuts;
    if (value == DietaryFlag.organic.index)
      return DietaryFlag.organic;
    if (value == DietaryFlag.seafood.index)
      return DietaryFlag.seafood;
    if (value == DietaryFlag.dairy.index)
      return DietaryFlag.dairy;
    if (value == DietaryFlag.honey.index)
      return DietaryFlag.honey;
    if (value == DietaryFlag.eggs.index)
      return DietaryFlag.eggs;
    if (value == DietaryFlag.raw.index)
      return DietaryFlag.raw;
    return DietaryFlag.organic;
  }

  static ThemeData _generateTheme({String colorString}) {
    Color color = Colors.white;
    try
    {
      switch (colorString) {
        case 'deepOrange':
          color = Colors.deepOrange;
          break;
        case 'deepPurple':
          color = Colors.deepPurple;
          break;
        case 'blue':
          color = Colors.indigo[800];
          break;
        case 'white':
          color = Colors.white;
          break;
        case 'black':
          color = Colors.black;
          break;
        default:
          try {
            var rgb = colorString.split(',');
            Color c = new Color.fromRGBO(int.parse(rgb[0]), int.parse(rgb[1]), int.parse(rgb[2]), rgb.length == 4 ? double.parse(rgb[3]) : 1.0);
           return new ThemeData(primaryColor: c); 
          } catch (e) {
            print("error creating color for recipe theme");
          }
          break;
      }
    }
    catch (e)
    {
      print("Error assigning theme color for recipe: $e");
    }
    return new ThemeData(primaryColor: color);
  }

  void adjustQuantityForServings({int newServings}) {
    bool increase = newServings < servings ? false : true;
    int amount = (newServings - servings).abs();

    for (Ingredient ingredient in ingredients) {
      ingredient.adjustQuantityForServing(increase: increase, byAmount: amount, originalServings: servings);
    }
    servings = newServings;
  }
}