import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    show
        BuildContext,
        Key,
        Scaffold,
        State,
        StatefulWidget,
        VerticalDivider,
        Widget;
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
  BaseDetailWidget? _detailWidget;

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
      _detailWidget = null;
    });
  }

  Future<void> _loadDetailItem(int itemId) async {
    setState(() {
      _isLoading = true;
      detailWidgetFuture = widget.fetchDetailItem(itemId);
    });
    final detailWidget = await detailWidgetFuture;
    if (detailWidget is BaseDetailWidget) {
      setState(() {
        _isLoading = false;
        _detailWidget = detailWidget;
      });
    } else {
      setState(() {
        _isLoading = false;
        _detailWidget = null;
      });
    }
  }

  Future<void> save() async {
    if (selectedItem != null && _detailWidget != null) {
      final resultObject = await _detailWidget!.save();
      if (resultObject != null) {
        await _loadItems();
      }
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
    return FluentApp(
      debugShowCheckedModeBanner: false,
      home: ScaffoldPage(
        header: Stack(
          children: [
            CommandBar(
              mainAxisAlignment: MainAxisAlignment.start,
              primaryItems: [
                CommandBarButton(
                  icon: const Icon(FluentIcons.add),
                  onPressed: () {
                    // Handle add action
                  },
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.save),
                  onPressed: () {
                    save();
                  },
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.delete),
                  onPressed: () {
                    delete();
                  },
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.refresh),
                  onPressed: () {
                    _loadItems();
                  },
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
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  bool isSelected = selectedItem?.id == item.id;
                  return Container(
                    color: isSelected
                        ? FluentTheme.of(context)
                            .accentColor // Background color for selected item
                        : Colors.transparent,
                    child: ListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black, // Text color for selected item
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedItem = item;
                          _loadDetailItem(selectedItem!.id);
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const VerticalDivider(width: 1),
            Expanded(
              flex: 2,
              child: _isLoading
                  ? const Center(child: ProgressRing())
                  : FutureBuilder<Widget?>(
                      future: detailWidgetFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: ProgressRing());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData) {
                          return const Center(
                              child: Text('No details available'));
                        } else {
                          return snapshot.data!;
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
