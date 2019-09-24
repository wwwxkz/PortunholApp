import 'package:firebase_database/firebase_database.dart';

class Note {
  String key;
  String front;
  String back;
  int understood;
  int days;
  String today;

  Note(this.front, this.back, this.understood, this.days, this.today);

  Note.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    front = snapshot.value["front"],
    back = snapshot.value["back"],
    understood = snapshot.value["understood"],
    days = snapshot.value["days"],
    today = snapshot.value["today"];

  toJson() {
    return {
      "front": front,
      "back": back,
      "understood": understood,
      "days": days,
      "today": today,
    };
  }
}