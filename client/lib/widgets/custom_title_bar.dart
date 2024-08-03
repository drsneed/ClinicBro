import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show PopupMenuButton, PopupMenuItem;
import 'package:window_manager/window_manager.dart';
import 'themed_icon.dart';
import 'dart:io' show Platform;

class CustomTitleBar extends StatelessWidget {
  final bool showBackButton;
  final Widget? title;
  final List<Widget>? actions;
  final String userAvatarUrl; // New parameter for user avatar URL

  const CustomTitleBar({
    Key? key,
    this.showBackButton = false,
    this.title,
    this.actions,
    required this.userAvatarUrl, // Initialize userAvatarUrl
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    return GestureDetector(
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: Container(
        height: 32,
        color: FluentTheme.of(context).micaBackgroundColor,
        child: Row(
          children: [
            SizedBox(width: isMobile ? 0 : 8),
            ThemedIcon(svgPath: 'assets/icon/app_icon.svg'),
            SizedBox(width: 8),
            if (showBackButton)
              IconButton(
                icon: Icon(FluentIcons.back, size: 12),
                onPressed: () {
                  // Handle back navigation
                },
              ),
            if (title != null)
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: title!,
                ),
              ),
            if (actions != null) ...actions!,
            if (!isMobile) ...[
              MinimizeWindowButton(),
              MaximizeWindowButton(),
              CloseWindowButton(),
            ],
            // Spacer(),
            // // Avatar Button with Popup Menu
            // PopupMenuButton<String>(
            //   onSelected: (String value) {
            //     // Handle the selected option
            //     if (value == 'settings') {
            //       // Navigate to account settings
            //     } else if (value == 'sign_out') {
            //       // Sign out logic
            //     }
            //   },
            //   itemBuilder: (BuildContext context) {
            //     return [
            //       PopupMenuItem<String>(
            //         value: 'settings',
            //         child: Text('Account Settings'),
            //       ),
            //       PopupMenuItem<String>(
            //         value: 'sign_out',
            //         child: Text('Sign Out'),
            //       ),
            //     ];
            //   },
            //   child: CircleAvatar(
            //     backgroundImage: NetworkImage(userAvatarUrl),
            //     radius: 16, // Adjust size as needed
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class MinimizeWindowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(FluentIcons.chrome_minimize, size: 12),
      onPressed: () async {
        await windowManager.minimize();
      },
    );
  }
}

class MaximizeWindowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(FluentIcons.chrome_full_screen, size: 12),
      onPressed: () async {
        if (await windowManager.isMaximized())
          await windowManager.restore();
        else
          await windowManager.maximize();
      },
    );
  }
}

class CloseWindowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(FluentIcons.chrome_close, size: 12),
      onPressed: () async {
        await windowManager.close();
      },
    );
  }
}
