import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'inventory.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // SQL komutu ile tabloyu oluşturuyoruz
        await db.execute('''
          CREATE TABLE ProductTable (
            barcodeNo TEXT PRIMARY KEY,
            productName TEXT NOT NULL,
            category TEXT NOT NULL,
            unitPrice REAL NOT NULL,
            taxRate INTEGER NOT NULL,
            price REAL NOT NULL,
            stockInfo INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('ProductTable', product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ProductTable');
    return maps.map((item) => Product.fromMap(item)).toList();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ProductTable',
      where: 'barcodeNo = ?',
      whereArgs: [barcode],
    );
    if (maps.isNotEmpty) return Product.fromMap(maps.first);
    return null;
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'ProductTable',
      product.toMap(),
      where: 'barcodeNo = ?',
      whereArgs: [product.barcodeNo],
    );
  }

  Future<int> deleteProduct(String barcode) async {
    final db = await database;
    return await db.delete(
      'ProductTable',
      where: 'barcodeNo = ?',
      whereArgs: [barcode],
    );
  }
}