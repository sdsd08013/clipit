import 'package:clipit/models/history.dart';
import 'package:clipit/models/side_type.dart';
import 'package:clipit/providers/top_state_provider.dart';
import 'package:clipit/repositories/history_repository.dart';
import 'package:clipit/color.dart';
import 'package:clipit/repositories/pin_repository.dart';
import 'package:clipit/states/top_state.dart';
import 'package:clipit/views/contents_main.dart';
import 'package:clipit/views/main_side_bar.dart';
import 'package:clipit/views/resizable_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'dart:async';
import 'dart:core';
import 'models/pin.dart';
import 'models/selectable.dart';
import 'models/trash.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
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

class Home extends ConsumerStatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  static const channelName = 'clipboard/html';
  final methodChannel = const MethodChannel(channelName);
  final clipRepository = HistoryRepository();
  final noteRepository = PinRepository();
  ScrollController listViewController = ScrollController();
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
      histories: HistoryList(currentIndex: 0, listTitle: "history", value: []),
      pins: PinList(currentIndex: 0, listTitle: "pin", value: []),
      trashes: TrashList(currentIndex: 0, listTitle: "trash", value: []),
      searchResults: [],
      type: ScreenType.CLIP);

  @override
  void initState() {
    super.initState();

    ref.read(topStateProvider);
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
    ref.read(topStateProvider.notifier).addHistories(retlievedHistorys ??
        HistoryList(currentIndex: 0, listTitle: "history", value: []));
  }

  Future<void> retlievePins() async {
    final retlievedPins = await noteRepository.getNotes();
    ref.read(topStateProvider.notifier).addPins(
        retlievedPins ?? PinList(currentIndex: 0, listTitle: "pi", value: []));
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
        (topState.histories as HistoryList).insertToFirst(History(
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
    setState(() {
      topState = topState.copyWith(type: newType);
    });
  }

  void handleArchiveItemTap() async {
    final target = topState.histories.currentItem;
    clipRepository.deleteHistory(target.id);
    (topState.histories as HistoryList).deleteTargetHistory(target);
    final noteId = await noteRepository.savePin(target.text);
    (topState.pins as PinList).insertToFirst(Pin(
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
    setState(() {
      topState = topState.copyWith(searchResults: []);
    });
  }

  void handleListDown() {
    final currentIndex = ref.read(topStateProvider.notifier).state.currentIndex;
    var visibleItemCount =
        (listViewController.position.viewportDimension / 75.5).ceil();

    var offset =
        listViewController.position.viewportDimension - visibleItemCount * 75.5;

    if ((listViewController.offset +
            listViewController.position.viewportDimension) <
        (currentIndex + 2) * 75.5) {
      listViewController
          .jumpTo((currentIndex - visibleItemCount + 2) * 75.5 - offset);
    }

    ref.read(topStateProvider.notifier).increment();
  }

  void handleListUp() {
    final currentIndex = ref.read(topStateProvider.notifier).state.currentIndex;
    var current = (currentIndex - 1) * 75.5;
    if (current < listViewController.offset) {
      listViewController.jumpTo((currentIndex - 1) * 75.5);
    }

    ref.read(topStateProvider.notifier).decrement();
  }

  void handleUpToTop() {
    if (isUpToTopTriggered) {
      listViewController.jumpTo(0);
      isUpToTopTriggered = false;
      ref.read(topStateProvider.notifier).selectFirstItem();
    } else {
      isUpToTopTriggered = true;
    }
  }

  void handleDownToBottom() {
    final length =
        ref.read(topStateProvider.notifier).state.currentItems.value.length;
    listViewController.jumpTo(length * 75.5);
    ref.read(topStateProvider.notifier).selectLastItem();
  }

  void handleListViewDeleteTap() {
    // TODO: 最新のclipboardと同じtextは消せないようにする
    if (topState.type == ScreenType.CLIP) {
      clipRepository.deleteHistory(topState.histories.currentItem.id);
      (topState.histories as HistoryList).deleteCurrentHistory();
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

  void handleSearchFormInput(String text) async {
    if (text.isEmpty) {
      listFocusNode?.requestFocus();
      searchFormFocusNode?.unfocus();

      setState(() {
        topState = topState.copyWith(searchResults: []);
      });
    } else {
      final result = await topState.getSearchResult(text);
      // setState(() {
      //   topState;
      // });
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
      MainSideBarView(
        type: topState.type,
        handleSideBarTap: handleSideBarTap,
      ),
      ResizableDivider(),
      ContentsMainView(
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
          searchResults: topState.searchResults)
    ]));
  }
}
