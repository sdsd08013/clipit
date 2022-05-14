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
  List<Clip> clips = [];
  String lastText = "";
  int index = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        Clipboard.getData('text/plain').then((clipboarContent) {
          if (clipboarContent != null) {
            if (lastText != clipboarContent.text!) {
              updateListIfNeeded(Clip(clipboarContent.text!));
              lastText = clipboarContent.text!;
            }
          }
        });
      });
    });
  }

  void updateListIfNeeded(Clip clip) {
    final Iterable<String> texts = clips.map((e) => e.text);
    setState(() {
      if (texts.contains(clip.text)) {
        clips.remove(clip);
        clips.add(clip);
      } else {
        clips.add(clip);
      }
    });
  }

  final _listViewDownKeySet = LogicalKeySet(LogicalKeyboardKey.keyJ);
  final _listViewUpKeySet = LogicalKeySet(LogicalKeyboardKey.keyK);

  void updateListViewState(Intent e) {
    if (e.runtimeType == _ListViewUpIntent) {
      decrementIndex();
      setState(() {
        clips[index].isSelected = true;
        clips[index + 1].isSelected = false;
      });
    } else if (e.runtimeType == _ListViewDownIntent) {
      incrementIndex();
      setState(() {
        clips[index].isSelected = true;
        clips[index - 1].isSelected = false;
      });
    }
  }

  void incrementIndex() {
    if (index == clips.length - 1) return;
    index++;
  }

  void decrementIndex() {
    if (index == 0) return;
    index--;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: FocusableActionDetector(
                autofocus: true,
                shortcuts: {
                  _listViewUpKeySet: _ListViewUpIntent(),
                  _listViewDownKeySet: _ListViewDownIntent()
                },
                actions: {
                  _ListViewUpIntent:
                      CallbackAction(onInvoke: (e) => updateListViewState(e)),
                  _ListViewDownIntent:
                      CallbackAction(onInvoke: (e) => updateListViewState(e)),
                },
                child: ListView.separated(
                  itemBuilder: (context, index) => Text(clips[index].subText(),
                      style: TextStyle(
                          backgroundColor: clips[index].backgroundColor())),
                  separatorBuilder: (context, index) =>
                      const Divider(height: 0.5),
                  itemCount: clips.length,
                ))));
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _ListViewDownIntent extends Intent {}

class _ListViewUpIntent extends Intent {}
