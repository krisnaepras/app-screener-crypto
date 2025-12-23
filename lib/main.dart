import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'services/fcm_service.dart';
import 'ui/main_navigation.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (only on mobile)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      print('✓ Firebase initialized');
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  }

  // Initialize Services only on mobile platforms
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await NotificationService.initialize();
    await initializeService();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    // Only on mobile
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    try {
      // Request notification permission
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✓ FCM permission granted');

        // Get FCM token
        String? token = await messaging.getToken();
        if (token != null) {
          print('FCM Token: $token');
          // Register token with backend
          await FcmService.registerToken(token);
        }

        // Handle token refresh
        messaging.onTokenRefresh.listen((newToken) {
          print('FCM Token refreshed: $newToken');
          FcmService.registerToken(newToken);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Foreground message: ${message.notification?.title}');

          // Show local notification
          if (message.notification != null) {
            NotificationService.showNotification(
              id: message.hashCode,
              title: message.notification!.title ?? 'Alert',
              body: message.notification!.body ?? '',
            );
          }
        });

        // Handle notification tap (app opened from notification)
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('Notification tapped: ${message.data}');
          // Navigate to specific screen if needed
        });
      } else {
        print('FCM permission denied');
      }
    } catch (e) {
      print('FCM initialization error: $e');
    }
  }

  Future<void> _requestPermissions() async {
    // Only request permissions on Android/iOS
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation
          .requestNotificationsPermission();
      if (granted ?? true) {
        // Start service only in main isolate
        try {
          final service = FlutterBackgroundService();
          final isRunning = await service.isRunning();
          if (!isRunning) {
            await service.startService();
          }
        } catch (e) {
          print('Error starting service: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Modern color scheme with vibrant accents
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1), // Indigo
      brightness: Brightness.dark,
      primary: const Color(0xFF6366F1),
      secondary: const Color(0xFF8B5CF6), // Purple
      tertiary: const Color(0xFF06B6D4), // Cyan
      surface: const Color(0xFF0F172A), // Slate 900
      background: const Color(0xFF020617), // Slate 950
    );

    final baseTheme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colorScheme.background,
    );

    final appTheme = baseTheme.copyWith(
      visualDensity: VisualDensity.compact,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: colorScheme.surface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: colorScheme.outline.withOpacity(0.1),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.surface,
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    return MaterialApp(
      title: 'Screener Micin App',
      theme: appTheme,
      darkTheme: appTheme,
      themeMode: ThemeMode.dark,
      home: const MainNavigation(),
    );
  }
}
