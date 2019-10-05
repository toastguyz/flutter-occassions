import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_occassions/auth/auth_user.dart';
import 'package:flutter_occassions/holiday/holiday_list.dart';
import 'package:flutter_occassions/home/home.dart';
import 'package:flutter_occassions/utils/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Occassions',
      theme: ThemeData(
          brightness: Brightness.light,
          cursorColor: activeColor,
          primaryColor: activeColor,
          accentColor: holidayTodayBackgroundColor,
          buttonColor: holidayTodayBackgroundColor),
//      home: HomePage(),
      routes: {
        '/': (BuildContext context) => HomePage(),
        '/auth': (BuildContext context) => AuthUserPage(),
        '/dashboard': (BuildContext context) => HolidayListPage(),
      },
    );
  }
}
