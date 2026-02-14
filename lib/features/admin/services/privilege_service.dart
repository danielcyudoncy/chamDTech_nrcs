import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/core/services/firebase_service.dart';
import 'package:chamDTech_nrcs/features/admin/models/privilege_set_model.dart';

class PrivilegeService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  static const String collectionPath = 'privilege_sets';

  Stream<List<PrivilegeSet>> getPrivilegeSets() {
    return _firestore.collection(collectionPath)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PrivilegeSet.fromJson(doc.data()))
            .toList());
  }

  Future<void> savePrivilegeSet(PrivilegeSet set) async {
    final docRef = _firestore.collection(collectionPath).doc(set.id.isEmpty ? null : set.id);
    
    final data = set.toJson();
    if (set.id.isEmpty) {
      data['id'] = docRef.id;
    }
    
    await docRef.set(data, SetOptions(merge: true));
  }

  Future<void> deletePrivilegeSet(String id) async {
    await _firestore.collection(collectionPath).doc(id).delete();
  }
}
