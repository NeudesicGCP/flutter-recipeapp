import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:recipes/user.dart';
import 'package:recipes/recipe.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

//Firebase
import 'package:firebase_database/firebase_database.dart'; 

enum FirebaseTables {
    categories, users, ratings
  }

class Firebase {
  FirebaseTables table;
  DatabaseReference reference;

  Firebase({this.table, String path}) : assert(table != null || path != null) {
    String t = '';
    if (path != null) {
      t = path;
    }
    else {
      switch (table) {
        case FirebaseTables.categories:
          t = "categories";
          print("Table toString(): ${table.toString()}");
          break;
        case FirebaseTables.users:
          t = "users";
          break;
        case FirebaseTables.ratings:
          t = "ratings";
          break;
        default:
          break;
      }
    }
    reference = FirebaseDatabase.instance.reference().child(t);
  }

  /// Determine if the given recipeID under the CategoryID is a favorite
  Future<bool> userHasFavorites({String userID}) async {
    if (table != FirebaseTables.users)
      throw new Exception("DB reference is not users");

    print("checking if user has favorites for userID: $userID...");
    final userFavoritesReference = reference.child('$userID').child('favorites').limitToFirst(1);
    var b = userFavoritesReference.once().then((h) {
      print('here');
      print("H value: ${h.value}");
      if (h.value != null) {
        print("User has favorites");
        return true;
      }
      else {
        print("User does not have favorites");
        return false;
      }
    }).catchError((error) {
      if (error is NoSuchMethodError) {
        //no data exists, so set initial data
        print("Error trying to see if user has favorites: $error");
        return false;
      }
    });
    return b;
  }

  /// Determine if the given recipeID under the CategoryID is a favorite
  Future<bool> isFavorite({String userID, int categoryID, int recipeID}) async {
    if (table != FirebaseTables.users)
      throw new Exception("DB reference is not users");

    final userFavoritesReference = reference.child('$userID').child('favorites').child('categoryID-$categoryID');
    var a = userFavoritesReference.child('recipeIDs').orderByKey();
    var b = a.once().then((h) {
      List<int> recipeFavorites = (h.value as List<dynamic>).cast<int>();
      List<int> newRecipeFavoritesList = [];
      newRecipeFavoritesList.addAll(recipeFavorites);
      if (newRecipeFavoritesList.contains(recipeID))
      { //Remove favorite
        return true;
      }
      else
      { //Add favorite
        return false;
      }
    }).catchError((error) {
      if (error is NoSuchMethodError) {
        //no data exists, so set initial data
        return false;
      }
    });
    return b;
  }

  /// Set a recipe as the favorite for the given CategoryID and RecipeIDs
  void setFavorite({String userID, int categoryID, int recipeID}) {
    if (table != FirebaseTables.users)
      throw new Exception("DB reference is not users");

    final userFavoritesReference = reference.child('$userID').child('favorites').child('categoryID-$categoryID');
    var a = userFavoritesReference.child('recipeIDs').orderByKey();
    if (a != null) {
      var b = a.once();
      b.then((h) {
        List<int> recipeFavorites = (h.value as List<dynamic>).cast<int>();
        List<int> newRecipeFavoritesList = [];
        newRecipeFavoritesList.addAll(recipeFavorites);
        if (newRecipeFavoritesList.contains(recipeID))
        { //Remove favorite
          newRecipeFavoritesList.remove(recipeID);
        }
        else
        { //Add favorite
          newRecipeFavoritesList.add(recipeID);
        }

        //Save favorites
        if (newRecipeFavoritesList.length == 0) {
          userFavoritesReference.remove();
        }
        else {
          userFavoritesReference.set({
            'recipeIDs': newRecipeFavoritesList,
            'count': newRecipeFavoritesList.length
          });
        }
      }).catchError((error) {
        if (error is NoSuchMethodError) {
          //no data exists, so set initial data
          userFavoritesReference.set({
            'recipeIDs': [recipeID],
            'count': 1
          });
        }
      });
    }
  }

  /// Save current users display name if it's not already saved, or overwrite the existing name
  void saveDisplayName({String userID, String displayName}) {
    if (table != FirebaseTables.users)
      throw new Exception("DB reference is not users");

    final userFavoritesReference = reference.child('$userID').child('userInfo');
    userFavoritesReference.set({
      'displayName': displayName
    });
  }

  /// Save current users display name if it's not already saved, or overwrite the existing name
  Future<dynamic> getDisplayName({String userID, String displayName}) async {
    if (table != FirebaseTables.users)
      throw new Exception("DB reference is not users");

    final userFavoritesReference = reference.child('$userID').child('userInfo').orderByKey();
    var b = userFavoritesReference.once().then((h) async {
      if (h != null) {
        if (h.value != null)
          return h.value["displayName"];
        else
          return "Jane Doe";
      }
    }).catchError((Error error) {
      if (error is NoSuchMethodError) {
        return "N/A";
      }
    });
    return b;
  }

  /// Get the recipe name for the given RecipeID and CategoryID
  Future<dynamic> recipeIDToName({int categoryID, int recipeID}) async {
    if (table != FirebaseTables.categories)
      throw new Exception("DB reference is not categories");

    final userFavoritesReference = reference.orderByKey();
    var b = userFavoritesReference.once().then((h) async {
      for (dynamic category in (h.value as List<dynamic>)) {
        if (category["categoryID"] == categoryID) {
          for (dynamic recipe in (category["recipes"] as List<dynamic>)) {
            if (recipe["recipeID"] == recipeID) {
              return recipe["title"];
            }
          }
        }
      }
      return 'Not Found';
    }).catchError((Error error) {
      if (error is NoSuchMethodError) {
        return "N/A";
      }
    });
    return b;
  }

  /// Get recipe snapshot for the given categoryID and recipeID
  Future<DataSnapshot> getRecipe({int categoryID, int recipeID}) async {
    if (table != FirebaseTables.categories)
      throw new Exception("DB reference is not categories");

    final userFavoritesReference = reference.orderByKey();
    var b = userFavoritesReference.once().then((h) async {
      int categoryIndex = 0;
      for (var category in h.value) {
        if (category["categoryID"] == categoryID) {
          int recipeIndex = 0;
          for (var recipe in category["recipes"]) {
            if (recipe["recipeID"] == recipeID) {
              return await reference.child('$categoryIndex/recipes/$recipeIndex').once().then((value) {
                return value;
              });
            }
            recipeIndex++;
          }
        }
        categoryIndex++;
      }
    }).catchError((Error error) {
      print("Error getting recipe: $error");
      if (error is NoSuchMethodError) {
        //return null;
      }
    });
    return b;
  }

  /// Get the category name for the given CategoryID
  Future<dynamic> categoryIDToName({int categoryID}) async {
    if (table != FirebaseTables.categories)
      throw new Exception("DB reference is not categories");

    final userFavoritesReference = reference.orderByKey();
    var b = userFavoritesReference.once().then((h) {
      for (dynamic category in (h.value as List<dynamic>)) {
        if (category["categoryID"] == categoryID)
          return category["name"];
      }
      return "Unknown";
    }).catchError((Error error) {
      if (error is NoSuchMethodError) {
        return "N/A";
      }
    });
    return b;
  }

  /// Get the recipe for the given CategoryID and RecipeID
  Future<DataSnapshot> recipeForID({int categoryID, int recipeID}) async {
    return await getRecipe(categoryID: categoryID, recipeID: recipeID);
  }

  /// pull the current rating for the recipe, create new average and save new rating to database
  Future<void> updateRatingForRecipe({int categoryID, int recipeID, double rating}) async {
    final recipiesSnapshot = await getRecipe(categoryID: categoryID, recipeID: recipeID);
    var oldRating = recipiesSnapshot.value["rating"];

    double newRating = 5.0;
    if (oldRating == 0.0) {
      newRating = rating;
    }
    else {
      newRating = (oldRating + rating) / 2;
      if (newRating % 1 > 0.75) {
        newRating = newRating.ceil().toDouble();
      }
      else if (newRating % 1 > 0.25) {
        newRating = newRating.floor() + 0.5;
      }
      else {
        newRating = newRating.floor().toDouble();
      }
    }

      // Set new rating in database
    await reference.once().then((h) async {
      int categoryIndex = 0;
      int recipeIndex = 0;
      for (var category in h.value) {
        if (category["categoryID"] == categoryID) {
          bool found = false;
          for (var recipe in category["recipes"]) {
            if (recipe["recipeID"] == recipeID) {
              found = true;
              break;
            }
            recipeIndex++;
          }
          if (found)
            break;
        }
        categoryIndex++;
      }

      reference.child('$categoryIndex/recipes/$recipeIndex/rating').set(newRating);

      return null;
    });
  }

  Future<dynamic> categoryAndRecipeIndexForIDs({int categoryID, int recipeID}) async {
    var reference = FirebaseDatabase.instance.reference().child("categories");
    var result = await reference.once().then((h) async {
      int categoryIndex = 0;
      int recipeIndex = 0;
      for (var category in h.value) {
        if (category["categoryID"] == categoryID) {
          bool found = false;
          for (var recipe in category["recipes"]) {
            if (recipe["recipeID"] == recipeID) {
              found = true;
              break;
            }
            recipeIndex++;
          }
          if (found)
            break;
        }
        categoryIndex++;
      }
      return { "categoryIndex": categoryIndex, "recipeIndex": recipeIndex };
    });
    return result;
  }

  /// User's specific category index for categoryID
  Future<dynamic> categoryIndexForID({int categoryID}) async {
    if (table != FirebaseTables.categories)
        throw new Exception("DB reference is not categories");
    var r = reference;
    var result = await r.once().then((h) async {
      int categoryIndex = 0;
      if (h.value != null) {
        for (var category in h.value) {
          if (category["categoryID"] == categoryID)
              break;
          categoryIndex++;
        }
      }
      return categoryIndex;
    });
    return result;
  }

  Future<dynamic> highestRecipeIndexForID({int categoryID}) async {
    if (table != FirebaseTables.categories)
        throw new Exception("DB reference is not categories");
    var r = reference;
    var result = await r.once().then((h) async {
      int recipeIndex = 0;
      if (h.value != null) {
        for (var category in h.value) {
          if (category["categoryID"] == categoryID) {
            for (var _ in category["recipes"]) {
              recipeIndex++;
            }
            break;
          }
        }
      }
      return recipeIndex;
    });
    return result;
  }

  Future<dynamic> highestRecipeID({int categoryID}) async {
    if (table != FirebaseTables.categories)
        throw new Exception("DB reference is not categories");
    var r = reference;
    var result = await r.once().then((h) async {
      int recipeID = 0;
      if (h.value != null) {
        for (var category in h.value) {
          if (category["categoryID"] == categoryID) {
            for (var recipe in category["recipes"]) {
              if (recipe["recipeID"] > recipeID) {
                recipeID = recipe["recipeID"];
              }
            }
            break;
          }
        }
      }
      else
        recipeID = 1;
      return recipeID;
    });
    return result;
  }

  /// Sets a review for the current recipe under the users profile
  /// 
  /// 
  /// *Example:*
  /// ```
  /// Firebase a = new Firebase(table: FirebaseTables.ratings);
  /// a.createRecipeReviewForUser(
  ///   categoryID: categoryID, 
  ///   recipeID: recipeID, 
  ///   userID: User.idToken, 
  ///   rating: 4.0, 
  ///   review: "Mry review");
  /// ```
  Future<void> createRecipeReviewForUser({@required int categoryID, @required int recipeID, @required double rating, String review = '', dynamic image}) async {
    try
    {
      String userID;
      print("saving review...");
      if (table != FirebaseTables.ratings)
        throw new Exception("DB reference is not ratings");

      if (!User.isSignedIn()) {
        await User.attemptPreviousLogin();
        userID = User.idToken ?? null;
      }
      else
        userID = User.idToken ?? null;

      if (!User.isSignedIn())
          throw new Exception("User must be signed in!");

      if (review != '') {
        var b = reference.child("categoryID-$categoryID/recipeID-$recipeID/$userID");
        b.set(
          {
            "rating": rating, 
            "review": review,
            "date": DateTime.now().millisecondsSinceEpoch
          });
        print("REVIEW SET. Now updating display name average rating on recipe...");

        reference = FirebaseDatabase.instance.reference().child("users");
        table = FirebaseTables.users;
        var displayName = User.googleSignIn.currentUser.displayName;
        saveDisplayName(userID: userID, displayName: displayName);
      }

      reference = FirebaseDatabase.instance.reference().child("categories");
      table = FirebaseTables.categories;
      await updateRatingForRecipe(categoryID: categoryID, recipeID: recipeID, rating: rating);

    }
    catch (error) {
      print("Error trying to save review: $error");
    }
  }

  /// Get the saved review for the user. Returns dictionary with ```{"rating: double, review: String, date: DateTime"}```
  /// 
  /// Example
  /// ```
  /// await new Firebase(table: FirebaseTables.ratings).getRecipeReviewForUser(categoryID: widget.categoryID, recipeID: widget.recipe.recipeID);
  /// ```
  Future<dynamic> getRecipeReviewForUser({@required int categoryID, @required int recipeID}) async {
    try
    {
      String userID;
      print("saving review...");
      if (table != FirebaseTables.ratings)
        throw new Exception("DB reference is not ratings");

      if (!User.isSignedIn()) {
        await User.attemptPreviousLogin();
        userID = User.idToken ?? null;
      }
      else
        userID = User.idToken ?? null;

      if (!User.isSignedIn())
          throw new Exception("User must be signed in!");

      var b = reference.child("categoryID-$categoryID/recipeID-$recipeID/$userID").orderByKey();

      var c = b.once().then((h) {
        return h.value;
      });
      return c;
    }
    catch (error) {
      print("Error trying to save review: $error");
    }
    return null;
  }

  Future<dynamic> getRecipeReviews({@required int categoryID, @required int recipeID}) async {
    try
    {
      if (table != FirebaseTables.ratings)
        throw new Exception("DB reference is not ratings");

      var b = reference.child("categoryID-$categoryID/recipeID-$recipeID").orderByKey();

      var c = b.once().then((h) {
        return h.value;
      });
      return c;
    }
    catch (error) {
      print("Error trying to save review: $error");
    }
    return null;
  }

  Future<dynamic> createNewRecipeForUser({String userID, Recipe recipe, int categoryID}) async {
    String userID;
    print("saving recipe...");
    if (table != FirebaseTables.categories)
      throw new Exception("DB reference is not categories");

    if (!User.isSignedIn()) {
      await User.attemptPreviousLogin();
      userID = User.idToken ?? null;
    }
    else
      userID = User.idToken ?? null;

    if (!User.isSignedIn())
      throw new Exception("User must be signed in!");

    var i = await categoryIndexForID(categoryID: categoryID);
    var j = await highestRecipeIndexForID(categoryID: categoryID);

    var downloadURL = await saveRecipePhoto(recipe.imageURL);
    print("NEW DOWNLOAD URL: $downloadURL");

    var r = reference.child("$i/recipes/$j");
    print("Path: ${r.path}");
    List<Map<String, dynamic>> ingredients = [];
    for (Ingredient i in recipe.ingredients) {
      ingredients.add({
        "qty": i.quantity,
        "type": i.type,
        "units": Ingredient.convertUnitToString(i.unit)
      });
    }
    r.set(
      {
        "userID": userID,
        "cal": recipe.calories,
        "imageURL": downloadURL,
        "locked": false,
        "mintes": recipe.minutes,
        "rating": 0,
        "recipeID": recipe.recipeID,
        "servings": recipe.servings,
        "title": recipe.title,
        "ingredients": ingredients,
        "preparationInstructions": recipe.preparationInstructions,
        "cookingInstructions": recipe.cookingInstructions

      }
    );
  }

  Future<String> saveRecipePhoto(String imagePath) async {
    try {
      DateTime now = new DateTime.now();
      String currentdate = '${now.millisecondsSinceEpoch}';
      File imageFile = new File.fromUri(new Uri.file(imagePath));


      StorageReference ref = FirebaseStorage.instance
          .ref()
          .child("recipeImages")
          .child("$currentdate.jpg");
      StorageUploadTask uploadTask = ref.put(imageFile);

      Uri downloadUrl = (await uploadTask.future).downloadUrl;
      String downloadLink = downloadUrl.toString();
      print(downloadLink);
      return downloadLink;
    } catch (error) {print(error);}
    return '';
  }

  Future<dynamic> getCategoriesInRange({int categoryIDStart, int categoryIDEnd}) async {
    if (table != FirebaseTables.categories)
        throw new Exception("DB reference is not categories");
    var r = reference;
    print("PATH: " + r.path);
    var result = await r.orderByChild("categoryID").startAt(categoryIDStart, key: "categoryID").endAt(categoryIDEnd, key: "categoryID").once().then((h) async {
      print("H Key: ${h.key}; H value: ${h.value}");
      return h.value;
    }, onError: (e) {
      print("OnError: $e");
    });
    return result;
  }
}