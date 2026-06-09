import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/firebase_options.dart';

class FirebaseService extends GetxService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseDatabase get database => FirebaseDatabase.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  
  Future<FirebaseService> init() async {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      Get.log('Initializing Firebase with: API Key: "${options.apiKey}", App ID: "${options.appId}", Project ID: "${options.projectId}"');
      await Firebase.initializeApp(
        options: options,
      );
      Get.log('Firebase initialized successfully');
      
      // Configure Firestore settings
      if (!kIsWeb) {
        firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      
        // Enable offline persistence for Realtime Database
        database.setPersistenceEnabled(true);
        database.setPersistenceCacheSizeBytes(10000000);
      }
      
      return this;
    } catch (e) {
      Get.log('Firebase initialization error: $e');
      rethrow;
    }
  }
  
  // Helper method to check connection status
  Future<bool> isConnected() async {
    try {
      final connectedRef = database.ref('.info/connected');
      final snapshot = await connectedRef.get();
      return snapshot.value == true;
    } catch (e) {
      return false;
    }
  }
}
