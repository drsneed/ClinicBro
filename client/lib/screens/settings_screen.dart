import 'package:fluent_ui/fluent_ui.dart';
import 'setup/appointment_types_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('App Settings'),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expander(
                header: _buildSettingsOption(
                  icon: FluentIcons.settings,
                  label: 'General Settings',
                ),
                content: _buildGeneralSettings(),
              ),
              const SizedBox(height: 16),
              Expander(
                header: _buildSettingsOption(
                  icon: FluentIcons.data_management_settings,
                  label: 'Data Configuration',
                ),
                content: SizedBox(
                  height: 500, // Adjust this height as needed
                  child: Column(
                    children: [
                      Expanded(
                        child: TabView(
                          currentIndex: _currentIndex,
                          onChanged: (index) =>
                              setState(() => _currentIndex = index),
                          tabs: [
                            Tab(
                              text: const Text('Appointment Types'),
                              body: const AppointmentTypesSetupScreen(),
                            ),
                            Tab(
                              text: const Text('Other Data'),
                              body: Center(
                                  child: Text('Other Data Configuration')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildDataConfiguration() {
    return SizedBox(
      height: 500, // Adjust this height as needed
      child: TabView(
        currentIndex: _currentIndex,
        onChanged: (index) => setState(() => _currentIndex = index),
        tabs: [
          Tab(
            text: const Text('Appointment Types'),
            body: const AppointmentTypesSetupScreen(),
          ),
          // Add more tabs as needed
          Tab(
            text: const Text('Other Data'),
            body: Center(child: Text('Other Data Configuration')),
          ),
        ],
      ),
    );
  }
}
