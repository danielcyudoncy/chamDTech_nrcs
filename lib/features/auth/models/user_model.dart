import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String role;
  final String? privilegeSetId;
  final Map<String, bool> permissions;
  final String? photoUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  
  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.privilegeSetId,
    this.permissions = const {},
    this.photoUrl,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
  });
  
  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role,
      'privilegeSetId': privilegeSetId,
      'permissions': permissions,
      'photoUrl': photoUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  // Create from Firestore JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.parse(date);
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      role: json['role'] ?? 'reporter',
      privilegeSetId: json['privilegeSetId'],
      permissions: Map<String, bool>.from(json['permissions'] ?? {}),
      photoUrl: json['photoUrl'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null 
          ? parseDate(json['lastSeen']) 
          : null,
      createdAt: parseDate(json['createdAt']),
    );
  }
  
  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? role,
    String? privilegeSetId,
    Map<String, bool>? permissions,
    String? photoUrl,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      privilegeSetId: privilegeSetId ?? this.privilegeSetId,
      permissions: permissions ?? this.permissions,
      photoUrl: photoUrl ?? this.photoUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Hierarchy index for takeover logic
  int get hierarchyIndex {
    switch (role) {
      case 'admin': return 10;
      case 'producer': return 8;
      case 'anchor': return 7;
      case 'editor': return 6;
      case 'assignment_desk': return 5;
      case 'reporter': return 2;
      default: return 0;
    }
  }

  bool canTakeOver(UserModel other) {
    return hierarchyIndex > other.hierarchyIndex;
  }
}
