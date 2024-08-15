import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Material;
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

import '../../models/appointment_type.dart';
import '../../repositories/appointment_type_repository.dart';
import 'base_detail_widget.dart';

class AppointmentTypeDetail extends BaseDetailWidget {
  final AppointmentType appointmentType;

  const AppointmentTypeDetail({super.key, required this.appointmentType});

  @override
  BaseDetailWidgetState<BaseDetailWidget> createState() =>
      _AppointmentTypeDetailState();
}

class _AppointmentTypeDetailState
    extends BaseDetailWidgetState<AppointmentTypeDetail> {
  final _formKey = GlobalKey<FormState>();

  late bool _active;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late Color _color;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with existing data
    _active = widget.appointmentType.active;
    _nameController = TextEditingController(text: widget.appointmentType.name);
    _descriptionController =
        TextEditingController(text: widget.appointmentType.description ?? '');
    _color = Color(
        int.parse(widget.appointmentType.color.substring(1), radix: 16) +
            0xFF000000);
  }

  @override
  Future<Object?> save() async {
    final repo = AppointmentTypeRepository();
    return await repo.updateAppointmentType(updatedAppointmentType);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    final colorNotifier = ValueNotifier<Color>(_color);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          child: ContentDialog(
            title: const Text('Pick a color'),
            content: Material(
              child: ColorPicker(
                color: _color,
                onChanged: (value) => colorNotifier.value = value,
                initialPicker: Picker.paletteHue,
              ),
            ),
            actions: <Widget>[
              Button(
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    _color = colorNotifier.value;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  AppointmentType get updatedAppointmentType {
    return AppointmentType(
      id: widget.appointmentType.id,
      active: _active,
      name: _nameController.text,
      description: _descriptionController.text,
      color: '#${_color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
      dateCreated: widget.appointmentType.dateCreated,
      dateUpdated: DateTime.now(),
      createdUserId: widget.appointmentType.createdUserId,
      updatedUserId: widget.appointmentType.updatedUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                ToggleSwitch(
                  checked: _active,
                  onChanged: (value) {
                    setState(() {
                      _active = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  _active ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.typography.body?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Increased space between fields
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextBox(
                    controller: _nameController,
                    placeholder: 'Enter name',
                    style: TextStyle(color: theme.typography.bodyLarge!.color),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextBox(
                    controller: _descriptionController,
                    placeholder: 'Enter description',
                    style: TextStyle(color: theme.typography.bodyLarge!.color),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Color',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(
                          width: 16), // Space between color circle and value
                      Expanded(
                        child: TextBox(
                          controller: TextEditingController(
                              text:
                                  '#${_color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}'),
                          placeholder: 'Pick a color',
                          onTap: _showColorPicker,
                          readOnly: true, // Make it read-only
                          style: TextStyle(
                              color: theme.typography.bodyLarge!.color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Space after the color field
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
