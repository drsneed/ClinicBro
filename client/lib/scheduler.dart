import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' as mat
    show Colors, FloatingActionButton, CircleBorder, ButtonStyle;

class SchedulingControl extends StatefulWidget {
  final bool isFlyoutVisible;
  const SchedulingControl({Key? key, required this.isFlyoutVisible})
      : super(key: key);

  @override
  _SchedulingControlState createState() => _SchedulingControlState();
}

class _SchedulingControlState extends State<SchedulingControl> {
  late PageController _pageController;
  late DateTime _centerDate;
  late bool _isFlyoutVisible;

  @override
  void initState() {
    super.initState();
    _isFlyoutVisible = false;
    _centerDate = DateTime.now();
    _pageController = PageController(
      initialPage:
          1000, // Start at a large number to allow "infinite" scrolling
      viewportFraction: 1.0,
    );
  }

  void _toggleFlyout() {
    setState(() {
      _isFlyoutVisible = !_isFlyoutVisible;
    });
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

  final List<String> items = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'];
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Stack(
      children: [
        Row(
          children: [
            if (isDesktop) _buildFlyout(),
            Expanded(
              child: Column(
                children: [
                  _buildDateHeader(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        final date =
                            DateTime.now().add(Duration(days: index - 1000));
                        return _buildDaySchedule(date);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isDesktop) _buildMobileFlyout(),
        _buildFloatingActionButton(), // Add this line
      ],
    );
  }

  Widget _buildMobileFlyout() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      left: 0,
      right: 0,
      bottom: _isFlyoutVisible ? 0 : -200,
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          color: FluentTheme.of(context).micaBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildDraggableItem(items[index]);
          },
        ),
      ),
    );
  }

  Widget _buildFlyout() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: widget.isFlyoutVisible ? 200 : 0,
      child: Container(
        color: FluentTheme.of(context).micaBackgroundColor,
        child: widget.isFlyoutVisible
            ? ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildDraggableItem(items[index]);
                },
              )
            : null,
      ),
    );
  }

  Widget _buildDraggableItem(String itemName) {
    return Draggable<String>(
      data: itemName,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(itemName),
      ),
      feedback: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(itemName),
      ),
      childWhenDragging: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FluentTheme.of(context).inactiveBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(itemName),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: mat.FloatingActionButton(
        child: Icon(
          _isFlyoutVisible ? FluentIcons.chevron_down : FluentIcons.people,
          color: Colors.white,
        ),
        backgroundColor: mat.Colors.blue,
        shape: mat.CircleBorder(),
        onPressed: _toggleFlyout,
        tooltip: _isFlyoutVisible ? 'Hide patients' : 'Show patients',
      ),
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
