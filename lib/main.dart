import 'package:flutter/material.dart';
import 'package:portunhol/root_page.dart';
import 'package:portunhol/services/authentication.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primaryColor: Colors.white,
        ),
        home: new RootPage(auth: new Auth()));
  }
}