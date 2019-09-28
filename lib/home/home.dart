import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_occassions/utils/constants.dart';
import 'package:flutter_occassions/utils/network_check.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final TextEditingController holidayCodeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  var holidayFocusNode = new FocusNode();
  bool isLoading = false;

  Widget _buildLabelField() {
    return Text(
      "CODE",
      style: TextStyle(
        color: dateBackgroundColor,
        fontWeight: FontWeight.w400,
        fontSize: 25.0,
      ),
    );
  }

  Widget _buildHolidayFormField() {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: holidayCodeController,
                maxLength: 10,
                focusNode: holidayFocusNode,
                decoration: InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  hintText: "",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0,
                  ),
                ),
                textAlign: TextAlign.end,
                validator: ((String holidayCode) {
                  if (holidayCode.isEmpty) {
                    return 'Company code is required !!';
                  }
                }),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: GestureDetector(
              onTap: () {
                holidayFocusNode.unfocus();
                FocusScope.of(context).requestFocus(holidayFocusNode);
              },
              child: Text(
                "| holidays",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _buildHolidayFormField() {
    return Padding(
      padding: EdgeInsets.all(
        5.0,
      ),
      child: Form(
        key: _formKey,
        child: TextFormField(
          controller: holidayCodeController,
          maxLength: 10,
          decoration: InputDecoration(
            counterText: "",
            border: UnderlineInputBorder(
              borderSide: new BorderSide(
                color: Colors.grey,
              ),
            ),
            hintText: "holidays",
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 20.0,
            ),
          ),
          textAlign: TextAlign.center,
          validator: ((String holidayCode) {
            if (holidayCode.isEmpty) {
              return 'Company code is required !!';
            }
          }),
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }*/

  Widget _buildCodeField() {
    return Container(
      padding: EdgeInsets.only(
        left: 5.0,
        top: 10.0,
        right: 5.0,
        bottom: 10.0,
      ),
      width: double.infinity,
      alignment: Alignment.topLeft,
      child: Text(
        "* Please provide your company code",
        style: TextStyle(
          color: dateBackgroundColor,
          fontWeight: FontWeight.w200,
          fontSize: 12.0,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return RaisedButton(
      padding: EdgeInsets.all(10.0),
      onPressed: () {
        if (!_formKey.currentState.validate()) {
          return;
        }
        _formKey.currentState.save();

        NetworkCheck networkCheck = new NetworkCheck();
        networkCheck.checkInternet((isNetworkPresent) async {
          if (!isNetworkPresent) {
            final snackBar = SnackBar(
                content: Text('Please check your internet connection !!'));

            _scaffoldkey.currentState.showSnackBar(snackBar);
            return;
          } else {
            setState(() {
              isLoading = true;
            });
          }
        });

        getFirebaseCompanyHolidayData(holidayCodeController.text);
      },
      color: dateBackgroundColor,
      child: Text(
        "SUBMIT",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void getFirebaseCompanyHolidayData(String holidayCode) async {
    try {
      final holidayReference = FirebaseDatabase.instance
          .reference()
          .child("Holiday")
          .child(holidayCode);

      holidayReference
          .limitToFirst(1)
          .once()
          .then((DataSnapshot snapShot) async {
        if (snapShot != null && snapShot.value != null) {
          print("values : if Block");

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("userCompanyCode", holidayCode);

          setState(() {
            isLoading = false;
          });

          Navigator.pushReplacementNamed(context, '/auth');
        } else {
          print("values : else Block");

          setState(() {
            isLoading = false;
          });

          final snackBar = SnackBar(content: Text("No Match Found !!"));
          _scaffoldkey.currentState.showSnackBar(snackBar);
        }
      }).catchError((onError) {
        print("values : ${onError}");
        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      print("Data Fetch : ${e.toString()}");
      e.toString();

      setState(() {
        isLoading = false;
      });
    }
  }

  _authenticateUserAndNavigate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userEmail = prefs.getString("userEmail");
    final group = prefs.getString("userCompanyCode");
    if (userEmail!=null && userEmail.isNotEmpty && group!=null && group.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  void initState() {
    super.initState();

    _authenticateUserAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(
              20.0,
            ),
            child: Column(
              children: <Widget>[
                _buildLabelField(),
                SizedBox(
                  height: 10.0,
                ),
                _buildHolidayFormField(),
                Container(
                  height: 1.5,
                  color: dateBackgroundColor,
                ),
                _buildCodeField(),
                isLoading ? CircularProgressIndicator() : _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
