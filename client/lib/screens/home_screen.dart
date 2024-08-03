import 'package:fluent_ui/fluent_ui.dart';
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

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    return NavigationView(
      appBar: NavigationAppBar(
        title: CustomTitleBar(
          showBackButton: !isMobile,
          title: Text(
            'ClinicBro',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          userAvatarUrl: "",
        ),
        automaticallyImplyLeading: false,
      ),
      pane: NavigationPane(
        selected: _currentIndex,
        onChanged: (index) => setState(() => _currentIndex = index),
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

  Widget _buildHomeContent() {
    return ScaffoldPage(
      content: Center(
        child: Text('Welcome to the Fluent UI Demo App!'),
      ),
    );
  }
}
