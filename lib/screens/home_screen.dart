import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  List<Product> _filtered = [];
  List<Product> _cart = [];
  bool _loading = true;
  String _selectedCategory = 'Tümü';
  String _searchQuery = '';

  final List<String> _categories = [
    'Tümü',
    'electronics',
    'jewelery',
    "men's clothing",
    "women's clothing",
  ];

  final Map<String, String> _categoryNames = {
    'Tümü': 'Tümü',
    'electronics': 'Elektronik',
    'jewelery': 'Mücevher',
    "men's clothing": 'Erkek Giyim',
    "women's clothing": 'Kadın Giyim',
  };

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products'),
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _products = data.map((e) => Product.fromJson(e)).toList();
          _filtered = _products;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filtered = _products.where((p) {
        final matchCategory =
            _selectedCategory == 'Tümü' || p.category == _selectedCategory;
        final matchSearch =
            p.title.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchCategory && matchSearch;
      }).toList();
    });
  }

  void _filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _onSearch(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _addToCart(Product product) {
    setState(() => _cart.add(product));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${product.title} sepete eklendi!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4DB6AC),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Keşfet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/cart',
                  arguments: _cart,
                ),
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${_cart.length}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Ürün ara...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4DB6AC)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // Kategori butonları
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: ElevatedButton(
                    onPressed: () => _filterByCategory(cat),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? const Color(0xFF4DB6AC)
                          : Colors.grey[200],
                      foregroundColor:
                          isSelected ? Colors.white : Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _categoryNames[cat] ?? cat,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),
          // Ürün listesi
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('Ürün bulunamadı.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => ProductCard(
                          product: _filtered[i],
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/detail',
                            arguments: _filtered[i],
                          ),
                          onAddToCart: () => _addToCart(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
