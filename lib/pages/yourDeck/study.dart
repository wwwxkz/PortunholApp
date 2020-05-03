import 'package:portunhol/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:portunhol/models/note.dart';
import 'package:translator/translator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';

class StudyYourSignUpPage extends StatefulWidget {
  StudyYourSignUpPage(
      {Key key, this.auth, this.onSignedIn, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _StudyYourSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }
enum ButtonMode { ANSWEAR, BUTTON }
enum TtsState { playing, stopped }

class _StudyYourSignUpPageState extends State<StudyYourSignUpPage> {
  FlutterTts flutterTts;
  dynamic languages;
  dynamic voices;
  String language;
  String voice;
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

  final _textEditingController1 = TextEditingController();
  final _textEditingController2 = TextEditingController();

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
        _database.reference().child("users/" + widget.userId + "/notes/");
    _onNoteAddedSubscription = _noteQuery.onChildAdded.listen(_onEntryAdded);
    _onNoteChangedSubscription =
        _noteQuery.onChildChanged.listen(_onEntryChanged);
  }

  initTts() {
    flutterTts = FlutterTts();

    if (Platform.isAndroid) {
      flutterTts.ttsInitHandler(() {
        _getLanguages();
        _getVoices();
      });
    } else if (Platform.isIOS) {
      _getLanguages();
      _getVoices();
    }

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

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) setState(() => languages);
  }

  Future _getVoices() async {
    voices = await flutterTts.getVoices;
    if (voices != null) setState(() => voices);
  }

  Future _speak(text) async {
    // if (_textEditingController1.text.toString() != null) {
    //   if (_textEditingController1.text.toString().isNotEmpty) {
    var result = await flutterTts.speak(text);
    if (result == 1) setState(() => ttsState = TtsState.playing);
    //   }
    // }
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
    flutterTts.stop();
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

// Note crud

  _addNewNote(String front, String back) {
    if (front.length > 0) {
      var today = new DateFormat.yMd().format(new DateTime.now());
      Note note =
          new Note(front.toString(), back.toString(), 0, 0, today.toString());
      _database
          .reference()
          .child("users/" + widget.userId + "/notes/")
          .push()
          .set(note.toJson());
    }

    // final birthday = DateTime(1967, 10, 12); // equal false
    // final date2 = DateTime.now();
    // print(date2.difference(birthday).isNegative);

    // if( is true { passed })
    // if false no
  }

  _updateNote(Note note, bool understood) {
    var days = note.days + note.days ~/ 2.toInt();
    if (understood == true) {
      note.understood += 1;
      if (note.days == null || note.days < 2) {
        note.days = 2;
      }
      if (note.days >= 2) {
        note.days += note.days ~/ 2.toInt();
      }
      days = note.days + note.days ~/ 2.toInt();
      var date = new DateFormat.yMd()
          .format(new DateTime.now().add(new Duration(days: days)));
      note.today = date;
      if (note != null) {
        _database
            .reference()
            .child("users/" + widget.userId + "/notes/")
            .child(note.key)
            .set(note.toJson());
      }
    } else {
      note.days = 1;
      var date = new DateFormat.yMd()
          .format(new DateTime.now().add(new Duration(days: note.days)));
      note.today = date;
      note.understood = 0;
      if (note != null) {
        _database
            .reference()
            .child("users/" + widget.userId + "/notes/")
            .child(note.key)
            .set(note.toJson());
      }
    }
  }

  _changeNote(String front, String back, Note note, int index) {
    note.front = front;
    note.back = back;
    if (note != null) {
      _database
          .reference()
          .child("users/" + widget.userId + "/notes/")
          .child(note.key)
          .set(note.toJson());
    }
  }

  _deleteNote(String noteId, int index) {
    _database
        .reference()
        .child("users/" + widget.userId + "/notes/")
        .child(noteId)
        .remove()
        .then((_) {
      print("Delete $noteId successful");
      setState(() {
        _noteList.removeAt(index);
      });
    });
  }

// Show dialog edit

  _showDialogEdit(BuildContext context) async {
    _textEditingController1.clear();
    _textEditingController2.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Container(
              height: 180,
              child: Column(
                children: <Widget>[
                  new Expanded(
                      child: new TextField(
                    maxLength: 120,
                    maxLengthEnforced: true,
                    controller: _textEditingController1,
                    autofocus: true,
                    decoration: new InputDecoration(
                      labelText: 'Front',
                    ),
                  )),
                  new Expanded(
                      child: new TextField(
                    maxLength: 120,
                    maxLengthEnforced: true,
                    controller: _textEditingController2,
                    autofocus: true,
                    decoration: new InputDecoration(
                      labelText: 'Back',
                    ),
                  ))
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    _deleteNote(_noteList[index].key, index);
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    _changeNote(
                        _textEditingController1.text.toString(),
                        _textEditingController2.text.toString(),
                        _noteList[index],
                        index);
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

// Translate
  _translateText(text, controller) async {
    final translator = new GoogleTranslator();
    String translation = await translator.translate(text, to: lang);
    setState(() {
      controller.text = translation;
    });
    _addNewNote(text.toString(), controller.text.toString());
  }

// Show dialog new

  _showDialogNew(BuildContext context) async {
    _textEditingController1.clear();
    _textEditingController2.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Container(
              height: 180,
              child: Column(
                children: <Widget>[
                  TextField(
                    maxLength: 120,
                    maxLengthEnforced: true,
                    controller: _textEditingController1,
                    autofocus: true,
                    decoration: new InputDecoration(
                      labelText: 'Front',
                    ),
                  ),
                  TextField(
                    maxLength: 120,
                    maxLengthEnforced: true,
                    controller: _textEditingController2,
                    autofocus: true,
                    decoration: new InputDecoration(
                      labelText: 'Back',
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Traduzir'),
                  onPressed: () {
                    _translateText(
                      this._textEditingController1.text,
                      _textEditingController2,
                    );
                  }),
              new FlatButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Salvar'),
                  onPressed: () {
                    _addNewNote(_textEditingController1.text.toString(),
                        _textEditingController2.text.toString());
                    _speak(_textEditingController1.text);
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  ButtonMode _formMode1 = ButtonMode.ANSWEAR;
  bool _isIos;
  bool _isLoading;

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

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToStudyYour() {
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
              backgroundColor: Colors.white,
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: _showBody(),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () {
                _showDialogNew(context);
              },
              tooltip: 'Create',
              child: Icon(Icons.add),
            ))
        : new Scaffold(
            appBar: new AppBar(
              elevation: 1,
              backgroundColor: Colors.white,
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('Editar',
                        style:
                            new TextStyle(fontSize: 17.0, color: Colors.black)),
                    onPressed: () {
                      _showDialogEdit(context);
                    }),
                IconButton(
                  icon: Icon(Icons.play_arrow, color: Colors.grey[850]),
                  onPressed: () {
                    _speak(_noteList[index].front);
                  },
                )
              ],
            ),
            body: _showBody(),
          );
  }

  Widget _showBody() {
    return new Container(
        margin: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your deck',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 24),
            ),
            SizedBox(height: 30),
            _formMode == FormMode.LOGIN
                ? new Form(
                    key: _formKey,
                    child: new ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        _showStudyButton(),
                      ],
                    ),
                  )
                : new Form(
                    key: _formKey,
                    child: new ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        _showNoteList(),
                      ],
                    ),
                  )
          ],
        ));
  }

  // List that you should do today
  var todayList;
  var tomorrowList = 0;
  // Translator var
  String lang;
  // Study Button
  String input1 = 'Língua';
  String input2 = 'Voz';
  Widget _showStudyButton() {
    todayList = new List();
    tomorrowList = 0;
    var today = DateTime.now();
    var tomorrow = DateTime.now();
    tomorrow = tomorrow.add(new Duration(days: 1));
    for (int i = 0; i < _noteList.length; i++) {
      var date = new DateFormat.yMd().parse(_noteList[i].today);
      if (today.difference(date).isNegative == false) {
        todayList.add(_noteList[i]);
      }
      if (tomorrow.difference(date).isNegative == false) {
        tomorrowList += 1;
      }
    }
    return Center(
        child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Cards: ',
                      style: TextStyle(color: Colors.grey[850], fontSize: 18),
                    ),
                    Text(
                      _noteList.length.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Today: ',
                      style: TextStyle(color: Colors.grey[850], fontSize: 18),
                    ),
                    Text(
                      todayList.length.toString(),
                      style: TextStyle(color: Colors.green, fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Tomorrow: ',
                      style: TextStyle(color: Colors.grey[850], fontSize: 18),
                    ),
                    Text(
                      tomorrowList.toString(),
                      style: TextStyle(color: Colors.lightBlue, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new DropdownButton<String>(
                  elevation: 1,
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
                      setState(() => lang = 'es');
                    }
                    if (value == "Francês") {
                      flutterTts.setLanguage("fr-FR");
                      setState(() => lang = 'fr');
                    }
                    if (value == "Inglês") {
                      flutterTts.setLanguage("en-US");
                      setState(() => lang = 'en');
                    }
                    if (value == "Português") {
                      flutterTts.setLanguage("pt-BR");
                      setState(() => lang = 'pt');
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
              elevation: 3.0,
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
                    : _changeFormToStudyYour();
                _speak(todayList[index].front);
              }),
        ),
      ],
    ));
  }

  // Show note list

  Widget _showNoteList() {
    // List
    if (todayList.length > 0) {
      if (index < todayList.length) {
        return Center(
          child: Column(
          children: <Widget>[
            Text(
              todayList[index].front,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0, color: Colors.grey[850]),
            ),
            Container(
                child: _formMode1 == ButtonMode.BUTTON
                    ? new Form(
                        key: _formKey1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              todayList[index].back,
                              style: TextStyle(
                                  fontSize: 30.0, color: Colors.grey[850]),
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
                                      _updateNote(todayList[index], false);
                                      setState(() => index += 1);
                                      _speak(todayList[index].front);
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
                                      _updateNote(todayList[index], true);
                                      setState(() => index += 1);
                                      _speak(todayList[index].front);
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
                              child: Text('Mostrar resposta',
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
        return Container(
            child: Text(
          "Você acabou por hoje",
          style: TextStyle(fontSize: 22.0, color: Colors.grey[850]),
        ));
      }
    } else {
      return Container(
          child: Text(
        "Você ainda não tem nenhum card",
        style: TextStyle(fontSize: 22.0, color: Colors.grey[850]),
      ));
    }
  }
}
