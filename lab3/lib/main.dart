import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

enum ChooseList { rich, raw }

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestHttp(),
    ));

class TestHttp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TestHttpState();
}

class TestHttpState extends State<TestHttp> {
  String _body;
  var artist;
  var artist2;
  var artist_text;
  var artist_liked;
  var artist_liked2;
  ChooseList _choice;

  httpGet() async {
    try {
      var response = await http.get('https://music.yandex.ru/artist/191175');
      //page-artist__title typo-h1 typo-h1_big
      print('Response status: ${response.statusCode}');
      var document = parse(response.body);
      _body = document.outerHtml;
      artist = document.getElementsByClassName('artist')[0].children[0];
      artist2 = document.getElementsByClassName('artist')[1].children[0];
      artist_liked = artist.getElementsByTagName('a');
      artist_liked2 = artist2.getElementsByTagName('a');
      artist_text = 'Похожие исполнители: ${artist_liked[0].text}, ${artist_liked2[0].text}';
      //
      setState(() {});
    } catch (error) {
      print('Error: $error');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ЛР3 Сети'),
        ),
        body: SingleChildScrollView(
          //FlatButton(onPressed: ()=> httpGet(), color: Colors. purple, textColor: Colors.white, child: Text('http'),),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15.0),
                child: FlatButton(
                  onPressed: () => httpGet(),
                  color: Colors.purple,
                  textColor: Colors.white,
                  child: Text('Get Response'),
                ),
                alignment: Alignment.topCenter,
              ),
              Opacity(
                opacity: _body == null ? 0.0 : 1.0,
                child: Container(
                  child: FlatButton(
                    minWidth: 130.0,
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SecondScreen(_body))),
                    color: Colors.red,
                    textColor: Colors.white,
                    child: Text('Get Raw'),
                  ),
                  alignment: Alignment.topCenter,
                ),
              ),
              SizedBox(height: 20.0),
              Text('Ответ сервера',
                  style: TextStyle(fontSize: 20.0, color: Colors.blue)),
              Container(

                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(5.0),
                child: Text(
                  artist_text == null ? '' : artist_text,
                  style: TextStyle(fontSize: 17.0, color: Colors.redAccent, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                child: Html(
                  data: _body == null ? '' : _body,
                  useRichText: true,
                ),
                padding: EdgeInsets.all(10.0),
              ),
            ],
          ),
        ));
  }
}

class SecondScreen extends StatelessWidget {
  String _body;

  SecondScreen(String body) {
    _body = body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
      SizedBox(
        height: 45.0,
      ),
      Container(
          child: RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.green,
              textColor: Colors.white,
              child: Text('Назад'))),
      Text(
        _body == null ? '' : _body,
        overflow: TextOverflow.clip,
      ),
    ])));
  }
}
//Text(_body == null ? '' : _body, overflow: TextOverflow.clip ,),
