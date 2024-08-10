import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_item.dart';

class AppointmentDetailsPopup extends StatelessWidget {
  final AppointmentItem appointment;
  final Offset position;

  const AppointmentDetailsPopup({
    Key? key,
    required this.appointment,
    required this.position,
  }) : super(key: key);

  Color _getBackgroundColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEvent = appointment.patient.isEmpty;
    final titleText = appointment.title;
    final backgroundColor = _getBackgroundColor(appointment.color);
    final screenSize = MediaQuery.of(context).size;
    final popupWidth = 320.0;
    final popupHeight = 400.0;
    final arrowSize = 10.0;
    final cursorOffset = 20.0; // Offset from cursor

    bool isLeftAligned = position.dx < screenSize.width / 2;

    double left = isLeftAligned
        ? position.dx + cursorOffset
        : position.dx - popupWidth - arrowSize - cursorOffset;
    double top = position.dy - popupHeight / 2;

    // Adjust if the popup goes off-screen
    if (top < 0) top = 0;
    if (top + popupHeight > screenSize.height)
      top = screenSize.height - popupHeight;

    return Positioned(
      left: left,
      top: top,
      child: CustomPaint(
        painter: BubblePainter(
          backgroundColor: FluentTheme.of(context).micaBackgroundColor,
          arrowPosition: isLeftAligned
              ? BubbleArrowPosition.left
              : BubbleArrowPosition.right,
          arrowTipPosition: position.dy - top,
        ),
        child: Container(
          width: popupWidth + arrowSize,
          constraints: BoxConstraints(maxHeight: popupHeight),
          child: Padding(
            padding: EdgeInsets.fromLTRB(isLeftAligned ? arrowSize + 16 : 16,
                16, isLeftAligned ? 16 : arrowSize + 16, 16),
            child: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
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
                        Expanded(
                            child: Text(titleText,
                                style: FluentTheme.of(context)
                                    .typography
                                    .subtitle)),
                      ],
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow('Date', _formatDate(appointment.apptDate)),
                    _buildInfoRow('Time',
                        '${appointment.apptFrom} - ${appointment.apptTo}'),
                    if (!isEvent) ...[
                      _buildInfoRow('Patient', appointment.patient),
                      _buildInfoRow('Status', appointment.status),
                    ],
                    _buildInfoRow(
                        isEvent ? 'Who' : 'Provider',
                        isEvent
                            ? appointment.participants
                            : appointment.provider),
                    _buildInfoRow(
                        isEvent ? 'Where' : 'Location', appointment.location),
                    SizedBox(height: 8),
                    Text('Notes:',
                        style: FluentTheme.of(context).typography.bodyStrong),
                    Text(appointment.notes),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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

enum BubbleArrowPosition { left, right }

class BubblePainter extends CustomPainter {
  final Color backgroundColor;
  final BubbleArrowPosition arrowPosition;
  final double arrowTipPosition;

  BubblePainter({
    required this.backgroundColor,
    required this.arrowPosition,
    required this.arrowTipPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final arrowSize = 10.0;
    final cornerRadius = 8.0;

    if (arrowPosition == BubbleArrowPosition.left) {
      path.moveTo(arrowSize, cornerRadius);
      path.quadraticBezierTo(arrowSize, 0, arrowSize + cornerRadius, 0);
      path.lineTo(size.width - cornerRadius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
      path.lineTo(size.width, size.height - cornerRadius);
      path.quadraticBezierTo(
          size.width, size.height, size.width - cornerRadius, size.height);
      path.lineTo(arrowSize + cornerRadius, size.height);
      path.quadraticBezierTo(
          arrowSize, size.height, arrowSize, size.height - cornerRadius);
      path.lineTo(arrowSize, arrowTipPosition + 15);
      path.lineTo(0, arrowTipPosition);
      path.lineTo(arrowSize, arrowTipPosition - 15);
    } else {
      path.moveTo(0, cornerRadius);
      path.quadraticBezierTo(0, 0, cornerRadius, 0);
      path.lineTo(size.width - arrowSize - cornerRadius, 0);
      path.quadraticBezierTo(
          size.width - arrowSize, 0, size.width - arrowSize, cornerRadius);
      path.lineTo(size.width - arrowSize, arrowTipPosition - 15);
      path.lineTo(size.width, arrowTipPosition);
      path.lineTo(size.width - arrowSize, arrowTipPosition + 15);
      path.lineTo(size.width - arrowSize, size.height - cornerRadius);
      path.quadraticBezierTo(size.width - arrowSize, size.height,
          size.width - arrowSize - cornerRadius, size.height);
      path.lineTo(cornerRadius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
