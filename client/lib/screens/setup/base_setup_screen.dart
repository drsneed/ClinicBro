import 'package:flutter/material.dart';
import '../../../models/lookup_item.dart';

class BaseSetupScreen extends StatefulWidget {
  final String title;
  final Future<List<LookupItem>> Function() fetchItems;

  const BaseSetupScreen({
    Key? key,
    required this.title,
    required this.fetchItems,
  }) : super(key: key);

  @override
  _BaseSetupScreenState createState() => _BaseSetupScreenState();
}

class _BaseSetupScreenState extends State<BaseSetupScreen> {
  List<LookupItem> items = [];
  LookupItem? selectedItem;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final loadedItems = await widget.fetchItems();
    setState(() {
      items = loadedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          // Lookup Item List
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name),
                  selected: selectedItem?.id == item.id,
                  onTap: () {
                    setState(() {
                      selectedItem = item;
                    });
                  },
                );
              },
            ),
          ),
          // Vertical Divider
          const VerticalDivider(width: 1),
          // Item Detail
          Expanded(
            flex: 2,
            child: selectedItem != null
                ? ItemDetailWidget(item: selectedItem!)
                : const Center(child: Text('Select an item to view details')),
          ),
        ],
      ),
    );
  }
}

class ItemDetailWidget extends StatelessWidget {
  final LookupItem item;

  const ItemDetailWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${item.id}'),
          Text('Name: ${item.name}'),
          Text('Active: ${item.active}'),
          // Add more fields as needed
        ],
      ),
    );
  }
}
