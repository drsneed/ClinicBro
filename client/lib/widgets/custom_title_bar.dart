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
  final VoidCallback? onAccountSettings;
  final VoidCallback? onSignOut;
  final VoidCallback? onBack;
  final GlobalKey<AvatarButtonState>? avatarButtonKey;

  const CustomTitleBar({
    super.key,
    this.showBackButton = false,
    this.showAvatarButton = false,
    this.title,
    this.actions,
    this.onAccountSettings,
    this.onSignOut,
    this.onBack,
    this.avatarButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;
    final textColor =
        FluentTheme.of(context).typography.body?.color ?? Colors.black;

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
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontWeight: FontWeight.w500, // Make text bold
                      fontSize: 16, // Optional: Adjust font size if needed
                      color: textColor, // Apply theme's text color
                    ),
                    child: title!,
                  ),
                ),
              ),
            if (showAvatarButton)
              Padding(
                padding: const EdgeInsets.only(
                    right: 5.0), // Move the avatar button 5 pixels to the left
                child: AvatarButton(
                  key: avatarButtonKey, // Pass the GlobalKey here
                  onAccountSettings: onAccountSettings ?? () => {},
                  onSignOut: onSignOut ?? () => {},
                ),
              ),
            if (actions != null) ...actions!,
            if (!isMobile) ...[
              const MinimizeWindowButton(),
              const MaximizeWindowButton(),
              const CloseWindowButton(),
            ],
          ],
        ),
      ),
    );
  }
}

class MinimizeWindowButton extends StatelessWidget {
  const MinimizeWindowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(FluentIcons.chrome_minimize, size: 12),
      onPressed: () async {
        await windowManager.minimize();
      },
    );
  }
}

class MaximizeWindowButton extends StatefulWidget {
  const MaximizeWindowButton({super.key});

  @override
  _MaximizeWindowButtonState createState() => _MaximizeWindowButtonState();
}

class _MaximizeWindowButtonState extends State<MaximizeWindowButton> {
  bool _isMaximized = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isMaximized ? FluentIcons.chrome_restore : FluentIcons.square_shape,
        size: 12,
      ),
      onPressed: () async {
        if (_isMaximized) {
          await windowManager.restore();
        } else {
          await windowManager.maximize();
        }

        // Update the icon state after the action
        final isMaximized = await windowManager.isMaximized();
        setState(() {
          _isMaximized = isMaximized;
        });
      },
    );
  }
}

class CloseWindowButton extends StatelessWidget {
  const CloseWindowButton({super.key});

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
