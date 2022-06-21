import 'package:clipit/models/history.dart';
import 'package:clipit/models/side_type.dart';
import 'package:clipit/repositories/history_repository.dart';
import 'package:clipit/color.dart';
import 'package:clipit/icon_text.dart';
import 'package:clipit/repositories/pin_repository.dart';
import 'package:clipit/views/contents_main.dart';
import 'package:clipit/views/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'dart:async';
import 'dart:core';
import 'models/pin.dart';
import 'models/selectable.dart';
import 'models/trash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      theme: MacosThemeData(
          typography: MacosTypography(
              largeTitle: const TextStyle(
                  color: textColor, fontFamily: "RictyDiminished"),
              title1: const TextStyle(
                  color: textColor, fontFamily: "RictyDiminished"),
              title2: const TextStyle(
                  color: textColor, fontFamily: "RictyDiminished"),
              title3: const TextStyle(
                  color: textColor, fontFamily: "RictyDiminished"),
              headline: const TextStyle(
                  color: textColor, fontFamily: "RictyDiminished"),
              subheadline: const TextStyle(
                  color: textColor, fontFamily: "RictyDiminished"),
              body: const TextStyle(
                  color: textColor, fontFamily: "RictyDiminished"),
              color: Colors.white)),
      home: const Home(title: 'clip it'),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const channelName = 'clipboard/html';
  final methodChannel = const MethodChannel(channelName);
  final clipRepository = HistoryRepository();
  final noteRepository = PinRepository();
  final listViewController = ScrollController();
  HistoryList clips = HistoryList(value: []);
  PinList notes = PinList(value: []);
  TrashList trashes = TrashList(value: []);
  SelectableList currentItems = SelectableList(value: []);
  List<SelectableList> searchResults = [];
  double offset = 0;
  double dragStartPos = 0;
  ScreenType type = ScreenType.CLIP;
  String lastText = "";
  SelectableList lists = SelectableList(value: []);
  bool showSearchbar = false;
  bool showSearchResult = false;
  FocusNode? searchFocusNode = FocusNode();
  FocusNode? listFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    retlieveHistorys();
    retlievePins();
    //clipRepository.dropTable();

    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        getHistoryboardHtml();
      });
    });
  }

  getHistoryboardHtml() async {
    try {
      final result = await methodChannel.invokeMethod('getHistoryboardContent');
      if (result != lastText) {
        if (result != null) {
          createOrUpdateItem(result);
          lastText = result;
        }
      }
    } on PlatformException catch (e) {
      print("error in getting clipboard image");
      print(e);
    }
  }

  Future<void> retlieveHistorys() async {
    final retlievedHistorys = await clipRepository.getClips();
    setState(() {
      clips = retlievedHistorys ?? HistoryList(value: []);
      currentItems = retlievedHistorys ?? HistoryList(value: []);
    });
  }

  Future<void> retlievePins() async {
    final retlievedPins = await noteRepository.getNotes();
    setState(() {
      notes = retlievedPins ?? PinList(value: []);
    });
  }

  void createOrUpdateItem(String result) async {
    if (notes.isExist(result)) return;
    if (clips.isExist(result)) {
      if (clips.shouldUpdate(result)) {
        setState(() {
          clips.updateTargetHistory(result);
          clips;
        });
        await clipRepository.updateHistory(clips.currentItem);
      }
    } else {
      final id = await clipRepository.saveHistory(result);
      setState(() {
        clips.insertToFirst(History(
            id: id,
            text: result,
            isSelected: true,
            count: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now()));
        clips;
      });
    }
  }

  void handleSideBarTap(ScreenType newType) {
    listFocusNode?.requestFocus();
    setState(() {
      type = newType;
      if (newType == ScreenType.CLIP) {
        currentItems = clips;
      } else if (newType == ScreenType.PINNED) {
        currentItems = notes;
      } else if (newType == ScreenType.TRASH) {
        currentItems = trashes;
      }
    });
  }

  void handleArchiveItemTap() async {
    final target = clips.currentItem;
    clipRepository.deleteHistory(target.id);
    clips.deleteTargetHistory(target);
    final noteId = await noteRepository.savePin(target.text);
    notes.insertToFirst(Pin(
        id: noteId,
        text: target.text,
        isSelected: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now()));
    setState(() {
      clips;
      notes;
    });
    listFocusNode?.requestFocus();
  }

  void handleListViewItemTap(int index) {
    if (type == ScreenType.CLIP) {
      clips.switchItem(index);
      setState(() {
        clips;
      });
    } else if (type == ScreenType.PINNED) {
      notes.switchItem(index);
      setState(() {
        notes;
      });
    }
  }

  void handleListDown() {
    var visibleItemCount =
        (listViewController.position.viewportDimension / 75.5).ceil();

    var offset =
        listViewController.position.viewportDimension - visibleItemCount * 75.5;

    if ((listViewController.offset +
            listViewController.position.viewportDimension) <
        (clips.currentIndex + 2) * 75.5) {
      listViewController.animateTo(
          (clips.currentIndex - visibleItemCount + 2) * 75.5 - offset,
          duration: const Duration(milliseconds: 10),
          curve: Curves.easeOut);
    }
    if (type == ScreenType.CLIP) {
      setState(() {
        clips.incrementIndex();
        clips;
      });
    } else if (type == ScreenType.PINNED) {
      setState(() {
        notes.incrementIndex();
        notes;
      });
    }
  }

  void handleListUp() {
    var current = (clips.currentIndex - 1) * 75.5;
    if (current < listViewController.offset) {
      listViewController.animateTo((clips.currentIndex - 1) * 75.5,
          duration: const Duration(milliseconds: 10), curve: Curves.easeOut);
    }

    if (type == ScreenType.CLIP) {
      setState(() {
        clips.decrementIndex();
        clips;
      });
    } else if (type == ScreenType.PINNED) {
      setState(() {
        notes.decrementIndex();
        notes;
      });
    }
  }

  void handleListViewDeleteTap() {
    // TODO: 最新のclipboardと同じtextは消せないようにする
    if (type == ScreenType.CLIP) {
      clipRepository.deleteHistory(clips.currentItem.id);

      setState(() {
        clips.deleteCurrentHistory();
        clips = clips;
      });
    } else if (type == ScreenType.PINNED) {}

    listFocusNode?.requestFocus();
  }

  void handleEditItemAction() {
    print("edit item");
  }

  void handleCopyToClipboardTap() {
    if (type == ScreenType.CLIP) {
      Clipboard.setData(ClipboardData(text: clips.currentItem.text));
    } else if (type == ScreenType.PINNED) {
      Clipboard.setData(ClipboardData(text: notes.currentItem.text));
    }
  }

  void handleSearchStart() {
    setState(() {
      searchFocusNode = FocusNode();
      showSearchbar = true;
    });
    listFocusNode?.unfocus();
    searchFocusNode?.requestFocus();
  }

  void handleSearchFormFocusChanged(hasFocus) {
    if (hasFocus) {
    } else {
      searchFocusNode?.unfocus();
      listFocusNode?.requestFocus();
      setState(() {
        showSearchbar = false;
        searchFocusNode = null;
      });
    }
  }

  void handleSearchFormInput(String text) {
    if (text.isEmpty) {
      listFocusNode?.requestFocus();
      searchFocusNode?.unfocus();
      setState(() {
        searchResults = [];
        showSearchResult = false;
      });
    } else {
      final searchedHistories =
          clips.value.where((element) => element.text.contains(text)).toList();
      final searchedPins =
          notes.value.where((element) => element.text.contains(text)).toList();
      final results = [
        HistoryList(value: searchedHistories),
        PinList(value: searchedPins)
      ];

      setState(() {
        searchResults = results;
        showSearchResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appWidth = MediaQuery.of(context).size.width;
    const ratio1 = 0.15;
    const ratio2 = 0.85;
    const ratio3 = 0.3;
    const ratio4 = 0.7;
    return Stack(children: [
      Center(
          // TODO: listviewのみにfocusする, コンテンツは対象外
          child: Row(children: [
        Container(
            color: side1stBackground,
            width: appWidth * ratio1 - 2 - offset,
            child: Stack(children: [
              SideMenu(type: type, handleSideBarTap: handleSideBarTap),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      color: type == ScreenType.SETTING
                          ? side1stBackgroundSelect
                          : side1stBackground,
                      child: IconText(
                        icon: Icons.settings,
                        text: "setting",
                        textColor: textColor,
                        iconColor: iconColor,
                        onTap: () => handleSideBarTap(ScreenType.SETTING),
                      ))),
            ])),
        MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
                onHorizontalDragStart: (detail) {
                  dragStartPos = detail.globalPosition.dx;
                },
                onHorizontalDragUpdate: (detail) {
                  final appWidth = MediaQuery.of(context).size.width;
                  double newOffset = dragStartPos - detail.globalPosition.dx;
                  if (appWidth * ratio1 < newOffset ||
                      appWidth * ratio1 - newOffset > appWidth) return;
                  setState(() =>
                      {offset = (dragStartPos - detail.globalPosition.dx)});
                },
                child: Container(
                  width: 1,
                  color: dividerColor,
                ))),
        Container(
            alignment: Alignment.topLeft,
            width: appWidth * ratio2 + offset,
            child: ContentsMainView(
                type: type,
                showSearchResult: showSearchResult,
                searchResults: searchResults,
                searchFocusNode: searchFocusNode ?? FocusNode(),
                listFocusNode: listFocusNode ?? FocusNode(),
                handleSearchFormFocusChange: (hasFocus) =>
                    handleSearchFormFocusChanged(hasFocus),
                handleSearchFormInput: (text) => handleSearchFormInput(text),
                handleArchiveItemTap: handleArchiveItemTap,
                handleListViewItemTap: handleListViewItemTap,
                handleCopyToClipboardTap: handleCopyToClipboardTap,
                handleDeleteItemTap: handleListViewDeleteTap,
                handleEditItemTap: handleEditItemAction,
                handleListUp: handleListUp,
                handleListDown: handleListDown,
                handleListViewDeleteTap: handleListViewDeleteTap,
                handleTapCopyToClipboard: handleCopyToClipboardTap,
                handleSearchFormFocused: handleSearchStart,
                isEditable: type == ScreenType.PINNED,
                isSearchable: showSearchbar,
                controller: listViewController,
                listWidth: (appWidth * ratio2 + offset) * ratio3,
                contentsWidth: (appWidth * ratio2 + offset) * ratio4,
                items: currentItems))
      ])),
      Visibility(
          visible: false,
          child: Container(
            decoration: const BoxDecoration(
              color: markdownBackground,
            ),
            child: const Text("for search window"),
          )),
    ]);
  }
}
