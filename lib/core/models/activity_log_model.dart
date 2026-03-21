import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogModel {
  final String id;
  final String userId;
  final String userName;
  final String action; // create, update, delete, approve, reject, lock, unlock
  final String entityType; // story, rundown, user, desk
  final String entityId;
  final String? entityTitle;
  final Map<String, dynamic>? changes; // Before/after values
  final String? description;
  final DateTime timestamp;
  final String? ipAddress;

  ActivityLogModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.entityTitle,
    this.changes,
    this.description,
    required this.timestamp,
    this.ipAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'entityTitle': entityTitle,
      'changes': changes,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
    };
  }

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return ActivityLogModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      action: json['action'] ?? '',
      entityType: json['entityType'] ?? '',
      entityId: json['entityId'] ?? '',
      entityTitle: json['entityTitle'],
      changes: json['changes'],
      description: json['description'],
      timestamp: parseDate(json['timestamp']),
      ipAddress: json['ipAddress'],
    );
  }

  // Factory methods for common actions
  factory ActivityLogModel.storyCreated({
    required String id,
    required String userId,
    required String userName,
    required String storyId,
    required String storyTitle,
  }) {
    return ActivityLogModel(
      id: id,
      userId: userId,
      userName: userName,
      action: 'create',
      entityType: 'story',
      entityId: storyId,
      entityTitle: storyTitle,
      description: 'Created story "$storyTitle"',
      timestamp: DateTime.now(),
    );
  }

  factory ActivityLogModel.storyUpdated({
    required String id,
    required String userId,
    required String userName,
    required String storyId,
    required String storyTitle,
    Map<String, dynamic>? changes,
  }) {
    return ActivityLogModel(
      id: id,
      userId: userId,
      userName: userName,
      action: 'update',
      entityType: 'story',
      entityId: storyId,
      entityTitle: storyTitle,
      changes: changes,
      description: 'Updated story "$storyTitle"',
      timestamp: DateTime.now(),
    );
  }

  factory ActivityLogModel.storyApproved({
    required String id,
    required String userId,
    required String userName,
    required String storyId,
    required String storyTitle,
  }) {
    return ActivityLogModel(
      id: id,
      userId: userId,
      userName: userName,
      action: 'approve',
      entityType: 'story',
      entityId: storyId,
      entityTitle: storyTitle,
      description: 'Approved story "$storyTitle"',
      timestamp: DateTime.now(),
    );
  }

  factory ActivityLogModel.storyLocked({
    required String id,
    required String userId,
    required String userName,
    required String storyId,
    required String storyTitle,
  }) {
    return ActivityLogModel(
      id: id,
      userId: userId,
      userName: userName,
      action: 'lock',
      entityType: 'story',
      entityId: storyId,
      entityTitle: storyTitle,
      description: 'Locked story "$storyTitle" for editing',
      timestamp: DateTime.now(),
    );
  }

  // Get human-readable action text
  String get actionText {
    switch (action) {
      case 'create':
        return 'Created';
      case 'update':
        return 'Updated';
      case 'delete':
        return 'Deleted';
      case 'approve':
        return 'Approved';
      case 'reject':
        return 'Rejected';
      case 'lock':
        return 'Locked';
      case 'unlock':
        return 'Unlocked';
      default:
        return action;
    }
  }
}
