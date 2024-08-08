import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

import 'navigation_month_view.dart';

class SchedulerNavigationPanel extends StatefulWidget {
  final bool isVisible;

  SchedulerNavigationPanel({required this.isVisible});

  @override
  _SchedulerNavigationPanelState createState() =>
      _SchedulerNavigationPanelState();
}

class _SchedulerNavigationPanelState extends State<SchedulerNavigationPanel> {
  late DateTime _centerDate;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _centerDate = DateTime.now();
    _pageController = PageController(initialPage: 1000);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _centerDate = newDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: widget.isVisible ? 250 : 0,
      color: FluentTheme.of(context).micaBackgroundColor,
      child: widget.isVisible
          ? Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildViewContent(),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildHeader() {
    final headerText = 'Navigator';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(FluentIcons.chevron_left),
            onPressed: () => _onDateChanged(
                DateTime(_centerDate.year, _centerDate.month - 1, 1)),
          ),
          Text(
            headerText,
            style: FluentTheme.of(context).typography.bodyLarge,
          ),
          IconButton(
            icon: const Icon(FluentIcons.chevron_right),
            onPressed: () => _onDateChanged(
                DateTime(_centerDate.year, _centerDate.month + 1, 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildViewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NavigationMonthView(
          initialDate: DateTime(_centerDate.year, _centerDate.month - 1, 1),
          onMonthChanged: _onDateChanged,
        ),
        NavigationMonthView(
          initialDate: _centerDate,
          onMonthChanged: _onDateChanged,
        ),
        NavigationMonthView(
          initialDate: DateTime(_centerDate.year, _centerDate.month + 1, 1),
          onMonthChanged: _onDateChanged,
        ),
        Expanded(
          child: SizedBox.expand(),
        ),
      ],
    );
  }
}
