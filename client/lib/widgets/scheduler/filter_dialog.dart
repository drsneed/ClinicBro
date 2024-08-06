import 'package:fluent_ui/fluent_ui.dart';

class FilterDialog extends StatefulWidget {
  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _selectedProvider;
  String? _selectedLocation;
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text('Filter Appointments'),
      content: Column(
        children: [
          ComboBox<String>(
            items: ['Provider 1', 'Provider 2', 'Provider 3'].map((provider) {
              return ComboBoxItem<String>(
                  value: provider, child: Text(provider));
            }).toList(),
            placeholder: Text('Select Provider'),
            onChanged: (value) {
              setState(() {
                _selectedProvider = value;
              });
            },
          ),
          ComboBox<String>(
            items: ['Location 1', 'Location 2', 'Location 3'].map((location) {
              return ComboBoxItem<String>(
                  value: location, child: Text(location));
            }).toList(),
            placeholder: Text('Select Location'),
            onChanged: (value) {
              setState(() {
                _selectedLocation = value;
              });
            },
          ),
          ComboBox<String>(
            items: ['Type 1', 'Type 2', 'Type 3'].map((type) {
              return ComboBoxItem<String>(value: type, child: Text(type));
            }).toList(),
            placeholder: Text('Select Type'),
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
          ),
        ],
      ),
      actions: [
        Button(
          child: Text('Apply'),
          onPressed: () {
            // Apply filters
            Navigator.pop(context);
          },
        ),
        Button(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
