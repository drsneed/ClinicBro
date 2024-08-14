import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // For the color picker

import '../../models/appointment_type.dart';
import '../../repositories/appointment_type_repository.dart';
import 'base_detail_widget.dart';

class AppointmentTypeDetail extends StatefulWidget {
  final AppointmentType appointmentType;

  const AppointmentTypeDetail({
    Key? key,
    required this.appointmentType,
  }) : super(key: key);

  @override
  _AppointmentTypeDetailState createState() => _AppointmentTypeDetailState();
}

class _AppointmentTypeDetailState extends State<AppointmentTypeDetail>
    implements BaseDetailWidget {
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ContentDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _color,
              onColorChanged: (color) {
                setState(() {
                  _color = color;
                });
              },
              showLabel: true,
            ),
          ),
          actions: <Widget>[
            Button(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
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
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Name',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextBox(
                    controller: _nameController,
                    placeholder: 'Enter name',
                  ),
                  const SizedBox(height: 16),
                  const Text('Description',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextBox(
                    controller: _descriptionController,
                    placeholder: 'Enter description',
                  ),
                  const SizedBox(height: 16),
                  const Text('Color',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextBox(
                    controller: TextEditingController(
                        text:
                            '#${_color.value.toRadixString(16).toUpperCase()}'), // Display color as string
                    placeholder: 'Pick a color',
                    onTap: _showColorPicker,
                    readOnly: true, // Make it read-only
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  StatelessElement createElement() {
    // TODO: implement createElement
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    // TODO: implement debugDescribeChildren
    throw UnimplementedError();
  }

  @override
  // TODO: implement key
  Key? get key => throw UnimplementedError();

  @override
  String toStringDeep(
      {String prefixLineOne = '',
      String? prefixOtherLines,
      DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    // TODO: implement toStringDeep
    throw UnimplementedError();
  }

  @override
  String toStringShallow(
      {String joiner = ', ',
      DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    // TODO: implement toStringShallow
    throw UnimplementedError();
  }
}
