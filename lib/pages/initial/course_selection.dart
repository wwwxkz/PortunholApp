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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Portunhol',
      theme: new ThemeData(fontFamily: 'Raleway'),
      home: new ListPage(
          title: 'Línguas',
          auth: auth,
          userId: userId,
          onSignedOut: onSignedOut),
      // home: DetailPage(),
    );
  }
}

class ListPage extends StatefulWidget {
  ListPage({Key key, this.title, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;
  final String title;

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
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: Container(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(Icons.check_circle, color: Colors.grey[850], size: 52),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                lesson.title,
                style: TextStyle(color: Colors.grey[850], fontWeight: FontWeight.w600, fontSize: 20)
              ),
              Row(
                children: <Widget>[
                Text(
                  '65 ',
                  style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                  Text(
                  '22 ',
                  style: TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                  Text(
                  '9472',
                  style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],)
            ],
          ),
          onTap: () {
            if (lesson.title == "Inglês") {
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

    Card makeCard(Lesson lesson) => Card(
         
          margin: new EdgeInsets.symmetric(vertical: 6.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: makeListTile(lesson),
          ),
        );

    final makeBody = Container(
        color: Colors.grey[300],
        padding: EdgeInsets.only(top: 10, left: 0, right: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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


    final topAppBar = AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'Decks',
        style: TextStyle(color: Colors.blueAccent, fontSize: 26),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
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
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search, color: Colors.blueAccent),
          onPressed: () {},
        )
      ],
    );

    return Scaffold(
      body: makeBody,
      appBar: topAppBar,
    );
  }
}

List getLessons() {
  return [
    Lesson(
      title: "Inglês",
    ),
    Lesson(
      title: "Crie seu deck",
    ),
  ];
}
