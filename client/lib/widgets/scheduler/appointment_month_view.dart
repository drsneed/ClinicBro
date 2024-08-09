import 'package:fluent_ui/fluent_ui.dart';
import '../../models/appointment_item.dart';
import 'appointment_details_dialog.dart';

class AppointmentMonthView extends StatelessWidget {
  final AppointmentItem appointment;
  const AppointmentMonthView({Key? key, required this.appointment})
      : super(key: key);

  Color _getBackgroundColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      // Return a default color if parsing fails
      return Colors.grey;
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
    Color backgroundColor = _getBackgroundColor(appointment.color);
    Color textColor = _getTextColor(backgroundColor);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) =>
              AppointmentDetailsDialog(appointment: appointment),
        );
      },
      child: Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          appointment.title,
          style: TextStyle(fontSize: 14, color: textColor),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
