class RundownModel {
  final String id;
  final String title;
  final String showName;
  final DateTime airDate;
  final String status;
  final String producerId;
  final String producerName;
  final List<RundownItem> items;
  final int totalDuration; // in seconds
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLocked;
  final String? lockedBy;
  
  RundownModel({
    required this.id,
    required this.title,
    required this.showName,
    required this.airDate,
    required this.status,
    required this.producerId,
    required this.producerName,
    this.items = const [],
    this.totalDuration = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isLocked = false,
    this.lockedBy,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'showName': showName,
      'airDate': airDate.toIso8601String(),
      'status': status,
      'producerId': producerId,
      'producerName': producerName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalDuration': totalDuration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isLocked': isLocked,
      'lockedBy': lockedBy,
    };
  }
  
  factory RundownModel.fromJson(Map<String, dynamic> json) {
    return RundownModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      showName: json['showName'] ?? '',
      airDate: json['airDate'] != null 
          ? DateTime.parse(json['airDate']) 
          : DateTime.now(),
      status: json['status'] ?? 'scheduled',
      producerId: json['producerId'] ?? '',
      producerName: json['producerName'] ?? '',
      items: json['items'] != null 
          ? (json['items'] as List).map((item) => RundownItem.fromJson(item)).toList()
          : [],
      totalDuration: json['totalDuration'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      isLocked: json['isLocked'] ?? false,
      lockedBy: json['lockedBy'],
    );
  }
  
  RundownModel copyWith({
    String? id,
    String? title,
    String? showName,
    DateTime? airDate,
    String? status,
    String? producerId,
    String? producerName,
    List<RundownItem>? items,
    int? totalDuration,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLocked,
    String? lockedBy,
  }) {
    return RundownModel(
      id: id ?? this.id,
      title: title ?? this.title,
      showName: showName ?? this.showName,
      airDate: airDate ?? this.airDate,
      status: status ?? this.status,
      producerId: producerId ?? this.producerId,
      producerName: producerName ?? this.producerName,
      items: items ?? this.items,
      totalDuration: totalDuration ?? this.totalDuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLocked: isLocked ?? this.isLocked,
      lockedBy: lockedBy ?? this.lockedBy,
    );
  }
}

class RundownItem {
  final String id;
  final String? storyId;
  final String title;
  final String type; // 'story', 'break', 'package', 'live'
  final int duration;
  final int order;
  final String? notes;
  
  RundownItem({
    required this.id,
    this.storyId,
    required this.title,
    required this.type,
    required this.duration,
    required this.order,
    this.notes,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyId': storyId,
      'title': title,
      'type': type,
      'duration': duration,
      'order': order,
      'notes': notes,
    };
  }
  
  factory RundownItem.fromJson(Map<String, dynamic> json) {
    return RundownItem(
      id: json['id'] ?? '',
      storyId: json['storyId'],
      title: json['title'] ?? '',
      type: json['type'] ?? 'story',
      duration: json['duration'] ?? 0,
      order: json['order'] ?? 0,
      notes: json['notes'],
    );
  }
  
  RundownItem copyWith({
    String? id,
    String? storyId,
    String? title,
    String? type,
    int? duration,
    int? order,
    String? notes,
  }) {
    return RundownItem(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      title: title ?? this.title,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      order: order ?? this.order,
      notes: notes ?? this.notes,
    );
  }
}
