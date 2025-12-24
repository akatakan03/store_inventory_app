import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

// Ürün ekleme ve düzenleme işlemlerini tek bir form üzerinden yöneteceğiz.
class ProductFormScreen extends StatefulWidget {
  // Eğer bu değişken dolu gelirse 'Düzenleme' modundayız demektir.
  final Product? product;
  // Arama sonucunda bulunamayan bir barkod ile gelinmişse buraya aktarılır.
  final String? barcode;

  const ProductFormScreen({super.key, this.product, this.barcode});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  // Formun durumunu ve validasyonunu (validation) kontrol etmek için anahtar.
  final _formKey = GlobalKey<FormState>();

  // Girdi alanlarını kontrol etmek için controller nesneleri.
  late TextEditingController _barcodeController;
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _unitPriceController;
  late TextEditingController _taxRateController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    // Gelen veriye göre controller'ları ilklendiriyoruz (initialization).
    _barcodeController = TextEditingController(text: widget.product?.barcodeNo ?? widget.barcode ?? "");
    _nameController = TextEditingController(text: widget.product?.productName ?? "");
    _categoryController = TextEditingController(text: widget.product?.category ?? "");
    _unitPriceController = TextEditingController(text: widget.product?.unitPrice.toString() ?? "");
    _taxRateController = TextEditingController(text: widget.product?.taxRate.toString() ?? "");
    _stockController = TextEditingController(text: widget.product?.stockInfo?.toString() ?? "");
  }

  // Kaydetme butonuna basıldığında çalışan fonksiyon.
  void _saveForm() {
    // Formdaki tüm alanların geçerli olup olmadığını kontrol eder (validate).
    if (_formKey.currentState!.validate()) {
      final unitPrice = double.parse(_unitPriceController.text);
      final taxRate = int.parse(_taxRateController.text);

      // Ödevde istenen toplam fiyat (price) hesaplaması: unitPrice + KDV
      final totalPrice = unitPrice + (unitPrice * taxRate / 100);

      // Yeni ürün nesnesini oluşturuyoruz.
      final newProduct = Product(
        barcodeNo: _barcodeController.text,
        productName: _nameController.text,
        category: _categoryController.text,
        unitPrice: unitPrice,
        taxRate: taxRate,
        price: totalPrice,
        stockInfo: _stockController.text.isEmpty ? null : int.parse(_stockController.text),
      );

      final provider = context.read<ProductProvider>();

      if (widget.product == null) {
        // Eğer ürün yoksa yeni ekleme yapıyoruz.
        provider.addProduct(newProduct).then((_) {
          Navigator.pop(context); // İşlem bitince geri dön.
        }).catchError((error) {
          // Hata durumunda kullanıcıya bilgi veriyoruz (örn: Duplicate Barcode).
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Barcode already exists!")),
          );
        });
      } else {
        // Eğer ürün varsa güncelleme yapıyoruz.
        provider.updateProduct(newProduct).then((_) {
          Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Modu başlığa yansıtıyoruz.
        title: Text(widget.product == null ? "Add New Product" : "Edit Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Kullanıcı girişlerini yönetmek için Form widget'ı.
        child: Form(
          key: _formKey,
          // Küçük ekranlarda taşmayı önlemek için kaydırılabilir alan.
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Barkod alanı: Düzenleme modunda değiştirilemez (disabled) olmalı.
                TextFormField(
                  controller: _barcodeController,
                  enabled: widget.product == null,
                  decoration: const InputDecoration(labelText: "Barcode Number*", border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? "Required field" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Product Name*", border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? "Required field" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: "Category*", border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? "Required field" : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _unitPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Unit Price*", border: OutlineInputBorder()),
                        validator: (value) => double.tryParse(value!) == null ? "Enter valid number" : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _taxRateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Tax Rate (%)*", border: OutlineInputBorder()),
                        validator: (value) => int.tryParse(value!) == null ? "Enter valid integer" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stok bilgisi opsiyonel (null olabilir).
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Stock Info (Optional)", border: OutlineInputBorder()),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (int.tryParse(value) == null || int.parse(value) < 0) {
                        return "Cannot be negative";
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Kaydet ve İptal butonları.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      child: const Text("Save Product"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Bellek sızıntısını (memory leak) önlemek için controller nesnelerini temizliyoruz.
    _barcodeController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _unitPriceController.dispose();
    _taxRateController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}