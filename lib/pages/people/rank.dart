import 'package:flutter/material.dart';
import 'package:portunhol/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:portunhol/models/users.dart';
import 'dart:async';

class RankPage extends StatefulWidget {
  RankPage({Key key, this.auth, this.onSignedIn, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _RankPageState();
}

class _RankPageState extends State<RankPage> {
  List _noteList;
  var index = 0;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  StreamSubscription<Event> _onNoteAddedSubscription;
  StreamSubscription<Event> _onNoteChangedSubscription;

  Query _noteQuery;

  bool _isEmailVerified = false;

// Firebase config
  @override
  void initState() {
    super.initState();

    _checkEmailVerification();

    _noteList = new List();
    _noteQuery = _database.reference().child("users/");
    _onNoteAddedSubscription = _noteQuery.onChildAdded.listen(_onEntryAdded);
    _onNoteChangedSubscription =
        _noteQuery.onChildChanged.listen(_onEntryChanged);
  }

// Email verification
  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _onNoteAddedSubscription.cancel();
    _onNoteChangedSubscription.cancel();
    super.dispose();
  }

// Real time database

  _onEntryChanged(Event event) {
    var oldEntry = _noteList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _noteList[_noteList.indexOf(oldEntry)] =
          Note.fromSnapshot(event.snapshot);
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      _noteList.add(Note.fromSnapshot(event.snapshot));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        title: new Text(
          'Rank',
          style: TextStyle(color: Colors.blueAccent, fontSize: 26),
        ),
      ),
      body: _showBody(),
    );
  }

  Widget _showBody() {
    return new Scaffold(
      backgroundColor: Colors.grey[300],
      body: _showNoteList(),
    );
  }

  // Show note list
  Widget _showNoteList() {
    _noteList.sort((a, b) => b.points.compareTo(a.points));

    return Container(
      padding: EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _noteList.length,
        itemBuilder: (BuildContext context, int index) {
          var name = _noteList[index].name.toString().split(" ");
          return Card(
              child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                          color: Colors.grey[850],
                          fontWeight: FontWeight.w600,
                          fontSize: 22),
                    )),
                IconButton(
                  color: Colors.grey,
                  icon: Icon(Icons.person),
                  iconSize: 30,
                  onPressed: () {},
                ),
                SizedBox(
                    width: 200,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          name[0],
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 22),
                        ),
                        Text(
                          _noteList[index].points.toString(),
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 22),
                        ),
                      ],
                    )),
              ],
            ),
          ));
        },
      ),
    );
  }
}
