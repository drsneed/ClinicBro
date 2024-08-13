import 'package:clinicbro/widgets/title_bar_tab_control.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';
import '../models/patient_item.dart';
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
  final int? selectedTabId;
  final void Function(int)? onTabSelected;
  final void Function(int)? onTabClosed;
  final void Function(PatientItem)? onPatientDropped;
  final List<TabButtonData>? tabButtonData;
  final void Function(List<TabButtonData>)? onTabsReordered;
  const CustomTitleBar({
    super.key,
    this.onTabSelected,
    this.onTabClosed,
    this.onPatientDropped,
    this.onTabsReordered,
    this.selectedTabId,
    this.showBackButton = false,
    this.showAvatarButton = false,
    this.title,
    this.actions,
    this.onAccountSettings,
    this.onSignOut,
    this.onBack,
    this.avatarButtonKey,
    this.tabButtonData,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;
    final textColor =
        FluentTheme.of(context).typography.body?.color ?? Colors.black;
    bool showSelectedPatientChart = false;
    if (title != null && title is Text) {
      String titleText = (title as Text).data ?? '';
      if (titleText == 'Patient Charts') {
        showSelectedPatientChart = true;
      }
    }
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
            ThemedIcon(
              svgPath: 'assets/icon/app_icon.svg',
              color: textColor,
            ),
            const SizedBox(width: 8),
            if (showBackButton)
              IconButton(
                icon: const Icon(FluentIcons.back, size: 12),
                onPressed: onBack,
              ),
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: textColor,
                  ),
                  child: title!,
                ),
              ),
            const SizedBox(width: 16),
            TitleBarTabControl(
              onPatientDropped: onPatientDropped ?? (patient) => {},
              onTabSelected: onTabSelected ?? (tabId) => {},
              selectedTabId: showSelectedPatientChart ? selectedTabId : null,
              onTabClosed: onTabClosed ?? (tabId) => {},
              tabButtons: tabButtonData ?? [],
              onTabsReordered: onTabsReordered ?? (tabButtonData) => {},
            ),
            const Spacer(),
            if (showAvatarButton)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: AvatarButton(
                  key: avatarButtonKey,
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
        size: 13,
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

/*

style: FluentTheme.of(context).typography.body?.copyWith(
                          color: FluentTheme.of(context).accentColor,
                        ) ??
                    TextStyle(color: FluentTheme.of(context).accentColor),

                    */
