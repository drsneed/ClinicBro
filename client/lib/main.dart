import 'dart:io' show Platform;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
import 'widgets/custom_typography.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize window_manager only for desktop platforms
    await windowManager.ensureInitialized();

    // Hide the title bar for desktop
    windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'Inter Thin';
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'ClinicBro',
      themeMode: _themeMode,
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
        // '/schedule': (context) => ScheduleScreen(),
        // '/settings': (context) => SettingsScreen(setThemeMode: setThemeMode),
      },
    );
  }
}
