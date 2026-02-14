class AppConstants {
  // App Info
  static const String appName = 'chamDTech NRCS';
  static const String appVersion = '1.1.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String storiesCollection = 'stories';
  static const String rundownsCollection = 'rundowns';
  static const String desksCollection = 'desks';
  static const String messagesCollection = 'messages';
  static const String templatesCollection = 'templates';
  
  // Firebase Realtime Database Paths
  static const String onlineUsersPath = 'online_users';
  static const String rundownUpdatesPath = 'rundown_updates';
  static const String storyUpdatesPath = 'story_updates';
  static const String storyLocksPath = 'story_locks';
  
  // User Roles & Designations
  static const String roleAdmin = 'admin';
  static const String roleProducer = 'producer';
  static const String roleReporter = 'reporter';
  static const String roleAnchor = 'anchor';
  static const String roleEditor = 'editor';

  // Designations (Hierarchy)
  static const String desigExecutiveProducer = 'executive_producer';
  static const String desigSeniorProducer = 'senior_producer';
  static const String desigProducer = 'producer';
  static const String desigAssociateProducer = 'associate_producer';
  static const String desigChiefReporter = 'chief_reporter';
  static const String desigReporter = 'reporter';
  static const String desigAssistantEditor = 'assistant_editor';

  // Story Stages (Lifecycle)
  static const String stageNew = 'new';
  static const String stageCopyEdited = 'copy_edited';
  static const String stageVerified = 'verified';
  static const String stageReadyToAir = 'ready_to_air';
  static const String stageAired = 'aired';
  
  // Story Status (UI Status)
  static const String statusDraft = 'draft';
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusArchived = 'archived';

  // Story Formats
  static const String formatVO = 'VO';
  static const String formatVOSOT = 'VO-SOT';
  static const String formatPackage = 'PKG';
  static const String formatLive = 'LIVE';
  static const String formatGraphic = 'GFX';
  
  // Rundown Status
  static const String rundownActive = 'active';
  static const String rundownCompleted = 'completed';
  static const String rundownScheduled = 'scheduled';
  static const String rundownOnAir = 'on_air';
  
  // Storage Paths
  static const String mediaStoragePath = 'media';
  static const String profilePicturesPath = 'profile_pictures';
  static const String storyMediaPath = 'story_media';
  
  // Local Storage Keys
  static const String keyUserData = 'user_data';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyOfflineStories = 'offline_stories';
  
  // Pagination
  static const int storiesPerPage = 20;
  static const int rundownsPerPage = 10;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration realtimeTimeout = Duration(seconds: 10);
  static const Duration autoSaveInterval = Duration(seconds: 30);
}
