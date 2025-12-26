import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Product> _products = [];

  String? _highlightedBarcode;

  List<Product> get products => _products;

  String? get highlightedBarcode => _highlightedBarcode;

  Future<void> loadProducts() async {
    _products = await _dbService.getAllProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _dbService.insertProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _dbService.updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(String barcode) async {
    await _dbService.deleteProduct(barcode);
    await loadProducts();
  }

  Future<Product?> searchProduct(String barcode) async {
    final result = await _dbService.getProductByBarcode(barcode);
    if (result != null) {
      _highlightedBarcode = barcode;
    } else {
      _highlightedBarcode = null;
    }
    notifyListeners();
    return result;
  }

  void clearHighlight() {
    _highlightedBarcode = null;
    notifyListeners();
  }
}