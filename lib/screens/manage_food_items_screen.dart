import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../services/database_service.dart';
import '../widgets/food_item_tile.dart';

class ManageFoodItemsScreen extends StatefulWidget {
  const ManageFoodItemsScreen({super.key});

  @override
  State<ManageFoodItemsScreen> createState() => _ManageFoodItemsScreenState();
}

class _ManageFoodItemsScreenState extends State<ManageFoodItemsScreen> {
  List<FoodItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await DatabaseService.instance.getFoodItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _showFoodDialog({FoodItem? item}) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final costController = TextEditingController(
      text: item != null ? item.cost.toStringAsFixed(2) : '',
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Add Food Item' : 'Edit Food Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cost (CAD)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final cost = double.tryParse(costController.text) ?? 0;
                if (name.isEmpty || cost <= 0) {
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final name = nameController.text.trim();
      final cost = double.tryParse(costController.text) ?? 0;
      if (item == null) {
        await DatabaseService.instance.addFoodItem(name, cost);
      } else {
        await DatabaseService.instance
            .updateFoodItem(item.id!, name, cost);
      }
      await _loadItems();
    }
  }

  Future<void> _deleteItem(FoodItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Remove ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService.instance.deleteFoodItem(item.id!);
      await _loadItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Food Items'),
        actions: [
          IconButton(
            onPressed: () => _showFoodDialog(),
            icon: const Icon(Icons.add),
            tooltip: 'Add Item',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadItems,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    child: FoodItemTile(
                      item: item,
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showFoodDialog(item: item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteItem(item),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
