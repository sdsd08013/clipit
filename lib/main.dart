import 'package:clipit/clip.dart';
import 'package:clipit/color.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:core';

import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clipit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Clipit'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Clip> clips = [];
  String lastText = "";
  int index = 0;
  static const channelName = 'clipboard/html';
  final methodChannel = const MethodChannel(channelName);

  Future<Database> get database async {
    return openDatabase(
      join(await getDatabasesPath(), 'clipit.db'),
      onCreate: (db, version) {
        //db.delete('clips');
        return db.execute(
          'CREATE TABLE clips(id INTEGER PRIMARY KEY, text TEXT)',
        );
      },
      version: 1,
    );
  }

  void dropTable() async {
    await deleteDatabase(await getDatabasesPath());
  }

  void retlieveClips() async {
    final db = await database;
    //db.delete('clips');
    final List<Map<String, dynamic>> maps =
        await db.query('clips', orderBy: "id asc");
    if (maps.isNotEmpty) {
      final newclips = List.generate(maps.length, (index) {
        if (index == 0) {
          return Clip(
              id: maps[index]['id'],
              text: maps[index]['text'],
              isSelected: true);
        } else {
          return Clip(
              id: maps[index]['id'],
              text: maps[index]['text'],
              isSelected: false);
        }
      });

      setState(() {
        clips = newclips;
      });
    }
  }

  getClipboardHtml() async {
    try {
      final result = await methodChannel.invokeMethod('getClipboardContent');
      if (result != null) {
        updateListIfNeeded(result);
        lastText = result;
      }
    } on PlatformException catch (e) {
      print("error in getting clipboard image");
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    //dropTable();
    retlieveClips();

    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        getClipboardHtml();
      });
    });
  }

  void updateListIfNeeded(String result) async {
    final exist = clips.firstWhereOrNull((element) => element.text == result);
    if (exist != null) {
      setState(() {
        clips.removeWhere((element) => element.id == exist.id);
        clips.insert(0, exist);
        clips;
      });
    } else {
      final id = await saveClip(result);
      setState(() {
        clips.insert(0, Clip(id: id, text: result, isSelected: false));
        clips;
      });
    }
  }

  final _listViewDownKeySet = LogicalKeySet(LogicalKeyboardKey.keyJ);
  final _listViewUpKeySet = LogicalKeySet(LogicalKeyboardKey.keyK);
  final _listViewItemCopyKeySet =
      LogicalKeySet(LogicalKeyboardKey.keyC, LogicalKeyboardKey.meta);
  final _listViewDeleteKeySet = LogicalKeySet(LogicalKeyboardKey.keyD);

  void updateListViewState(Intent e) {
    if (e.runtimeType == _ListViewUpIntent) {
      decrementIndex();
      setState(() {
        clips[index + 1].isSelected = false;
        clips[index].isSelected = true;
      });
    } else if (e.runtimeType == _ListViewDownIntent) {
      incrementIndex();
      setState(() {
        clips[index - 1].isSelected = false;
        clips[index].isSelected = true;
      });
    }
  }

  void handleListViewDeleteAction() {
    deleteClip();
    final targetClip = clips[index];

    setState(() {
      clips.remove(targetClip);
      clips;
    });
    decrementIndex();
  }

  void copyToClipboard(String s) {
    Clipboard.setData(ClipboardData(text: s));
  }

  void incrementIndex() {
    if (index == clips.length - 1 || clips.length < 2) return;
    index++;
  }

  void decrementIndex() {
    if (index == 0 || clips.length < 2) return;
    index--;
  }

  Future<int> deleteClip() async {
    final db = await database;
    return db.delete('clips', where: 'id = ?', whereArgs: [clips[index].id]);
  }

  Future<int> saveClip(String clipText) async {
    final db = await database;
    return db.insert('clips', {'text': clipText},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  void saveClips() async {
    final db = await database;
    final batch = db.batch();
    for (var clip in clips) {
      batch.insert('clips', clip.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: clips.isEmpty
                ? const Text("empty ;)")
                : FocusableActionDetector(
                    autofocus: true,
                    shortcuts: {
                      _listViewUpKeySet: _ListViewUpIntent(),
                      _listViewDownKeySet: _ListViewDownIntent(),
                      _listViewItemCopyKeySet: _ListViewItemCopyIntent(),
                      _listViewDeleteKeySet: _ListViewItemDeleteIntent()
                    },
                    actions: {
                      _ListViewUpIntent: CallbackAction(
                          onInvoke: (e) => updateListViewState(e)),
                      _ListViewDownIntent: CallbackAction(
                          onInvoke: (e) => updateListViewState(e)),
                      _ListViewItemCopyIntent: CallbackAction(
                          onInvoke: (e) =>
                              copyToClipboard(clips[index].mdText)),
                      _ListViewItemDeleteIntent: CallbackAction(
                          onInvoke: (e) => handleListViewDeleteAction())
                    },
                    child: Row(children: <Widget>[
                      Container(
                          color: sideBackground,
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: ListView.separated(
                            itemBuilder: (context, index) => Container(
                                padding: const EdgeInsets.all(8),
                                color: clips[index].backgroundColor(context),
                                child: Text(
                                  style: const TextStyle(color: textColor),
                                  clips[index].subText(),
                                )),
                            separatorBuilder: (context, index) =>
                                const Divider(color: sideDivider, height: 0.5),
                            itemCount: clips.length,
                          )),
                      Container(
                          alignment: Alignment.topLeft,
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Markdown(
                              controller: ScrollController(),
                              shrinkWrap: true,
                              data: clips[index].mdText))
                      // Expanded(
                      //     flex: 1,
                      //     child: SingleChildScrollView(
                      //         scrollDirection: Axis.vertical,
                      //         child: Expanded(
                      //             child: Markdown(
                      //                 data: clips[index].mdText)))))
                    ]))));
  }
}

class _ListViewDownIntent extends Intent {}

class _ListViewUpIntent extends Intent {}

class _ListViewItemCopyIntent extends Intent {}

class _ListViewItemDeleteIntent extends Intent {}
