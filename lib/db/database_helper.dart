import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/product.dart';
import '../models/sale.dart';
import '../models/inventory_transaction.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hypermarket.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price INTEGER,
            stock INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE sales(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER,
            quantity INTEGER,
            price INTEGER,
            total INTEGER,
            created_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE inventory_transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER,
            type TEXT,
            quantity INTEGER,
            created_at TEXT
          )
        ''');
      },
    );
  }

  // ---------------- PRODUCTS ----------------

  Future<List<Product>> getProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert('products', product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // ---------------- SALES ----------------

  Future<void> insertSale(Sale sale) async {
    final db = await database;
    await db.insert('sales', sale.toMap());
  }

  Future<List<Sale>> getSales() async {
    final db = await database;
    final maps =
        await db.query('sales', orderBy: 'created_at DESC');
    return maps.map((e) => Sale.fromMap(e)).toList();
  }

  // ---------------- INVENTORY ----------------

  Future<List<InventoryTransaction>> getTransactionsByProduct(
      int productId) async {
    final db = await database;
    final maps = await db.query(
      'inventory_transactions',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
    return maps
        .map((e) => InventoryTransaction.fromMap(e))
        .toList();
  }
}
  