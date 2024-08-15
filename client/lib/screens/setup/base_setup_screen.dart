import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    show BuildContext, Key, State, StatefulWidget, VerticalDivider, Widget;
import '../../../models/lookup_item.dart';
import '../../repositories/appointment_type_repository.dart';
import 'base_detail_widget.dart';

class BaseSetupScreen extends StatefulWidget {
  final Future<List<LookupItem>> Function() fetchItems;
  final Future<Widget?> Function(int) fetchDetailItem;

  const BaseSetupScreen({
    Key? key,
    required this.fetchItems,
    required this.fetchDetailItem,
  }) : super(key: key);

  @override
  _BaseSetupScreenState createState() => _BaseSetupScreenState();
}

class _BaseSetupScreenState extends State<BaseSetupScreen> {
  List<LookupItem> items = [];
  LookupItem? selectedItem;
  Future<Widget?>? detailWidgetFuture;
  bool _isLoading = false;
  GlobalKey<BaseDetailWidgetState> detailKey =
      GlobalKey<BaseDetailWidgetState>();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final loadedItems = await widget.fetchItems();
    setState(() {
      items = loadedItems;
      selectedItem = null;
      detailWidgetFuture = null;
    });
  }

  Future<void> _loadDetailItem(int itemId) async {
    print('loading detail item for id $itemId');
    setState(() {
      _isLoading = true;
      detailWidgetFuture = widget.fetchDetailItem(itemId);
    });
    final detailWidget = await detailWidgetFuture;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> save() async {
    if (detailKey.currentState != null) {
      print('current state is not null');
      await detailKey.currentState!.save();
      await _loadItems(); // Refresh the list after saving
    } else {
      print('current state is null');
    }
  }

  Future<void> delete() async {
    if (selectedItem != null) {
      final repo = AppointmentTypeRepository();
      await repo.deleteAppointmentType(selectedItem!.id);
      await _loadItems(); // Refresh the list after deleting
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    Color errorColor = theme.accentColor.withOpacity(0.8);

    return ScaffoldPage(
      header: Stack(
        children: [
          CommandBar(
            mainAxisAlignment: MainAxisAlignment.start,
            primaryItems: [
              CommandBarButton(
                icon: Icon(FluentIcons.add, color: theme.inactiveColor),
                onPressed: () {
                  // Handle add action
                },
              ),
              CommandBarButton(
                icon: Icon(FluentIcons.save, color: theme.inactiveColor),
                onPressed: save,
              ),
              CommandBarButton(
                icon: Icon(FluentIcons.delete, color: theme.inactiveColor),
                onPressed: delete,
              ),
              CommandBarButton(
                icon: Icon(FluentIcons.refresh, color: theme.inactiveColor),
                onPressed: _loadItems,
              ),
            ],
          ),
        ],
      ),
      content: Row(
        children: [
          // Lookup Item List
          Expanded(
            flex: 1,
            child: Container(
              color: theme.micaBackgroundColor, // Set the list background color
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  bool isSelected = selectedItem?.id == item.id;
                  return Container(
                    color:
                        Colors.transparent, // Keep the background transparent
                    child: Row(
                      children: [
                        // Vertical bar of accent color
                        Container(
                          width: 4, // Width of the vertical bar
                          height:
                              48, // Height of the vertical bar, adjust as needed
                          color: isSelected
                              ? theme.accentColor
                              : Colors.transparent,
                        ),
                        const SizedBox(
                            width: 8), // Space between the bar and text
                        Expanded(
                          child: ListTile(
                            title: Text(
                              item.name,
                              style: TextStyle(
                                color: isSelected
                                    ? theme.accentColor
                                    : theme.typography.body?.color,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedItem = item;
                                _loadDetailItem(selectedItem!.id);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: theme.brightness == Brightness.light
                ? Colors.grey.withOpacity(0.2)
                : Colors.white.withOpacity(0.7),
          ),
          Expanded(
            flex: 2,
            child: _isLoading
                ? Center(
                    child: ProgressRing(
                      activeColor: theme.accentColor,
                    ),
                  )
                : FutureBuilder<Widget?>(
                    future: detailWidgetFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: ProgressRing(
                          activeColor: theme.accentColor,
                        ));
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: ${snapshot.error}',
                                style: TextStyle(color: errorColor)));
                      } else if (!snapshot.hasData) {
                        return Center(
                            child: Text('No details available',
                                style: theme.typography.body));
                      } else {
                        return snapshot.data!;
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
