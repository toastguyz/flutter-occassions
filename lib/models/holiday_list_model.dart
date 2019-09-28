import 'package:intl/intl.dart';

class HolidayModel {
  String Name;
  String Description;
  String Photo;
  String Tags;
  int Date;
  int UpdatedAt;
  int CreatedAt;
  String Month;
  String Day;
  DateTime HolidayDate;
//  var dateFormat = new DateFormat("dd-MM-yyyy HH:mm:ss");

  HolidayModel(this.Name, this.Description, this.Photo, this.Tags, this.Date,
      this.UpdatedAt, this.CreatedAt, this.Month, this.Day);

  HolidayModel.fromJson(var value) {
    this.Name = value['name'];
    this.Description = value['description'];
    this.Photo = value['photo'];
    this.Tags = value['tags'];
    this.Date = value['date'];
    this.UpdatedAt = value['updatedAt'];
    this.CreatedAt = value['createdAt'];
    this.HolidayDate = new DateTime.fromMillisecondsSinceEpoch(value['date'] * 1000);

    /*this.HolidayDate =
    new DateTime.fromMillisecondsSinceEpoch(this.Date, isUtc: true);
    print("Date : ${value['date']}");
    print("HolidayDate : ${this.HolidayDate}");*/

    /*var date = new DateTime.fromMillisecondsSinceEpoch(value['date'] * 1000);
    print("finalDate : $date");*/
  }
}
