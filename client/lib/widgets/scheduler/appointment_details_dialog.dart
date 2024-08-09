import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_item.dart';

class AppointmentDetailsDialog extends StatelessWidget {
  final AppointmentItem appointment;

  const AppointmentDetailsDialog({Key? key, required this.appointment})
      : super(key: key);

  Color _getBackgroundColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(appointment.title);
    print(appointment.patient);
    print(appointment.status);
    final isEvent = appointment.patient.isEmpty;
    print('isEvent? $isEvent');
    final titleText = appointment.title;
    final backgroundColor = _getBackgroundColor(appointment.color);

    return ContentDialog(
      title: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(titleText)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('Date', _formatDate(appointment.apptDate)),
            _buildInfoRow(
                'Time', '${appointment.apptFrom} - ${appointment.apptTo}'),
            if (!isEvent) ...[
              _buildInfoRow('Patient', appointment.patient),
              _buildInfoRow('Status', appointment.status),
            ],
            _buildInfoRow(isEvent ? 'Participants' : 'Provider',
                isEvent ? appointment.participants : appointment.provider),
            _buildInfoRow('Location', appointment.location),
            SizedBox(height: 8),
            Text('Notes:', style: FluentTheme.of(context).typography.subtitle),
            Text(appointment.notes),
          ],
        ),
      ),
      actions: [
        Button(
          child: Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child:
                Text('$label:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateFormat('yyyy-MM-dd').parse(dateString);
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }
}
