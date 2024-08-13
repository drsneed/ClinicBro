import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:intl/intl.dart';
import '../../models/create_appointment_data.dart';
import '../../models/appointment.dart';
import '../../models/location.dart';
import '../../utils/popup_menu_utils.dart';
import '../custom_time_picker.dart';
import 'appointment_history_dialog.dart';

class CreateAppointmentDialog extends StatefulWidget {
  final CreateAppointmentData? viewModel;
  final DateTime date;
  final Function(Appointment) onSave;

  const CreateAppointmentDialog({
    super.key,
    required this.viewModel,
    required this.date,
    required this.onSave,
  });

  @override
  _CreateAppointmentDialogState createState() =>
      _CreateAppointmentDialogState();
}

class _CreateAppointmentDialogState extends State<CreateAppointmentDialog> {
  late Appointment _appointment;
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  DateTime? _selectedFrom;
  DateTime? _selectedTo;
  late TextEditingController _notesController;
  static const labelWidth = 65.0;

  @override
  void initState() {
    super.initState();

    // Calculate the next 30-minute interval
    final now = DateTime.now();
    final nextInterval = _getNextHalfHourInterval(now);

    // Set the appointment times
    final apptFrom = DateTime(
      now.year,
      now.month,
      now.day,
      nextInterval.hour,
      nextInterval.minute,
    );

    final apptTo = apptFrom.add(const Duration(minutes: 30));

    _appointment = Appointment(
      id: 0,
      title: '',
      isEvent: false,
      patientId: widget.viewModel?.patient.id ?? 0,
      providerId: widget.viewModel?.providers.first.id ?? 0,
      appointmentTypeId: widget.viewModel?.appointmentTypes.first.id ?? 0,
      appointmentStatusId: widget.viewModel?.appointmentStatuses.first.id ?? 0,
      locationId: widget.viewModel?.locations.first.id ?? 0,
      apptDate: widget.date,
      apptFrom: mat.TimeOfDay(hour: apptFrom.hour, minute: apptFrom.minute),
      apptTo: mat.TimeOfDay(hour: apptTo.hour, minute: apptTo.minute),
      notes: '',
    );

    _selectedDate = widget.date;
    _selectedFrom = apptFrom;
    _selectedTo = apptTo;

    _notesController = TextEditingController(text: _appointment.notes);
  }

  // Helper function to get the next 30-minute interval
  DateTime _getNextHalfHourInterval(DateTime dateTime) {
    final minutes = dateTime.minute;
    final nextIntervalMinutes = (minutes ~/ 30 + 1) * 30;

    // If the next interval is in the next hour
    if (nextIntervalMinutes >= 60) {
      return DateTime(
          dateTime.year, dateTime.month, dateTime.day, dateTime.hour + 1, 0);
    }

    return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
        nextIntervalMinutes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showPatientMenu() async {
    final RenderBox? button = context.findRenderObject() as RenderBox?;
    final RenderBox? overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox?;

    if (button == null || overlay == null) {
      print('Button or Overlay RenderBox is null');
      return;
    }

    final buttonPosition = button.localToGlobal(Offset.zero);

    final result = await showPopupMenu<String>(
      context: context,
      buttonRect: Rect.fromLTWH(
        buttonPosition.dx + 188,
        buttonPosition.dy + 160,
        388,
        0,
      ),
      items: <mat.PopupMenuEntry<String>>[
        const mat.PopupMenuItem<String>(
          value: 'appointment_history',
          child: Row(
            children: <Widget>[
              Icon(mat.Icons.history),
              SizedBox(width: 8),
              Text('Appointment History'),
            ],
          ),
        ),
      ],
      color: mat.Theme.of(context).brightness == Brightness.dark
          ? const Color.fromARGB(255, 46, 45, 44)
          : Colors.white,
    );

    if (result == 'appointment_history') {
      _showAppointmentHistoryDialog();
    }
  }

  void _showAppointmentHistoryDialog() {
    final patientId = widget.viewModel?.patient.id ?? 0; // Get the patient ID

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AppointmentHistoryDialog(patientId: patientId);
      },
    );
  }

  Widget _buildPatientDropdown() {
    final patient = widget.viewModel?.patient;
    final theme = FluentTheme.of(context);
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final dob = patient?.dateOfBirth != null
        ? dateFormatter.format(patient!.dateOfBirth!)
        : 'N/A';

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: patient?.active ?? false
              ? theme.accentColor.withOpacity(0.8)
              : theme.inactiveColor.withOpacity(0.5),
          child: Text(
            patient?.initials() ?? 'UNK',
            style: const TextStyle(
                color: Colors.white, fontSize: 14), // Smaller size
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient?.fullName ?? 'No patient selected',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14, // Smaller size
              ),
            ),
            Text(
              'DOB: $dob',
              style: TextStyle(
                fontSize: 12, // Smaller size for date of birth
                color: patient?.active ?? false
                    ? theme.inactiveColor
                    : theme.inactiveColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(FluentIcons.chevron_down),
          onPressed: _showPatientMenu,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text('Create Appointment'),
        ),
        const SizedBox(width: 12),
        _buildPatientDropdown(),
      ],
    );
  }

  Widget _buildAppointmentTypesComboBox() {
    if (widget.viewModel?.appointmentTypes.isEmpty ?? true) {
      return const Center(child: Text('No appointment types found.'));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
          width: labelWidth,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('Type:'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ComboBox<int>(
            placeholder: const Text('Select an appointment type'),
            isExpanded: true,
            items: widget.viewModel?.appointmentTypes
                    .map((type) => ComboBoxItem<int>(
                          value: type.id,
                          child: Text(
                            type.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList() ??
                [],
            value: _appointment.appointmentTypeId,
            onChanged: (value) {
              setState(() {
                _appointment.appointmentTypeId = value ?? 0;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentStatusesComboBox() {
    if (widget.viewModel?.appointmentStatuses.isEmpty ?? true) {
      return const Center(child: Text('No appointment statuses found.'));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
            width: labelWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Status:'),
            )),
        const SizedBox(width: 8),
        Expanded(
          child: ComboBox<int>(
            placeholder: const Text('Select an appointment status'),
            isExpanded: true,
            items: widget.viewModel?.appointmentStatuses
                    .map((status) => ComboBoxItem<int>(
                          value: status.id,
                          child: Text(
                            status.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList() ??
                [],
            value: _appointment.appointmentStatusId,
            onChanged: (value) {
              setState(() {
                _appointment.appointmentStatusId = value ?? 0;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProviderComboBox() {
    if (widget.viewModel?.providers.isEmpty ?? true) {
      return const Center(child: Text('No providers found.'));
    }
    return Row(
      children: [
        const SizedBox(
            width: labelWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Provider:'),
            )),
        const SizedBox(width: 8),
        Expanded(
          child: ComboBox<int>(
            placeholder: const Text('Select a provider'),
            isExpanded: true,
            items: widget.viewModel?.providers
                    .map((provider) => ComboBoxItem<int>(
                          value: provider.id,
                          child: Text(
                            provider.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList() ??
                [],
            value: _appointment.providerId,
            onChanged: (value) {
              setState(() {
                _appointment.providerId = value ?? 0;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationsComboBox() {
    if (widget.viewModel?.locations.isEmpty ?? true) {
      return const Center(child: Text('No locations found.'));
    }
    return Row(
      children: [
        const SizedBox(
            width: labelWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Location:'),
            )),
        const SizedBox(width: 8),
        Expanded(
          child: ComboBox<int>(
            placeholder: const Text('Select a location'),
            isExpanded: true,
            items: widget.viewModel?.locations
                    .map((Location location) => ComboBoxItem<int>(
                          value: location.id,
                          child: Text(
                            location.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList() ??
                [],
            value: _appointment.locationId,
            onChanged: (value) {
              setState(() {
                _appointment.locationId = value ?? 0;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        const SizedBox(
            width: labelWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Date:'),
            )),
        const SizedBox(width: 8),
        SizedBox(
          width: 250,
          height: 30,
          child: DatePicker(
            selected: _selectedDate,
            onChanged: (date) {
              setState(() {
                _selectedDate = date;
                _appointment.apptDate = date;
              });
            },
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  mat.TimeOfDay getTimeOfDayFromDateTime(DateTime dateTime) {
    return mat.TimeOfDay(
      hour: dateTime.hour,
      minute: dateTime.minute,
    );
  }

  Widget _buildTimePickers() {
    return Row(
      children: [
        SizedBox(
          width: 280,
          height: 30,
          child: _buildFromTimePicker(),
        ),
        SizedBox(
          width: 280,
          height: 30,
          child: _buildToTimePicker(),
        ),
      ],
    );
  }

  Widget _buildFromTimePicker() {
    return Row(
      children: [
        const SizedBox(
          width: labelWidth,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('From:'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomTimePicker(
            showClearButton: false,
            selected: _selectedFrom,
            onChanged: (date) {
              setState(() {
                _selectedFrom = date;
                _appointment.apptFrom = getTimeOfDayFromDateTime(date);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToTimePicker() {
    return Row(
      children: [
        const SizedBox(
          width: labelWidth,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('To:'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomTimePicker(
            selected: _selectedTo,
            showClearButton: false,
            onChanged: (date) {
              setState(() {
                _selectedTo = date;
                _appointment.apptTo = getTimeOfDayFromDateTime(date);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(
            maxHeight: 150, // Adjust this value as needed
          ),
          padding: const EdgeInsets.only(top: 8.0), // Adjust padding as needed
          child: TextBox(
            controller: _notesController,
            placeholder: 'Enter notes here',
            maxLines: null,
            textAlignVertical: TextAlignVertical.top, // Ensures top alignment
            onChanged: (value) {
              setState(() {
                _appointment.notes = value;
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const width = 800.0;
    return ContentDialog(
      constraints: const BoxConstraints(
        maxWidth: width,
      ),
      title: _buildHeader(),
      content: SizedBox(
        width: width, // Set your desired width here
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildTimePickers(),
              const SizedBox(height: 16),
              _buildAppointmentTypesComboBox(),
              const SizedBox(height: 16),
              _buildAppointmentStatusesComboBox(),
              const SizedBox(height: 16),
              _buildProviderComboBox(),
              const SizedBox(height: 16),
              _buildLocationsComboBox(),
              const SizedBox(height: 16),
              _buildNotesField(), // Updated to include label
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: Text('Save'),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onSave(_appointment);
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
