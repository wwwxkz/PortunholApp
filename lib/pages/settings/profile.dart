import 'package:flutter/material.dart';
import 'package:portunhol/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  ProfilePage(
      {Key key, this.auth, this.onSignedIn, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    _noteQuery = _database.reference().child("users/" + widget.userId + "/");
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
      _noteList[_noteList.indexOf(oldEntry)] = event.snapshot;
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      _noteList.add(event.snapshot.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.white,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: new Text(
            'Profile',
            style: TextStyle(color: Colors.blueAccent, fontSize: 26),
          ),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
          ],
        ));
  }

  Widget _showBody() {
    return new Container(
      color: Colors.grey[300],
      padding: EdgeInsets.all(16.0),
      child: _showNoteList(),
    );
  }

  // Show note list
  Widget _showNoteList() {
    return Container(
        child: Column(
      children: <Widget>[
        Container(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.person),
                  iconSize: 70,
                  color: Colors.grey,
                  onPressed: () {},
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _noteList[1].toString(),
                      style: TextStyle(fontSize: 18, color: Colors.grey[850]),
                    ),
                    Text(
                      _noteList[0].toString(),
                      style: TextStyle(fontSize: 16, color: Colors.grey[850]),
                    ),
                  ],
                ),
              ],
            )),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'ID: ' + _noteList[5].toString(),
              style: TextStyle(fontSize: 18, color: Colors.grey[850]),
            ),
            Text(
              'Numero: ' + _noteList[3].toString(),
              style: TextStyle(fontSize: 18, color: Colors.grey[850]),
            ),
          ],
        )
      ],
    ));
  }
}
