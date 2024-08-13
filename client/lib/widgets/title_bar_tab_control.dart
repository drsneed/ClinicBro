import 'package:fluent_ui/fluent_ui.dart';
import 'themed_icon.dart';
import '../models/patient_item.dart';

class TitleBarTabControl extends StatelessWidget {
  final void Function(int tabId) onTabSelected;
  final int? selectedTabId;
  final void Function(int tabId) onTabClosed;
  final List<TabButtonData> tabButtons;
  final void Function(PatientItem) onPatientDropped; // New callback

  const TitleBarTabControl({
    super.key,
    required this.onTabSelected,
    required this.selectedTabId,
    required this.onTabClosed,
    required this.tabButtons,
    required this.onPatientDropped,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<PatientItem>(
      onAccept: (patient) {
        onPatientDropped(patient);
      },
      builder: (context, candidateData, rejectedData) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: tabButtons
                .map((tabButton) => _buildTabButton(context, tabButton))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildTabButton(BuildContext context, TabButtonData tabData) {
    final primaryColor = FluentTheme.of(context).inactiveColor.withOpacity(0.8);
    final isSelected = tabData.tabId == selectedTabId;

    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: MouseRegion(
        onEnter: (_) {},
        onExit: (_) {},
        child: GestureDetector(
          onTap: () => onTabSelected(tabData.tabId),
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
                  size: 12.0,
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
                  onPressed: () => onTabClosed(tabData.tabId),
                ),
              ],
            ),
          ),
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
