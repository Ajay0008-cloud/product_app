import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';

  /// Fetches products from dummyjson.
  /// Supports pagination using [limit] and [skip].
  /// Supports [search] query and [category] filter.
  Future<Map<String, dynamic>> fetchProducts({
    int limit = 20,
    int skip = 0,
    String search = '',
    String category = '',
  }) async {
    Uri url;
    if (search.isNotEmpty) {
      url = Uri.parse('$baseUrl/products/search?q=${Uri.encodeComponent(search)}&limit=$limit&skip=$skip');
    } else if (category.isNotEmpty) {
      url = Uri.parse('$baseUrl/products/category/${Uri.encodeComponent(category)}&limit=$limit&skip=$skip');
    } else {
      url = Uri.parse('$baseUrl/products?limit=$limit&skip=$skip');
    }

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'] ?? [];
        final List<Product> products = productsJson.map((json) => Product.fromJson(json)).toList();
        final int total = data['total'] ?? 0;

        return {
          'products': products,
          'total': total,
        };
      } else {
        throw Exception('Failed to load products: Server responded with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetches list of categories.
  /// Returns a list of maps containing 'slug' and 'name'.
  Future<List<Map<String, String>>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/products/categories');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<Map<String, String>>((item) {
          if (item is Map) {
            return {
              'slug': (item['slug'] as String? ?? '').toString(),
              'name': (item['name'] as String? ?? '').toString(),
            };
          } else {
            // Fallback if structure changes
            final str = item.toString();
            return {
              'slug': str,
              'name': str[0].toUpperCase() + str.substring(1),
            };
          }
        }).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
}
