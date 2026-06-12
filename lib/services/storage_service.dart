import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class StorageService {
  static const String _wishlistKey = 'wishlist_product_ids';
  static const String _cachedProductsKey = 'cached_products_list';

  /// Save wishlist to local storage
  Future<void> saveWishlist(Set<int> productIds) async {
    final prefs = await SharedPreferences.getInstance();
    final stringIds = productIds.map((id) => id.toString()).toList();
    await prefs.setStringList(_wishlistKey, stringIds);
  }

  /// Get wishlist from local storage
  Future<Set<int>> getWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final stringIds = prefs.getStringList(_wishlistKey) ?? [];
    return stringIds.map((id) => int.parse(id)).toSet();
  }

  /// Cache products to local storage for offline support
  Future<void> cacheProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((product) => product.toJson()).toList();
    await prefs.setString(_cachedProductsKey, json.encode(jsonList));
  }

  /// Load cached products from local storage
  Future<List<Product>> getCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_cachedProductsKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = json.decode(jsonStr);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
