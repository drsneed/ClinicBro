import 'package:fluent_ui/fluent_ui.dart';
import '../managers/user_manager.dart';
import '../services/auth_service.dart';
import 'schedule_screen.dart';
import 'settings_screen.dart';
import 'account_settings_dialog.dart';
import '../widgets/custom_title_bar.dart';
import 'dart:io' show Platform;
import '../widgets/avatar_button.dart'; // Import AvatarButton

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;

  const HomeScreen({Key? key, required this.setThemeMode}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<int> _history = [];
  final GlobalKey<AvatarButtonState> _avatarButtonKey =
      GlobalKey<AvatarButtonState>();
  String _currentPaneTitle = 'Home'; // Default title

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    return NavigationView(
      appBar: NavigationAppBar(
        title: CustomTitleBar(
          showBackButton: _history.isNotEmpty,
          showAvatarButton: true,
          title: Text(_currentPaneTitle), // Display the current pane item title
          onBack: () {
            if (_history.isNotEmpty) {
              setState(() {
                _currentIndex = _history.removeLast();
                _updatePaneTitle();
              });
            }
          },
          onAccountSettings: () {
            _showAccountSettingsDialog(context); // Show the dialog
          },
          onSignOut: () {
            AuthService().signOut();
            Navigator.of(context).pushReplacementNamed('/');
          },
          avatarButtonKey: _avatarButtonKey, // Pass the key
        ),
        automaticallyImplyLeading: false,
      ),
      pane: NavigationPane(
        selected: _currentIndex,
        onChanged: (index) {
          setState(() {
            if (_currentIndex != index) {
              _history.add(_currentIndex);
              _currentIndex = index;
              _updatePaneTitle(); // Update the title when pane changes
            }
          });
        },
        displayMode: isMobile ? PaneDisplayMode.auto : PaneDisplayMode.compact,
        items: [
          PaneItem(
            icon: Icon(FluentIcons.home),
            title: Text('Home'),
            body: _buildHomeContent(),
          ),
          PaneItem(
            icon: Icon(FluentIcons.calendar),
            title: Text('Schedule'),
            body: ScheduleScreen(),
          ),
          PaneItem(
            icon: Icon(FluentIcons.settings),
            title: Text('Settings'),
            body: SettingsScreen(setThemeMode: widget.setThemeMode),
          ),
        ],
      ),
    );
  }

  void _updatePaneTitle() {
    // Update the current pane title based on the selected index
    setState(() {
      _currentPaneTitle = [
        'Home',
        'Schedule',
        'Settings',
      ][_currentIndex];
    });
  }

  void _showAccountSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AccountSettingsDialog(
          onAvatarChanged: () {
            // Call refreshAvatar on the AvatarButton
            if (_avatarButtonKey.currentState != null) {
              _avatarButtonKey.currentState!.refreshAvatar();
            }
          },
        );
      },
    );
  }

  Widget _buildHomeContent() {
    return ScaffoldPage(
      content: Center(
        child: Text('Welcome ${UserManager().currentUser?.name ?? 'User'}!'),
      ),
    );
  }
}
