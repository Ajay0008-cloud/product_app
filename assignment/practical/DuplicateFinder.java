package assignment.practical;

import java.util.HashSet;
import java.util.ArrayList;
import java.util.List;

/**
 * Part 3: Question 5
 * Write a Java program to find duplicate elements in an array.
 * 
 * We use a HashSet to keep track of elements we've seen.
 * HashSets do not allow duplicates. If set.add(item) returns false, 
 * it means the item already exists in the set and is a duplicate.
 * 
 * Time Complexity: O(n) - Single pass through the array.
 * Space Complexity: O(n) - To store unique elements in the set.
 */
public class DuplicateFinder {

    public static List<Integer> findDuplicates(int[] nums) {
        List<Integer> duplicates = new ArrayList<>();
        HashSet<Integer> seenElements = new HashSet<>();

        for (int num : nums) {
            // set.add() returns false if the item was already present in the set
            if (!seenElements.add(num)) {
                // If it's a duplicate and not already added to duplicates list, add it
                if (!duplicates.contains(num)) {
                    duplicates.add(num);
                }
            }
        }
        return duplicates;
    }

    // Main method to test the duplicate finder function
    public static void main(String[] args) {
        int[] arr = {1, 2, 3, 2, 4, 5, 1, 6, 2};
        List<Integer> dupList = findDuplicates(arr);
        
        System.out.println("Array elements: ");
        for (int num : arr) {
            System.out.print(num + " ");
        }
        System.out.println("\nDuplicate elements: " + dupList); // Expected: [2, 1]
    }
}
