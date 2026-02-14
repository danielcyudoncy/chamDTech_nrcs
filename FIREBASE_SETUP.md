# chamDTech NRCS - Firebase Setup Guide

## Prerequisites

1. **Flutter SDK** installed and configured
2. **Firebase CLI** installed: `npm install -g firebase-tools`
3. **FlutterFire CLI** installed: `dart pub global activate flutterfire_cli`

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: **chamDTech-NRCS** (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Configure Firebase for Flutter

### Option A: Using FlutterFire CLI (Recommended)

```bash
# Navigate to project directory
cd c:\Users\dudoncy\Documents\GitHub\chamDTech_nrcs

# Login to Firebase
firebase login

# Configure FlutterFire
flutterfire configure
```

This will:
- Create Firebase apps for all platforms (Android, iOS, Web, Windows, macOS)
- Generate `firebase_options.dart` file
- Update platform-specific configuration files

### Option B: Manual Configuration

If FlutterFire CLI doesn't work, follow these manual steps:

#### 1. Android Configuration

1. In Firebase Console, add an Android app
2. Package name: `com.newsroom.chamDTech_nrcs`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`
5. Update `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
6. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### 2. iOS Configuration

1. In Firebase Console, add an iOS app
2. Bundle ID: `com.newsroom.chamDTech-nrcs`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

#### 3. Web Configuration

1. In Firebase Console, add a Web app
2. Copy the Firebase config
3. Update `web/index.html` with Firebase SDK scripts

#### 4. Windows & macOS

These will use the same Firebase project but require `firebase_options.dart` file.

## Step 3: Enable Firebase Services

### 1. Authentication

1. Go to Firebase Console → Authentication
2. Click "Get started"
3. Enable "Email/Password" sign-in method
4. (Optional) Enable other providers (Google, Facebook, etc.)

### 2. Firestore Database

1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Choose "Start in **test mode**" (for development)
4. Select your region
5. Click "Enable"

**Security Rules (for development):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3. Realtime Database

1. Go to Firebase Console → Realtime Database
2. Click "Create Database"
3. Choose "Start in **test mode**"
4. Select your region
5. Click "Enable"

**Security Rules (for development):**
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

### 4. Firebase Storage

1. Go to Firebase Console → Storage
2. Click "Get started"
3. Choose "Start in **test mode**"
4. Select your region
5. Click "Done"

**Security Rules (for development):**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 4: Update Firebase Options

After running `flutterfire configure`, you should have a `lib/firebase_options.dart` file.

Update `lib/core/services/firebase_service.dart` to use it:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:chamDTech_nrcs/firebase_options.dart'; // Add this import

Future<FirebaseService> init() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Add this line
    );
    // ... rest of the code
  }
}
```

## Step 5: Test the Setup

Run the app on different platforms:

```bash
# Web
flutter run -d chrome

# Windows
flutter run -d windows

# Android (with emulator or device)
flutter run -d android

# iOS (macOS only, with simulator or device)
flutter run -d ios
```

## Step 6: Create First Admin User

Since you need an admin to approve users, create one manually:

1. Run the app
2. Sign up with your admin email
3. Go to Firebase Console → Firestore Database
4. Find your user document in the `users` collection
5. Edit the document and change `role` to `admin`

## Troubleshooting

### Issue: "No Firebase App has been created"
**Solution**: Make sure `Firebase.initializeApp()` is called in `main.dart` before `runApp()`

### Issue: "MissingPluginException"
**Solution**: Run `flutter clean` and `flutter pub get`, then rebuild

### Issue: Platform-specific build errors
**Solution**: 
- Android: Ensure Google Services plugin is applied
- iOS: Ensure GoogleService-Info.plist is in the correct location
- Web: Check that Firebase SDK scripts are in index.html

### Issue: "Permission denied" errors
**Solution**: Update Firebase Security Rules to allow authenticated users

## Production Security Rules

Before deploying to production, update your security rules:

### Firestore Rules (Production)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read all user profiles but only update their own
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Stories: authenticated users can read, authors can write
    match /stories/{storyId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (resource.data.authorId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Rundowns: authenticated users can read, producers/admins can write
    match /rundowns/{rundownId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['producer', 'admin']);
      allow update, delete: if request.auth != null && 
        (resource.data.producerId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
  }
}
```

## Next Steps

1. ✅ Complete Firebase setup
2. ✅ Test authentication flow
3. ✅ Create test stories
4. 🔄 Implement rundown management (Phase 2)
5. 🔄 Add media upload functionality (Phase 2)
6. 🔄 Implement real-time collaboration (Phase 2)

## Support

For issues or questions:
- Firebase Documentation: https://firebase.google.com/docs
- FlutterFire Documentation: https://firebase.flutter.dev/
