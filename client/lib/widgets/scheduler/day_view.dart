import 'package:fluent_ui/fluent_ui.dart';

class DayView extends StatelessWidget {
  final PageController pageController;
  final Function(int) onPageChanged;

  const DayView({
    Key? key,
    required this.pageController,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        final date = DateTime.now().add(Duration(days: index - 1000));
        return _buildDaySchedule(context, date);
      },
    );
  }

  Widget _buildDaySchedule(BuildContext context, DateTime date) {
    return Container(
      color: FluentTheme.of(context).cardColor,
      child: ListView.builder(
        itemCount: 24,
        itemBuilder: (context, index) {
          String timeString = _formatTime(index);

          return Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: FluentTheme.of(context).inactiveBackgroundColor,
                ),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 8,
                  child: SizedBox(
                    width: 60, // Adjusted width to fit longer time strings
                    height: 20,
                    child: Text(
                      timeString,
                      textAlign: TextAlign.center,
                      style: FluentTheme.of(context).typography.caption,
                    ),
                  ),
                ),
                Positioned(
                  left: 60,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color:
                              FluentTheme.of(context).inactiveBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 60,
                  right: 0,
                  top: 60,
                  child: CustomPaint(
                    size: Size(double.infinity, 1),
                    painter: DashedLinePainter(
                      color: FluentTheme.of(context).inactiveBackgroundColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(int index) {
    final hour = index % 24;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:00 $ampm';
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 3, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
