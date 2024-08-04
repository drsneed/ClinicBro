import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'avatar_button.dart';
import 'themed_icon.dart';
import 'dart:io' show Platform;

class CustomTitleBar extends StatelessWidget {
  final bool showBackButton;
  final bool showAvatarButton;
  final Widget? title;
  final List<Widget>? actions;
  final VoidCallback onAccountSettings;
  final VoidCallback onSignOut;
  final VoidCallback? onBack;

  const CustomTitleBar({
    super.key,
    this.showBackButton = false,
    this.showAvatarButton = false,
    this.title,
    this.actions,
    required this.onAccountSettings,
    required this.onSignOut,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    return GestureDetector(
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: Container(
        height: 32,
        color: isMobile
            ? Colors.transparent
            : FluentTheme.of(context).micaBackgroundColor,
        child: Row(
          children: [
            SizedBox(width: isMobile ? 0 : 8),
            const ThemedIcon(svgPath: 'assets/icon/app_icon.svg'),
            const SizedBox(width: 8),
            if (showBackButton)
              IconButton(
                icon: const Icon(FluentIcons.back, size: 12),
                onPressed: onBack,
              ),
            if (title != null)
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: title!,
                ),
              ),
            if (showAvatarButton)
              Padding(
                padding: const EdgeInsets.only(
                    right: 5.0), // Move the avatar button 5 pixels to the left
                child: AvatarButton(
                  onAccountSettings: onAccountSettings,
                  onSignOut: onSignOut,
                ),
              ),
            if (actions != null) ...actions!,
            if (!isMobile) ...[
              MinimizeWindowButton(),
              MaximizeWindowButton(),
              CloseWindowButton(),
            ],
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
      icon: const Icon(FluentIcons.chrome_close, size: 12),
      onPressed: () async {
        await windowManager.close();
      },
    );
  }
}
