class UssdUtils {
  /// Check if input looks like a USSD code (*123# or *123 or similar)
  static bool isUssdCode(String input) {
    if (input.isEmpty) return false;
    
    // Match patterns like *123#, *123*, *123, etc.
    final ussdPattern = RegExp(r'^\*\d+[#*]?$');
    return ussdPattern.hasMatch(input);
  }

  /// Extract service code from USSD input
  /// Examples: *123# -> 123, *456 -> 456
  static String extractServiceCode(String ussdInput) {
    final match = RegExp(r'\*?(\d+)[#*]?').firstMatch(ussdInput);
    if (match != null) {
      return match.group(1) ?? '';
    }
    
    // Fallback: remove all non-digits
    return ussdInput.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Validate menu selection input
  static bool isValidMenuSelection(String input) {
    if (input.isEmpty) return false;
    
    // Allow digits, *, #, and simple combinations
    final validPattern = RegExp(r'^[\d*#]+$');
    return validPattern.hasMatch(input);
  }

  /// Build text input from USSD path
  /// For initial request: returns empty string
  /// For subsequent requests: returns path joined with '*' (e.g., "1*2*3")
  static String buildTextInput(List<String> ussdPath) {
    return ussdPath.join('*');
  }

  /// Add user input to USSD path
  static List<String> addToPath(List<String> currentPath, String userInput) {
    return [...currentPath, userInput];
  }

  /// Check if response indicates session end
  static bool isSessionEndResponse(String responseText) {
    final endIndicators = [
      'END',
      'Thank you',
      'Session ended',
      'Goodbye',
      'Transaction completed',
      'Invalid selection',
      'Session timeout'
    ];
    
    final upperResponse = responseText.toUpperCase();
    return endIndicators.any((indicator) => 
        upperResponse.contains(indicator.toUpperCase()));
  }

  /// Generate a unique session ID
  static String generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (DateTime.now().microsecond % 1000).toString().padLeft(3, '0');
    return 'ussd_${timestamp}_$random';
  }

  /// Format USSD path for display
  static String formatPathForDisplay(List<String> ussdPath) {
    if (ussdPath.isEmpty) {
      return 'Initial Request';
    }
    return 'Path: ${ussdPath.join(' → ')}';
  }

  /// Clean user input (remove extra spaces, normalize)
  static String cleanUserInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), '');
  }

  /// Check if input is a cancellation command
  static bool isCancelCommand(String input) {
    final cancelCommands = ['0', '00', '*', '#', 'cancel', 'exit'];
    return cancelCommands.contains(input.toLowerCase());
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    // Basic validation for international format
    final phonePattern = RegExp(r'^\+?[\d\s\-\(\)]{7,20}$');
    return phonePattern.hasMatch(phoneNumber);
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digits except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure it starts with +
    if (!cleaned.startsWith('+') && cleaned.isNotEmpty) {
      cleaned = '+$cleaned';
    }
    
    return cleaned;
  }

  /// Extract numbers and special characters for keypad input
  static List<String> getKeypadButtons() {
    return [
      '1', '2', '3',
      '4', '5', '6', 
      '7', '8', '9',
      '*', '0', '#'
    ];
  }

  /// Get quick USSD codes for testing
  static List<String> getCommonUssdCodes() {
    return [
      '*123#',  // Common balance check
      '*124#',  // Data balance
      '*125#',  // Airtime balance
      '*555#',  // Service menu
      '*777#',  // Mobile money
      '*144#',  // Customer care
      '*100#',  // Main menu
    ];
  }
}