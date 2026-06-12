// ignore_for_file: avoid_print

// Part 2: DSA Questions

// Q1: Two Sum Variant
// Given an array and a target, return indices of two numbers such that sum = target.
// Time Complexity: O(n) using a Map (HashMap lookup is O(1))
// Space Complexity: O(n) to store seen elements in the map
List<int> twoSum(List<int> nums, int target) {
  final Map<int, int> map = {};
  for (int i = 0; i < nums.length; i++) {
    final int complement = target - nums[i];
    if (map.containsKey(complement)) {
      return [map[complement]!, i];
    }
    map[nums[i]] = i;
  }
  return []; // Return empty if no pair is found
}

/// Q2: Longest Substring Without Repeating Characters
/// Time Complexity: O(n) using the Sliding Window technique
/// Space Complexity: O(min(m, n)) for the Set containing unique characters
int lengthOfLongestSubstring(String s) {
  int maxLength = 0;
  int left = 0;
  final Set<String> charSet = {};

  for (int right = 0; right < s.length; right++) {
    final String char = s[right];
    while (charSet.contains(char)) {
      // Shrink window from the left
      charSet.remove(s[left]);
      left++;
    }
    charSet.add(char);
    // Track maximum length
    final int currentLength = right - left + 1;
    if (currentLength > maxLength) {
      maxLength = currentLength;
    }
  }
  return maxLength;
}

/// Main method to demonstrate and test the DSA solutions
void main() {
  print('--- Testing Two Sum Variant ---');
  final nums = [2, 7, 11, 15];
  final target = 9;
  print('Array: $nums, Target: $target');
  print('Result Indices: ${twoSum(nums, target)}'); // Expected: [0, 1]

  print('\n--- Testing Longest Substring Without Repeating Characters ---');
  final inputStr = 'abcabcbb';
  print('Input String: "$inputStr"');
  print('Longest Substring Length: ${lengthOfLongestSubstring(inputStr)}'); // Expected: 3
}
