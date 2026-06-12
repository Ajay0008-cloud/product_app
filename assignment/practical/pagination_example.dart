import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Part 3: Question 2
/// Implement pagination in Flutter.
/// 
/// This is a simple, easy-to-understand implementation using:
/// 1. A ScrollController to listen for scroll events.
/// 2. Offset/limit parameters in the API call.
/// 3. A loading indicator at the bottom of the list when fetching the next page.

class PaginatedListExample extends StatefulWidget {
  const PaginatedListExample({super.key});

  @override
  State<PaginatedListExample> createState() => _PaginatedListExampleState();
}

class _PaginatedListExampleState extends State<PaginatedListExample> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _items = [];
  
  bool _isLoading = false;      // True when fetching initial page or new page
  int _currentPage = 0;         // Tracks page index
  final int _pageSize = 15;     // Number of items to fetch per page
  bool _hasMore = true;         // True if there is more data to fetch

  @override
  void initState() {
    super.initState();
    _fetchNextPage();
    // Listen to scroll movements
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Listener called when user scrolls
  void _onScroll() {
    // Check if user has scrolled to the bottom of the list
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _fetchNextPage();
    }
  }

  // Fetch items for the next page from mock API
  Future<void> _fetchNextPage() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network request delay
      await Future.delayed(const Duration(seconds: 1));

      // Fetch from DummyJSON API using limit and skip
      final int skip = _currentPage * _pageSize;
      final response = await http.get(
        Uri.parse('https://dummyjson.com/products?limit=$_pageSize&skip=$skip'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> products = data['products'] ?? [];
        
        setState(() {
          _currentPage++;
          // Extract product titles to show in the list
          for (var item in products) {
            _items.add(item['title'] as String);
          }
          // If returned items count is less than page size, no more pages exist
          if (products.length < _pageSize) {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      debugPrint('Pagination Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paginated List')),
      body: _items.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _items.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                // If it is the last item, show a loading spinner at the bottom
                if (index == _items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return ListTile(
                  title: Text(_items[index]),
                  leading: CircleAvatar(child: Text('${index + 1}')),
                );
              },
            ),
    );
  }
}
