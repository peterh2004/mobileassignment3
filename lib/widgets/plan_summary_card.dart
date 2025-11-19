import 'package:flutter/material.dart';

import '../models/food_item.dart';

class PlanSummaryCard extends StatelessWidget {
  final String date;
  final double targetCost;
  final double totalCost;
  final List<FoodItem> items;

  const PlanSummaryCard({
    super.key,
    required this.date,
    required this.targetCost,
    required this.totalCost,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan for $date',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('Target: CAD ${targetCost.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: Text(
                    'Total: CAD ${totalCost.toStringAsFixed(2)}',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Selected Items',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.name)),
                    Text('CAD ${item.cost.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
