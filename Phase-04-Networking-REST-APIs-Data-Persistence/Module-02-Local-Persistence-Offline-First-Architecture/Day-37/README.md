# 📘 Day 37: Relational SQL Persistence with SQLite & Drift

**Module 02:** [Local Persistence & Offline-First Architecture](../README.md) • **Phase 04:** [Networking, REST APIs & Data Persistence](../../README.md)

> [!NOTE]
> **Lesson Objective:** Master relational database architecture in Flutter using SQLite and Drift. Learn how to configure Write-Ahead Logging (WAL mode), enforce foreign key constraints and cascading deletes, execute multi-table joins, implement atomic ACID transactions for financial ledgers, and manage safe incremental schema migrations across app releases.

**Tags:** `Flutter` `Database` `SQLite` `sqflite` `Drift` `SQL` `Relational` `ACID` `Migrations`

---

## 🚦 Prerequisites
Local Persistence Architecture; Dart Object-Oriented Programming; Streams & Asynchronous Programming.
You should understand database schemas, relational foreign keys, ACID transactions, and asynchronous Dart streams.

## 📖 Overview
While NoSQL databases like Hive are exceptionally fast for flat key-value pairs and document caches, enterprise mobile applications frequently model complex, interconnected domain relationships:
- **Relational Integrity**: An Order must reference a valid Customer; deleting a Customer must safely cascade or restrict deleting their historical invoices.
- **Complex Aggregations & Joins**: Calculating total revenue grouped by product category across quarterly date ranges in a single query.
- **Strict ACID Guarantees**: Atomicity, Consistency, Isolation, and Durability—ensuring that a banking transfer deducts money from Account A and credits Account B atomically without partial state corruptions if the app crashes mid-transaction.
- **Ad-Hoc Indexing**: Querying data by arbitrary combinations of fields (price range, creation date, status tags) without loading every record into RAM.

For these relational domains, **SQLite** is the undisputed global industry standard. Built into both Android and iOS operating systems, SQLite is a zero-configuration, serverless, transactional SQL database engine.

```text
┌────────────────────────────────────────────────────────────────────────┐
│                   RELATIONAL PERSISTENCE IN FLUTTER                    │
├───────────────────────────────────┬────────────────────────────────────┤
│     Raw SQLite (package:sqflite)  │   Reactive Drift (package:drift)   │
├───────────────────────────────────┼────────────────────────────────────┤
│ • Direct raw SQL queries (strings)│ • Compile-time verified Dart tables│
│ • Manual Map-to-Object parsing    │ • Auto-generated type-safe models  │
│ • Lightweight runtime footprint   │ • Reactive queries: watch() Stream │
│ • Manual migration tracking       │ • Built-in schema migration tools  │
│ • Ideal for simple SQL needs      │ • Native isolate background support│
│ • Risk of SQL typos & injections  │ • Zero SQL typos at runtime        │
└───────────────────────────────────┴────────────────────────────────────┘
```

## 📚 Topics Covered
* **1. The Case for Relational SQL in Modern Flutter Applications**: An Order must reference a valid Customer; deleting a Customer must safely cascade or restrict deleting their historical invoices.
* **2. Under the Hood: SQLite Architecture & WAL Mode**: SQLite stores an entire relational database inside a single cross-platform file on disk (typically in the application support directory).
* **3. sqflite vs Drift: Raw SQL vs Reactive Type-Safety**: The foundational SQLite plugin for Flutter. It exposes standard methods: `db.rawQuery()`, `db.insert()`, `db.update()`, and `db.transacti...
* **4. ACID Transactions & Foreign Key Enforcement**: If an exception occurs or the phone battery dies halfway through the loop, SQLite rolls back every single statement, leaving the database...
* **5. Production Schema Migrations**: Incremental `if (oldVersion < X)` migration guards guarantee that users upgrading from Version 1 directly to Version 3 have their data sa...

## 🎯 Implementation Objective
Build a production-grade Retail Inventory & Ledger Database application in Flutter using `package:sqflite`. Demonstrate SQLite database initialization with WAL mode, foreign key constraint enforcement, relational joins between categories and products, atomic transactions for batch stock adjustments, and safe schema migrations.

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize our production SQLite inventory database
  final dbHelper = InventoryDatabaseHelper.instance;
  await dbHelper.database; // Pre-warm database connection

  runApp(InventoryLedgerApp(dbHelper: dbHelper));
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. DOMAIN MODELS & RELATIONAL AGGREGATES
// ─────────────────────────────────────────────────────────────────────────────

class Category {
  final int id;
  final String name;

  const Category({required this.id, required this.name});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }
}

class ProductItem {
  final int id;
  final int categoryId;
  final String categoryName;
  final String sku;
  final String name;
  final double price;
  final int stockQuantity;

  const ProductItem({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.sku,
    required this.name,
    required this.price,
    required this.stockQuantity,
  });

  factory ProductItem.fromMap(Map<String, dynamic> map) {
    return ProductItem(
      id: map['id'] as int,
      categoryId: map['category_id'] as int,
      categoryName: map['category_name'] as String? ?? 'General',
      sku: map['sku'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      stockQuantity: map['stock_quantity'] as int,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. PRODUCTION SQLITE DATABASE HELPER
// ─────────────────────────────────────────────────────────────────────────────

class InventoryDatabaseHelper {
  static final InventoryDatabaseHelper instance = InventoryDatabaseHelper._init();
  static Database? _database;

  InventoryDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('retail_inventory_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        // Enforce foreign key constraints and WAL mode
        await db.execute('PRAGMA foreign_keys = ON;');
        await db.execute('PRAGMA journal_mode = WAL;');
      },
      onCreate: (db, version) async {
        // Create Categories Table
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          );
        ''');

        // Create Products Table with Foreign Key
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category_id INTEGER NOT NULL,
            sku TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            stock_quantity INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
          );
        ''');

        // Create Performance Index on SKU
        await db.execute('CREATE INDEX idx_products_sku ON products(sku);');

        // Seed initial data
        await _seedInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Schema Migration: Add barcode or tracking columns
          await db.execute('ALTER TABLE products ADD COLUMN notes TEXT;');
        }
      },
    );
  }

  Future<void> _seedInitialData(Database db) async {
    await db.transaction((txn) async {
      final cat1 = await txn.insert('categories', {'name': 'Electronics'});
      final cat2 = await txn.insert('categories', {'name': 'Accessories'});

      await txn.insert('products', {
        'category_id': cat1,
        'sku': 'TECH-001',
        'name': 'MacBook Pro M3 Max',
        'price': 3499.99,
        'stock_quantity': 12,
      });

      await txn.insert('products', {
        'category_id': cat2,
        'sku': 'ACC-002',
        'name': 'USB-C Thunderbolt 4 Cable',
        'price': 29.99,
        'stock_quantity': 45,
      });
    });
  }

  // ── RELATIONAL QUERIES ─────────────────────────────────────────────────────

  Future<List<ProductItem>> getAllProductsWithCategory() async {
    final db = await instance.database;
    // Relational INNER JOIN across categories and products
    final result = await db.rawQuery('''
      SELECT 
        p.id, p.category_id, c.name AS category_name,
        p.sku, p.name, p.price, p.stock_quantity
      FROM products p
      INNER JOIN categories c ON p.category_id = c.id
      ORDER BY p.name ASC;
    ''');

    return result.map((map) => ProductItem.fromMap(map)).toList();
  }

  /// Atomic transaction: Adjusts stock and logs inventory ledger atomically
  Future<void> adjustStockAtomic({required int productId, required int delta}) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      // 1. Fetch current stock with write lock
      final res = await txn.rawQuery(
        'SELECT stock_quantity FROM products WHERE id = ?',
        [productId],
      );

      if (res.isEmpty) throw StateError('Product not found');
      final currentStock = res.first['stock_quantity'] as int;
      final newStock = currentStock + delta;

      if (newStock < 0) {
        throw StateError('Insufficient stock! Operation rolled back.');
      }

      // 2. Update stock quantity
      await txn.rawUpdate(
        'UPDATE products SET stock_quantity = ? WHERE id = ?',
        [newStock, productId],
      );
    });
  }

  Future<void> deleteProduct(int id) async {
    final db = await instance.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. PRESENTATION LAYER
// ─────────────────────────────────────────────────────────────────────────────

class InventoryLedgerApp extends StatelessWidget {
  final InventoryDatabaseHelper dbHelper;
  const InventoryLedgerApp({super.key, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Relational Ledger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blueGrey,
        useMaterial3: true,
      ),
      home: InventoryScreen(dbHelper: dbHelper),
    );
  }
}

class InventoryScreen extends StatefulWidget {
  final InventoryDatabaseHelper dbHelper;
  const InventoryScreen({super.key, required this.dbHelper});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<ProductItem>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = widget.dbHelper.getAllProductsWithCategory();
    });
  }

  Future<void> _adjustStock(ProductItem item, int delta) async {
    try {
      await widget.dbHelper.adjustStockAtomic(productId: item.id, delta: delta);
      _refreshProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relational Inventory (SQLite)'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ProductItem>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Database Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('No products in database.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.categoryName.toUpperCase(),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800),
                            ),
                          ),
                          Text(
                            product.sku,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unit Price: \$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.inventory_rounded, size: 18, color: Colors.teal),
                              const SizedBox(width: 6),
                              Text(
                                'In Stock: ${product.stockQuantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton.filledTonal(
                                icon: const Icon(Icons.remove, size: 16),
                                onPressed: () => _adjustStock(product, -1),
                                tooltip: 'Decrement Stock',
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: () => _adjustStock(product, 1),
                                tooltip: 'Increment Stock',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

## 💡 Deep-Dive Materials Included

* **3 Interview Prep Scenarios** included
* **Technology Comparisons:** SQLite (Raw sqflite) vs Drift vs Hive
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[⬅️ Day 36: Local Key-Value, Secure & NoSQL Storage Engines](../Day-36/README.md) | [📂 Module Index](../README.md) | [Day 38: Offline-First Repository Pattern, Caching & Data Sync ➡️](../Day-38/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

