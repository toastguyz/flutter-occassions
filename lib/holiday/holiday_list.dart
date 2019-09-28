import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_occassions/models/header_item_list.dart';
import 'package:flutter_occassions/models/holiday_list_model.dart';
import 'package:flutter_occassions/utils/network_check.dart';
import 'package:intl/intl.dart';
import 'package:flutter_occassions/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HolidayListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HolidayListPageState();
  }
}

class HolidayListPageState extends State<HolidayListPage> {
  bool isLoading = false;

//  final holidayReference = FirebaseDatabase.instance.reference().child("Holiday");
  List<HolidayModel> holidayList = [];
  List<HeaderItemModel> finalHolidayList = [];

  @override
  void initState() {
    super.initState();

//    addDataToFirebase();
    getHolidays();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        titleSpacing: 0.0,
        title: new Transform(
          transform: new Matrix4.translationValues(-15.0, 0.0, 0.0),
          child: Text(
            "HOLIDAYS",
            style: TextStyle(
              color: dateBackgroundColor,
            ),
          ),
        ),
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: dateBackgroundColor,
          ),
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.share,
              color: holidayTodayBackgroundColor,
            ),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
      ),
//      body: Container(),
      body: getHolidayListView(),
    );
  }

  void addDataToFirebase() async {
    final holidayReference = FirebaseDatabase.instance
        .reference()
        .child("Holiday")
        .child("UPCOMING");

    holidayReference.push().set({
      "name": "Company Holiday",
      "description": "Testing Holiday Data.",
      "photo":
          "https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg",
      "tags": "#Diwali#Celebration",
      "date": 1562586617169,
      "updatedAt": 1562586617169,
      "createdAt": 1562586617169,
    }).then((_) {
      print("Transaction Completed");
    });

    holidayReference.push().set({
      "name": "Company Holiday",
      "description": "Testing Holiday Data.",
      "photo":
      "https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg",
      "tags": "#Diwali#Celebration",
      "date": 1562653800000,
      "updatedAt": 1562653800000,
      "createdAt": 1562653800000,
    }).then((_) {
      print("Transaction Completed");
    });
  }

  void getHolidays() async {
    NetworkCheck networkCheck = new NetworkCheck();
    networkCheck.checkInternet((isNetworkPresent) async {
      if (!isNetworkPresent) {
        final snackBar =
        SnackBar(content: Text('Please check your internet connection !!'));

        Scaffold.of(context).showSnackBar(snackBar);
        return;
      } else {
        setState(() {
          isLoading = true;
        });
      }
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final group = prefs.getString("userCompanyCode");
      final holidayReference =
          FirebaseDatabase.instance.reference().child("Holiday").child(group);

      await holidayReference.once().then((DataSnapshot snapshot) {
        print('HolidayList : ${snapshot.value}');

        for (var value in snapshot.value.values) {
          holidayList.add(new HolidayModel.fromJson(value));
        }

        holidayList.sort((a, b) => a.HolidayDate.compareTo(b.HolidayDate));

        var dateFormat = new DateFormat("dd-MM-yyyy");
        String today = dateFormat.format(DateTime.now());
        var monthFormatter = new DateFormat('MMMM');
        String todayMonth = monthFormatter.format(DateTime.now());
        var dayFormatter = new DateFormat('dd');
        String todayDay = dayFormatter.format(DateTime.now());

        for (int i = 0; i < holidayList.length; i++) {
          if (holidayList[i].HolidayDate.day == DateTime.now().day) {
            finalHolidayList.add(new HolidayHeadingModel("TODAY"));
            finalHolidayList.add(new HolidayItemModel(
                holidayList[i].Name,
                holidayList[i].Description,
                holidayList[i].Photo,
                holidayList[i].Tags,
                holidayList[i].Date,
                holidayList[i].UpdatedAt,
                holidayList[i].CreatedAt,
                todayMonth,
                todayDay,
                0));
            break;
          }
        }

        DateTime currentDay = dateFormat.parse(today);
        int futureFlag = 0;
        for (int i = 0; i < holidayList.length; i++) {
//        DateTime nextDay = dateFormat.parse(holidayList[i].Date);
          DateTime nextDay = holidayList[i].HolidayDate;
          String futureMonth =
              monthFormatter.format(holidayList[i].HolidayDate);
          String futureDay = dayFormatter.format(holidayList[i].HolidayDate);

          if (holidayList[i].HolidayDate.day == DateTime.now().day) {
            continue;
          }

          if (nextDay.isAfter(currentDay)) {
            if (futureFlag == 0) {
              finalHolidayList.add(new HolidayHeadingModel("NEXT"));
              finalHolidayList.add(new HolidayItemModel(
                  holidayList[i].Name,
                  holidayList[i].Description,
                  holidayList[i].Photo,
                  holidayList[i].Tags,
                  holidayList[i].Date,
                  holidayList[i].UpdatedAt,
                  holidayList[i].CreatedAt,
                  futureMonth,
                  futureDay,
                  1));
              futureFlag = 1;
            } else {
              if (futureFlag == 1) {
                finalHolidayList.add(new HolidayHeadingModel("UPCOMING"));
                finalHolidayList.add(new HolidayItemModel(
                    holidayList[i].Name,
                    holidayList[i].Description,
                    holidayList[i].Photo,
                    holidayList[i].Tags,
                    holidayList[i].Date,
                    holidayList[i].UpdatedAt,
                    holidayList[i].CreatedAt,
                    futureMonth,
                    futureDay,
                    2));
                futureFlag = 2;
              } else {
                finalHolidayList.add(new HolidayItemModel(
                    holidayList[i].Name,
                    holidayList[i].Description,
                    holidayList[i].Photo,
                    holidayList[i].Tags,
                    holidayList[i].Date,
                    holidayList[i].UpdatedAt,
                    holidayList[i].CreatedAt,
                    futureMonth,
                    futureDay,
                    2));
              }
            }
          }
        }

        int pastFlag = 0;
        for (int i = 0; i < holidayList.length; i++) {
//        DateTime pastDay = dateFormat.parse(holidayList[i].Date);
          DateTime pastDay = holidayList[i].HolidayDate;
          String goneMonth = monthFormatter.format(pastDay);
          String goneDay = dayFormatter.format(pastDay);

          if (pastDay.isBefore(currentDay)) {
            if (pastFlag == 0) {
              finalHolidayList.add(new HolidayHeadingModel("PAST"));
              finalHolidayList.add(new HolidayItemModel(
                  holidayList[i].Name,
                  holidayList[i].Description,
                  holidayList[i].Photo,
                  holidayList[i].Tags,
                  holidayList[i].Date,
                  holidayList[i].UpdatedAt,
                  holidayList[i].CreatedAt,
                  goneMonth,
                  goneDay,
                  3));
              pastFlag = 1;
            } else {
              finalHolidayList.add(new HolidayItemModel(
                  holidayList[i].Name,
                  holidayList[i].Description,
                  holidayList[i].Photo,
                  holidayList[i].Tags,
                  holidayList[i].Date,
                  holidayList[i].UpdatedAt,
                  holidayList[i].CreatedAt,
                  goneMonth,
                  goneDay,
                  3));
            }
          }
        }

        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  /*Widget getHolidayListView() {
    return finalHolidayList == null || finalHolidayList.length == 0
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            itemCount: finalHolidayList.length,
            itemBuilder: (BuildContext context, int index) {
              final item = finalHolidayList[index];
              if (item is HolidayHeadingModel) {
                */ /*return ListTile(
                  title: Text(
                    item.heading,
                    style: Theme.of(context).textTheme.headline,
                  ),
                );*/ /*

                return ListTile(
                  title: Text(item.heading,
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 18.0,
                      )),
                );
              } else if (item is HolidayItemModel) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(item.Photo),
                  ),
                  title: Text(item.Name),
                  subtitle: Text(item.Date),
                );
              }
            });
  }*/

  /*Widget getHolidayListView() {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            itemCount: finalHolidayList.length,
            itemBuilder: (BuildContext context, int index) {
              final item = finalHolidayList[index];
              if (item is HolidayHeadingModel) {
                return Container(
                  alignment: Alignment.centerLeft,
                  height: 40.0,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(item.heading,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 18.0,
                      )),
                );
              } else if (item is HolidayItemModel) {
                return Container(
                  height: 60.0,
                  margin: EdgeInsets.only(
                    top: 5.0,
                    bottom: 5.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 4,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: dateBackgroundColor,
                          ),
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              new Text(
                                item.Day,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30.0,
                                  color: Colors.white,
                                ),
                                textScaleFactor: 1.0,
                                textAlign: TextAlign.left,
                              ),
                              new Text(
                                item.Month,
                                textScaleFactor: 0.5,
                                textAlign: TextAlign.right,
                                style: new TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 2.0,
                      ),
                      Expanded(
                        flex: 13,
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 8.0,
                          ),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: item.holidayColor == 0
                                ? holidayTodayBackgroundColor
                                : item.holidayColor == 1
                                    ? holidayNextBackgroundColor
                                    : holidayGlobalBackgroundColor,
                          ),
                          child: new Text(
                            item.Name,
                            textScaleFactor: 1.5,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: item.holidayColor == 0
                                  ? Colors.white
                                  : dateBackgroundColor,
                            ),
                          ),
                        ),
                      ),
                      new Expanded(
                        flex: 3,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.navigate_next,
                            size: 35.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            });
  }*/

  Widget getHolidayListView() {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            itemCount: finalHolidayList.length,
            itemBuilder: (BuildContext context, int index) {
              final item = finalHolidayList[index];
              if (item is HolidayHeadingModel) {
                return Container(
                  alignment: Alignment.centerLeft,
                  height: 60.0,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Text(item.heading,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 25.0,
                      )),
                );
              } else if (item is HolidayItemModel) {
                return Container(
                  height: 60.0,
                  margin: EdgeInsets.only(
                    top: 3.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: dateBackgroundColor,
                          ),
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              new Text(
                                item.Day,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30.0,
                                  color: Colors.white,
                                ),
                                textScaleFactor: 1.0,
                                textAlign: TextAlign.left,
                              ),
                              new Text(
                                item.Month,
                                textScaleFactor: 0.5,
                                textAlign: TextAlign.right,
                                style: new TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 2.0,
                      ),
                      Expanded(
                        flex: 9,
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 8.0,
                          ),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: item.holidayColor == 0
                                ? holidayTodayBackgroundColor
                                : item.holidayColor == 1
                                    ? holidayNextBackgroundColor
                                    : holidayGlobalBackgroundColor,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 9,
                                child: Text(
                                  item.Name,
                                  textScaleFactor: 1.5,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: item.holidayColor == 0
                                        ? Colors.white
                                        : item.holidayColor == 1
                                            ? Colors.black
                                            : dateBackgroundColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: dateBackgroundColor,
                                  size: 20.0,
                                ),
                              ),
                            ],
                          ),

                          /*child: Text(
                            item.Name,
                            textScaleFactor: 1.5,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: item.holidayColor == 0
                                  ? Colors.white
                                  : item.holidayColor == 1
                                      ? Colors.black
                                      : dateBackgroundColor,
                            ),
                          ),*/
                        ),
                      ),
                    ],
                  ),
                );
              }
            });
  }
}
