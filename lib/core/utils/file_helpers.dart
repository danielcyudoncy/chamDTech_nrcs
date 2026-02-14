class FileHelpers {
  // Get file extension from filename
  static String getFileExtension(String filename) {
    final parts = filename.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  // Format file size to human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Get MIME type from file extension
  static String getMimeType(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    
    // Video formats
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
      return 'video/$ext';
    }
    
    // Audio formats
    if (['mp3', 'wav', 'ogg', 'aac', 'm4a'].contains(ext)) {
      return 'audio/$ext';
    }
    
    // Image formats
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].contains(ext)) {
      return 'image/$ext';
    }
    
    // Document formats
    if (ext == 'pdf') return 'application/pdf';
    if (ext == 'doc' || ext == 'docx') {
      return 'application/msword';
    }
    if (ext == 'xls' || ext == 'xlsx') {
      return 'application/vnd.ms-excel';
    }
    if (ext == 'ppt' || ext == 'pptx') {
      return 'application/vnd.ms-powerpoint';
    }
    if (ext == 'txt') return 'text/plain';
    
    return 'application/octet-stream';
  }

  // Check if file is an image
  static bool isImageFile(String filename) {
    final ext = getFileExtension(filename);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp'].contains(ext);
  }

  // Check if file is a video
  static bool isVideoFile(String filename) {
    final ext = getFileExtension(filename);
    return ['mp4', 'mov', 'avi', 'mkv', 'webm', 'flv', 'wmv'].contains(ext);
  }

  // Check if file is audio
  static bool isAudioFile(String filename) {
    final ext = getFileExtension(filename);
    return ['mp3', 'wav', 'ogg', 'aac', 'm4a', 'flac', 'wma'].contains(ext);
  }

  // Check if file is a document
  static bool isDocumentFile(String filename) {
    final ext = getFileExtension(filename);
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt']
        .contains(ext);
  }

  // Sanitize filename (remove special characters)
  static String sanitizeFilename(String filename) {
    return filename
        .replaceAll(RegExp(r'[^\w\s.-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  // Get filename without extension
  static String getFilenameWithoutExtension(String filename) {
    final parts = filename.split('.');
    if (parts.length > 1) {
      parts.removeLast();
    }
    return parts.join('.');
  }

  // Generate unique filename with timestamp
  static String generateUniqueFilename(String originalFilename) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = getFileExtension(originalFilename);
    final nameWithoutExt = getFilenameWithoutExtension(originalFilename);
    return '${sanitizeFilename(nameWithoutExt)}_$timestamp${ext.isNotEmpty ? '.$ext' : ''}';
  }

  // Check if file size is within limit
  static bool isFileSizeValid(int bytes, int maxSizeInMB) {
    final maxBytes = maxSizeInMB * 1024 * 1024;
    return bytes <= maxBytes;
  }

  // Get file type category
  static String getFileTypeCategory(String filename) {
    if (isImageFile(filename)) return 'image';
    if (isVideoFile(filename)) return 'video';
    if (isAudioFile(filename)) return 'audio';
    if (isDocumentFile(filename)) return 'document';
    return 'other';
  }

  // Get icon name for file type
  static String getFileIcon(String filename) {
    final category = getFileTypeCategory(filename);
    switch (category) {
      case 'image':
        return 'image';
      case 'video':
        return 'videocam';
      case 'audio':
        return 'audiotrack';
      case 'document':
        return 'description';
      default:
        return 'insert_drive_file';
    }
  }

  // Validate file extension against allowed list
  static bool isAllowedExtension(String filename, List<String> allowedExtensions) {
    final ext = getFileExtension(filename);
    return allowedExtensions.map((e) => e.toLowerCase()).contains(ext);
  }
}
