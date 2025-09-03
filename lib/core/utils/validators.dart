class Validators {
  // Rating validation
  static String? validateRating(double? rating) {
    if (rating == null) {
      return 'Rating is required';
    }
    if (rating < 0 || rating > 10) {
      return 'Rating must be between 0 and 10';
    }
    return null;
  }

  // Review validation
  static String? validateReview(String? review) {
    if (review != null && review.length > 500) {
      return 'Review must be less than 500 characters';
    }
    return null;
  }

  // Search query validation
  static String? validateSearchQuery(String? query) {
    if (query == null || query.trim().isEmpty) {
      return 'Search query cannot be empty';
    }
    if (query.length < 2) {
      return 'Search query must be at least 2 characters';
    }
    if (query.length > 100) {
      return 'Search query is too long';
    }
    return null;
  }

  // Year validation
  static String? validateYear(int? year) {
    if (year == null) return null;

    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 5) {
      return 'Invalid year';
    }
    return null;
  }

  // Email validation (for future auth)
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // Password validation (for future auth)
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}