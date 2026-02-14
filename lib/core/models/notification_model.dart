class NotificationModel {
  final String id;
  final String userId;
  final String type; // story_update, rundown_change, mention, system
  final String title;
  final String message;
  final Map<String, dynamic>? data; // Additional context (storyId, rundownId, etc.)
  final bool isRead;
  final DateTime createdAt;
  final String? actionUrl; // Deep link to related content

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.actionUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'actionUrl': actionUrl,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? 'system',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      actionUrl: json['actionUrl'],
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  // Factory methods for common notification types
  factory NotificationModel.storyUpdate({
    required String id,
    required String userId,
    required String storyTitle,
    required String updatedBy,
    required String storyId,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: 'story_update',
      title: 'Story Updated',
      message: '$updatedBy updated "$storyTitle"',
      data: {'storyId': storyId},
      createdAt: DateTime.now(),
      actionUrl: '/story/editor?id=$storyId',
    );
  }

  factory NotificationModel.rundownChange({
    required String id,
    required String userId,
    required String rundownTitle,
    required String changedBy,
    required String rundownId,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: 'rundown_change',
      title: 'Rundown Changed',
      message: '$changedBy modified "$rundownTitle"',
      data: {'rundownId': rundownId},
      createdAt: DateTime.now(),
      actionUrl: '/rundown/builder?id=$rundownId',
    );
  }

  factory NotificationModel.mention({
    required String id,
    required String userId,
    required String mentionedBy,
    required String context,
    required String entityId,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: 'mention',
      title: 'You were mentioned',
      message: '$mentionedBy mentioned you in $context',
      data: {'entityId': entityId},
      createdAt: DateTime.now(),
    );
  }
}
