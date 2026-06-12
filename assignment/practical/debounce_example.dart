import 'dart:async';

/// Part 3: Question 3
/// Write a Dart function to debounce user input (search optimization).
/// 
/// Debouncing ensures that a function is not called immediately. 
/// Instead, it waits for a specified delay (e.g. 500ms) after the user has stopped typing.
/// If the user types a new character before the delay ends, the timer resets.

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// Runs the provided action callback after the configured delay.
  /// If run() is called again before the timer expires, the previous timer is canceled.
  void run(void Function() action) {
    // 1. Cancel the previous timer if it exists
    _timer?.cancel();
    
    // 2. Start a new timer with the configured delay duration
    _timer = Timer(delay, action);
  }

  /// Cancels any active timer to clean up resources (e.g., when disposing a widget)
  void dispose() {
    _timer?.cancel();
  }
}

// Example of usage in a Flutter Search Bar:
/*
class SearchBarExample extends StatefulWidget {
  const SearchBarExample({super.key});

  @override
  State<SearchBarExample> createState() => _SearchBarExampleState();
}

class _SearchBarExampleState extends State<SearchBarExample> {
  // Create a debouncer instance with a 500ms delay
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  void _onSearchChanged(String query) {
    // Trigger the search query api call after user stops typing for 500ms
    _debouncer.run(() {
      print('API Called for query: $query');
      // trigger fetch request...
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: _onSearchChanged,
      decoration: const InputDecoration(
        hintText: 'Search...',
      ),
    );
  }
}
*/
