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
  late List<DateTime> _monthList;
  final int _initialMonthCount = 36; // Start with 3 years worth of months
  final double _estimatedMonthViewHeight =
      240.0; // Estimate of NavigationMonthView height

  @override
  void initState() {
    super.initState();
    _scrollController =
        ScrollController(initialScrollOffset: _estimatedMonthViewHeight * 12);
    _initializeMonthList();
    _scrollController.addListener(_onScroll);
  }

  void _initializeMonthList() {
    DateTime startDate =
        DateTime(widget.centerDate.year - 1, widget.centerDate.month, 1);
    _monthList = List.generate(_initialMonthCount, (index) {
      return DateTime(startDate.year, startDate.month + index, 1);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _addMonthsToEnd();
    } else if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      _addMonthsToStart();
    }
  }

  void _updateCenterDate() {
    if (!_scrollController.position.isScrollingNotifier.value) {
      _monthList.forEach(print);
      //widget.onDateChanged(_monthList[_monthList.length - 2]);
      double viewportHeight = _scrollController.position.viewportDimension;
      double scrollOffset = _scrollController.offset;
      int centralIndex =
          ((scrollOffset + (viewportHeight / 2)) / _estimatedMonthViewHeight)
              .floor();

      if (centralIndex >= 0 && centralIndex < _monthList.length) {
        // _monthList.forEach(print);
        // print('centralIndex = $centralIndex');
        // print('updating center date with ${_monthList[centralIndex]}');
        widget.onDateChanged(_monthList[centralIndex]);
      }
    }
  }

  void _addMonthsToEnd() {
    setState(() {
      DateTime lastDate = _monthList.last;
      _monthList.add(DateTime(lastDate.year, lastDate.month + 1, 1));
    });
  }

  void _addMonthsToStart() {
    setState(() {
      DateTime firstDate = _monthList.first;
      _monthList.insert(0, DateTime(firstDate.year, firstDate.month - 1, 1));
      // Adjust scroll position to keep the view stable
      _scrollController
          .jumpTo(_scrollController.offset + (1 * _estimatedMonthViewHeight));
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
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
    //_initializeMonthList();
    return ListView.builder(
      controller: _scrollController,
      itemCount: _monthList.length,
      itemBuilder: (context, index) {
        return NavigationMonthView(
          key: ValueKey('month-$index'),
          initialDate: _monthList[index],
          onMonthChanged: (_) {}, // We're not using this anymore
        );
      },
    );
  }

  Widget _buildFloatingButtons() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(FluentIcons.chevron_left),
              onPressed: () {
                double newOffset =
                    _scrollController.offset - _estimatedMonthViewHeight;
                _scrollController.animateTo(newOffset,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              },
            ),
            IconButton(
              icon: const Icon(FluentIcons.chevron_right),
              onPressed: () {
                double newOffset =
                    _scrollController.offset + _estimatedMonthViewHeight;
                _scrollController.animateTo(newOffset,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              },
            ),
          ],
        ),
      ),
    );
  }
}
