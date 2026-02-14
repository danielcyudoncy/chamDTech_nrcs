import 'package:chamDTech_nrcs/features/rundowns/models/rundown_model.dart';

class TemplateModel {
  final String id;
  final String name;
  final String description;
  final List<RundownItem> skeleton; // Default items like 'Break', 'Opening', 'Closing'
  final DateTime createdAt;
  final String? createdBy;

  TemplateModel({
    required this.id,
    required this.name,
    required this.description,
    this.skeleton = const [],
    required this.createdAt,
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'skeleton': skeleton.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      skeleton: json['skeleton'] != null 
          ? (json['skeleton'] as List).map((item) => RundownItem.fromJson(item)).toList()
          : [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      createdBy: json['createdBy'],
    );
  }
}
