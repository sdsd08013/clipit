import 'package:clipit/clip.dart';
import 'package:clipit/clip_repository.dart';
import 'package:clipit/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:async';
import 'dart:core';

void main() {
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
  ClipList clips = ClipList(value: []);
  String lastText = "";
  static const channelName = 'clipboard/html';
  final methodChannel = const MethodChannel(channelName);
  final clipRepository = ClipRepository();

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

  Future<void> retlieveClips() async {
    final retlievedClips = await clipRepository.getClips();
    setState(() {
      clips = retlievedClips ?? ClipList(value: []);
    });
  }

  @override
  void initState() {
    super.initState();
    retlieveClips();
    //dropTable();

    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        getClipboardHtml();
      });
    });
  }

  void updateListIfNeeded(String result) async {
    if (clips.isExist(result)) {
      // setState(() {
      //   clips.removeWhere((element) => element.id == exist.id);
      //   clips.insert(0, exist);
      //   clips;
      // });
    } else {
      final id = await clipRepository.saveClip(result);
      setState(() {
        clips.insertToFirst(Clip(id: id, text: result, isSelected: true));
        clips;
      });
    }
  }

  void updateListViewState(Intent e) {
    if (e.runtimeType == _ListViewUpIntent) {
      setState(() {
        clips.decrement();
        clips;
      });
    } else if (e.runtimeType == _ListViewDownIntent) {
      setState(() {
        clips.increment();
        clips;
      });
    }
  }

  void handleListViewDeleteAction() {
    clipRepository.deleteClip(clips.currentClip.id);

    setState(() {
      clips.deleteCurrentClip();
      clips = clips;
    });
  }

  void copyToClipboard(String s) {
    Clipboard.setData(ClipboardData(text: s));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: clips.value.isEmpty
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
                              copyToClipboard(clips.currentClip.mdText)),
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
                                color:
                                    clips.value[index].backgroundColor(context),
                                child: Text(
                                  style: const TextStyle(color: textColor),
                                  clips.value[index].id.toString(),
                                )),
                            separatorBuilder: (context, index) =>
                                const Divider(color: sideDivider, height: 0.5),
                            itemCount: clips.value.length,
                          )),
                      Container(
                          alignment: Alignment.topLeft,
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Markdown(
                              controller: ScrollController(),
                              shrinkWrap: true,
                              data: clips.currentClip.mdText))
                    ]))));
  }
}

class _ListViewDownIntent extends Intent {}

class _ListViewUpIntent extends Intent {}

class _ListViewItemCopyIntent extends Intent {}

class _ListViewItemDeleteIntent extends Intent {}

final _listViewDownKeySet = LogicalKeySet(LogicalKeyboardKey.keyJ);
final _listViewUpKeySet = LogicalKeySet(LogicalKeyboardKey.keyK);
final _listViewItemCopyKeySet =
    LogicalKeySet(LogicalKeyboardKey.keyC, LogicalKeyboardKey.meta);
final _listViewDeleteKeySet = LogicalKeySet(LogicalKeyboardKey.keyD);
