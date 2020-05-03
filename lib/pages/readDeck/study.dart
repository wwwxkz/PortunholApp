import 'package:flutter/material.dart';
import 'package:portunhol/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:portunhol/models/note.dart';
import 'dart:async';

class StudyPage extends StatefulWidget {
  StudyPage(
      {Key key, this.auth, this.onSignedIn, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _StudyPageState();
}

enum FormMode { LOGIN, SIGNUP }
enum ButtonMode { ANSWEAR, BUTTON }
enum TtsState { playing, stopped }

class _StudyPageState extends State<StudyPage> {
  FlutterTts flutterTts;
  // dynamic languages;
  // dynamic voices;
  String language = "en-US";
  String voice = "en-US-language";

  int silencems;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  final _formKey = new GlobalKey<FormState>();
  final _formKey1 = new GlobalKey<FormState>();

  List<Note> _noteList;
  var index = 0;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();

  StreamSubscription<Event> _onNoteAddedSubscription;
  StreamSubscription<Event> _onNoteChangedSubscription;

  Query _noteQuery;

  bool _isEmailVerified = false;

// Firebase config

  @override
  void initState() {
    _isLoading = false;
    super.initState();
    initTts();

    _checkEmailVerification();

    _noteList = new List();
    _noteQuery =
        // _database.reference().child("courses/" + coursename + "/notes/");
        _database.reference().child("courses/ingles/");
    _onNoteAddedSubscription = _noteQuery.onChildAdded.listen(_onEntryAdded);
    _onNoteChangedSubscription =
        _noteQuery.onChildChanged.listen(_onEntryChanged);
  }

  initTts() {
    flutterTts = FlutterTts();
    // flutterTts.setLanguage("en-US");

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _speak(text) async {
    var result = await flutterTts.speak(text);
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
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

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  ButtonMode _formMode1 = ButtonMode.ANSWEAR;
  bool _isIos;
  bool _isLoading;

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToButton() {
    _formKey1.currentState.reset();
    setState(() {
      _formMode1 = ButtonMode.ANSWEAR;
    });
  }

  void _changeFormToAnswer() {
    _formKey1.currentState.reset();
    setState(() {
      _formMode1 = ButtonMode.BUTTON;
    });
  }

  void _changeFormToStudyPageYour() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return _formMode == FormMode.LOGIN
        ? new Scaffold(
            appBar: new AppBar(
              elevation: 1,
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Colors.white,
            ),
            body: Stack(
              children: <Widget>[
                _showBody(),
              ],
            ),
          )
        : new Scaffold(
            appBar: new AppBar(
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Colors.white,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    _speak(_noteList[index].front);
                  },
                )
              ],
            ),
            body: Stack(
              children: <Widget>[
                _showBody(),
              ],
            ));
  }

  Widget _showBody() {
    return new Scaffold(
        //backgroundColor: Colors.grey[300],
        body: _formMode == FormMode.LOGIN
            ? new Form(
                key: _formKey,
                child: new ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(16.0),
                  children: <Widget>[
                    _showStudyPageButton(),
                  ],
                ),
              )
            : new Form(
                key: _formKey,
                child: new ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(16.0),
                  children: <Widget>[
                    _showNoteList(),
                  ],
                ),
              ));
  }

  // StudyPage Button
  String input1 = 'Língua';
  String input2 = 'Voz';
  Widget _showStudyPageButton() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new DropdownButton<String>(
                  items: <String>['Espanhol', 'Francês', 'Inglês', 'Português']
                      .map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (String value) {
                    setState(() => input1 = value);
                    if (value == "Espanhol") {
                      flutterTts.setLanguage("es-ES");
                    }
                    if (value == "Francês") {
                      flutterTts.setLanguage("fr-FR");
                    }
                    if (value == "Inglês") {
                      flutterTts.setLanguage("en-US");
                    }
                    if (value == "Português") {
                      flutterTts.setLanguage("pt-BR");
                    }
                  },
                  hint: Text(input1,
                      style: TextStyle(
                        color: Colors.grey[850],
                      )),
                ),
                new DropdownButton<String>(
                  elevation: 1,
                  items:
                      <String>['Voz 1', 'Voz 2', 'Voz 3'].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (String value) {
                    setState(() => input2 = value);
                  },
                  hint: Text(input2,
                      style: TextStyle(
                        color: Colors.grey[850],
                      )),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 50.0,
          width: double.infinity,
          child: new RaisedButton(
              shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  topLeft: Radius.circular(100.0),
                  bottomRight: Radius.circular(100.0),
                  bottomLeft: Radius.circular(20.0),
                ),
              ),
              color: Colors.blueAccent,
              child: Text('Study',
                  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
              onPressed: () {
                _formMode == FormMode.LOGIN
                    ? _changeFormToSignUp()
                    : _changeFormToStudyPageYour();
                _speak(_noteList[index].front);
              }),
        ),
      ],
    );
  }

  // Show note list
  Widget _showNoteList() {
    // List
    if (_noteList.length > 0) {
      if (index < _noteList.length) {
        return Center(
            child: Column(
          children: <Widget>[
            Text(
              _noteList[index].front,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0, color: Colors.black),
            ),
            Container(
                child: _formMode1 == ButtonMode.BUTTON
                    ? new Form(
                        key: _formKey1,
                        child: Column(
                          children: <Widget>[
                            Text(
                              _noteList[index].back,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 30.0, color: Colors.black),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: new RaisedButton(
                                    elevation: 3.0,
                                    shape: new RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20.0),
                                        topLeft: Radius.circular(100.0),
                                        bottomRight: Radius.circular(100.0),
                                        bottomLeft: Radius.circular(20.0),
                                      ),
                                    ),
                                    color: Colors.redAccent,
                                    child: Text('Não entendi',
                                        style: new TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white)),
                                    onPressed: () {
                                      _changeFormToButton();
                                      setState(() => index += 1);
                                      _speak(_noteList[index].front);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: new RaisedButton(
                                    elevation: 3.0,
                                    shape: new RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20.0),
                                        topLeft: Radius.circular(100.0),
                                        bottomRight: Radius.circular(100.0),
                                        bottomLeft: Radius.circular(20.0),
                                      ),
                                    ),
                                    color: Colors.greenAccent,
                                    child: Text('Entendi',
                                        style: new TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white)),
                                    onPressed: () {
                                      _changeFormToButton();
                                      setState(() => index += 1);
                                      _speak(_noteList[index].front);
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ))
                    : new Form(
                        key: _formKey1,
                        child: SizedBox(
                          height: 50.0,
                          width: double.infinity,
                          child: new RaisedButton(
                              elevation: 3.0,
                              shape: new RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(100.0),
                                  bottomRight: Radius.circular(100.0),
                                  bottomLeft: Radius.circular(20.0),
                                ),
                              ),
                              color: Colors.grey,
                              child: Text('Show answear',
                                  style: new TextStyle(
                                      fontSize: 20.0, color: Colors.white)),
                              onPressed: () {
                                _changeFormToAnswer();
                              }),
                        ),
                      ))
          ],
        ));
      } else {
        return Center(
            child: Text(
          "Você acabou por hoje",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30.0, color: Colors.black),
        ));
      }
    } else {
      return Center(
          child: Text(
        "Você ainda não tem nenhum card",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0, color: Colors.black),
      ));
    }
  }
}
