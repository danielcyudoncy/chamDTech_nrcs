import 'package:get/get.dart';
import 'package:chamDTech_nrcs/features/auth/views/login_screen.dart';
import 'package:chamDTech_nrcs/features/auth/views/splash_screen.dart';
import 'package:chamDTech_nrcs/features/auth/views/user_management_screen.dart';
import 'package:chamDTech_nrcs/features/stories/views/story_list_screen.dart';
import 'package:chamDTech_nrcs/features/stories/views/story_editor_screen.dart';
import 'package:chamDTech_nrcs/features/rundowns/views/rundown_list_screen.dart';
import 'package:chamDTech_nrcs/features/rundowns/views/rundown_builder_screen.dart';
import 'package:chamDTech_nrcs/features/settings/views/settings_screen.dart';
import 'package:chamDTech_nrcs/features/profile/views/profile_screen.dart';
import 'package:chamDTech_nrcs/features/admin/views/admin_dashboard_screen.dart';
import 'package:chamDTech_nrcs/features/admin/views/master_management_screen.dart';
import 'package:chamDTech_nrcs/features/admin/views/privilege_master_screen.dart';
import 'package:chamDTech_nrcs/features/dashboard/views/shells/reporter_app_shell.dart';
import 'package:chamDTech_nrcs/features/dashboard/views/shells/editor_app_shell.dart';
import 'package:chamDTech_nrcs/features/dashboard/views/shells/producer_app_shell.dart';
import 'package:chamDTech_nrcs/features/dashboard/views/shells/admin_app_shell.dart';
import 'package:chamDTech_nrcs/features/rundowns/views/rundown_builder_screen.dart';
import 'package:chamDTech_nrcs/features/dashboard/views/anchor_dashboard_screen.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String userManagement = '/users';
  static const String storyList = '/stories';
  static const String storyEditor = '/story/editor';
  static const String rundownList = '/rundowns';
  static const String rundownBuilder = '/rundown/builder';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String adminDashboard = '/admin';
  static const String adminPrivileges = '/admin/privileges';
  static const String adminDesignations = '/admin/designations';
  static const String adminStoryState = '/admin/story-state';
  static const String adminFormat = '/admin/format';
  static const String adminSubFormat = '/admin/sub-format';
  static const String adminShowTemplate = '/admin/show-template';
  static const String adminShowMaster = '/admin/show-master';
  static const String adminDesks = '/admin/desks';
  static const String adminWire = '/admin/wire';
  static const String adminLocations = '/admin/locations';
  static const String adminStrings = '/admin/strings';
  static const String adminMosDevices = '/admin/mos-devices';
  static const String adminConfigurations = '/admin/configurations';
  static const String adminAuditTrail = '/admin/audit-trail'; // Admin Audit Trail
  
  static const String reporterDashboard = '/reporter-dashboard';
  static const String editorDashboard = '/editor-dashboard';
  static const String producerDashboard = '/producer-dashboard';
  static const String anchorDashboard = '/anchor-dashboard';
  
  static String getRouteForRole(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return adminDashboard;
      case AppConstants.roleReporter:
        return reporterDashboard;
      case AppConstants.roleEditor:
        return editorDashboard;
      case AppConstants.roleProducer:
        return producerDashboard;
      case AppConstants.roleAnchor:
        return anchorDashboard;
      default:
        // Fallback for unknown roles (use stories as generic workspace for now)
        return storyList;
    }
  }

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: userManagement,
      page: () => const UserManagementScreen(),
    ),
    GetPage(
      name: storyList,
      page: () => const StoryListScreen(),
    ),
    GetPage(
      name: storyEditor,
      page: () => const StoryEditorScreen(),
    ),
    GetPage(
      name: rundownList,
      page: () => const RundownListScreen(),
    ),
    GetPage(
      name: rundownBuilder,
      page: () => const RundownBuilderScreen(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: adminDashboard,
      page: () => const AdminAppShell(), // Updated to new shell
    ),
    GetPage(
      name: reporterDashboard,
      page: () => const ReporterAppShell(),
    ),
    GetPage(
      name: editorDashboard,
      page: () => const EditorAppShell(),
    ),
    GetPage(
      name: producerDashboard,
      page: () => const ProducerAppShell(),
    ),
    GetPage(
      name: adminPrivileges,
      page: () => const PrivilegeMasterScreen(),
    ),
    GetPage(
      name: adminDesignations,
      page: () => const MasterManagementScreen(title: 'Designations'),
    ),
    GetPage(
      name: adminStoryState,
      page: () => const MasterManagementScreen(title: 'Story State'),
    ),
    GetPage(
      name: adminFormat,
      page: () => const MasterManagementScreen(title: 'Format'),
    ),
    GetPage(
      name: adminSubFormat,
      page: () => const MasterManagementScreen(title: 'Sub Format'),
    ),
    GetPage(
      name: adminShowTemplate,
      page: () => const MasterManagementScreen(title: 'Show Template'),
    ),
    GetPage(
      name: adminShowMaster,
      page: () => const MasterManagementScreen(title: 'Show Master'),
    ),
    GetPage(
      name: adminDesks,
      page: () => const MasterManagementScreen(title: 'Desks'),
    ),
    GetPage(
      name: adminWire,
      page: () => const MasterManagementScreen(title: 'Wire'),
    ),
    GetPage(
      name: adminLocations,
      page: () => const MasterManagementScreen(title: 'Locations'),
    ),
    GetPage(
      name: adminStrings,
      page: () => const MasterManagementScreen(title: 'Strings'),
    ),
    GetPage(
      name: adminMosDevices,
      page: () => const MasterManagementScreen(title: 'MOS Devices'),
    ),
    GetPage(
      name: adminConfigurations,
      page: () => const MasterManagementScreen(title: 'Configurations'),
    ),
    GetPage(
      name: adminAuditTrail,
      page: () => const MasterManagementScreen(title: 'Audit Trail'),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
    ),
  ];
}
