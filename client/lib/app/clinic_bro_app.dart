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

  @override
  Widget build(BuildContext context) {
    print("font_family = ${_preferencesManager.fontFamily}");
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'ClinicBro',
      themeMode: _preferencesManager.themeMode,
      theme: FluentThemeData(
        brightness: Brightness.light,
        fontFamily: _preferencesManager.fontFamily,
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        fontFamily: _preferencesManager.fontFamily,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignInScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}


// how to use custom typography:
// theme: FluentThemeData(
//   brightness: Brightness.light,
//   typography:
//       CustomTypography.getTypography(brightness: Brightness.light),
// ),
