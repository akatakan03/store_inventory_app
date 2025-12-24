import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_form_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Arama çubuğu için controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ekran açıldığında verileri yüklemesi için tetikliyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  // Arama butonuna basıldığında çalışan mantık
  void _onSearch() async {
    final barcode = _searchController.text.trim();
    if (barcode.isEmpty) return;

    final provider = context.read<ProductProvider>();
    final foundProduct = await provider.searchProduct(barcode);

    // Eğer ürün bulunamadıysa ödevde istenen diyaloğu gösteriyoruz
    if (foundProduct == null && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Product not found"),
          content: const Text("Would you like to add a new product?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Yeni ekleme sayfasına barkodu göndererek gidiyoruz
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(barcode: barcode),
                  ),
                );
              },
              child: const Text("Add Product"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory Management"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // ÜST KISIM: Barkod Arama Formu
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: "Enter Barcode Number",
                          prefixIcon: Icon(Icons.qr_code_scanner),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _onSearch,
                      icon: const Icon(Icons.search, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ALT KISIM: Ürün Listesi (Grid Layout benzeri ListView)
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.products.isEmpty) {
                    return const Center(child: Text("No products found in database."));
                  }
                  return ListView.builder(
                    itemCount: provider.products.length,
                    itemBuilder: (context, index) {
                      final product = provider.products[index];
                      // Aranan ürün mü kontrolü (Highlighting)
                      bool isHighlighted = provider.highlightedBarcode == product.barcodeNo;

                      return Card(
                        color: isHighlighted ? Colors.blue.shade50 : null,
                        elevation: isHighlighted ? 8 : 2,
                        shape: RoundedRectangleBorder(
                          side: isHighlighted
                              ? const BorderSide(color: Colors.blue, width: 2)
                              : BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            "Barcode: ${product.barcodeNo}\nPrice: \$${product.price.toStringAsFixed(2)} | Stock: ${product.stockInfo ?? 'N/A'}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit butonu
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductFormScreen(product: product),
                                    ),
                                  );
                                },
                              ),
                              // Delete butonu
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(context, product.barcodeNo),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Sağ alttaki hızlı ekleme butonu
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Silme onayı için Dialog gösterir
  void _confirmDelete(BuildContext context, String barcode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text("This action will delete the product permanently."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              context.read<ProductProvider>().deleteProduct(barcode);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}