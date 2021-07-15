import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as Enc;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final keyField = TextEditingController();
  String path;
  String text = '';
  String check = 'null';
  String _enc = '';
  String _dec = 'Не зашифровано';
  String decrypted;
  String keyOne;

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/file.txt');
  }

  Future<void> _showMyDialog(String show) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: AlertDialog(
              title: Text('Plain Text'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(show),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
      },
    );
  }

  Future<void> encrypt(String keyStr) async {
    String plainText = '';
    if (check == 'null') {
      plainText = await loadAsset();
    } else {
      plainText = check;
    }
    keyOne = keyStr;
    print('length: ${keyStr.length}');
    if (keyStr.length < 32) {
      /*for (int i = 0; i < 32 - keyStr.length; i++) {
        keyStr = "$keyStr ";
      }*/
      while (keyStr.length < 32) {
        keyStr = "$keyStr ";
      }
    }
    print('length: ${keyStr.length}');
    final key = Enc.Key.fromUtf8(keyStr);
    final iv = Enc.IV.fromLength(16);
    final encrypter = Enc.Encrypter(Enc.AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    _enc = encrypted.base64.toString();
    print("Зашифрованное: $_enc");
  }

  Future<void> decrypt(String keyStr) async {
    if(_enc == ''){
      await encrypt(keyStr);
    }

    String plainText = _enc;
    keyOne = keyStr;
    print('length: ${keyStr.length}');
    if (keyStr.length < 32) {
      /*for (int i = 0; i < 32 - keyStr.length; i++) {
        keyStr = "$keyStr ";
      }*/
      while (keyStr.length < 32) {
        keyStr = "$keyStr ";
      }
    }
    print("Ключ: $keyStr");
    final key = Enc.Key.fromUtf8(keyStr);
    final iv = Enc.IV.fromLength(16);
    final encrypter = Enc.Encrypter(Enc.AES(key, padding: null));
    final encryptedText = Enc.Encrypted.fromBase64(plainText);
    final decrypted = encrypter.decrypt(encryptedText, iv: iv);

    print("Расшифрованное: $decrypted");
    //print(decrypted);
    _dec = decrypted;
    //return decrypted;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Text('Crypt'),
            backgroundColor: Colors.deepPurple,
          ),
          body:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              padding: EdgeInsets.all(15.0),
              width: 350.0,
              child: Center(
                child: TextField(
                    controller: keyField,
                    maxLength: 32,
                    decoration: InputDecoration(
                      fillColor: Colors.deepPurple,
                      suffixIcon: Icon(Icons.vpn_key_outlined),
                      border: OutlineInputBorder(
                      ),
                      labelText: 'Введите ключ',
                    )),
              ),
            ),
            Center(
                // ignore: deprecated_member_use
                child: RaisedButton(
              color: Colors.green,
              onPressed: () async {
                text = await loadAsset();
                setState(() {
                  check = text;
                  _showMyDialog(check);
                });
              },
              child: Text('plain text'),
            )),
            Center(
                // ignore: deprecated_member_use
                child: RaisedButton(
              color: Colors.red,
              onPressed: () async {
                await encrypt(keyField.text);
                setState(() {
                  _showMyDialog(_enc);
                });
              },
              child: Text('encrypted text'),
            )),
            Center(
                // ignore: deprecated_member_use
                child: RaisedButton(
              color: Colors.yellow,
              onPressed: () async {
                await decrypt(keyField.text);
                setState(() {
                  _showMyDialog(_dec);
                });
              },
              child: Text('decrypted text'),
            )),
            SingleChildScrollView(
              child: Text(''),
            )
          ])),
    );
  }
}
