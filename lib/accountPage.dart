import 'package:flutter/material.dart';
import 'dart:async';
import 'Controls/nButton.dart';
import 'Controls/nTextField.dart';
import 'user.dart';
import 'Util/utils.dart';
import 'creditPage.dart';

String loginText = "Login";
String greetingText = "Hello!";

class AccountPage extends StatefulWidget {
  @override
  AccountPageState createState() => new AccountPageState();
}

class AccountPageState extends State<AccountPage> {

  void _setSignInValues() {
    print("Set sign in values");
    if (User.isSignedIn())
    {
      greetingText = "Hello, ${User.googleSignIn.currentUser.displayName}!";
      loginText = "Logout";
    }
    else
    {
      greetingText = "Hello!";
      loginText = "Login with Google";
    }
  }

  void updateSignIn() {
    setState(() {
      _setSignInValues();
    });
  }

  void signIn() {
    User.ensureLoggedIn(callback: () {
      updateSignIn();
    });
  }

  void signOut() {
    User.signOut(callback: () {
      updateSignIn();
    });
  }

  /// Modal dialog for signing in
  Future<Null> _showLoginDialog() async {
    await showDialog(
      context: context,
      child: new SimpleDialog(
        contentPadding: new EdgeInsets.only(left: 20.0, right: 20.0, bottom: 45.0, top: 20.0),
        title: new Text('Login'),
        children: <Widget>[
          new Container(
            child: new Column(
              children: <Widget>[
                new Container(
                  padding: new EdgeInsets.only(bottom: 10.0),
                  child: new NTextField(hint: "Username")
                ),
                new Container(
                  child: new NTextField(hint: "Password")
                ),
                new Container(
                  padding: new EdgeInsets.only(top: 20.0, bottom: 35.0),
                  child: new NButton(
                    text: "Submit",
                    onPressed: () {
                      
                    }),
                ),
                new Text("By signing in, you agree to our terms and conditions", style: new TextStyle(fontSize: 10.0))
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _setSignInValues();
    return new Container(
      color: Colors.white,
      child: new Column(
        children: <Widget>[
          new ListTile(
            title: new Text(greetingText),
            onTap: () {
              print("cell tapped");
            },
            trailing: new GestureDetector(
              onTap: () {
                print("Logout tapped");
                if (!User.isSignedIn())
                  signIn();
                else
                  signOut();
              },
              child: new Text(loginText)
            )
          ),
          new Divider(),
          new ListTile(
            title: new Text("Contact Us!"),
            onTap: () {
              Email.sendEmail(to: "grenadier89@gmail.com", subject: "Test", content: "Test_body", context: context);
            }
          ),
          new Divider(),
          new ListTile(
            title: new Text("Credits"),
            onTap: () {
              Navigation.push(context, new CreditPage());
            },
          ),
          new Divider()
        ],
      ),
    );
  }
}