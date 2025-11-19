import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/food_item.dart';
import '../models/order_plan.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> init() async {
    await database;
    await _ensureDefaultFoodItems();
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'food_ordering.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE food_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              cost REAL NOT NULL
            );
          ''');
        await db.execute('''
            CREATE TABLE order_plan (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL UNIQUE,
              target_cost REAL NOT NULL,
              selected_items TEXT NOT NULL
            );
          ''');
      },
    );
  }

  Future<void> _ensureDefaultFoodItems() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM food_items'),
        ) ??
        0;
    if (count >= 20) return;

    final defaults = <Map<String, dynamic>>[
      {'name': 'Margherita Pizza', 'cost': 10.99},
      {'name': 'BBQ Chicken Pizza', 'cost': 12.49},
      {'name': 'Veggie Wrap', 'cost': 8.50},
      {'name': 'Caesar Salad', 'cost': 7.25},
      {'name': 'Grilled Salmon', 'cost': 15.75},
      {'name': 'Steak Sandwich', 'cost': 11.80},
      {'name': 'Chicken Tacos', 'cost': 9.60},
      {'name': 'Beef Burrito', 'cost': 9.95},
      {'name': 'Pasta Alfredo', 'cost': 13.20},
      {'name': 'Sushi Platter', 'cost': 16.99},
      {'name': 'Pad Thai', 'cost': 12.10},
      {'name': 'Falafel Bowl', 'cost': 8.95},
      {'name': 'Greek Salad', 'cost': 7.90},
      {'name': 'Chicken Shawarma', 'cost': 10.25},
      {'name': 'Banh Mi Sandwich', 'cost': 8.75},
      {'name': 'Avocado Toast', 'cost': 6.50},
      {'name': 'Smoothie Bowl', 'cost': 7.40},
      {'name': 'Ramen Bowl', 'cost': 13.95},
      {'name': 'Korean Bibimbap', 'cost': 14.00},
      {'name': 'Chocolate Cake', 'cost': 5.95},
    ];

    final batch = db.batch();
    for (final entry in defaults.take(20 - count)) {
      batch.insert('food_items', entry);
    }
    await batch.commit(noResult: true);
  }

  Future<List<FoodItem>> getFoodItems() async {
    final db = await database;
    final items = await db.query('food_items', orderBy: 'name ASC');
    return items.map(FoodItem.fromMap).toList();
  }

  Future<int> addFoodItem(String name, double cost) async {
    final db = await database;
    return db.insert('food_items', {'name': name, 'cost': cost});
  }

  Future<void> updateFoodItem(int id, String name, double cost) async {
    final db = await database;
    await db.update(
      'food_items',
      {'name': name, 'cost': cost},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteFoodItem(int id) async {
    final db = await database;
    await db.delete('food_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveOrderPlan(
    String date,
    double targetCost,
    List<FoodItem> itemsList,
  ) async {
    final db = await database;
    final plan = OrderPlan(
      date: date,
      targetCost: targetCost,
      selectedItems: itemsList,
    );
    await db.insert(
      'order_plan',
      plan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<OrderPlan?> getOrderPlanByDate(String date) async {
    final db = await database;
    final results = await db.query(
      'order_plan',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return OrderPlan.fromMap(results.first);
  }
}
