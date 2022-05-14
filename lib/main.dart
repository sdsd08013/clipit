import 'package:clipit/clip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:core';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ClipNotifier(),
        child: MaterialApp(
          title: 'Clipit',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(title: 'Clipit'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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
  final clipboardContentStream = StreamController<String>.broadcast();
  List<String> clips = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        Clipboard.getData('text/plain').then((clipboarContent) {
          if (clipboarContent != null) {
            updateListIfNeeded(clipboarContent.text!);
          }
        });
      });
    });
  }

  void updateListIfNeeded(String clip) {
    setState(() {
      if (clips.contains(clip)) {
        clips.remove(clip);
        clips.add(clip);
      } else {
        clips.add(clip);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: ListView(
              children:
                  clips.map((clip) => Text(Clip(clip).subText())).toList())),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
