class DeskModel {
  final String id;
  final String name;
  final String? description;
  final String producerId;
  final List<String> userIds;
  final Map<String, dynamic>? config; // Default format, slug prefix, etc.

  DeskModel({
    required this.id,
    required this.name,
    this.description,
    required this.producerId,
    this.userIds = const [],
    this.config,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'producerId': producerId,
      'userIds': userIds,
      'config': config,
    };
  }

  factory DeskModel.fromJson(Map<String, dynamic> json) {
    return DeskModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      producerId: json['producerId'] ?? '',
      userIds: List<String>.from(json['userIds'] ?? []),
      config: json['config'],
    );
  }
}
