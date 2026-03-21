import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/core/services/firebase_service.dart';
import 'package:chamdtech_nrcs/features/auth/models/user_model.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/rundowns/models/rundown_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';


class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Observable statistics
  final RxInt totalUsersCount = 0.obs;
  final RxInt activeTodayCount = 0.obs;
  final RxInt storiesTodayCount = 0.obs;
  final RxInt activeRundownsCount = 0.obs;

  // Detailed lists for the summary view
  final RxList<UserModel> allUsersList = <UserModel>[].obs;
  final RxList<UserModel> activeUsersList = <UserModel>[].obs;
  final RxList<StoryModel> storiesTodayList = <StoryModel>[].obs;
  final RxList<RundownModel> activeRundownsList = <RundownModel>[].obs;

  // Selection state
  final RxString selectedStat = 'none'.obs; // 'users', 'active', 'stories', 'rundowns'

  @override
  void onInit() {
    super.onInit();
    _listenToStats();
  }

  void selectStat(String stat) {
    if (selectedStat.value == stat) {
      selectedStat.value = 'none';
    } else {
      selectedStat.value = stat;
    }
  }

  void _listenToStats() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    // 1. Total Users
    _firestore.collection(AppConstants.usersCollection).snapshots().listen((snapshot) {
      allUsersList.value = snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
      totalUsersCount.value = allUsersList.length;
    });

    // 2. Active Today (Users seen in the last 24 hours)
    _firestore
        .collection(AppConstants.usersCollection)
        .where('lastSeen', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
        .snapshots()
        .listen((snapshot) {
      activeUsersList.value = snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
      activeTodayCount.value = activeUsersList.length;
    });

    // 3. Stories Today
    _firestore
        .collection(AppConstants.storiesCollection)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
        .snapshots()
        .listen((snapshot) {
      storiesTodayList.value = snapshot.docs.map((doc) => StoryModel.fromJson(doc.data())).toList();
      storiesTodayCount.value = storiesTodayList.length;
    });

    // 4. Active Rundowns (Status: On-Air)
    _firestore
        .collection(AppConstants.rundownsCollection)
        .where('status', isEqualTo: AppConstants.rundownOnAir)
        .snapshots()
        .listen((snapshot) {
      activeRundownsList.value = snapshot.docs.map((doc) => RundownModel.fromJson(doc.data())).toList();
      activeRundownsCount.value = activeRundownsList.length;
    });
  }


  // Navigation for dashbaord cards
  void navigateTo(String route) {
    Get.toNamed(route);
  }

  // Placeholder for bulk maintenance actions
  Future<void> clearAuditTrail() async {
    // Implement audit trail clearing logic
  }
}

