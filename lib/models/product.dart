// Ürün verilerini temsil eden sınıfımız (Data Model)
class Product {
  // Barkod numarası, birincil anahtar (primary key) olacak
  final String barcodeNo;
  // Ürün adı
  final String productName;
  // Kategori bilgisi
  final String category;
  // Birim fiyat (KDV hariç)
  final double unitPrice;
  // Vergi oranı (%)
  final int taxRate;
  // Toplam fiyat (KDV dahil hesaplanmış hali)
  final double price;
  // Stok bilgisi (opsiyonel/null olabilir)
  final int? stockInfo;

  // Yapıcı metod (Constructor)
  Product({
    required this.barcodeNo,
    required this.productName,
    required this.category,
    required this.unitPrice,
    required this.taxRate,
    required this.price,
    this.stockInfo,
  });

  // Veritabanına kaydetmek için nesneyi Map formatına dönüştürür (Serialization)
  Map<String, dynamic> toMap() {
    return {
      'barcodeNo': barcodeNo,
      'productName': productName,
      'category': category,
      'unitPrice': unitPrice,
      'taxRate': taxRate,
      'price': price,
      'stockInfo': stockInfo,
    };
  }

  // Veritabanından gelen Map verisini nesneye dönüştürür (Deserialization)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      barcodeNo: map['barcodeNo'],
      productName: map['productName'],
      category: map['category'],
      unitPrice: (map['unitPrice'] as num).toDouble(),
      taxRate: map['taxRate'],
      price: (map['price'] as num).toDouble(),
      stockInfo: map['stockInfo'],
    );
  }
}