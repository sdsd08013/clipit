import 'package:clipit/models/history.dart';
import 'package:clipit/models/side_type.dart';
import 'package:clipit/models/top_state.dart';
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
  ScrollController listViewController = ScrollController();
  SelectableList currentItems = SelectableList(value: []);
  double offset = 0;
  double dragStartPos = 0;
  ScreenType type = ScreenType.CLIP;
  String lastText = "";
  bool showSearchbar = false;
  FocusNode? searchFormFocusNode = FocusNode();
  FocusNode? searchResultFocusNode = FocusNode();
  FocusNode? listFocusNode = FocusNode();
  bool isUpToTopTriggered = false;
  TopState topState = TopState(
      histories: HistoryList(value: []),
      pins: PinList(value: []),
      trashes: TrashList(value: []));

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
      final result = await methodChannel.invokeMethod('getClipboardContent');
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
      topState.histories = retlievedHistorys ?? HistoryList(value: []);
      // clips = retlievedHistorys ?? HistoryList(value: []);
      // currentItems = retlievedHistorys ?? HistoryList(value: []);
    });
  }

  Future<void> retlievePins() async {
    final retlievedPins = await noteRepository.getNotes();
    setState(() {
      topState.pins = retlievedPins ?? PinList(value: []);
      //notes = retlievedPins ?? PinList(value: []);
    });
  }

  void createOrUpdateItem(String result) async {
    if (topState.isPinExist(result)) return;
    if (topState.isHistoryExist(result)) {
      /*
      if (topState.shouldUpdateHistory(result)) {
        topState.histories.updateTargetHistory(result);
        setState(() {
          topState;
        });
        await clipRepository.updateHistory(topState.histories.currentItem);
      }
      */
    } else {
      final id = await clipRepository.saveHistory(result);
      setState(() {
        topState.histories.insertToFirst(History(
            id: id,
            text: result,
            isSelected: true,
            count: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now()));
        topState;
      });
    }
  }

  void handleSideBarTap(ScreenType newType) {
    listFocusNode?.requestFocus();
    topState.type = newType;
    setState(() {
      topState;
    });
  }

  void handleArchiveItemTap() async {
    final target = topState.histories.currentItem;
    clipRepository.deleteHistory(target.id);
    topState.histories.deleteTargetHistory(target);
    final noteId = await noteRepository.savePin(target.text);
    topState.pins.insertToFirst(Pin(
        id: noteId,
        text: target.text,
        isSelected: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now()));
    setState(() {
      topState;
    });
    listFocusNode?.requestFocus();
  }

  void handleListViewItemTap(int index) {
    topState.switchCurrentItems(index);
    setState(() {
      topState;
    });
  }

  void handleSearchedtemTap(Selectable item) {
    topState.searchResults = [];
    setState(() {
      topState;
    });
  }

  void handleListDown() {
    var visibleItemCount =
        (listViewController.position.viewportDimension / 75.5).ceil();

    var offset =
        listViewController.position.viewportDimension - visibleItemCount * 75.5;

    if ((listViewController.offset +
            listViewController.position.viewportDimension) <
        (topState.currentIndex + 2) * 75.5) {
      listViewController.jumpTo(
          (topState.currentIndex - visibleItemCount + 2) * 75.5 - offset);
    }

    topState.incrementCurrentItems();
    setState(() {
      topState;
    });
  }

  void handleListUp() {
    var current = (topState.currentIndex - 1) * 75.5;
    if (current < listViewController.offset) {
      listViewController.jumpTo((topState.currentIndex - 1) * 75.5);
    }

    topState.decrementCurrentItems();
    setState(() {
      topState;
    });
  }

  void handleUpToTop() {
    if (isUpToTopTriggered) {
      listViewController.jumpTo(0);
      isUpToTopTriggered = false;
      topState.currentItems.selectFirstItem();
    } else {
      isUpToTopTriggered = true;
    }
  }

  void handleDownToBottom() {
    listViewController.jumpTo(topState.currentItems.value.length * 75.5);
    topState.currentItems.selectLastItem();
  }

  void handleListViewDeleteTap() {
    // TODO: 最新のclipboardと同じtextは消せないようにする
    if (topState.type == ScreenType.CLIP) {
      clipRepository.deleteHistory(topState.histories.currentItem.id);
      topState.histories.deleteCurrentHistory();
    } else if (type == ScreenType.PINNED) {}

    setState(() {
      topState;
    });
    listFocusNode?.requestFocus();
  }

  void handleEditItemAction() {
    print("edit item");
  }

  void handleCopyToClipboardTap() {
    Clipboard.setData(ClipboardData(text: topState.currentItem.text));
  }

  void handleSearchStart() {
    setState(() {
      searchFormFocusNode = FocusNode();
      showSearchbar = true;
    });
    listFocusNode?.unfocus();
    searchFormFocusNode?.requestFocus();
  }

  void handleSearchFormFocusChanged(hasFocus) {
    if (hasFocus) {
    } else {
      if (topState.showSearchResult) {
        searchFormFocusNode?.unfocus();
        searchResultFocusNode?.requestFocus();
        setState(() {
          showSearchbar = false;
        });
      } else {
        searchFormFocusNode?.unfocus();
        listFocusNode?.requestFocus();
        setState(() {
          showSearchbar = false;
          searchFormFocusNode = null;
        });
      }
    }
  }

  void handleSearchFormInput(String text) {
    if (text.isEmpty) {
      listFocusNode?.requestFocus();
      searchFormFocusNode?.unfocus();

      topState.clearSearchResult();
      setState(() {
        topState;
      });
    } else {
      topState.setSearchResult(text);
      setState(() {
        topState;
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
    return Center(
        // TODO: listviewのみにfocusする, コンテンツは対象外
        child: Row(children: [
      Container(
          color: side1stBackground,
          width: appWidth * ratio1 - 2 - offset,
          child: Stack(children: [
            SideMenu(
                key: GlobalKey(),
                type: topState.type,
                handleSideBarTap: handleSideBarTap),
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
                setState(
                    () => {offset = (dragStartPos - detail.globalPosition.dx)});
              },
              child: Container(
                width: 1,
                color: dividerColor,
              ))),
      Container(
          alignment: Alignment.topLeft,
          width: appWidth * ratio2 + offset,
          child: ContentsMainView(
              type: topState.type,
              showSearchResult: topState.showSearchResult,
              searchFormFocusNode: searchFormFocusNode ?? FocusNode(),
              searchResultFocusNode: searchResultFocusNode ?? FocusNode(),
              listFocusNode: listFocusNode ?? FocusNode(),
              handleSearchFormFocusChange: (hasFocus) =>
                  handleSearchFormFocusChanged(hasFocus),
              handleSearchFormInput: (text) => handleSearchFormInput(text),
              handleArchiveItemTap: handleArchiveItemTap,
              handleListViewItemTap: handleListViewItemTap,
              handleSearchedItemTap: handleSearchedtemTap,
              handleCopyToClipboardTap: handleCopyToClipboardTap,
              handleDeleteItemTap: handleListViewDeleteTap,
              handleEditItemTap: handleEditItemAction,
              handleListUp: handleListUp,
              handleListDown: handleListDown,
              handleListUpToTop: handleUpToTop,
              handleListDownToBottom: handleDownToBottom,
              handleListViewDeleteTap: handleListViewDeleteTap,
              handleTapCopyToClipboard: handleCopyToClipboardTap,
              handleSearchFormFocused: handleSearchStart,
              isEditable: topState.type == ScreenType.PINNED,
              isSearchable: showSearchbar,
              controller: listViewController,
              listWidth: (appWidth * ratio2 + offset) * ratio3,
              contentsWidth: (appWidth * ratio2 + offset) * ratio4,
              searchResults: topState.searchResults,
              items: topState.currentItems))
    ]));
  }
}
