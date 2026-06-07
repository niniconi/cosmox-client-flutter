import 'package:flutter/material.dart';

class PopupMenuAction {
  static List<PopupMenuItem<dynamic>> basicElementActions({
    Function()? delete,
  }) {
    return <PopupMenuItem<dynamic>>[
      PopupMenuItem(onTap: delete, child: const Text("Delete")),
      const PopupMenuItem(onTap: null, child: Text("Refresh metadata")),
      const PopupMenuItem(onTap: null, child: Text("Edit metadata")),
      const PopupMenuItem(onTap: null, child: Text("Change cover")),
    ];
  }
}
