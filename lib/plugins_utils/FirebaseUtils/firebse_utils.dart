import 'package:flutter/foundation.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

// 🐦 Flutter imports:

// 📦 Package imports:

class FirebaseUtils {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static Future<void> firebaseLogEvent(
      {String? eventName, String? routePath, eventArgs}) async {
    try {
      eventArgs?["routePath"] = routePath ?? "";
      await analytics.logEvent(
        name: eventName ?? "",
        parameters: eventArgs,
      );
    } catch (_) {}
  }

  static Future<void> setDefaultEventParameters(
      {String? eventName,
      String? routePath,
      Map<String, dynamic>? eventArgs}) async {
    if (kIsWeb) {
      return;
    } else {
      try {
        if (eventArgs != null) {
          eventArgs["eventName"] = eventName;
          eventArgs["routePath"] = routePath;
        }
        await analytics.setDefaultEventParameters(eventArgs);
      } catch (_) {}
    }
  }
}
