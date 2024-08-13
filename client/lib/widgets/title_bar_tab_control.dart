import 'package:fluent_ui/fluent_ui.dart';
import 'themed_icon.dart';
import '../models/patient_item.dart';

class TitleBarTabControl extends StatefulWidget {
  final void Function(int tabId) onTabSelected;
  final int? selectedTabId;
  final void Function(int tabId) onTabClosed;
  final List<TabButtonData> tabButtons;
  final void Function(PatientItem) onPatientDropped;
  final void Function(List<TabButtonData>) onTabsReordered;

  const TitleBarTabControl({
    Key? key,
    required this.onTabSelected,
    required this.selectedTabId,
    required this.onTabClosed,
    required this.tabButtons,
    required this.onPatientDropped,
    required this.onTabsReordered,
  }) : super(key: key);

  @override
  _TitleBarTabControlState createState() => _TitleBarTabControlState();
}

class _TitleBarTabControlState extends State<TitleBarTabControl> {
  late List<TabButtonData> _tabButtons;
  int? _draggedTabIndex;
  int? _dropIndicatorIndex;

  @override
  void initState() {
    super.initState();
    _tabButtons = List.from(widget.tabButtons);
  }

  @override
  void didUpdateWidget(TitleBarTabControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabButtons != oldWidget.tabButtons) {
      _tabButtons = List.from(widget.tabButtons);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<PatientItem>(
      onAccept: (patient) {
        widget.onPatientDropped(patient);
      },
      builder: (context, candidateData, rejectedData) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildTabListWithIndicator(),
              ),
              if (_dropIndicatorIndex != null)
                Positioned(
                  left: _getDropIndicatorPosition(),
                  top: 0,
                  bottom: 0,
                  child: _buildDropIndicator(),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildTabListWithIndicator() {
    final tabWidgets = _tabButtons.asMap().entries.map((entry) {
      final index = entry.key;
      final tabButton = entry.value;
      return _buildDraggableTabButton(context, tabButton, index);
    }).toList();

    if (_dropIndicatorIndex != null &&
        _dropIndicatorIndex! <= tabWidgets.length) {
      tabWidgets.insert(_dropIndicatorIndex!, _buildDropIndicator());
    }

    return tabWidgets;
  }

  Widget _buildDraggableTabButton(
      BuildContext context, TabButtonData tabData, int index) {
    return DragTarget<int>(
      onWillAccept: (data) => data != null && data != index,
      onAccept: (draggedIndex) {
        setState(() {
          final draggedTab = _tabButtons.removeAt(draggedIndex);
          _tabButtons.insert(index, draggedTab);
          widget.onTabsReordered(_tabButtons);
          _dropIndicatorIndex = null;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          key: tabData.tabKey, // Attach the key here
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          child: Draggable<int>(
            data: index,
            child: _buildTabButton(context, tabData),
            feedback: _buildTabButton(context, tabData, isDragging: true),
            childWhenDragging: SizedBox(width: 0),
            onDragStarted: () {
              setState(() {
                _draggedTabIndex = index;
              });
            },
            onDragEnd: (details) {
              setState(() {
                _draggedTabIndex = null;
                _dropIndicatorIndex = null;
              });
            },
            onDragUpdate: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              setState(() {
                _dropIndicatorIndex = _getDropIndicatorIndex(localPosition.dx);
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildTabButton(BuildContext context, TabButtonData tabData,
      {bool isDragging = false}) {
    final primaryColor = FluentTheme.of(context).inactiveColor.withOpacity(0.8);
    final isSelected = tabData.tabId == widget.selectedTabId;

    return Opacity(
      opacity: isDragging ? 0.7 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: GestureDetector(
          onTap: () => widget.onTabSelected(tabData.tabId),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? FluentTheme.of(context).accentColor
                    : primaryColor,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ThemedIcon(
                  svgPath: 'assets/icon/clipboard.svg',
                  size: 13.0,
                  color:
                      isSelected ? FluentTheme.of(context).accentColor : null,
                ),
                const SizedBox(width: 8),
                Text(
                  tabData.label,
                  style: TextStyle(
                    color:
                        isSelected ? FluentTheme.of(context).accentColor : null,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(FluentIcons.chrome_close,
                      size: 8,
                      color: isSelected
                          ? FluentTheme.of(context).accentColor
                          : null),
                  onPressed: () => widget.onTabClosed(tabData.tabId),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropIndicator() {
    return Container(
      width: 2,
      height: 30.0, // Set a fixed height for the indicator
      color: FluentTheme.of(context).accentColor,
    );
  }

  int _getDropIndicatorIndex(double x) {
    double accumulatedWidth = 0.0;

    for (int i = 0; i < _tabButtons.length; i++) {
      final tabWidth = _getTabWidth(_tabButtons[i].tabKey);
      final tabEnd = accumulatedWidth + tabWidth;

      if (x < tabEnd) {
        return x < (accumulatedWidth + tabEnd) / 2 ? i : i + 1;
      }

      accumulatedWidth = tabEnd;
    }

    return _tabButtons.length; // Place at the end
  }

  double _getDropIndicatorPosition() {
    double position = 0.0;

    if (_dropIndicatorIndex != null) {
      for (int i = 0; i < _dropIndicatorIndex!; i++) {
        position += _getTabWidth(_tabButtons[i].tabKey);
      }
    }

    return position;
  }

  double _getTabWidth(GlobalKey key) {
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 150.0; // Default width if not available
  }
}

class TabButtonData {
  final int tabId;
  final String label;
  final GlobalKey tabKey; // Add this key to measure width

  TabButtonData({
    required this.tabId,
    required this.label,
  }) : tabKey = GlobalKey();
}
