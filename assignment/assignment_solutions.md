# 📝 Flutter Internship Assignment - Part 2 & Part 3 Solutions

This document contains detailed solutions for **Part 2 (DSA Questions)** and **Part 3 (Practical Coding Questions)** of the assignment.

---

## 🚀 Part 2: DSA Questions

### Q1: Two Sum Variant (O(N) Complexity)
**Problem**: Given an array and a target, return indices of two numbers such that sum = target. Optimize from $O(n^2)$ to $O(n)$.

#### 💡 Solution Explanation
By using a **HashMap** (or `Map` in Dart), we can keep track of the numbers we have already scanned and their index positions. For each number `x` in the array, we check if its complement (`target - x`) already exists in the map.
- If it exists, we found our pair and return their indices.
- If not, we store the current number and its index in the map and continue.
This reduces the time complexity from $O(N^2)$ (nested loops) to **$O(N)$** because map lookups and insertions take $O(1)$ on average.

#### 💻 Dart Implementation (`assignment/dsa/dsa_solutions.dart`)
```dart
List<int> twoSum(List<int> nums, int target) {
  final Map<int, int> map = {};
  for (int i = 0; i < nums.length; i++) {
    final int complement = target - nums[i];
    if (map.containsKey(complement)) {
      return [map[complement]!, i];
    }
    map[nums[i]] = i;
  }
  return []; // Return empty if no solution
}
```

---

### Q2: Longest Substring Without Repeating Characters
**Problem**: Find the length of the longest substring without repeating characters. E.g., Input: `"abcabcbb"` $\rightarrow$ Output: `3` (`"abc"`).

#### 💡 Solution Explanation
We use the **Sliding Window** technique with a hash set (or map) to track characters in the current window.
1. Maintain two pointers (`left` and `right`) defining the bounds of the current substring.
2. Expand the window by moving `right` pointer and adding characters to a `Set`.
3. If a duplicate character is encountered, shrink the window from the left by moving `left` pointer forward and removing characters from the `Set` until the duplicate is removed.
4. Keep track of the maximum window size.
This runs in **$O(N)$ time** since each character is visited at most twice.

#### 💻 Dart Implementation (`assignment/dsa/dsa_solutions.dart`)
```dart
int lengthOfLongestSubstring(String s) {
  int maxLength = 0;
  int left = 0;
  final Set<String> charSet = {};

  for (int right = 0; right < s.length; right++) {
    final char = s[right];
    while (charSet.contains(char)) {
      charSet.remove(s[left]);
      left++;
    }
    charSet.add(char);
    maxLength = maxLength > (right - left + 1) ? maxLength : (right - left + 1);
  }
  return maxLength;
}
```

---

## 🛠️ Part 3: Practical Coding Questions (Flutter / Dart / Java)

### 1. Call an API and Display Data in a List (Flutter)
A simple clean implementation showing how to fetch dynamic JSON list items, map them to objects, and display them in a list with error handling and loading indicators.
*Ref: See full implementation in [assignment/practical/api_list_example.dart](file:///Users/ajaychauhan/Downloads/product_app/assignment/practical/api_list_example.dart).*

---

### 2. Implement Pagination in Flutter
Using a `ScrollController` listener, we append items dynamically when the user reaches the end of the scroll list.
*Ref: See full implementation in [assignment/practical/pagination_example.dart](file:///Users/ajaychauhan/Downloads/product_app/assignment/practical/pagination_example.dart).*

---

### 3. Dart Debouncer Function (Search Optimization)
Debouncing delays a function call until a certain amount of silence has elapsed, preventing unnecessary requests on every keystroke.
*Ref: See full implementation in [assignment/practical/debounce_example.dart](file:///Users/ajaychauhan/Downloads/product_app/assignment/practical/debounce_example.dart).*

---

### 4. Java String Reversal (Without built-in methods)
Reverses a string manually by converting it to a character array and swapping characters from start to end.
*Ref: See full implementation in [assignment/practical/StringReversal.java](file:///Users/ajaychauhan/Downloads/product_app/assignment/practical/StringReversal.java).*

```java
public class StringReversal {
    public static String reverse(String str) {
        if (str == null) return null;
        char[] chars = str.toCharArray();
        int left = 0;
        int right = chars.length - 1;
        while (left < right) {
            char temp = chars[left];
            chars[left] = chars[right];
            chars[right] = temp;
            left++;
            right--;
        }
        return new String(chars);
    }
}
```

---

### 5. Java Duplicate Finder in Array
Identifies duplicate elements in an array using a `HashSet` for $O(N)$ time complexity.
*Ref: See full implementation in [assignment/practical/DuplicateFinder.java](file:///Users/ajaychauhan/Downloads/product_app/assignment/practical/DuplicateFinder.java).*

```java
import java.util.HashSet;
import java.util.ArrayList;
import java.util.List;

public class DuplicateFinder {
    public static List<Integer> findDuplicates(int[] nums) {
        HashSet<Integer> seen = new HashSet<>();
        HashSet<Integer> duplicates = new HashSet<>();
        for (int num : nums) {
            if (!seen.add(num)) {
                duplicates.add(num);
            }
        }
        return new ArrayList<>(duplicates);
    }
}
```
