import 'package:flutter/material.dart';

typedef PopupMenuCallback = void Function(String value);

class PopupMenuHelper {
  static Widget buildPopupMenu(BuildContext context,
      {required PopupMenuCallback onSelected,
      required List<Map<String, String>> optionsList}) {
    return PopupMenuButton<String>(
      color: Colors.white,
      padding: EdgeInsets.zero,
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return List.generate(
          optionsList.length,
          (index) => PopupMenuItem<String>(
            value: optionsList[index].entries.first.key,
            child: Text(optionsList[index].entries.first.value),
          ),
        );
      },
      child: Container(
        height: 36,
        width: 48,
        alignment: Alignment.centerRight,
        child: const Icon(Icons.more_vert),
      ),
    );
  }
}

class PopUp {
  static Widget buildPopupMenu(BuildContext context,
      {required PopupMenuCallback onSelected,
      required List<Map<String, String>> optionsList}) {
    return PopupMenuButton<String>(
      color: Colors.white,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      offset: const Offset(5, 40),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return List.generate(
          optionsList.length,
          (index) => PopupMenuItem<String>(
            value: optionsList[index].entries.first.key,
            child: Text(optionsList[index].entries.first.value),
          ),
        );
      },
      child: Container(
        height: 36,
        width: 48,
        alignment: Alignment.center,
        child: const Icon(Icons.attach_file),
      ),
    );
  }
}
