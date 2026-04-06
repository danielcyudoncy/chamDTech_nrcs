import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLog {
  final String id;
  final String action; // e.g., 'ROLE_CREATED', 'ROLE_UPDATED', 'ROLE_DELETED'
  final String entityType; // e.g., 'role'
  final String entityId;
  final String entityName;
  final String? userId; // Admin who performed the action
  final String? userName;
  final Map<String, dynamic>? prevData;
  final Map<String, dynamic>? newData;
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.entityName,
    this.userId,
    this.userName,
    this.prevData,
    this.newData,
    required this.timestamp,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.parse(date);
      return DateTime.now();
    }

    return AuditLog(
      id: json['id'] ?? '',
      action: json['action'] ?? '',
      entityType: json['entityType'] ?? '',
      entityId: json['entityId'] ?? '',
      entityName: json['entityName'] ?? '',
      userId: json['userId'],
      userName: json['userName'],
      prevData: json['prevData'],
      newData: json['newData'],
      timestamp: parseDate(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'entityName': entityName,
      'userId': userId,
      'userName': userName,
      'prevData': prevData,
      'newData': newData,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
