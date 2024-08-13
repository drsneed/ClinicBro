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
  int? _dropTargetIndex;

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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._tabButtons.asMap().entries.map((entry) {
                final index = entry.key;
                final tabButton = entry.value;
                return _buildDraggableTabButton(context, tabButton, index);
              }),
              if (_dropTargetIndex == _tabButtons.length) _buildTabSkeleton(),
            ],
          ),
        );
      },
    );
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
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Draggable<int>(
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
              _dropTargetIndex = null;
            });
          },
          onDragUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            setState(() {
              _dropTargetIndex =
                  (localPosition.dx ~/ 150).clamp(0, _tabButtons.length);
            });
          },
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
        padding: const EdgeInsets.only(right: 4.0),
        child: MouseRegion(
          onEnter: (_) {},
          onExit: (_) {},
          child: GestureDetector(
            onTap: () => widget.onTabSelected(tabData.tabId),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                    size: 12.0,
                    color:
                        isSelected ? FluentTheme.of(context).accentColor : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tabData.label,
                    style: TextStyle(
                      color: isSelected
                          ? FluentTheme.of(context).accentColor
                          : null,
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
      ),
    );
  }

  Widget _buildTabSkeleton() {
    return Container(
      width: 100,
      height: 30,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).accentColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: FluentTheme.of(context).accentColor,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
    );
  }
}

class TabButtonData {
  final int tabId;
  final String label;

  TabButtonData({required this.tabId, required this.label});
}
