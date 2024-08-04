import 'package:fluent_ui/fluent_ui.dart';
import '../managers/user_manager.dart';
import '../services/auth_service.dart';
import 'schedule_screen.dart';
import 'settings_screen.dart';
import '../widgets/custom_title_bar.dart';
import 'dart:io' show Platform;

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;

  const HomeScreen({Key? key, required this.setThemeMode}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<int> _history = [];

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    return NavigationView(
      appBar: NavigationAppBar(
        title: CustomTitleBar(
          showBackButton: _history.isNotEmpty,
          showAvatarButton: true,
          title: const Text('ClinicBro'),
          onBack: () {
            if (_history.isNotEmpty) {
              setState(() {
                _currentIndex = _history.removeLast();
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

  void _showAccountSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ContentDialog(
          title: Text('Account Settings'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Icon and text for each setting option
              _buildSettingsOption(
                icon: FluentIcons.diamond_user,
                label: 'Profile',
                onTap: () {
                  Navigator.pop(context);
                  // Handle Profile settings navigation
                },
              ),
              _buildSettingsOption(
                icon: FluentIcons.lock,
                label: 'Change Password',
                onTap: () {
                  Navigator.pop(context);
                  // Handle Change Password navigation
                },
              ),
              SizedBox(
                  height: 20), // Add space between options and close button
            ],
          ),
          actions: <Widget>[
            Button(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(icon),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
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
