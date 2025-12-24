import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'screens/main_screen.dart';

void main() {
  // Uygulama başlamadan önce Provider'ları sisteme tanıtıyoruz
  runApp(
    MultiProvider(
      providers: [
        // ProductProvider'ı tüm Widget Tree için erişilebilir kılıyoruz
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Uygulama başlığı
      title: 'Store Inventory',
      // Debug bandını kaldırıyoruz
      debugShowCheckedModeBanner: false,
      // Modern bir Material 3 teması kullanıyoruz
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // Başlangıç ekranı olarak MainScreen'i belirliyoruz
      home: const MainScreen(),
    );
  }
}