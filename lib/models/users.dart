import 'package:firebase_database/firebase_database.dart';

class Note {
  String key;
  String name;
  int points;

  Note(this.name, this.points);

  Note.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    name = snapshot.value["name"],
    points = snapshot.value["points"];

  toJson() {
    return {
      "name": name,
      "points": points,
    };
  }
}