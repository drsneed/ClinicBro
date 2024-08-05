import 'package:fluent_ui/fluent_ui.dart';

class Scheduler extends StatefulWidget {
  const Scheduler({Key? key}) : super(key: key);

  @override
  _SchedulerState createState() => _SchedulerState();
}

class _SchedulerState extends State<Scheduler> {
  late PageController _pageController;
  late DateTime _centerDate;

  @override
  void initState() {
    super.initState();
    _centerDate = DateTime.now();
    _pageController = PageController(
      initialPage: 1000,
      viewportFraction: 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _centerDate = DateTime.now().add(Duration(days: page - 1000));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDateHeader(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index - 1000));
              return _buildDaySchedule(date);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(FluentIcons.chevron_left),
            onPressed: () => _pageController.previousPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          Text(
            '${_centerDate.year}-${_centerDate.month.toString().padLeft(2, '0')}-${_centerDate.day.toString().padLeft(2, '0')}',
            style: FluentTheme.of(context).typography.subtitle,
          ),
          IconButton(
            icon: Icon(FluentIcons.chevron_right),
            onPressed: () => _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(DateTime date) {
    return Container(
      color: FluentTheme.of(context).cardColor,
      child: DragTarget<String>(
        builder: (context, candidateData, rejectedData) {
          return ListView.builder(
            itemCount: 24,
            itemBuilder: (context, index) {
              String timeString = _formatTime(index);

              return Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color:
                              FluentTheme.of(context).inactiveBackgroundColor)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 8,
                      child: SizedBox(
                        width: 50,
                        height: 20,
                        child: Text(
                          timeString,
                          textAlign: TextAlign.center,
                          style: FluentTheme.of(context).typography.caption,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 50,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: FluentTheme.of(context)
                                      .inactiveBackgroundColor)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 50,
                      right: 0,
                      top: 60,
                      child: CustomPaint(
                        size: Size(double.infinity, 1),
                        painter: DashedLinePainter(
                            color: FluentTheme.of(context)
                                .inactiveBackgroundColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        onAcceptWithDetails: (item) {
          // TODO: Handle item drop
          print('Dropped ${item.data} on ${date.toString()}');
        },
      ),
    );
  }

  String _formatTime(int hour) {
    String period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;
    return '$displayHour $period';
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
