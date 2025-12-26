import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final String? barcode;

  const ProductFormScreen({super.key, this.product, this.barcode});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _barcodeController;
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _unitPriceController;
  late TextEditingController _taxRateController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController(text: widget.product?.barcodeNo ?? widget.barcode ?? "");
    _nameController = TextEditingController(text: widget.product?.productName ?? "");
    _categoryController = TextEditingController(text: widget.product?.category ?? "");
    _unitPriceController = TextEditingController(text: widget.product?.unitPrice.toString() ?? "");
    _taxRateController = TextEditingController(text: widget.product?.taxRate.toString() ?? "");
    _stockController = TextEditingController(text: widget.product?.stockInfo?.toString() ?? "");
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final unitPrice = double.parse(_unitPriceController.text);
      final taxRate = int.parse(_taxRateController.text);

      final totalPrice = unitPrice + (unitPrice * taxRate / 100);

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
        provider.addProduct(newProduct).then((_) {
          Navigator.pop(context); // İşlem bitince geri dön.
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Barcode already exists!")),
          );
        });
      } else {
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
        title: Text(widget.product == null ? "Add New Product" : "Edit Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
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
    _barcodeController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _unitPriceController.dispose();
    _taxRateController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}