import 'package:clipit/controllers/search_form_visible_notifier.dart';
import 'package:clipit/controllers/top_state_notifier.dart';
import 'package:clipit/models/history.dart';
import 'package:clipit/models/side_type.dart';
import 'package:clipit/providers/search_form_visible_provider.dart';
import 'package:clipit/providers/top_state_provider.dart';
import 'package:clipit/repositories/history_repository.dart';
import 'package:clipit/color.dart';
import 'package:clipit/repositories/pin_repository.dart';
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
import 'models/tree_node.dart';

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
  late TopStateNotifier topStateNotifier;
  late SearchFormVisibleNotifier searchFormVisibleNotifier;

  initialize() {
    topStateNotifier = ref.read(topStateProvider.notifier);
    searchFormVisibleNotifier = ref.read(searchFormVisibleProvider.notifier);
    // retlieveHistorys();
    // retlievePins();
    // retlieveTrashes();
    retlieveTree();
    //clipRepository.dropTable();
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        getHistoryboardHtml();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
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

  Future<void> retlieveTree() async {
    final retlievedHistories = await clipRepository.getClips();
    final retlievedPins = await noteRepository.getNotes();
    topStateNotifier.retlieveTree(
        retlievedHistories ??
            HistoryList(currentIndex: 0, listTitle: "history", value: []),
        retlievedPins ?? PinList(currentIndex: 0, listTitle: "pin", value: []),
        TrashList(currentIndex: 0, listTitle: "trash", value: []));
  }

  void createOrUpdateItem(String result) async {
    if (topStateNotifier.state.isPinExist(result)) return;
    if (topStateNotifier.state.isHistoryExist(result)) {
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
      ref.read(topStateProvider.notifier).insertHistoryToHead(History(
          id: id,
          text: result,
          isSelected: true,
          count: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()));
    }
  }

  void handleSideBarTap(TreeNode node) {
    listFocusNode?.requestFocus();
    ref.read(topStateProvider.notifier).selectTargetNode(node);
  }

  void handlePinItemTap() async {
    final target = topStateNotifier.state.listCurrentNode.item;
    clipRepository.deleteHistory(target?.id ?? 0);
    topStateNotifier.deleteCurrentNode();
    final noteId = await noteRepository.savePin(target?.text ?? "");
    topStateNotifier.insertPinToHead(Pin(
        id: noteId,
        text: target?.text ?? "",
        isSelected: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now()));
    listFocusNode?.requestFocus();
  }

  void handleListViewItemTap(TreeNode node) {
    topStateNotifier.selectTargetNode(node);
  }

  void handleListDown() {
    final currentIndex = ref.read(topStateProvider.notifier).state.currentIndex;
    var visibleItemCount =
        (listViewController.position.viewportDimension / 76).ceil();

    var offset =
        listViewController.position.viewportDimension - visibleItemCount * 76;

    if ((listViewController.offset +
            listViewController.position.viewportDimension) <
        (currentIndex + 2) * 76) {
      listViewController
          .jumpTo((currentIndex - visibleItemCount + 2) * 76 - offset);
    }

    ref.read(topStateProvider.notifier).moveToNextList();
  }

  void handleListUp() {
    final currentIndex = ref.read(topStateProvider.notifier).state.currentIndex;
    var current = (currentIndex - 1) * 76;
    if (current < listViewController.offset) {
      listViewController.jumpTo((currentIndex - 1) * 76);
    }

    ref.read(topStateProvider.notifier).moveToPrevList();
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
        ref.read(topStateProvider.notifier).state.currentDirNodes.length;
    listViewController.jumpTo(length * 76);
    ref.read(topStateProvider.notifier).selectLastItem();
  }

  handleSearchResultDown() {
    ref.read(topStateProvider.notifier).moveToNextSearchResult();
  }

  handleSearchResultUp() {
    ref.read(topStateProvider.notifier).moveToPrevSearchResult();
  }

  handleSearchResultSelect(TreeNode node) {
    if (node.self != null) {
      topStateNotifier.moveToTargetNode(node.self!);
      searchFormFocusNode?.unfocus();
      listFocusNode?.requestFocus();
      searchFormVisibleNotifier.update(false);

      final length = ref.read(topStateProvider.notifier).state.currentIndex;
      listViewController.jumpTo(length * 76);
    }
  }

  void handleListViewDeleteTap() {
    // TODO: 最新のclipboardと同じtextは消せないようにする
    if (topStateNotifier.state.type == ScreenType.CLIP) {
      clipRepository
          .deleteHistory(topStateNotifier.state.listCurrentNode.item?.id ?? 0);
      topStateNotifier.deleteCurrentNode();
    } else if (type == ScreenType.PINNED) {}

    listFocusNode?.requestFocus();
  }

  void handleEditItemAction() {
    print("edit item");
  }

  void handleCopyToClipboardTap() {
    Clipboard.setData(
        ClipboardData(text: topStateNotifier.state.currentItem?.text));
  }

  void handleSearchStart() {
    print("handleSearchStart");
    if (topStateNotifier.state.showSearchResult) {
      searchFormVisibleNotifier.update(true);
      searchResultFocusNode?.unfocus();
      searchFormFocusNode?.requestFocus();
    } else {
      searchFormVisibleNotifier.update(true);
      listFocusNode?.unfocus();
      searchFormFocusNode?.requestFocus();
    }
  }

  void handleSearchFormFocusChanged(hasFocus) {
    print("handleSearchFormFocusChanged:${hasFocus}");
    if (hasFocus) {
    } else {
      if (topStateNotifier.state.showSearchResult) {
        searchFormFocusNode?.unfocus();
        searchResultFocusNode?.requestFocus();
        topStateNotifier.updateSearchBarVisibility(false);
        searchFormVisibleNotifier.update(true);
      } else {
        searchFormFocusNode?.unfocus();
        listFocusNode?.requestFocus();
        topStateNotifier.updateSearchBarVisibility(false);
        searchFormVisibleNotifier.update(false);
      }
    }
  }

  void handleSearchFormInput(String text) async {
    if (text.isEmpty) {
      listFocusNode?.requestFocus();
      searchFormFocusNode?.unfocus();
      searchFormVisibleNotifier.update(false);
      topStateNotifier.clearSearchResult();
    } else {
      topStateNotifier.searchTreeNode(text);
      searchFormVisibleNotifier.update(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        // TODO: listviewのみにfocusする, コンテンツは対象外
        child: Row(children: [
      MainSideBarView(
        handleSideBarTap: handleSideBarTap,
      ),
      ResizableDivider(),
      ContentsMainView(
          searchFormFocusNode: searchFormFocusNode ?? FocusNode(),
          searchResultFocusNode: searchResultFocusNode ?? FocusNode(),
          listFocusNode: listFocusNode ?? FocusNode(),
          handleSearchFormFocusChange: (hasFocus) =>
              handleSearchFormFocusChanged(hasFocus),
          handleSearchFormInput: (text) => handleSearchFormInput(text),
          handleArchiveItemTap: handlePinItemTap,
          handleListViewItemTap: handleListViewItemTap,
          handleSearchResultSelect: handleSearchResultSelect,
          handleCopyToClipboardTap: handleCopyToClipboardTap,
          handleDeleteItemTap: handleListViewDeleteTap,
          handleEditItemTap: handleEditItemAction,
          handleListUp: handleListUp,
          handleListDown: handleListDown,
          handleSearchResultUp: handleSearchResultUp,
          handleSearchResultDown: handleSearchResultDown,
          handleListUpToTop: handleUpToTop,
          handleListDownToBottom: handleDownToBottom,
          handleListViewDeleteTap: handleListViewDeleteTap,
          handleTapCopyToClipboard: handleCopyToClipboardTap,
          handleSearchFormFocused: handleSearchStart,
          controller: listViewController)
    ]));
  }
}
