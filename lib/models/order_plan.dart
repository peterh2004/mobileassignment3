import 'dart:convert';

import 'food_item.dart';

class OrderPlan {
  final int? id;
  final String date;
  final double targetCost;
  final List<FoodItem> selectedItems;

  const OrderPlan({
    this.id,
    required this.date,
    required this.targetCost,
    required this.selectedItems,
  });

  double get totalCost =>
      selectedItems.fold(0, (sum, item) => sum + item.cost);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'target_cost': targetCost,
      'selected_items': jsonEncode(
        selectedItems.map((item) => item.toMap()).toList(),
      ),
    };
  }

  factory OrderPlan.fromMap(Map<String, dynamic> map) {
    final List<dynamic> itemsJson = jsonDecode(map['selected_items'] as String);
    return OrderPlan(
      id: map['id'] as int?,
      date: map['date'] as String,
      targetCost: (map['target_cost'] as num).toDouble(),
      selectedItems: itemsJson
          .map((json) => FoodItem.fromMap(json as Map<String, dynamic>))
          .toList(),
    );
  }
}
