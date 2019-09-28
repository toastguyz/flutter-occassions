import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_occassions/auth/sign_in.dart';
import 'package:flutter_occassions/auth/sign_up.dart';
import 'package:flutter_occassions/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AuthUserPageState();
  }
}

class AuthUserPageState extends State<AuthUserPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    firebaseCloudMessaging_Listeners();
    _tabController = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void firebaseCloudMessaging_Listeners() async {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("userToken", token);
      print("Firebase Messaging : " + token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    TabController _tabController =  TabController(vsync: this, length: 2);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Holidays",
          style: TextStyle(
            color: dateBackgroundColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              text: "SIGN IN",
            ),
            Tab(
              text: "SIGN UP",
            ),
          ],
          labelColor: dateBackgroundColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: dateBackgroundColor,
        ),
        backgroundColor: Colors.white,
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          SignInPage(),
          SignUpPage(),
        ],
      ),
    );
  }
}

/*class AuthUserPageState extends State<AuthUserPage>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        labelPadding: MediaQuery.of(context).padding,
        tabs: <Widget>[
          Tab(
            text: "SIGN IN",
          ),
          Tab(
            text: "SIGN UP",
          ),
        ],
        labelColor: dateBackgroundColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: dateBackgroundColor,
        controller: tabController,
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          Center(
            child: Container(
              child: Text("SIGN IN"),
            ),
          ),
          Center(
            child: Container(
              child: Text("SIGN UP"),
            ),
          ),
        ],
      ),
    );
  }
}*/

/*class DecoratedTabBar extends StatelessWidget implements PreferredSizeWidget {
  DecoratedTabBar({@required this.tabBar, @required this.decoration});

  final TabBar tabBar;
  final BoxDecoration decoration;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(decoration: decoration)),
        tabBar,
      ],
    );
  }
}*/

/*class AuthUserPageState extends State<AuthUserPage>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget getTabBar() {
    return TabBar(controller: tabController, tabs: [
      Tab(
        text: "SIGN IN",
      ),
      Tab(
        text: "SIGN UP",
      ),
    ]);
  }

  Widget getTabBarPages() {
    return TabBarView(controller: tabController, children: <Widget>[
      Container(
        child: Text("SIGN IN"),
      ),
      Container(
        child: Text("SIGN UP"),
      ),
      Container(color: Colors.red),
      Container(color: Colors.green),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          flexibleSpace: SafeArea(
            child: getTabBar(),
          ),
        ),
        body: getTabBarPages());
  }
}*/
