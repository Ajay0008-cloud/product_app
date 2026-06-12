import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Part 3: Question 1
/// Write code to call an API and display data in a list (Flutter).

// 1. Simple Data Model representing an item
class ProductItem {
  final int id;
  final String title;
  final double price;

  ProductItem({required this.id, required this.title, required this.price});

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// 2. StatefulWidget displaying the list
class ApiListExample extends StatefulWidget {
  const ApiListExample({super.key});

  @override
  State<ApiListExample> createState() => _ApiListExampleState();
}

class _ApiListExampleState extends State<ApiListExample> {
  List<ProductItem> _products = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Method to trigger network GET request
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/products?limit=10'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'] ?? [];
        
        setState(() {
          _products = productsJson.map((json) => ProductItem.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API List Example')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _fetchProducts, child: const Text('Retry')),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ListTile(
                      title: Text(product.title),
                      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                      leading: CircleAvatar(child: Text('${index + 1}')),
                    );
                  },
                ),
    );
  }
}
