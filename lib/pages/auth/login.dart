import 'package:flutter/material.dart';
import 'package:portunhol/services/authentication.dart';

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();

  String _name;
  String _email;
  String _number;
  String _password;
  String _errorMessage;

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in: $userId');
        } else {
          userId = await widget.auth
              .signUpWithName(_email, _password, _name, _number);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog();
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 &&
            userId != null &&
            _formMode == FormMode.LOGIN) {
          widget.onSignedIn();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          title: Text('Login', style: TextStyle(color: Colors.blueAccent, fontSize: 26)),
          backgroundColor: Colors.white,
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
          ],
        ));
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verifique sua conta"),
          content:
              new Text("Link para verificação da conta enviado para o email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                _changeFormToLogin();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showBody() {
    return new Container(
        // padding: EdgeInsets.only(top: 100, left: 16, right: 16),
        padding: EdgeInsets.all(16.0),
        child: _formMode == FormMode.LOGIN
            ? new Form(
                key: _formKey,
                child: new ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    // _showLogo(),
                    _showEmailInput(),
                    _showPasswordInput(),
                    _showPrimaryButton(),
                    _showSecondaryButton(),
                    _showErrorMessage(),
                  ],
                ),
              )
            : new Form(
                key: _formKey,
                child: new ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    // _showLogo(),
                    _showNameInput(),
                    _showEmailInput(),
                    _showNumberInput(),
                    _showPasswordInput(),
                    _showPrimaryButton(),
                    _showSecondaryButton(),
                    _showErrorMessage(),
                  ],
                ),
              ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  // Widget _showLogo() {
  //   return new Container(
  //       child: _formMode == FormMode.LOGIN
  //           ? new Form(
  //               child: Padding(
  //                 padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
  //                 // child: 
  //               ),
  //             )
  //           : new Form(
  //               child: Padding(
  //                 padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
  //                 // child: 
  //               ),
  //             )
  //             );
  // }

  Widget _showNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.grey[300],
            hintText: 'Nome',
            icon: new Icon(
              Icons.person,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'Nome não pode estar vazio' : null,
        onSaved: (value) => _name = value.trim(),
      ),
    );
  }

  Widget _showNumberInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.grey[300],
            hintText: 'Numero',
            icon: new Icon(
              Icons.smartphone,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'Numero não pode estar vazio' : null,
        onSaved: (value) => _number = value.trim(),
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.grey[300],
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'Email não pode estar vazio' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.grey[300],
            hintText: 'Senha',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'Senha não pode estar vazia' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      child: _formMode == FormMode.LOGIN
          ? new Text('Criar conta',
              style: new TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.black))
          : new Text('Tem uma conta ? Logue',
              style: new TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.black)),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 50.0,
          child: new RaisedButton(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            color: Colors.blueAccent,
            child: _formMode == FormMode.LOGIN
                ? new Text('Entrar',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : new Text('Criar conta',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _validateAndSubmit,
          ),
        ));
  }
}
