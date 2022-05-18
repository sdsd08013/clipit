import 'package:clipit/clip.dart';
import 'package:clipit/clip_repository.dart';
import 'package:clipit/color.dart';
import 'package:clipit/icon_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:async';
import 'dart:core';

import 'package:macos_ui/macos_ui.dart';

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
  static const channelName = 'clipboard/html';
  final methodChannel = const MethodChannel(channelName);
  final clipRepository = ClipRepository();
  double offset = 0;
  double dragStartPos = 0;

  getClipboardHtml() async {
    try {
      final result = await methodChannel.invokeMethod('getClipboardContent');
      if (result != null) {
        updateListIfNeeded(result);
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
    //clipRepository.dropTable();

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
        clips.insertToFirst(Clip(
            id: id,
            text: result,
            isSelected: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now()));
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

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: clips.currentClip.plainText));
  }

  @override
  Widget build(BuildContext context) {
    final appWidth = MediaQuery.of(context).size.width;
    const ratio1 = 0.15;
    const ratio2 = 0.85;
    const ratio3 = 0.3;
    const ratio4 = 0.7;
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
                      _ListViewItemCopyIntent:
                          CallbackAction(onInvoke: (e) => copyToClipboard()),
                      _ListViewItemDeleteIntent: CallbackAction(
                          onInvoke: (e) => handleListViewDeleteAction())
                    },
                    child: Row(children: [
                      Container(
                          color: side1stBackground,
                          width: appWidth * ratio1 - 2 - offset,
                          child: ListView(children: [
                            Container(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                color: side1stBackgroundSelect,
                                child: IconText(
                                  icon: Icons.copy,
                                  text: "clip",
                                  textColor: textColor,
                                  iconColor: iconColor,
                                  onTap: {print("tap1st")},
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                color: side1stBackground,
                                child: IconText(
                                  icon: Icons.memory,
                                  text: "archived",
                                  textColor: textColor,
                                  iconColor: iconColor,
                                  onTap: {print("tap2nd")},
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                color: side1stBackground,
                                child: IconText(
                                  icon: Icons.delete,
                                  text: "trash",
                                  textColor: textColor,
                                  iconColor: iconColor,
                                  onTap: {print("tap2nd")},
                                )),
                          ])),
                      MouseRegion(
                          cursor: SystemMouseCursors.resizeColumn,
                          child: GestureDetector(
                              onHorizontalDragStart: (detail) {
                                dragStartPos = detail.globalPosition.dx;
                              },
                              onHorizontalDragUpdate: (detail) {
                                final appWidth =
                                    MediaQuery.of(context).size.width;
                                double newOffset =
                                    dragStartPos - detail.globalPosition.dx;
                                if (appWidth * ratio1 < newOffset ||
                                    appWidth * ratio1 - newOffset > appWidth)
                                  return;
                                setState(() => {
                                      offset = (dragStartPos -
                                          detail.globalPosition.dx)
                                    });
                              },
                              child: Container(
                                width: 2,
                                color: Colors.black,
                              ))),
                      Container(
                        alignment: Alignment.topLeft,
                        width: appWidth * ratio2 + offset,
                        child: Row(children: <Widget>[
                          Container(
                              color: side2ndBackground,
                              width: (appWidth * ratio2 + offset) * ratio3,
                              child: ListView.separated(
                                itemBuilder: (context, index) => Container(
                                    padding: const EdgeInsets.all(8),
                                    color: clips.value[index]
                                        .backgroundColor(context),
                                    child: Text(
                                      style: const TextStyle(color: textColor),
                                      clips.value[index].subText(),
                                    )),
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                        color: sideDivider, height: 0.5),
                                itemCount: clips.value.length,
                              )),
                          Container(
                              alignment: Alignment.topLeft,
                              width: (appWidth * ratio2 + offset) * ratio4,
                              child: Column(children: [
                                Container(
                                  color: side1stBackground,
                                  height: 50,
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: IconButton(
                                              onPressed: () =>
                                                  copyToClipboard(),
                                              color: iconColor,
                                              icon: const Icon(
                                                Icons.copy,
                                              ),
                                              tooltip: 'Copy to clipboard',
                                            )),
                                        Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: IconButton(
                                              onPressed: () =>
                                                  copyToClipboard(),
                                              color: iconColor,
                                              icon: const Icon(
                                                Icons.memory,
                                              ),
                                              tooltip: 'Archive and save',
                                            )),
                                        Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: IconButton(
                                              onPressed: () =>
                                                  copyToClipboard(),
                                              color: iconColor,
                                              icon: const Icon(Icons.delete),
                                              tooltip: 'move to trash',
                                            ))
                                      ]),
                                ),
                                Markdown(
                                    controller: ScrollController(),
                                    shrinkWrap: true,
                                    data: clips.currentClip.mdText)
                              ]))
                        ]),
                      )
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
