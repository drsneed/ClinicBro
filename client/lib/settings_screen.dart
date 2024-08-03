import 'package:fluent_ui/fluent_ui.dart';

class SettingsScreen extends StatelessWidget {
  final Function(ThemeMode) setThemeMode;

  const SettingsScreen({Key? key, required this.setThemeMode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text('Settings'),
      ),
      content: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme Mode',
                style: FluentTheme.of(context).typography.subtitle),
            SizedBox(height: 8),
            ComboBox<ThemeMode>(
              items: [
                ComboBoxItem(value: ThemeMode.system, child: Text('System')),
                ComboBoxItem(value: ThemeMode.light, child: Text('Light')),
                ComboBoxItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              value: FluentTheme.of(context).brightness == Brightness.light
                  ? ThemeMode.light
                  : ThemeMode.dark,
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  setThemeMode(mode);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
