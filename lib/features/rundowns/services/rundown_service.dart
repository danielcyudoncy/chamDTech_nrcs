import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/core/services/firebase_service.dart';
import 'package:chamDTech_nrcs/features/rundowns/models/rundown_model.dart';
import 'package:chamDTech_nrcs/features/rundowns/models/template_model.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';

class RundownService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final AuthService _authService = Get.find<AuthService>();

  Stream<List<RundownModel>> getRundowns() {
    return _firestore
        .collection(AppConstants.rundownsCollection)
        .orderBy('airDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RundownModel.fromJson(doc.data()))
            .toList());
  }

  Future<RundownModel?> createRundownFromTemplate(TemplateModel template, DateTime airDate) async {
    final user = _authService.currentUser.value;
    if (user == null) return null;

    final rundown = RundownModel(
      id: '', // Will be updated
      title: '${template.name} - ${airDate.toLocal().toString().split(' ')[0]}',
      showName: template.name,
      airDate: airDate,
      status: AppConstants.rundownScheduled,
      producerId: user.id,
      producerName: user.displayName,
      items: template.skeleton,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final docRef = await _firestore
          .collection(AppConstants.rundownsCollection)
          .add(rundown.toJson());
      
      await docRef.update({'id': docRef.id});
      return rundown.copyWith(id: docRef.id);
    } catch (e) {
      Get.log('Error creating rundown: $e');
      return null;
    }
  }

  Future<void> updateRundownStatus(String rundownId, String status) async {
    await _firestore
        .collection(AppConstants.rundownsCollection)
        .doc(rundownId)
        .update({
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> toggleOnAir(String rundownId, bool isOnAir) async {
    await _firestore
        .collection(AppConstants.rundownsCollection)
        .doc(rundownId)
        .update({
          'status': isOnAir ? AppConstants.rundownOnAir : AppConstants.rundownActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> updateItems(String rundownId, List<RundownItem> items) async {
    await _firestore
        .collection(AppConstants.rundownsCollection)
        .doc(rundownId)
        .update({
          'items': items.map((i) => i.toJson()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
          'totalDuration': items.fold<int>(0, (prev, element) => prev + element.duration),
        });
  }
}
