import 'dart:io' show Platform;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:dotenv/dotenv.dart';
import 'app/clinic_bro_app.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize window_manager only for desktop platforms
    await windowManager.ensureInitialized();
    // We draw our own title bar so we need to hide the default one
    windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  }
  Logger().init();

  const app = ClinicBroApp();
  runApp(app);
}
