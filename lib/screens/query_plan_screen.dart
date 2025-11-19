import 'package:flutter/material.dart';

import '../models/order_plan.dart';
import '../services/database_service.dart';
import '../widgets/plan_summary_card.dart';

class QueryPlanScreen extends StatefulWidget {
  const QueryPlanScreen({super.key});

  @override
  State<QueryPlanScreen> createState() => _QueryPlanScreenState();
}

class _QueryPlanScreenState extends State<QueryPlanScreen> {
  DateTime? _selectedDate;
  OrderPlan? _plan;
  bool _isFetching = false;

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
      await _fetchPlan();
    }
  }

  Future<void> _fetchPlan() async {
    if (_selectedDate == null) return;
    setState(() {
      _isFetching = true;
    });
    final plan = await DatabaseService.instance
        .getOrderPlanByDate(_formattedDate(_selectedDate!));
    setState(() {
      _plan = plan;
      _isFetching = false;
    });
  }

  String _formattedDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Order Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Text(
                      _selectedDate == null
                          ? 'Select date'
                          : _formattedDate(_selectedDate!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isFetching
                  ? const Center(child: CircularProgressIndicator())
                  : _plan != null
                      ? SingleChildScrollView(
                          child: PlanSummaryCard(
                            date: _plan!.date,
                            targetCost: _plan!.targetCost,
                            totalCost: _plan!.totalCost,
                            items: _plan!.selectedItems,
                          ),
                        )
                      : Center(
                          child: Text(
                            _selectedDate == null
                                ? 'Select a date to view a plan.'
                                : 'No plan saved for ${_formattedDate(_selectedDate!)}.',
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
