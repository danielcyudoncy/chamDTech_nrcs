class AttachmentModel {
  final String id;
  final String name;
  final String type; // video, audio, image, graphic, document
  final String url;
  final String? thumbnailUrl;
  final int sizeBytes;
  final String? mimeType;
  final int? durationSeconds; // For video/audio
  final int? width; // For images/video
  final int? height; // For images/video
  final DateTime uploadedAt;
  final String uploadedBy;
  final Map<String, dynamic>? metadata; // Additional info (codec, bitrate, etc.)

  AttachmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    required this.sizeBytes,
    this.mimeType,
    this.durationSeconds,
    this.width,
    this.height,
    required this.uploadedAt,
    required this.uploadedBy,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'sizeBytes': sizeBytes,
      'mimeType': mimeType,
      'durationSeconds': durationSeconds,
      'width': width,
      'height': height,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
      'metadata': metadata,
    };
  }

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'document',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      sizeBytes: json['sizeBytes'] ?? 0,
      mimeType: json['mimeType'],
      durationSeconds: json['durationSeconds'],
      width: json['width'],
      height: json['height'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
      uploadedBy: json['uploadedBy'] ?? '',
      metadata: json['metadata'],
    );
  }

  AttachmentModel copyWith({
    String? id,
    String? name,
    String? type,
    String? url,
    String? thumbnailUrl,
    int? sizeBytes,
    String? mimeType,
    int? durationSeconds,
    int? width,
    int? height,
    DateTime? uploadedAt,
    String? uploadedBy,
    Map<String, dynamic>? metadata,
  }) {
    return AttachmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      mimeType: mimeType ?? this.mimeType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      width: width ?? this.width,
      height: height ?? this.height,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      metadata: metadata ?? this.metadata,
    );
  }

  // Type checks
  bool get isVideo => type == 'video';
  bool get isAudio => type == 'audio';
  bool get isImage => type == 'image';
  bool get isGraphic => type == 'graphic';
  bool get isDocument => type == 'document';

  // Get file extension
  String get extension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  // Get human-readable file size
  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Get formatted duration (MM:SS or HH:MM:SS)
  String get formattedDuration {
    if (durationSeconds == null) return '';
    final duration = Duration(seconds: durationSeconds!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
