import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/core/services/firebase_service.dart';
import 'package:chamdtech_nrcs/features/admin/models/role_model.dart';
import 'package:chamdtech_nrcs/features/admin/models/audit_log_model.dart';
import 'package:uuid/uuid.dart';

class PrivilegeService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  static const String rolesCollection = 'privilege_sets';
  static const String auditCollection = 'audit_logs';

  Stream<List<Role>> getRoles() {
    return _firestore.collection(rolesCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Role.fromJson(doc.data()))
            .toList());
  }

  Future<void> saveRole(Role role, {String? adminId, String? adminName, Role? prevRole}) async {
    final docRef = _firestore.collection(rolesCollection).doc(role.id.isEmpty ? null : role.id);
    
    final data = role.toJson();
    String roleId = role.id;
    if (role.id.isEmpty) {
      roleId = docRef.id;
      data['id'] = roleId;
    }
    
    await docRef.set(data, SetOptions(merge: true));

    // Create Audit Log
    await saveAuditLog(AuditLog(
      id: const Uuid().v4(),
      action: prevRole == null ? 'ROLE_CREATED' : 'ROLE_UPDATED',
      entityType: 'role',
      entityId: roleId,
      entityName: role.name,
      userId: adminId,
      userName: adminName,
      prevData: prevRole?.permissions,
      newData: role.permissions,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> deleteRole(String id, {String? adminId, String? adminName, required String roleName}) async {
    await _firestore.collection(rolesCollection).doc(id).delete();

    // Create Audit Log
    await saveAuditLog(AuditLog(
      id: const Uuid().v4(),
      action: 'ROLE_DELETED',
      entityType: 'role',
      entityId: id,
      entityName: roleName,
      userId: adminId,
      userName: adminName,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> saveAuditLog(AuditLog log) async {
    await _firestore.collection(auditCollection).doc(log.id).set(log.toJson());
  }
}
