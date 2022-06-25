import 'package:clipit/views/contents_list_view.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import '../color.dart';
import 'modified_macos_search_field.dart';

class ContentsHeader extends StatelessWidget {
  final VoidCallback handleCopyToClipboardTap;
  final VoidCallback handleMoveToPinTap;
  final VoidCallback handleMoveToTrashTap;
  final VoidCallback handleEditItemTap;
  final Bool2VoidFunc handleSearchFormFocusChange;
  final String2VoidFunc handleSearchFormInput;
  final bool isEditable;
  final bool isSearchable;
  final FocusNode searchFormFocusNode;

  const ContentsHeader(
      {Key? key,
      required this.isEditable,
      required this.isSearchable,
      required this.handleCopyToClipboardTap,
      required this.handleMoveToPinTap,
      required this.handleMoveToTrashTap,
      required this.handleSearchFormFocusChange,
      required this.handleSearchFormInput,
      required this.searchFormFocusNode,
      required this.handleEditItemTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: side1stBackground,
        height: 40,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(
              padding: const EdgeInsets.all(4),
              child: MacosIconButton(
                onPressed: () => handleCopyToClipboardTap(),
                icon: const Icon(
                  Icons.copy,
                ),
              )),
          Padding(
              padding: const EdgeInsets.all(4),
              child: MacosIconButton(
                onPressed: () => handleMoveToPinTap(),
                icon: const Icon(Icons.push_pin_sharp),
              )),
          Padding(
              padding: const EdgeInsets.all(4),
              child: MacosIconButton(
                onPressed: () => handleMoveToTrashTap(),
                icon: const Icon(Icons.delete),
              )),
          Visibility(
              visible: isEditable,
              child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: MacosIconButton(
                    onPressed: () => handleEditItemTap(),
                    icon: const Icon(Icons.edit),
                  ))),
          Visibility(
              visible: isSearchable,
              child: Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Focus(
                          onFocusChange: (value) {
                            handleSearchFormFocusChange(value);
                          },
                          child: ModifiedMacosSearchField(
                              maxLines: 1,
                              focusNode: searchFormFocusNode,
                              onChanged: (string) =>
                                  {handleSearchFormInput(string)})))))
        ]));
  }
}
