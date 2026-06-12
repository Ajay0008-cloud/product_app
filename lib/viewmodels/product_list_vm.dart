import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProductListViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  List<Product> _products = [];
  List<Map<String, String>> _categories = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _error = '';
  
  // Pagination
  int _skip = 0;
  final int _limit = 20;
  int _total = 0;

  // Filters
  String _searchQuery = '';
  String _selectedCategory = ''; // Empty means "All"
  double _minPrice = 0.0;
  double _maxPrice = 2000.0; // Dynamic or set default high ceiling

  // Debouncing for search
  Timer? _searchDebounce;

  // Getters
  List<Product> get products => _products;
  List<Map<String, String>> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;

  bool get hasMore => _products.length < _total;

  ProductListViewModel() {
    initialize();
  }

  /// Initial setup: Load cache first, then fetch live data and categories.
  Future<void> initialize() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    // 1. Load from cache first for instant load
    final cached = await _storageService.getCachedProducts();
    if (cached.isNotEmpty) {
      _products = cached;
      _isLoading = false;
      notifyListeners();
    }

    // 2. Fetch fresh categories & products concurrently
    await Future.wait([
      fetchCategories(),
      refreshProducts(),
    ]);
  }

  /// Fetch all product categories from the API
  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await _apiService.fetchCategories();
      _categories = [
        {'slug': '', 'name': 'All'}, // Prepend the "All" option
        ...fetchedCategories,
      ];
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  /// Pull-to-refresh or initial live load
  Future<void> refreshProducts() async {
    _skip = 0;
    _error = '';
    
    // Only show full loading if we don't have cached data already showing
    if (_products.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final result = await _apiService.fetchProducts(
        limit: _limit,
        skip: _skip,
        search: _searchQuery,
        category: _selectedCategory,
      );

      _products = result['products'] as List<Product>;
      _total = result['total'] as int;

      // Cache the first page of products if search and category are empty
      if (_searchQuery.isEmpty && _selectedCategory.isEmpty) {
        await _storageService.cacheProducts(_products);
      }
    } catch (e) {
      // If we have cached products showing, don't override with error unless it's a hard fail
      if (_products.isEmpty) {
        _error = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more products for infinite scroll
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    _skip += _limit;

    try {
      final result = await _apiService.fetchProducts(
        limit: _limit,
        skip: _skip,
        search: _searchQuery,
        category: _selectedCategory,
      );

      final newProducts = result['products'] as List<Product>;
      _products.addAll(newProducts);
      _total = result['total'] as int;
    } catch (e) {
      _skip -= _limit; // Revert skip on error
      debugPrint('Error loading more products: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Change the search query (with a 500ms debounce)
  void updateSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      refreshProducts();
    });
  }

  /// Select a category filter
  void selectCategory(String categorySlug) {
    if (_selectedCategory == categorySlug) return;
    _selectedCategory = categorySlug;
    refreshProducts();
  }

  /// Apply price range filters locally
  void updatePriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedCategory = '';
    _searchQuery = '';
    _minPrice = 0.0;
    _maxPrice = 2000.0;
    refreshProducts();
  }

  /// Filtered product list based on client-side price range
  List<Product> get filteredProducts {
    return _products.where((product) {
      final price = product.price;
      return price >= _minPrice && price <= _maxPrice;
    }).toList();
  }
}
