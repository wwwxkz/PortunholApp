// Models / libs
import 'package:portunhol/models/decks.dart';
import 'package:flutter/material.dart';
// Auth
import 'package:portunhol/services/authentication.dart';
// Pages
import 'package:portunhol/pages/readDeck/study.dart';
import 'package:portunhol/pages/yourDeck/study.dart';
import 'package:portunhol/pages/people/rank.dart';
import 'package:portunhol/pages/settings/profile.dart';
import 'package:portunhol/pages/shopping/store.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key key, this.auth, this.userId, this.onSignedOut}) : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(fontFamily: 'Raleway'),
      home: new ListPage(auth: auth, userId: userId, onSignedOut: onSignedOut),
    );
  }
}

class ListPage extends StatefulWidget {
  ListPage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List lessons;

  @override
  void initState() {
    lessons = getLessons();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ListTile makeListTile(Lesson lesson) => ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: -20.0, vertical: 10),
          title: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(lesson.title,
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 18)),
                    SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Text(
                          '65 ',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        Text(
                          '22 ',
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        Text(
                          '9472',
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                      ],
                    )
                  ],
                ),
                IconButton(
                  icon: new Icon(Icons.arrow_forward, color: Colors.black),
                  //onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          onTap: () {
            if (lesson.title == "English") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudyPage(
                            userId: widget.userId,
                            auth: widget.auth,
                            onSignedOut: widget.onSignedOut,
                          )));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudyYourSignUpPage(
                            userId: widget.userId,
                            auth: widget.auth,
                            onSignedOut: widget.onSignedOut,
                          )));
            }
          },
        );

    Container makeCard(Lesson lesson) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: makeListTile(lesson),
        );

    final makeBody = Container(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Decks',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 24),
            ),
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: lessons.length,
              itemBuilder: (BuildContext context, int index) {
                return makeCard(lessons[index]);
              },
            ),
          ],
        ));

    final bottomAppBar = BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            iconSize: 30,
            color: Colors.blueAccent,
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => StudyPage()));
            },
          ),
          IconButton(
            iconSize: 30,
            color: Colors.blueAccent,
            icon: Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RankPage(
                            userId: widget.userId,
                            auth: widget.auth,
                            onSignedOut: widget.onSignedOut,
                          )));
            },
          ),
          IconButton(
            iconSize: 30,
            color: Colors.blueAccent,
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StorePage(
                            userId: widget.userId,
                            auth: widget.auth,
                            onSignedOut: widget.onSignedOut,
                          )));
            },
          ),
          IconButton(
            iconSize: 30,
            color: Colors.blueAccent,
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                            userId: widget.userId,
                            auth: widget.auth,
                            onSignedOut: widget.onSignedOut,
                          )));
            },
          )
        ],
      ),
    );

    return Scaffold(
      body: makeBody,
      bottomNavigationBar: bottomAppBar,
    );
  }
}

List getLessons() {
  return [
    Lesson(
      title: "English",
    ),
    Lesson(
      title: "French",
    ),
    Lesson(
      title: "Portuguese",
    ),
    Lesson(
      title: "Spanish",
    ),
    Lesson(
      title: "Create your own deck",
    ),
  ];
}
