import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class WishlistViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  Set<int> _wishlistedIds = {};

  Set<int> get wishlistedIds => _wishlistedIds;

  WishlistViewModel() {
    _loadWishlist();
  }

  /// Loads wishlist from local storage
  Future<void> _loadWishlist() async {
    _wishlistedIds = await _storageService.getWishlist();
    notifyListeners();
  }

  /// Check if a product is in the wishlist
  bool isWishlisted(int productId) {
    return _wishlistedIds.contains(productId);
  }

  /// Toggle wishlist status of a product
  Future<void> toggleWishlist(int productId) async {
    if (_wishlistedIds.contains(productId)) {
      _wishlistedIds.remove(productId);
    } else {
      _wishlistedIds.add(productId);
    }
    notifyListeners();
    await _storageService.saveWishlist(_wishlistedIds);
  }
}
