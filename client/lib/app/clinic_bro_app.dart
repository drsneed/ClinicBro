import 'package:fluent_ui/fluent_ui.dart';

import '../screens/home_screen.dart';
import '../screens/sign_in_screen.dart';
import '../widgets/custom_typography.dart';

class ClinicBroApp extends StatefulWidget {
  const ClinicBroApp({super.key});

  @override
  ClinicBroAppState createState() => ClinicBroAppState();
}

class ClinicBroAppState extends State<ClinicBroApp> {
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
      },
    );
  }
}
