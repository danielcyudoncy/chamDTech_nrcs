class StringHelpers {
  // Truncate string with ellipsis
  static String truncate(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  // Convert to title case
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  // Generate URL-safe slug from title
  static String generateSlug(String title) {
    return title
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special chars
        .replaceAll(RegExp(r'[\s_]+'), '-') // Replace spaces/underscores with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
        .replaceAll(RegExp(r'^-+|-+$'), ''); // Remove leading/trailing hyphens
  }

  // Strip HTML tags from rich text
  static String stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Count words in text
  static int wordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  // Convert to sentence case
  static String toSentenceCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split('. ')
        .map((sentence) => sentence.isEmpty
            ? sentence
            : '${sentence[0].toUpperCase()}${sentence.substring(1).toLowerCase()}')
        .join('. ');
  }

  // Remove extra whitespace
  static String normalizeWhitespace(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Check if string is empty or whitespace
  static bool isBlank(String? text) {
    return text == null || text.trim().isEmpty;
  }

  // Check if string is not empty
  static bool isNotBlank(String? text) {
    return !isBlank(text);
  }

  // Extract initials from name
  static String getInitials(String name, {int maxInitials = 2}) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words
        .take(maxInitials)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();
    return initials;
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    return phone;
  }

  // Highlight search term in text
  static String highlightSearchTerm(String text, String searchTerm) {
    if (searchTerm.isEmpty) return text;
    final regex = RegExp(searchTerm, caseSensitive: false);
    return text.replaceAllMapped(
      regex,
      (match) => '**${match.group(0)}**',
    );
  }

  // Convert camelCase to Title Case
  static String camelCaseToTitle(String camelCase) {
    return camelCase
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim()
        .split(' ')
        .map((word) => capitalize(word))
        .join(' ');
  }

  // Convert snake_case to Title Case
  static String snakeCaseToTitle(String snakeCase) {
    return snakeCase
        .split('_')
        .map((word) => capitalize(word))
        .join(' ');
  }

  // Pluralize word (basic English rules)
  static String pluralize(String word, int count) {
    if (count == 1) return word;
    
    if (word.endsWith('y')) {
      return '${word.substring(0, word.length - 1)}ies';
    } else if (word.endsWith('s') ||
        word.endsWith('x') ||
        word.endsWith('z') ||
        word.endsWith('ch') ||
        word.endsWith('sh')) {
      return '${word}es';
    } else {
      return '${word}s';
    }
  }

  // Format number with commas
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}
