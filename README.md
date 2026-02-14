# chamDTech NRCS - README

## Overview

**chamDTech NRCS** is a cross-platform Newsroom Computer System built with Flutter, inspired by professional broadcast newsroom systems like BLAZE NRCS. It provides a comprehensive solution for managing news stories, rundowns, and newsroom workflows across multiple platforms.

## Supported Platforms

- ✅ **Android** - Mobile app (Google Play Store)
- ✅ **iOS** - Mobile app (Apple App Store)
- ✅ **Windows** - Desktop application
- ✅ **macOS** - Desktop application
- ✅ **Web** - Progressive Web App (PWA)

## Features (MVP - Phase 1)

### ✅ Authentication
- Email/password authentication
- Role-based access control (Admin, Producer, Reporter, Editor, Anchor)
- User profile management
- Online/offline status tracking

### ✅ Story Management
- Create and edit stories with rich text editor
- Story metadata (title, slug, duration, tags)
- Story status workflow (Draft → Pending → Approved)
- Story approval system
- Filter stories by status and author
- Real-time story synchronization

### 🔄 Rundown Management (Coming Soon)
- Create and manage broadcast rundowns
- Drag-and-drop story ordering
- Rundown timing and duration tracking
- Multi-rundown view (PowerView)
- Real-time rundown updates

## Technology Stack

- **Framework**: Flutter 3.9.2+
- **State Management**: GetX
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore (database)
  - Firebase Realtime Database (real-time sync)
  - Firebase Storage (media files)
- **Rich Text Editor**: flutter_quill
- **UI Components**: Material Design 3

## Project Structure

```
lib/
├── app/
│   ├── routes/          # Navigation routes
│   ├── themes/          # App themes (light/dark)
│   └── config/          # App configuration
├── core/
│   ├── constants/       # App constants
│   ├── utils/           # Utility functions
│   ├── services/        # Core services (Firebase)
│   └── models/          # Shared models
├── features/
│   ├── auth/            # Authentication feature
│   │   ├── models/
│   │   ├── controllers/
│   │   ├── views/
│   │   └── services/
│   ├── stories/         # Story management feature
│   │   ├── models/
│   │   ├── controllers/
│   │   ├── views/
│   │   └── services/
│   └── rundowns/        # Rundown management feature
│       ├── models/
│       ├── controllers/
│       ├── views/
│       └── services/
└── shared/
    ├── widgets/         # Reusable widgets
    └── layouts/         # Layout components
```

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Firebase account
- Firebase CLI
- FlutterFire CLI

### Installation

1. **Clone the repository**
   ```bash
   cd c:\Users\dudoncy\Documents\GitHub\chamDTech_nrcs
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   
   Follow the detailed instructions in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

4. **Run the app**
   
   ```bash
   # Web
   flutter run -d chrome
   
   # Windows
   flutter run -d windows
   
   # Android
   flutter run -d android
   
   # iOS (macOS only)
   flutter run -d ios
   ```

## Building for Production

### Android (APK/AAB)
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS (IPA)
```bash
flutter build ios --release
```

### Windows
```bash
flutter build windows --release
```

### macOS
```bash
flutter build macos --release
```

### Web
```bash
flutter build web --release
```

## User Roles

- **Admin**: Full system access, user management, approve all content
- **Producer**: Create rundowns, manage stories, approve content
- **Reporter**: Create and edit stories, submit for approval
- **Editor**: Edit stories, review content
- **Anchor**: View rundowns and scripts

## Development Roadmap

### Phase 1: MVP (Current) ✅
- [x] Authentication system
- [x] Story management
- [x] Basic UI/UX
- [ ] Firebase setup and testing

### Phase 2: Enhanced Features
- [ ] Complete rundown management
- [ ] Media upload and management
- [ ] Real-time collaboration
- [ ] User notifications
- [ ] Search and filtering

### Phase 3: Advanced Features
- [ ] News feed ingestion (RSS, wires)
- [ ] Social media publishing
- [ ] Analytics and reporting
- [ ] Mobile offline mode
- [ ] AI-powered tools

### Phase 4: Production Ready
- [ ] Performance optimization
- [ ] Security hardening
- [ ] Comprehensive testing
- [ ] Documentation
- [ ] App store deployment

## Contributing

This is a private project. For questions or suggestions, contact the development team.

## License

Proprietary - chamDTech © 2026

## Support

For technical support or questions:
- Email: [your-email]
- Documentation: See FIREBASE_SETUP.md and other docs in the project

---

**Built with ❤️ using Flutter**
