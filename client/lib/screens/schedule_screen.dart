import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat
    show Colors, FloatingActionButton, CircleBorder;
import '../widgets/scheduler.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _isFlyoutVisible = false;
  final List<String> items = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'];

  void _toggleFlyout() {
    setState(() {
      _isFlyoutVisible = !_isFlyoutVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Stack(
      children: [
        ScaffoldPage(
          header: PageHeader(
            title: Text('Schedule'),
          ),
          content: SchedulingControl(isFlyoutVisible: _isFlyoutVisible),
        ),
        if (isDesktop) _buildDesktopFlyout(),
        if (!isDesktop) _buildMobileFlyout(),
        _buildFloatingActionButton(isDesktop),
      ],
    );
  }

  Widget _buildDesktopFlyout() {
    return Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: _isFlyoutVisible ? 200 : 0,
        child: Container(
          color: FluentTheme.of(context).micaBackgroundColor,
          child: _isFlyoutVisible
              ? ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildDraggableItem(items[index]);
                  },
                )
              : null,
        ),
      ),
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

  Widget _buildFloatingActionButton(bool isDesktop) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: SizedBox(
        width: isDesktop ? 40 : 64,
        height: isDesktop ? 40 : 64,
        child: mat.FloatingActionButton(
          child: Icon(
            _isFlyoutVisible
                ? (isDesktop
                    ? FluentIcons.chevron_right
                    : FluentIcons.chevron_down)
                : FluentIcons.people,
            color: Colors.white,
            size: isDesktop ? 20 : 24,
          ),
          backgroundColor: mat.Colors.blue,
          shape: mat.CircleBorder(),
          onPressed: _toggleFlyout,
          tooltip: _isFlyoutVisible ? 'Hide Patients' : 'Show Patients',
        ),
      ),
    );
  }
}
