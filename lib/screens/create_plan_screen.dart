import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../services/database_service.dart';
import '../widgets/plan_summary_card.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final TextEditingController _targetController = TextEditingController();
  final Set<int> _selectedIds = {};
  DateTime? _selectedDate;
  List<FoodItem> _foodItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _loadFoodItems() async {
    final items = await DatabaseService.instance.getFoodItems();
    setState(() {
      _foodItems = items;
      _isLoading = false;
    });
  }

  double get _targetCost => double.tryParse(_targetController.text) ?? 0;

  double get _currentTotal {
    return _foodItems
        .where((item) => _selectedIds.contains(item.id))
        .fold(0, (sum, item) => sum + item.cost);
  }

  List<FoodItem> get _selectedItems => _foodItems
      .where((item) => _selectedIds.contains(item.id))
      .toList();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _selectedDate ?? now,
    );
    if (result != null) {
      setState(() {
        _selectedDate = result;
      });
    }
  }

  void _handleSelection(bool? value, FoodItem item) {
    final isSelected = _selectedIds.contains(item.id);
    if (value == true && !isSelected) {
      if (_targetCost <= 0) {
        _showMessage('Enter a target cost before selecting items.');
        return;
      }
      final tentativeTotal = _currentTotal + item.cost;
      if (tentativeTotal > _targetCost) {
        _showMessage('Selection exceeds the target budget.');
        return;
      }
      setState(() {
        _selectedIds.add(item.id!);
      });
    } else if (value == false && isSelected) {
      setState(() {
        _selectedIds.remove(item.id);
      });
    }
  }

  Future<void> _savePlan() async {
    if (_selectedDate == null || _targetCost <= 0 || _selectedIds.isEmpty) {
      _showMessage('Please select a date, target cost, and items.');
      return;
    }
    await DatabaseService.instance.saveOrderPlan(
      _formattedDate(_selectedDate!),
      _targetCost,
      _selectedItems,
    );
    _showMessage('Plan saved successfully.');
  }

  String _formattedDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order Plan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Selected Date'),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: _pickDate,
                              child: Text(
                                _selectedDate == null
                                    ? 'Pick a date'
                                    : _formattedDate(_selectedDate!),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _targetController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Target Cost (CAD)',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Running Total: CAD ${_currentTotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _foodItems.length,
                      itemBuilder: (context, index) {
                        final item = _foodItems[index];
                        final isSelected = _selectedIds.contains(item.id);
                        return Card(
                          child: CheckboxListTile(
                            value: isSelected,
                            title: Text(item.name),
                            subtitle:
                                Text('CAD ${item.cost.toStringAsFixed(2)}'),
                            onChanged: (value) => _handleSelection(value, item),
                          ),
                        );
                      },
                    ),
                  ),
                  PlanSummaryCard(
                    date: _selectedDate == null
                        ? 'No date selected'
                        : _formattedDate(_selectedDate!),
                    targetCost: _targetCost,
                    totalCost: _currentTotal,
                    items: _selectedItems,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selectedDate != null &&
                              _targetCost > 0 &&
                              _selectedIds.isNotEmpty
                          ? _savePlan
                          : null,
                      child: const Text('Save Plan'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
