import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/core/services/firebase_service.dart';
import 'package:chamDTech_nrcs/features/auth/models/user_model.dart';

import 'package:chamDTech_nrcs/features/auth/models/user_model.dart';
import 'package:chamDTech_nrcs/features/admin/models/privilege_set_model.dart';
import 'package:chamDTech_nrcs/features/admin/services/privilege_service.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final FirebaseDatabase _database = FirebaseService.database;
  
  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  
  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    // ever(firebaseUser, _setInitialScreen); // Removed to prevent immediate navigation loop
    // Instead, just listen once after init or handle in Splash screen
  }
  
  // Public method to trigger initial navigation
  void initNavigation() {
    _setInitialScreen(firebaseUser.value);
  }

  void _setInitialScreen(User? user) async {
    // Wait for the app to be mounted
    if (user == null) {
      // Use microtask to avoid immediate navigation errors during build
      Future.delayed(Duration.zero, () {
        Get.offAllNamed('/login');
      });
    } else {
      await _loadUserData(user.uid);
      await _setUserOnlineStatus(true);
      Future.delayed(Duration.zero, () {
        Get.offAllNamed('/stories');
      });
    }
  }
  
  // Sign in with email and password
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        await _setUserOnlineStatus(true);
        return currentUser.value;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login Error',
        _getAuthErrorMessage(e.code),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
  
  // Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Create user document in Firestore
        final userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          displayName: displayName,
          role: role,
          createdAt: DateTime.now(),
          isOnline: true,
        );
        
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .set(userModel.toJson());
        
        currentUser.value = userModel;
        await _setUserOnlineStatus(true);
        
        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Sign Up Error',
        _getAuthErrorMessage(e.code),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
  
  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        var user = UserModel.fromJson(doc.data()!);
        
        // If user has a privilege set, fetch it and update localized permissions
        if (user.privilegeSetId != null) {
          try {
            final privDoc = await _firestore
                .collection(PrivilegeService.collectionPath)
                .doc(user.privilegeSetId)
                .get();
            if (privDoc.exists) {
              final privSet = PrivilegeSet.fromJson(privDoc.data()!);
              // For simplicity in checking, we'll store them as nested maps in the user model
              // or flatten them. Let's keep them nested to match the PrivilegeMaster structure.
              user = user.copyWith(
                permissions: _flattenPrivileges(privSet.privileges),
              );
            }
          } catch (e) {
            Get.log('Error loading privilege set: $e');
          }
        }
        
        currentUser.value = user;
      }
    } catch (e) {
      Get.log('Error loading user data: $e');
    }
  }

  Map<String, bool> _flattenPrivileges(Map<String, dynamic> grouped) {
    final Map<String, bool> flat = {};
    grouped.forEach((group, items) {
      if (items is Map) {
        items.forEach((key, value) {
          flat['$group->$key'] = value == true;
        });
      }
    });
    return flat;
  }
  
  // Set user online/offline status in Realtime Database
  Future<void> _setUserOnlineStatus(bool isOnline) async {
    if (currentUser.value == null) return;
    
    try {
      final userStatusRef = _database.ref(
        '${AppConstants.onlineUsersPath}/${currentUser.value!.id}'
      );
      
      if (isOnline) {
        // Set online
        await userStatusRef.set({
          'isOnline': true,
          'lastSeen': ServerValue.timestamp,
          'displayName': currentUser.value!.displayName,
          'role': currentUser.value!.role,
        });
        
        // Set offline on disconnect
        await userStatusRef.onDisconnect().set({
          'isOnline': false,
          'lastSeen': ServerValue.timestamp,
          'displayName': currentUser.value!.displayName,
          'role': currentUser.value!.role,
        });
      } else {
        // Set offline
        await userStatusRef.set({
          'isOnline': false,
          'lastSeen': ServerValue.timestamp,
          'displayName': currentUser.value!.displayName,
          'role': currentUser.value!.role,
        });
      }
      
      // Also update Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.value!.id)
          .update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.log('Error setting user status: $e');
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _setUserOnlineStatus(false);
      await _auth.signOut();
      currentUser.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.log('Error signing out: $e');
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile({String? displayName, String? photoUrl}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Update Firebase Auth profile
        if (displayName != null) await user.updateDisplayName(displayName);
        if (photoUrl != null) await user.updatePhotoURL(photoUrl);
        
        // Update Firestore
        final updates = <String, dynamic>{};
        if (displayName != null) updates['displayName'] = displayName;
        if (photoUrl != null) updates['photoUrl'] = photoUrl;
        
        if (updates.isNotEmpty) {
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .update(updates);
              
          // Update local state
          currentUser.value = currentUser.value?.copyWith(
            displayName: displayName,
            photoUrl: photoUrl,
          );
        }
      }
    } catch (e) {
      Get.log('Error updating profile: $e');
      rethrow;
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(data);
      
      // If updating current user, refresh local state
      if (currentUser.value?.id == uid) {
        await _loadUserData(uid);
      }
    } catch (e) {
      Get.log('Error updating user data: $e');
      rethrow;
    }
  }

  // Get auth error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
