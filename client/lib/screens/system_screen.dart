import 'package:fluent_ui/fluent_ui.dart';
import 'setup/appointment_types_setup_screen.dart';

class SystemScreen extends StatefulWidget {
  const SystemScreen({Key? key}) : super(key: key);

  @override
  _SystemScreenState createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('System Settings'),
      ),
      content: TabView(
        currentIndex: _currentIndex,
        onChanged: (index) => setState(() => _currentIndex = index),
        tabs: [
          Tab(
            text: const Text('General'),
            body: _buildGeneralTab(),
          ),
          Tab(
            text: const Text('Appointment Types'),
            body: const AppointmentTypesSetupScreen(),
          ),
          // Add more tabs as needed
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
        ],
      ),
    );
  }
}
