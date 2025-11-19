import 'package:flutter/material.dart';

import '../models/food_item.dart';

class FoodItemTile extends StatelessWidget {
  final FoodItem item;
  final VoidCallback? onTap;
  final Widget? trailing;

  const FoodItemTile({
    super.key,
    required this.item,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(item.name),
      subtitle: Text('CAD ${item.cost.toStringAsFixed(2)}'),
      trailing: trailing,
    );
  }
}
