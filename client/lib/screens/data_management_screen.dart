import 'package:fluent_ui/fluent_ui.dart';
import 'setup/appointment_types_setup_screen.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({Key? key}) : super(key: key);

  @override
  _DataManagementScreenState createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    List<Tab> tabs = [
      Tab(
        text: Text(
          'Appointment Types',
          style: TextStyle(
            color: _currentIndex == 0
                ? theme.accentColor
                : theme.typography.body?.color,
            fontWeight:
                _currentIndex == 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        body: const AppointmentTypesSetupScreen(),
        icon: Icon(
          FluentIcons.calendar,
          color: _currentIndex == 0
              ? theme.accentColor
              : theme.typography.body?.color,
        ),
      ),
      Tab(
        text: Text(
          'Other Data',
          style: TextStyle(
            color: _currentIndex == 1
                ? theme.accentColor
                : theme.typography.body?.color,
            fontWeight:
                _currentIndex == 1 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        body: Center(child: Text('Other Data Configuration')),
        icon: Icon(
          FluentIcons.database,
          color: _currentIndex == 1
              ? theme.accentColor
              : theme.typography.body?.color,
        ),
      ),
    ];

    return ScaffoldPage(
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 500, // Adjust this height as needed
                child: TabView(
                  currentIndex: _currentIndex,
                  onChanged: (index) => setState(() => _currentIndex = index),
                  tabWidthBehavior: TabWidthBehavior.equal,
                  closeButtonVisibility: CloseButtonVisibilityMode.never,
                  showScrollButtons: false,
                  tabs: tabs,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }

  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('A Setting', style: FluentTheme.of(context).typography.subtitle),
        const SizedBox(height: 8),
        ComboBox<int?>(
          items: [
            ComboBoxItem(value: 1, child: const Text('Item 1')),
            ComboBoxItem(value: 2, child: const Text('Item 2')),
            ComboBoxItem(value: 3, child: const Text('Item 3')),
          ],
          value: 1,
          onChanged: (int? mode) {},
          placeholder: const Text('Select an item'),
        ),
        // Add more general settings here
      ],
    );
  }
}
