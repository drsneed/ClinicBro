import 'package:fluent_ui/fluent_ui.dart';
import '../screens/home_screen.dart';
import '../screens/sign_in_screen.dart';
import '../widgets/custom_typography.dart';
import '../managers/preferences_manager.dart';
import '../managers/user_manager.dart';

class ClinicBroApp extends StatefulWidget {
  const ClinicBroApp({super.key});
  @override
  ClinicBroAppState createState() => ClinicBroAppState();
}

class ClinicBroAppState extends State<ClinicBroApp> {
  final PreferencesManager _preferencesManager = PreferencesManager();
  final UserManager _userManager = UserManager();

  @override
  void initState() {
    super.initState();
    _preferencesManager.addListener(_onPreferencesChanged);
  }

  @override
  void dispose() {
    _preferencesManager.removeListener(_onPreferencesChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    setState(() {});
  }

  Future<void> _loadPreferences() async {
    if (_userManager.currentUser != null) {
      await _preferencesManager.loadPreferences(_userManager.currentUser!.id);
      setState(() {});
    }
  }

  void setThemeMode(ThemeMode themeMode) async {
    await _preferencesManager.setThemeMode(themeMode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'Inter Thin';
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'ClinicBro',
      themeMode: _preferencesManager.themeMode,
      theme: FluentThemeData(
        brightness: Brightness.light,
        typography:
            CustomTypography.getTypography(brightness: Brightness.light),
      ),
      darkTheme:
          FluentThemeData(brightness: Brightness.dark, fontFamily: fontFamily),
      initialRoute: '/',
      routes: {
        '/': (context) => SignInScreen(),
        '/home': (context) => HomeScreen(setThemeMode: setThemeMode),
      },
    );
  }
}
