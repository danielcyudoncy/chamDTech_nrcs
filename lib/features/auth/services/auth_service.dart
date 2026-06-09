// features/auth/services/auth_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/story_pool_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/core/services/firebase_service.dart';
import 'package:chamdtech_nrcs/features/auth/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:chamdtech_nrcs/features/admin/models/role_model.dart';
import 'package:chamdtech_nrcs/features/admin/services/privilege_service.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';

import 'package:chamdtech_nrcs/features/admin/controllers/admin_controller.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/anchor_dashboard_controller.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/desk_controller.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/editor_dashboard_controller.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/producer_dashboard_controller.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/reporter_dashboard_controller.dart';
import 'package:chamdtech_nrcs/features/newsroom/controllers/newsroom_controller.dart';
import 'package:chamdtech_nrcs/features/rundowns/controllers/rundown_builder_controller.dart';
import 'package:chamdtech_nrcs/features/stories/controllers/story_controller.dart';
import 'package:chamdtech_nrcs/features/stories/controllers/story_editor_controller.dart';
import 'package:chamdtech_nrcs/core/services/rbac_service.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final FirebaseDatabase _database = FirebaseService.database;
  final GoogleSignIn? _googleSignIn = kIsWeb
      ? null
      : GoogleSignIn(
          clientId:
              '543726067765-gceqeb5j0i6tufvedvakcfrs6qsnvpt6.apps.googleusercontent.com',
        );

  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Active listeners for live user and role updates.
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _userDocSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _roleDocSubscription;
  String? _currentUserId;
  String? _currentRoleId;
  UserModel? _latestUserSnapshot;
  Map<String, Map<String, Map<String, bool>>>? _latestRolePermissions;

  // If Realtime DB permission is denied, avoid retrying writes repeatedly.
  bool _realtimeWritesAllowed = true;

  /// Initializes auth state before the app renders its first screen.
  Future<AuthService> init() async {
    // Register RbacService globally so any controller can Get.find<RbacService>()
    if (!Get.isRegistered<RbacService>()) {
      Get.put<RbacService>(RbacService(), permanent: true);
    }

    firebaseUser.bindStream(_auth.authStateChanges());

    ever(firebaseUser, (User? fbUser) async {
      if (fbUser != null) {
        try {
          await _loadUserData(fbUser.uid);
          await _watchUserProfile(fbUser.uid);
          await _setUserOnlineStatus(true);
        } catch (e) {
          Get.log('AuthService: Silent user-data reload failed: $e');
        }
      } else {
        _cancelProfileSubscriptions();
        currentUser.value = null;
      }
    });

    // Wait for the initial auth state to resolve before continuing the app.
    await _auth.authStateChanges().first;
    return this;
  }

  Future<void> _watchUserProfile(String uid) async {
    if (_currentUserId == uid && _userDocSubscription != null) return;

    _cancelProfileSubscriptions();
    _currentUserId = uid;

    _userDocSubscription = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists || snapshot.data() == null) {
        currentUser.value = null;
        return;
      }

      final user = UserModel.fromJson(snapshot.data()!);
      _latestUserSnapshot = user;

      final resolvedRoleId = await _resolveRoleIdForUser(user);
      if (resolvedRoleId != null) {
        if (resolvedRoleId != _currentRoleId) {
          _watchRolePermissions(resolvedRoleId);
        } else if (_latestRolePermissions != null) {
          currentUser.value = user.copyWith(
            roleId: resolvedRoleId,
            permissions: _flattenPrivileges(_latestRolePermissions!),
          );
        } else {
          currentUser.value = user.copyWith(roleId: resolvedRoleId);
        }
      } else {
        _currentRoleId = null;
        _latestRolePermissions = null;
        currentUser.value = user;
      }
    }, onError: (error) {
      Get.log('AuthService user profile listener error: $error');
    });
  }

  void _watchRolePermissions(String roleId) {
    if (_currentRoleId == roleId && _roleDocSubscription != null) return;

    _roleDocSubscription?.cancel();
    _currentRoleId = roleId;

    _roleDocSubscription = _firestore
        .collection(PrivilegeService.rolesCollection)
        .doc(roleId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        _latestRolePermissions = null;
        if (_latestUserSnapshot != null) {
          currentUser.value = _latestUserSnapshot!.copyWith(permissions: {});
        }
        return;
      }

      final roleModel = Role.fromJson(snapshot.data()!);
      _latestRolePermissions = roleModel.permissions;

      if (_latestUserSnapshot != null) {
        currentUser.value = _latestUserSnapshot!.copyWith(
          permissions: _flattenPrivileges(roleModel.permissions),
        );
      }
    }, onError: (error) {
      Get.log('AuthService role permission listener error: $error');
    });
  }

  void _cancelProfileSubscriptions() {
    _userDocSubscription?.cancel();
    _userDocSubscription = null;
    _roleDocSubscription?.cancel();
    _roleDocSubscription = null;
    _currentUserId = null;
    _currentRoleId = null;
    _latestUserSnapshot = null;
    _latestRolePermissions = null;
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
        Get.offAllNamed(AppRoutes.login);
      });
    } else {
      try {
        await _loadUserData(user.uid);
        await _setUserOnlineStatus(true);
        Future.delayed(Duration.zero, () {
          final roleRoute =
              AppRoutes.getRouteForRole(currentUser.value?.role ?? '');
          Get.offAllNamed(roleRoute);
        });
      } catch (e) {
        Get.log('Error in _setInitialScreen: $e');
        await _auth.signOut();
        Future.delayed(Duration.zero, () {
          Get.offAllNamed(AppRoutes.login);
          Get.snackbar(
            'Session Error',
            'Failed to load user profile. Please log in again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
            colorText: Get.theme.colorScheme.error,
          );
        });
      }
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
        await _watchUserProfile(credential.user!.uid);
        await _setUserOnlineStatus(true);
        return currentUser.value;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login Error',
        _getAuthErrorMessage(e.code),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return null;
    } catch (e) {
      Get.snackbar(
        'Login Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return null;
    }
  }

  // Sign in with Google
  Future<dynamic> signInWithGoogle() async {
    try {
      User? user;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(provider);
        user = userCredential.user;
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn?.signIn();
        if (googleUser == null) {
          // The user canceled the sign-in
          return null;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        user = userCredential.user;
      }

      if (user != null) {
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // User already exists, log them in
          await _loadUserData(user.uid);
          await _watchUserProfile(user.uid);
          await _setUserOnlineStatus(true);
          return currentUser.value;
        } else {
          // This is a new user, return the Firebase User object
          // so the controller can prompt for a role.
          return user;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Google Sign-In Error',
        _getAuthErrorMessage(e.code),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return null;
    } catch (e) {
      Get.log('Google Sign-In Exception: $e');
      Get.snackbar(
        'Google Sign-In Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return null;
    }
  }

  // Create user document in Firestore after Google Sign-In and role selection
  Future<UserModel?> completeGoogleSignUp({
    required User user,
    required String role,
  }) async {
    try {
      // Create user document in Firestore
      final userModel = UserModel(
        id: user.uid,
        email: user.email!,
        displayName: user.displayName!,
        role: role,
        createdAt: DateTime.now(),
        isOnline: true,
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toJson());

      currentUser.value = userModel;
      await _watchUserProfile(user.uid);
      await _setUserOnlineStatus(true);

      return userModel;
    } catch (e) {
      Get.snackbar(
        'Sign Up Error',
        'Failed to create your account. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
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
        await _watchUserProfile(credential.user!.uid);
        await _setUserOnlineStatus(true);

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Sign Up Error',
        _getAuthErrorMessage(e.code),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return null;
    } catch (e) {
      Get.snackbar(
        'Sign Up Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
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

        final resolvedRoleId = await _resolveRoleIdForUser(user);
        if (resolvedRoleId != null) {
          user = user.copyWith(roleId: resolvedRoleId);
          try {
            final roleDoc = await _firestore
                .collection(PrivilegeService.rolesCollection)
                .doc(resolvedRoleId)
                .get();
            if (roleDoc.exists) {
              final roleModel = Role.fromJson(roleDoc.data()!);
              user = user.copyWith(
                permissions: _flattenPrivileges(roleModel.permissions),
              );
            }
          } catch (e) {
            Get.log('Error loading role permissions: $e');
          }
        }

        currentUser.value = user;
      } else {
        throw Exception('User profile not found in database.');
      }
    } catch (e) {
      Get.log('Error loading user data: $e');
      rethrow;
    }
  }

  Future<String?> _resolveRoleIdForUser(UserModel user) async {
    if (user.roleId != null && user.roleId!.isNotEmpty) {
      return user.roleId;
    }

    if (user.role.isEmpty) return null;

    final normalizedRole = _normalizeRoleName(user.role);
    try {
      final exactSnapshot = await _firestore
          .collection(PrivilegeService.rolesCollection)
          .where('name', isEqualTo: user.role)
          .limit(1)
          .get();
      if (exactSnapshot.docs.isNotEmpty) {
        final matchedId = exactSnapshot.docs.first.id;
        await _persistResolvedRoleId(user.id, matchedId);
        return matchedId;
      }

      final allRolesSnapshot =
          await _firestore.collection(PrivilegeService.rolesCollection).get();
      for (final doc in allRolesSnapshot.docs) {
        final name = (doc.data()['name'] ?? '').toString();
        if (_normalizeRoleName(name) == normalizedRole) {
          final matchedId = doc.id;
          await _persistResolvedRoleId(user.id, matchedId);
          return matchedId;
        }
      }
    } catch (e) {
      Get.log('Error resolving roleId for user ${user.id}: $e');
    }
    return null;
  }

  Future<void> _persistResolvedRoleId(String userId, String roleId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'roleId': roleId});
    } catch (e) {
      Get.log('Failed to persist roleId for user $userId: $e');
    }
  }

  String _normalizeRoleName(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[\s_]+'), ' ');
  }

  Map<String, bool> _flattenPrivileges(
      Map<String, Map<String, Map<String, bool>>> nested) {
    final Map<String, bool> flat = {};
    nested.forEach((category, groups) {
      groups.forEach((group, perms) {
        perms.forEach((permName, value) {
          flat['$category->$group->$permName'] = value;
        });
      });
    });
    return flat;
  }

  // Set user online/offline status in Realtime Database
  Future<void> _setUserOnlineStatus(bool isOnline) async {
    if (currentUser.value == null) return;

    // Update in-memory state immediately so the UI reacts right away,
    // regardless of whether Firebase calls succeed or fail.
    currentUser.value = currentUser.value?.copyWith(isOnline: isOnline);

    // Update Realtime Database (skip if we've detected permission issues)
    if (_realtimeWritesAllowed) {
      try {
        final userStatusRef = _database
            .ref('${AppConstants.onlineUsersPath}/${currentUser.value!.id}');

        if (isOnline) {
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
          await userStatusRef.set({
            'isOnline': false,
            'lastSeen': ServerValue.timestamp,
            'displayName': currentUser.value!.displayName,
            'role': currentUser.value!.role,
          });
        }
      } on FirebaseException catch (e) {
        final msg = e.message ?? e.toString();
        Get.log('Realtime DB write error: $msg');
        if (msg.contains('permission-denied')) {
          _realtimeWritesAllowed = false;
          Get.log('Realtime DB writes disabled due to permission-denied.');
        }
      } catch (e) {
        Get.log('Error setting Realtime DB status: $e');
      }
    } else {
      Get.log(
          'Skipping Realtime DB write: writes disabled due to earlier permission error');
    }

    // Update Firestore (separate try/catch so a permission error here
    // does not undo the in-memory or Realtime DB update)
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.value!.id)
          .update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.log('Error updating Firestore status: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _setUserOnlineStatus(false);

      // Navigate first to unmount any active StreamBuilders in the UI
      Get.offAllNamed(AppRoutes.login);

      // Selectively delete controllers that are not essential for core app
      // Selectively delete controllers. This is more stable than a full Get.reset()
      // and safer than try-catching every deletion.
      if (Get.isRegistered<DeskController>()) {
        Get.delete<DeskController>(force: true);
      }
      if (Get.isRegistered<EditorDashboardController>()) {
        Get.delete<EditorDashboardController>(force: true);
      }
      if (Get.isRegistered<StoryController>()) {
        Get.delete<StoryController>(force: true);
      }
      if (Get.isRegistered<ProducerDashboardController>()) {
        Get.delete<ProducerDashboardController>(force: true);
      }
      if (Get.isRegistered<AnchorDashboardController>()) {
        Get.delete<AnchorDashboardController>(force: true);
      }
      if (Get.isRegistered<ReporterDashboardController>()) {
        Get.delete<ReporterDashboardController>(force: true);
      }
      if (Get.isRegistered<StoryPoolController>()) {
        Get.delete<StoryPoolController>(force: true);
      }
      if (Get.isRegistered<AdminController>()) {
        Get.delete<AdminController>(force: true);
      }
      if (Get.isRegistered<StoryEditorController>()) {
        Get.delete<StoryEditorController>(force: true);
      }
      if (Get.isRegistered<RundownBuilderController>()) {
        Get.delete<RundownBuilderController>(force: true);
      }
      if (Get.isRegistered<NewsroomController>()) {
        Get.delete<NewsroomController>(force: true);
      }

      // A minimal delay to allow UI streams to unmount gracefully.
      await Future.delayed(const Duration(milliseconds: 50));

      _cancelProfileSubscriptions();
      await _auth.signOut();
      currentUser.value = null;
    } catch (e) {
      Get.log('Error signing out: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
      {String? displayName, String? photoUrl}) async {
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
        await _watchUserProfile(uid);
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

  // Get stream of all users
  Stream<List<UserModel>> getUsersStream() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    });
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Password Reset Error',
        _getAuthErrorMessage(e.code),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Password Reset Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return false;
    }
  }

  // Get user IDs by role
  Future<List<String>> getUserIdsByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: role)
          .get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      Get.log('Error getting user IDs by role: $e');
      return [];
    }
  }
}
