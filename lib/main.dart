import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/cart_screen.dart';
import 'models/product.dart';

// uygulamanın en basındayız
void main() {
  runApp(const MyApp());
}

// ana uyg widget'ı
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Katalog',
      debugShowCheckedModeBanner: false, //debug bandını gizle
      //uyg teması mint kullanmak istedim
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4DB6AC),
          primary: const Color(0xFF4DB6AC),
        ),
        useMaterial3: true,
        fontFamily: 'Georgia',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontWeight: FontWeight.w300),
          bodyMedium: TextStyle(fontWeight: FontWeight.w300),
          titleLarge: TextStyle(fontWeight: FontWeight.w400),
        ),
      ),
      // baslangıc teması
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          // anasayfa
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        } else if (settings.name == '/detail') {
          // detay sayfası
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (_) => DetailScreen(product: product),
          );
        } else if (settings.name == '/cart') {
          // sepet sayfası
          final cart = settings.arguments as List<Product>;
          return MaterialPageRoute(
            builder: (_) => CartScreen(cartItems: cart),
          );
        }
        return null;
      },
    );
  }
}
