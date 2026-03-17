import 'package:cloud_firestore/cloud_firestore.dart';

class RundownItem {
  final String id;
  final String title;
  final int duration; // Duration in seconds
  final String type; // 'story', 'break', 'opening', 'closing', etc.
  final String? storyId; // Reference to story if applicable
  final int order;

  RundownItem({
    required this.id,
    required this.title,
    required this.duration,
    required this.type,
    this.storyId,
    required this.order,
  });

  factory RundownItem.fromJson(Map<String, dynamic> json) {
    return RundownItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? 0,
      type: json['type'] ?? 'story',
      storyId: json['storyId'],
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'type': type,
      'storyId': storyId,
      'order': order,
    };
  }

  RundownItem copyWith({
    String? id,
    String? title,
    int? duration,
    String? type,
    String? storyId,
    int? order,
  }) {
    return RundownItem(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      storyId: storyId ?? this.storyId,
      order: order ?? this.order,
    );
  }
}

class RundownModel {
  final String id;
  final String name;
  final DateTime scheduledTime;
  final int targetDuration; // Target duration in seconds
  final String status; // 'draft', 'locked', 'on-air', 'completed'
  final String producerId;
  final List<String> storyIds; // Ordered list of story IDs

  RundownModel({
    required this.id,
    required this.name,
    required this.scheduledTime,
    required this.targetDuration,
    required this.status,
    required this.producerId,
    required this.storyIds,
  });

  factory RundownModel.fromJson(Map<String, dynamic> json) {
    return RundownModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scheduledTime: (json['scheduledTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetDuration: json['targetDuration'] ?? 0,
      status: json['status'] ?? 'draft',
      producerId: json['producerId'] ?? '',
      storyIds: List<String>.from(json['storyIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'targetDuration': targetDuration,
      'status': status,
      'producerId': producerId,
      'storyIds': storyIds,
    };
  }

  RundownModel copyWith({
    String? id,
    String? name,
    DateTime? scheduledTime,
    int? targetDuration,
    String? status,
    String? producerId,
    List<String>? storyIds,
  }) {
    return RundownModel(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      targetDuration: targetDuration ?? this.targetDuration,
      status: status ?? this.status,
      producerId: producerId ?? this.producerId,
      storyIds: storyIds ?? this.storyIds,
    );
  }
}
