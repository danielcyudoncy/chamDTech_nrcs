import 'package:cloud_firestore/cloud_firestore.dart';

class PrivilegeSet {
  final String id;
  final String name;
  final Map<String, dynamic> privileges;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PrivilegeSet({
    required this.id,
    required this.name,
    required this.privileges,
    this.createdAt,
    this.updatedAt,
  });

  factory PrivilegeSet.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.parse(date);
      return null;
    }

    return PrivilegeSet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      privileges: Map<String, dynamic>.from(json['privileges'] ?? {}),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'privileges': privileges,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  PrivilegeSet copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? privileges,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrivilegeSet(
      id: id ?? this.id,
      name: name ?? this.name,
      privileges: privileges ?? this.privileges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
