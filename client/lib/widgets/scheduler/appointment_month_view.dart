import 'package:fluent_ui/fluent_ui.dart';

import '../../models/appointment_item.dart';

class AppointmentMonthView extends StatelessWidget {
  final AppointmentItem appointment;

  const AppointmentMonthView({Key? key, required this.appointment})
      : super(key: key);

  Color _getTextColor(Color backgroundColor) {
    // Convert the background color to grayscale
    double grayscale = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    // If the grayscale value is greater than 0.5, use black text. Otherwise, use white.
    return grayscale > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        Color(int.parse(appointment.color.replaceAll('#', '0xFF')));
    Color textColor = _getTextColor(backgroundColor);

    return Container(
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
    );
  }
}
