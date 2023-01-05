import 'dart:convert';

import 'package:fallout_shelter_editor/editor_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fallout Shelter Save Editor ☢',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: '☢ Fallout Shelter Save Editor ☢'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late Future<EditorData> _data;
  
  _MyHomePageState() : super() {
    _data = _getEditorData();
  }

  Future<EditorData> _getEditorData() async {
    final sp = await SharedPreferences.getInstance();
    final rawData = sp.getString("data");
    
    if (rawData == null) {
      return EditorData();
    }

    final json = jsonDecode(rawData);
    return EditorData(recentSaves: json["recentSaves"]);
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    var tabs = <_Tab>[
      _Tab(
        icon: const Icon(Icons.home),
        text: const Text("Home"),
        body: Tab(
          child: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Recent save files',
                  style: Theme.of(context).textTheme.headline4
                ),
                FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data!;
                      if (data.recentSaves.isEmpty) {
                        return Text(
                          "No recent save files to show",
                          style: Theme.of(context).textTheme.subtitle1,
                        );
                      } else {
                        return Expanded(
                          child: ListView(
                            children: data.recentSaves.map((x) => Text(x)).toList(),
                          )
                        );
                      }
                    } else if (snapshot.hasError) {
                      return const Text("Could not load recent saves list");
                    } else {
                      return const Text("Loading recent saves list");
                    }
                  },
                  future: _data,
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Open a save file',
              child: const Icon(Icons.file_open),
            ),
          ),
        )
      )
    ];
    return DefaultTabController(
      length: tabs.length,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(tabs: tabs.map((t) => Row(children: [t.icon, t.text],)).toList()),
        ),
        body: TabBarView(
          children: tabs.map((t) => t.body).toList()
        ),
      ),
    );
  }
}

class _Tab {
  Icon icon;
  Text text;
  Tab body;
  
  _Tab({required this.icon, required this.text, required this.body});
}