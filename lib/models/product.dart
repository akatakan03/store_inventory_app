class Product {
  final String barcodeNo;
  final String productName;
  final String category;
  final double unitPrice;
  final int taxRate;
  final double price;
  final int? stockInfo;

  Product({
    required this.barcodeNo,
    required this.productName,
    required this.category,
    required this.unitPrice,
    required this.taxRate,
    required this.price,
    this.stockInfo,
  });

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