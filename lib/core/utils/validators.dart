class Validators {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Slug validation (lowercase, hyphens, alphanumeric)
  static bool isValidSlug(String slug) {
    final slugRegex = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');
    return slugRegex.hasMatch(slug);
  }

  // Duration validation (in seconds, 0-3600)
  static bool isValidDuration(int duration, {int min = 0, int max = 3600}) {
    return duration >= min && duration <= max;
  }

  // File name validation (no special characters except . - _)
  static bool isValidFileName(String fileName) {
    final fileNameRegex = RegExp(r'^[a-zA-Z0-9._-]+$');
    return fileNameRegex.hasMatch(fileName);
  }

  // Password strength validation
  static bool isStrongPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    if (password.length < 8) return false;
    
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    
    return hasUppercase && hasLowercase && hasDigit;
  }

  // Phone number validation (basic)
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s-()]'), ''));
  }

  // URL validation
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Story title validation (not empty, max 200 chars)
  static String? validateStoryTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Title is required';
    }
    if (title.length > 200) {
      return 'Title must be less than 200 characters';
    }
    return null;
  }

  // Slug validation with error message
  static String? validateSlug(String? slug) {
    if (slug == null || slug.trim().isEmpty) {
      return 'Slug is required';
    }
    if (!isValidSlug(slug)) {
      return 'Slug must be lowercase with hyphens only';
    }
    if (slug.length > 100) {
      return 'Slug must be less than 100 characters';
    }
    return null;
  }

  // Email validation with error message
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validation with error message
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName must be a number';
    }
    return null;
  }

  // Range validation
  static String? validateRange(
    String? value,
    String fieldName,
    int min,
    int max,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final num = int.tryParse(value);
    if (num == null) {
      return '$fieldName must be a number';
    }
    if (num < min || num > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }
}
