import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_analytics/firebase_analytics.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseAnalytics().logEvent(name: 'app_was_opened', parameters: null);
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>with WidgetsBindingObserver {
  String responseText = 'empty';
  final _controllerLogin = TextEditingController();
  final _controllerPassword = TextEditingController();
  final focusNodeLogin = FocusNode();
  final focusNodePassword = FocusNode();

  void dismissKeyboardPassword() {
    focusNodeLogin.unfocus();
  }

  void dismissKeyboardLogin() {
    focusNodePassword.unfocus();
  }
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        {
          await FirebaseAnalytics()
              .logEvent(name: 'app_was_resumed', parameters: null);
          break;
        }
      case AppLifecycleState.inactive:
        {
          await FirebaseAnalytics()
              .logEvent(name: 'app_is_inactive', parameters: null);
          break;
        }
      case AppLifecycleState.paused:
        {
          await FirebaseAnalytics()
              .logEvent(name: 'app_was_paused', parameters: null);
          break;
        }
      case AppLifecycleState.detached:
        {
          FirebaseAnalytics()
              .logEvent(name: 'app_was_detached', parameters: null);
          break;
        }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Лаба 8. Авторизация по JWT-токену'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 200.0,
            ),
            Center(
              child: TextFormField(
                focusNode: focusNodeLogin,
                controller: _controllerLogin,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Введите ваше логин',
                  labelText: 'Логин *',
                ),
                onSaved: (String? value) {
                  // This optional block of code can be used to run
                  // code when the user saves the form.
                },
                validator: (String? value) {
                  return (value != null && value.contains('@'))
                      ? 'Do not use the @ char.'
                      : null;
                },
              ),
            ),
            Center(
              child: TextFormField(
                focusNode: focusNodePassword,
                controller: _controllerPassword,
                decoration: const InputDecoration(
                  icon: Icon(Icons.lock),
                  hintText: 'Введите ваш пароль',
                  labelText: 'Пароль *',
                ),
                onSaved: (String? value) {
                  // This optional block of code can be used to run
                  // code when the user saves the form.
                },
                validator: (String? value) {
                  return (value != null && value.contains('@'))
                      ? 'Do not use the @ char.'
                      : null;
                },
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Center(
                child: RaisedButton(
              padding: EdgeInsets.only(left: 60.0, right: 60.0),
              color: Colors.blue,
              onPressed: () async {
                var url = Uri.parse('https://vast-cove-79369.herokuapp.com/');
                if (_controllerLogin.text.isNotEmpty &&
                    _controllerPassword.text.isNotEmpty) {
                  var response = await http.post(url, body: {
                    'login': _controllerLogin.text,
                    'password': _controllerPassword.text
                  });
                  if (response.statusCode == 200) {
                    responseText = response.body;
                    var url = Uri.parse(
                        'https://vast-cove-79369.herokuapp.com/auth.php');
                    var responseToken =
                        await http.post(url, body: {'jwt': responseText});
                    setState(() {
                      if (response.body != 'failed') {
                        if (responseToken.statusCode == 200) {
                          var bytes = base64Decode(
                              jsonDecode(responseToken.body)['image']);
                          var time = jsonDecode(responseToken.body)['time'];
                          FirebaseAnalytics().logEvent(name: 'user_was_logined', parameters: null);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Result(responseText, bytes, time)));
                        }
                      } else {
                        final snackBar = SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            'Вы ввели неправильный логин или пароль',
                            style: TextStyle(color: Colors.white),
                          ),
                          action: SnackBarAction(
                            textColor: Colors.white,
                            label: 'Закрыть',
                            onPressed: () {
                              // Some code to undo the change.
                            },
                          ),
                        );
                        dismissKeyboardLogin();
                        dismissKeyboardPassword();
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    });
                  } else {
                    setState(() {
                      responseText = 'Error';
                    });
                  }
                  _controllerLogin.clear();
                  _controllerPassword.clear();
                }
              },
              child: Text(
                'Войти',
                style: TextStyle(color: Colors.white),
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class Result extends StatefulWidget {
  String responseText = '';
  var bytes, time;

  Result(String _responseText, var _bytes, var _time) {
    bytes = _bytes;
    time = _time;
    responseText = _responseText;
  }

  @override
  _ResultState createState() => _ResultState(responseText, bytes, time);
}

class _ResultState extends State<Result> {
  String responseText = '';
  String responseAuth = 'Вы успешно авторизовались.';
  var bytes;
  var time;

  _ResultState(String _responseText, var _bytes, var _time) {
    bytes = _bytes;
    time = _time;
    responseText = _responseText;
  }

  Future<void> _showMyDialog(String responseText) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('JWT token'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(responseText),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Закрыть'),
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        FirebaseAnalytics().logEvent(name: 'user_left_page_of_auth_method', parameters: null);
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('User1'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              FirebaseAnalytics().logEvent(name: 'user_left_page_of_auth_method', parameters: null);
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Container(
              child: Column(
            children: <Widget>[
              SizedBox(
                height: 100.0,
              ),
              Center(
                  child:
                      bytes == null ? Text('No Image') : Image.memory(bytes)),
              SizedBox(
                height: 30.0,
              ),
              Center(
                  child: time == null
                      ? Text('')
                      : Text(
                          time,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
              RaisedButton(
                  color: Colors.green,
                  child: Text('Показать JWT токен'),
                  onPressed: () {
                    FirebaseAnalytics().logEvent(name: 'user_opened_jwt', parameters: null);
                    _showMyDialog(responseText);
                  })
            ],
          )),
        ),
      ),
    );
  }
}
