import 'package:fluent_ui/fluent_ui.dart';
import '../../managers/overlay_manager.dart';
import '../../models/appointment_item.dart';

class AppointmentDayView extends StatelessWidget {
  final AppointmentItem appointment;
  final OverlayManager overlayManager;
  final void Function(int) onEditAppointment;
  const AppointmentDayView({
    Key? key,
    required this.appointment,
    required this.overlayManager,
    required this.onEditAppointment,
  }) : super(key: key);

  Color _getBackgroundColor(String colorString, BuildContext context) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      final isDarkTheme = FluentTheme.of(context).brightness == Brightness.dark;
      return isDarkTheme
          ? Color.fromARGB(255, 41, 40, 40)
          : Color.fromARGB(255, 225, 223, 221);
    }
  }

  Color _getTextColor(Color backgroundColor) {
    double grayscale = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;
    return grayscale > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _getBackgroundColor(appointment.color, context);
    Color textColor = _getTextColor(backgroundColor);

    return GestureDetector(
      onTapUp: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset globalPosition =
            renderBox.localToGlobal(details.localPosition);
        overlayManager.showAppointmentDetailsPopup(
            context, appointment, globalPosition, onEditAppointment);
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: double.infinity,
        ),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.title,
              style: TextStyle(
                  fontSize: 12, color: textColor, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            Text(
              '${_formatTime(DateTime.parse(appointment.apptDate))}',
              style: TextStyle(fontSize: 10, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}
