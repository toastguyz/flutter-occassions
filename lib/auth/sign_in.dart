import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_occassions/utils/constants.dart';
import 'package:flutter_occassions/utils/network_check.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError }

class SignInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignInPageState();
  }
}

class SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    "email": null,
    "password": null,
    "name": null,
    "group": null,
    "deviceType": null,
    "deviceToken": null,
    "online": false,
    "statusUpdatedAt": null,
    "userApprovalStatus": 1,
    "createdAt": null,
    "updatedAt": null,
  };

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isAuthenticating = false;

  Widget _buildEmailTextField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        hintText: "E-mail",
        hintStyle: TextStyle(
          color: Colors.grey[400],
        ),
        filled: true,
        fillColor: dateBackgroundColor,
      ),
      style: TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String email) {
        if (email.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(email)) {
          return 'Please enter a valid email';
        }
      },
      onSaved: (String email) {
        _formData['email'] = email;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        hintText: "Password",
        hintStyle: TextStyle(
          color: Colors.grey[400],
        ),
        filled: true,
        fillColor: dateBackgroundColor,
      ),
      style: TextStyle(color: Colors.white),
      obscureText: true,
      keyboardType: TextInputType.text,
      validator: (String password) {
        if (password.isEmpty || password.length < 6) {
          return 'Password invalid';
        }
      },
      onSaved: (String password) {
        _formData['password'] = password;
      },
    );
  }

  void _submitAuthForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    NetworkCheck networkCheck = new NetworkCheck();
    networkCheck.checkInternet((isNetworkPresent) async {
      if (!isNetworkPresent) {
        final snackBar =
            SnackBar(content: Text('Please check your internet connection !!'));

        Scaffold.of(context).showSnackBar(snackBar);
        return;
      } else {
        setState(() {
          isAuthenticating = true;
        });
      }
    });

    String firebaseUserID = "";
    try {
      _firebaseAuth
          .signInWithEmailAndPassword(
              email: _formData["email"], password: _formData["password"])
          .then((FirebaseUser firebaseUser) async {
        firebaseUserID = firebaseUser.uid;
        print('Signed in: $firebaseUserID');

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final group = prefs.getString("userCompanyCode");

        final userReference = FirebaseDatabase.instance
            .reference()
            .child("Users")
            .limitToFirst(1)
            .orderByChild("email")
            .equalTo(_formData["email"]);

        userReference.once().then((DataSnapshot snapShot) {
          print("User Data : ${snapShot.value}");
          String firebaseGroup = "";
          for (var value in snapShot.value.values) {
            firebaseGroup = value['group'];
            print("Found Group :  ${value['group']}");
          }

          if (!firebaseGroup.isEmpty && firebaseGroup == group) {
            setState(() {
              isAuthenticating = false;
            });

            prefs.setString("userEmail", firebaseUser.email);
            prefs.setString("userID", firebaseUserID);

            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            setState(() {
              isAuthenticating = false;
            });

            Navigator.pushReplacementNamed(context, '/');
          }
        });

        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HolidayListPage()),
        );*/
      }).catchError((onError) {
        print("Detail Message : ${onError.message}");
        setState(() {
          isAuthenticating = false;
        });

        final snackBar = SnackBar(content: Text(onError.message));
        Scaffold.of(context).showSnackBar(snackBar);
      });
    } catch (e) {
      print('Error: $e');

      setState(() {
        isAuthenticating = false;
      });
    }

    /*try {
      String firebaseUserID = "";
      FirebaseUser firebaseUser =
          await _firebaseAuth.signInWithEmailAndPassword(
              email: _formData["email"], password: _formData["password"]);
      firebaseUserID = firebaseUser.uid;
      print('Signed in: $firebaseUserID');

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("userEmail", firebaseUser.email);
      prefs.setString("userID", firebaseUserID);

      setState(() {
        isAuthenticating = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HolidayListPage()),
      );
    } catch (e) {
      print('Error: $e');

      setState(() {
        isAuthenticating = false;
      });
    }*/
  }

  Widget _buildFormSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50.0,
      child: RaisedButton(
        padding: EdgeInsets.all(10.0),
        textColor: Colors.white,
        child: Text(
          'CONTINUE',
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: () => _submitAuthForm(),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return FlatButton(
      onPressed: () {},
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
          "FORGOT PASSWORD",
          style: TextStyle(
            color: holidayGlobalBackgroundColor,
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      decoration: new BoxDecoration(
//          color: Colors.lightGreen,
        color: Colors.white,
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: targetWidth,
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  _buildEmailTextField(),
                  SizedBox(
                    height: 20.0,
                  ),
                  _buildPasswordTextField(),
                  SizedBox(
                    height: 20.0,
                  ),
                  _buildForgotPasswordButton(),
                  SizedBox(
                    height: 20.0,
                  ),
                  isAuthenticating
                      ? CircularProgressIndicator()
                      : _buildFormSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
