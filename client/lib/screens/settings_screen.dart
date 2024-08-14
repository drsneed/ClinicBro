import 'package:fluent_ui/fluent_ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Settings'),
      ),
      content: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A Setting',
                style: FluentTheme.of(context).typography.subtitle),
            SizedBox(height: 8),
            ComboBox<int?>(
              items: [
                ComboBoxItem(value: 1, child: Text('Item 1')),
                ComboBoxItem(value: 2, child: Text('Item 2')),
                ComboBoxItem(value: 3, child: Text('Item 3')),
              ],
              value: 1,
              onChanged: (int? mode) {},
              placeholder: const Text('Select an item'),
            ),
          ],
        ),
      ),
    );
  }
}
