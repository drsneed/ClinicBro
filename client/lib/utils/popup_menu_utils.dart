// popup_menu_utils.dart

import 'package:flutter/material.dart';

Future<T?> showPopupMenu<T>({
  required BuildContext context,
  required List<PopupMenuEntry<T>> items,
  required Rect buttonRect,
  Color? color,
}) async {
  final RenderBox overlay =
      Overlay.of(context)!.context.findRenderObject() as RenderBox;

  return await showMenu<T>(
    context: context,
    position: RelativeRect.fromRect(
      buttonRect,
      Offset.zero & overlay.size,
    ),
    items: items,
    color: color,
  );
}
