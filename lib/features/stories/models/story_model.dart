import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chamDTech_nrcs/core/models/attachment_model.dart';

class StoryModel {
  final String id;
  final String title;
  final String slug;
  final String content; // Rich text JSON from flutter_quill
  final String authorId;
  final String authorName;
  final String status; // UI Status (draft, approved, etc.)
  final String stage; // Lifecycle stage (new, copy_edited, etc.)
  final String format; // VO, PKG, etc.
  final String? subFormat;
  final int version;
  final String? deskId;
  final int duration; // in seconds
  final List<String> tags;
  final List<AttachmentModel> attachments; // Strong typed attachments
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final List<String>? mediaUrls;
  final String? lockedBy; // User ID who currently has the story open
  final DateTime? lockedAt;
  
  StoryModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.status,
    this.stage = 'new',
    this.format = 'VO',
    this.subFormat,
    this.version = 1,
    this.deskId,
    this.duration = 0,
    this.tags = const [],
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.approvedBy,
    this.approvedAt,
    this.mediaUrls,
    this.lockedBy,
    this.lockedAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'status': status,
      'stage': stage,
      'format': format,
      'subFormat': subFormat,
      'version': version,
      'deskId': deskId,
      'duration': duration,
      'tags': tags,
      'attachments': attachments.map((x) => x.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'mediaUrls': mediaUrls,
      'lockedBy': lockedBy,
      'lockedAt': lockedAt?.toIso8601String(),
    };
  }
  
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.parse(date);
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return StoryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      content: json['content'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      status: json['status'] ?? 'draft',
      stage: json['stage'] ?? 'new',
      format: json['format'] ?? 'VO',
      subFormat: json['subFormat'],
      version: json['version'] ?? 1,
      deskId: json['deskId'],
      duration: json['duration'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      attachments: json['attachments'] != null 
          ? (json['attachments'] as List).map((i) => AttachmentModel.fromJson(i)).toList()
          : [],
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt'] != null 
          ? parseDate(json['approvedAt']) 
          : null,
      mediaUrls: json['mediaUrls'] != null 
          ? List<String>.from(json['mediaUrls']) 
          : null,
      lockedBy: json['lockedBy'],
      lockedAt: json['lockedAt'] != null 
          ? parseDate(json['lockedAt']) 
          : null,
    );
  }
  
  StoryModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? content,
    String? authorId,
    String? authorName,
    String? status,
    String? stage,
    String? format,
    String? subFormat,
    int? version,
    String? deskId,
    int? duration,
    List<String>? tags,
    List<AttachmentModel>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? approvedBy,
    DateTime? approvedAt,
    List<String>? mediaUrls,
    String? lockedBy,
    DateTime? lockedAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      status: status ?? this.status,
      stage: stage ?? this.stage,
      format: format ?? this.format,
      subFormat: subFormat ?? this.subFormat,
      version: version ?? this.version,
      deskId: deskId ?? this.deskId,
      duration: duration ?? this.duration,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      lockedBy: lockedBy ?? this.lockedBy,
      lockedAt: lockedAt ?? this.lockedAt,
    );
  }
}
