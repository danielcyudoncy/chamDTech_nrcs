import 'package:cloud_firestore/cloud_firestore.dart';

class Role {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final Map<String, Map<String, Map<String, bool>>> permissions;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Role({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    required this.permissions,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.parse(date);
      return null;
    }

    // Convert raw permissions map to structured Map<String, Map<String, Map<String, bool>>>
    final rawPermissions = Map<String, dynamic>.from(json['permissions'] ?? {});
    final Map<String, Map<String, Map<String, bool>>> formattedPermissions = {};
    
    rawPermissions.forEach((category, groups) {
      if (groups is Map) {
        final Map<String, Map<String, bool>> formattedGroups = {};
        groups.forEach((group, perms) {
          if (perms is Map) {
            formattedGroups[group.toString()] = Map<String, bool>.from(
              perms.map((key, value) => MapEntry(key.toString(), value as bool))
            );
          }
        });
        formattedPermissions[category.toString()] = formattedGroups;
      }
    });

    return Role(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      parentId: json['parentId'],
      permissions: formattedPermissions,
      updatedBy: json['updatedBy'],
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parentId': parentId,
      'permissions': permissions,
      'updatedBy': updatedBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  Role copyWith({
    String? id,
    String? name,
    String? description,
    String? parentId,
    Map<String, Map<String, Map<String, bool>>>? permissions,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      permissions: permissions ?? this.permissions,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
