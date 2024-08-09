import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'navigation_month_view.dart';

class SchedulerNavigationPanel extends StatefulWidget {
  final bool isVisible;
  final DateTime centerDate;
  final void Function(DateTime) onDateChanged;

  SchedulerNavigationPanel({
    required this.isVisible,
    required this.centerDate,
    required this.onDateChanged,
  });

  @override
  _SchedulerNavigationPanelState createState() =>
      _SchedulerNavigationPanelState();
}

class _SchedulerNavigationPanelState extends State<SchedulerNavigationPanel> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: widget.isVisible ? 250 : 0,
      color: FluentTheme.of(context).micaBackgroundColor,
      child: widget.isVisible
          ? Stack(
              children: [
                _buildScrollableContent(),
                _buildFloatingButtons(),
              ],
            )
          : null,
    );
  }

  Widget _buildScrollableContent() {
    return ListView(
      controller: _scrollController,
      children: [
        NavigationMonthView(
          key: ValueKey('previous-month'),
          initialDate:
              DateTime(widget.centerDate.year, widget.centerDate.month - 1, 1),
          onMonthChanged: widget.onDateChanged,
        ),
        NavigationMonthView(
          key: ValueKey('current-month'),
          initialDate: widget.centerDate,
          onMonthChanged: widget.onDateChanged,
        ),
        NavigationMonthView(
          key: ValueKey('next-month'),
          initialDate:
              DateTime(widget.centerDate.year, widget.centerDate.month + 1, 1),
          onMonthChanged: widget.onDateChanged,
        ),
        SizedBox(height: 1000), // Add extra space to allow scrolling
      ],
    );
  }

  Widget _buildFloatingButtons() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        color: Colors
            .transparent, //FluentTheme.of(context).micaBackgroundColor.withOpacity(0.8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(FluentIcons.chevron_left),
              onPressed: () => widget.onDateChanged(DateTime(
                  widget.centerDate.year, widget.centerDate.month - 1, 1)),
            ),
            IconButton(
              icon: const Icon(FluentIcons.chevron_right),
              onPressed: () => widget.onDateChanged(DateTime(
                  widget.centerDate.year, widget.centerDate.month + 1, 1)),
            ),
          ],
        ),
      ),
    );
  }
}
