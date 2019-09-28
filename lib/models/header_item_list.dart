abstract class HeaderItemModel {}

class HolidayHeadingModel implements HeaderItemModel {
  final String heading;

  HolidayHeadingModel(this.heading);
}

// A ListItem that contains data to display a message.
class HolidayItemModel implements HeaderItemModel {
  String Name;
  String Description;
  String Photo;
  String Tags;
  int Date;
  int UpdatedAt;
  int CreatedAt;
  String Month;
  String Day;
  int holidayColor;

  HolidayItemModel(this.Name, this.Description, this.Photo, this.Tags,
      this.Date, this.UpdatedAt, this.CreatedAt, this.Month, this.Day,this.holidayColor);

  HolidayItemModel.fromJson(var value) {
    this.Name = value['name'];
    this.Description = value['description'];
    this.Photo = value['photo'];
    this.Tags = value['tags'];
    this.Date = value['date'];
    this.UpdatedAt = value['updatedAt'];
    this.CreatedAt = value['createdAt'];
  }
}
