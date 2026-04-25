// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';
import 'package:chamdtech_nrcs/app/config/theme_config.dart';
import 'package:chamdtech_nrcs/core/services/firebase_service.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';
import 'package:chamdtech_nrcs/features/rundowns/services/rundown_service.dart';
import 'package:chamdtech_nrcs/core/services/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// For FlutterQuillLocalizations
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quill/translations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Note: we intentionally avoid globally suppressing the browser context menu
// so that users can select and copy text like a normal webpage.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Get.putAsync(() => FirebaseService().init());

  // Initialize Auth Service
  Get.put(AuthService());

  // Initialize Notification Service
  Get.put(NotificationService());

  // Initialize Story & Rundown Services
  Get.put(StoryService());
  Get.put(RundownService());

  // Previously we suppressed the browser context menu which interfered
  // with normal text selection and copying on web. Leave the browser
  // default behavior enabled so users can select/copy text.

  // Run the app normally; `SelectionArea` must be inside the Material app
  // so MaterialLocalizations are available.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'chamDTech NRCS',
          debugShowCheckedModeBanner: false,
          theme: ThemeConfig.lightTheme,
          darkTheme: ThemeConfig.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.routes,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
          ],
        );
      },
    );
  }
}
