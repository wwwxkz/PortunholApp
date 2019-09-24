import 'package:flutter/material.dart';
import 'package:portunhol/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class StorePage extends StatefulWidget {
  StorePage(
      {Key key, this.auth, this.onSignedIn, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _StorePageState();
}

class _StorePageState extends State<StorePage> {
  // List _noteList;
  // var index = 0;

  // final FirebaseDatabase _database = FirebaseDatabase.instance;

  StreamSubscription<Event> _onNoteAddedSubscription;
  StreamSubscription<Event> _onNoteChangedSubscription;

  // Query _noteQuery;

  bool _isEmailVerified = false;

// Firebase config
  @override
  void initState() {
    super.initState();

    _checkEmailVerification();

    // _noteList = new List();
    // _noteQuery = _database.reference().child("users/" + widget.userId + "/");
    // _onNoteAddedSubscription = _noteQuery.onChildAdded.listen(_onEntryAdded);
    // _onNoteChangedSubscription =
    //     _noteQuery.onChildChanged.listen(_onEntryChanged);
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

  // _onEntryChanged(Event event) {
  //   var oldEntry = _noteList.singleWhere((entry) {
  //     return entry.key == event.snapshot.key;
  //   });

  //   setState(() {
  //     _noteList[_noteList.indexOf(oldEntry)] = event.snapshot;
  //   });
  // }

  // _onEntryAdded(Event event) {
  //   setState(() {
  //     _noteList.add(event.snapshot.value);
  //   });
  // }

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
            'Shopping',
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
      padding: EdgeInsets.only(bottom: 200),
      child: _showNoteList(),
    );
  }

  // Show note list
  Widget _showNoteList() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        "Em breve :)",
        style: TextStyle(fontSize: 28, color: Colors.black),
      )
    );
  }
}
