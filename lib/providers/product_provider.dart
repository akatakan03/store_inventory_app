import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/database_service.dart';

// ChangeNotifier sınıfından türeterek state management yeteneği kazanır
class ProductProvider with ChangeNotifier {
  // Veritabanı servisine erişim için instance alırız
  final DatabaseService _dbService = DatabaseService();

  // Uygulama içindeki ürün listesini tutan private değişken
  List<Product> _products = [];

  // Arama sonucunda filtrelenmiş barkodu tutar
  String? _highlightedBarcode;

  // Dışarıya ürün listesini açan getter
  List<Product> get products => _products;

  // Vurgulanacak barkodu veren getter
  String? get highlightedBarcode => _highlightedBarcode;

  // Tüm ürünleri veritabanından çekip listeyi güncelleyen metod
  Future<void> loadProducts() async {
    // Veritabanından verileri asenkron olarak çeker
    _products = await _dbService.getAllProducts();
    // Dinleyen tüm widget'lara arayüzü güncellemeleri gerektiğini haber verir
    notifyListeners();
  }

  // Yeni ürün ekleme işlevi
  Future<void> addProduct(Product product) async {
    await _dbService.insertProduct(product);
    // Ekleme sonrası listeyi yeniden yükleriz
    await loadProducts();
  }

  // Ürün güncelleme işlevi
  Future<void> updateProduct(Product product) async {
    await _dbService.updateProduct(product);
    await loadProducts();
  }

  // Ürün silme işlevi
  Future<void> deleteProduct(String barcode) async {
    await _dbService.deleteProduct(barcode);
    await loadProducts();
  }

  // Barkod ile ürün arama işlevi
  Future<Product?> searchProduct(String barcode) async {
    final result = await _dbService.getProductByBarcode(barcode);
    if (result != null) {
      // Eğer ürün bulunursa, o barkodu vurgulamak için saklarız
      _highlightedBarcode = barcode;
    } else {
      _highlightedBarcode = null;
    }
    notifyListeners();
    return result;
  }

  // Vurguyu temizleme metodu
  void clearHighlight() {
    _highlightedBarcode = null;
    notifyListeners();
  }
}