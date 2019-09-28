import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_occassions/utils/constants.dart';
import 'package:flutter_occassions/utils/network_check.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignUpPageState();
  }
}

class SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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

  final userReference = FirebaseDatabase.instance.reference().child("Users");
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isAuthenticating = false;

  Widget _buildEmailTextField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
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
      style: TextStyle(color: Colors.white),
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

  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        hintText: "Confirm Password",
        hintStyle: TextStyle(
          color: Colors.grey[400],
        ),
        filled: true,
        fillColor: dateBackgroundColor,
        labelStyle: TextStyle(color: Colors.white),
      ),
      keyboardType: TextInputType.text,
      obscureText: true,
      validator: (String value) {
        if (_passwordController.text != value) {
          return 'Passwords do not match.';
        }
      },
    );
  }

  Widget _buildFormSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50.0,
      child: RaisedButton(
        padding: EdgeInsets.all(10.0),
        textColor: Colors.white,
        child: Text('CONTINUE',style: TextStyle(fontSize: 18.0,),),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: () => _submitAuthForm(),
      ),
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
        final snackBar = SnackBar(content: Text('Please check your internet connection !!'));

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
          .createUserWithEmailAndPassword(
              email: _formData["email"], password: _formData["password"])
          .then((FirebaseUser firebaseUser) async {
        firebaseUserID = firebaseUser.uid;
        print('Signed up user: $firebaseUserID');

        try {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("userEmail", firebaseUser.email);
          prefs.setString("userID", firebaseUserID);

          String firebaseToken = prefs.getString("userToken");
          print("firebaseToken : $firebaseToken");

          final group = prefs.getString("userCompanyCode");

          var targetPlatform =
              Theme.of(context).platform == TargetPlatform.android
                  ? "Android"
                  : "iOS";

          /*DateTime currentTime = DateTime.now();
          var dateFormat = new DateFormat('dd-MM-yyyyTHH:mm:ss');
          String formattedDate = dateFormat.format(currentTime);*/

          await userReference.push().set({
            "name": _formData["name"],
            "email": firebaseUser.email,
            "photo": "-",
            "group": group.isEmpty ? "-" : group,
            "deviceType": targetPlatform,
            "deviceToken": firebaseToken.isEmpty ? "-" : firebaseToken,
            "online": false,
            "statusUpdatedAt": DateTime.now().millisecondsSinceEpoch,
            "userApprovalStatus": 1,
            "updatedAt": DateTime.now().millisecondsSinceEpoch,
            "createdAt": DateTime.now().millisecondsSinceEpoch,
            "userID": firebaseUserID,
          });

          print("success!!!");

          setState(() {
            isAuthenticating = false;
          });

          Navigator.pushReplacementNamed(context, '/dashboard');

          /*Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HolidayListPage()),
          );*/
        } catch (e) {
          setState(() {
            isAuthenticating = false;
          });

          print("Failure Message : " + e.toString());
          print("failed!!!");
        }
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

    /*String firebaseUserID = "";
    try {
      FirebaseUser firebaseUser =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: _formData["email"], password: _formData["password"]);
      firebaseUserID = firebaseUser.uid;
      print('Signed up user: $firebaseUserID');

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("userEmail", firebaseUser.email);
      prefs.setString("userID", firebaseUserID);

      String firebaseToken = prefs.getString("userToken");

      try {
        var targetPlatform =
            Theme.of(context).platform == TargetPlatform.android
                ? "Android"
                : "iOS";

        DateTime currentTime = DateTime.now();
        var dateFormat = new DateFormat('dd-MM-yyyyTHH:mm:ss');
        String formattedDate = dateFormat.format(currentTime);

        await userReference.push().set({
          "name": _formData["name"],
          "email": firebaseUser.email,
          "photo": "-",
          "group": "-",
          "deviceType": targetPlatform,
          "deviceToken": firebaseToken,
          "online": false,
          "statusUpdatedAt": DateTime.now().millisecondsSinceEpoch,
          "userApprovalStatus": 1,
          "updatedAt": DateTime.now().millisecondsSinceEpoch,
          "createdAt": DateTime.now().millisecondsSinceEpoch,
          "userID": firebaseUserID,
        });

        print("success!!!");
      } catch (e) {
        print("Failure Message : " + e.toString());
        print("failed!!!");
      }

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

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      decoration: new BoxDecoration(
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
                  _buildConfirmPasswordTextField(),
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
