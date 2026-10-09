import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Centralized Firebase Crashlytics & Error Telemetry Service for Okdoz Delivery Partner App.
class CrashService {
  CrashService._internal();
  static final CrashService instance = CrashService._internal();

  static bool _initialized = false;

  /// Initialize Crashlytics and hook global error listeners
  static Future<void> initialize({String appRole = 'delivery'}) async {
    if (_initialized) return;
    _initialized = true;

    try {
      if (!kIsWeb) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

        // Catch Flutter framework errors (map rendering, GPS widgets, UI exceptions)
        FlutterError.onError = (FlutterErrorDetails details) {
          FlutterError.presentError(details);
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
          debugPrint('[CrashService] Captured Delivery framework fatal error: ${details.exceptionAsString()}');
        };

        // Catch asynchronous errors (background GPS updates, network drops, async tasks)
        PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          debugPrint('[CrashService] Captured Delivery async fatal error: $error');
          return true;
        };

        await FirebaseCrashlytics.instance.setCustomKey('app_role', appRole);
        await FirebaseCrashlytics.instance.setCustomKey('app_name', 'Okdoz Delivery Rider App');

        debugPrint('[CrashService] Delivery Crashlytics initialized.');
      } else {
        FlutterError.onError = (FlutterErrorDetails details) {
          FlutterError.presentError(details);
          debugPrint('[CrashService Web] Framework error: ${details.exceptionAsString()}');
        };
        PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
          debugPrint('[CrashService Web] Async error: $error\n$stack');
          return true;
        };
      }

      _configureGlobalErrorWidget();
    } catch (e, stack) {
      debugPrint('[CrashService] Initialization warning: $e\n$stack');
    }
  }

  static Future<void> setUserId(String? userId) async {
    if (kIsWeb) return;
    try {
      if (userId == null || userId.isEmpty) {
        await FirebaseCrashlytics.instance.setUserIdentifier('');
      } else {
        await FirebaseCrashlytics.instance.setUserIdentifier(userId);
      }
    } catch (e) {
      debugPrint('[CrashService] Failed to set delivery rider id: $e');
    }
  }

  static Future<void> setCustomKey(String key, Object value) async {
    if (kIsWeb) return;
    try {
      if (value is int) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is double) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is bool) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else {
        await FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
      }
    } catch (e) {
      debugPrint('[CrashService] Failed to set custom key $key: $e');
    }
  }

  static void log(String message) {
    if (kIsWeb) {
      debugPrint('[CrashService Breadcrumb] $message');
      return;
    }
    try {
      FirebaseCrashlytics.instance.log(message);
    } catch (e) {
      debugPrint('[CrashService] Log warning: $e');
    }
  }

  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    debugPrint('[CrashService] Recording delivery error: $exception');
    if (kIsWeb) return;
    try {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        reason: reason,
        information: information,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('[CrashService] Failed to record error: $e');
    }
  }

  static void _configureGlobalErrorWidget() {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return Material(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.two_wheeler,
                    color: Colors.blue.shade700,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Rider App Notice',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A temporary screen glitch occurred. The dispatch team has been notified.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    };
  }
}
