import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:garbage_bogota/util/globals.dart';
import 'package:garbage_bogota/screens/homePage.dart';
import 'package:garbage_bogota/model/user.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = FlutterSecureStorage();

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  Future<String> attemptLogIn(String username, String password) async {
    User usuario = new User(username, password);
    var jsonUser = jsonEncode(usuario);

    var res = await http.post(Globals.urlServ + Globals.endPoinLogin,
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: jsonUser);
    if (res.statusCode == 200) return res.body;
    return null;
  }

  Future<int> attemptSignUp(String username, String password) async {
    var res = await http.post(Globals.urlApi + Globals.endPoinSingUp,
        body: {"username": username, "password": password});
    return res.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Bogota Garbage Collection"),
          backgroundColor: Colors.green,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Text(
                "Log In",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              SizedBox(
                height: 10.0,
              ),
              Image.asset('assets/images/logo.png'),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              RaisedButton(
                onPressed: () async {
                  var username = _usernameController.text;
                  var password = _passwordController.text;
                  var response = await attemptLogIn(username, password);
                  if (response != null) {
                    var resp = jsonDecode(response);
                    storage.write(key: "jwt", value: resp['token']);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomePage.fromBase64(resp['token'])));
                  } else {
                    displayDialog(context, "An Error Occurred",
                        "No account was found matching that username and password");
                  }
                },
                child: Text(
                  "Log In",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                color: Colors.green,
              ),
              RaisedButton(
                onPressed: () async {
                  var username = _usernameController.text;
                  var password = _passwordController.text;

                  if (username.length < 4)
                    displayDialog(context, "Invalid Username",
                        "The username should be at least 4 characters long");
                  else if (password.length < 4)
                    displayDialog(context, "Invalid Password",
                        "The password should be at least 4 characters long");
                  else {
                    var res = await attemptSignUp(username, password);
                    if (res == 201)
                      displayDialog(context, "Success",
                          "The user was created. Log in now.");
                    else if (res == 409)
                      displayDialog(
                          context,
                          "That username is already registered",
                          "Please try to sign up using another username or log in if you already have an account.");
                    else {
                      displayDialog(
                          context, "Error", "An unknown error occurred.");
                    }
                  }
                },
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                color: Colors.lightGreen[300],
              )
            ],
          ),
        ));
  }
}
