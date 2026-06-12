package assignment.practical;

/**
 * Part 3: Question 4
 * Write a Java function to reverse a string without using built-in methods.
 * 
 * We convert the string to a character array and swap characters 
 * from the two ends (start and end pointers) moving towards the center.
 */
public class StringReversal {

    public static String reverseString(String input) {
        // Handle null input case
        if (input == null) {
            return null;
        }

        // Convert the string to a character array
        char[] chars = input.toCharArray();
        
        // Pointers for swapping
        int start = 0;
        int end = chars.length - 1;

        // Loop until pointers meet in the middle
        while (start < end) {
            // Swap characters at start and end indices
            char temp = chars[start];
            chars[start] = chars[end];
            chars[end] = temp;

            // Move pointers closer to the center
            start++;
            end--;
        }

        // Convert the character array back to a String and return
        return new String(chars);
    }

    // Main method to test the string reversal function
    public static void main(String[] args) {
        String original = "hello";
        String reversed = reverseString(original);
        
        System.out.println("Original: " + original);
        System.out.println("Reversed: " + reversed); // Expected: "olleh"
    }
}
