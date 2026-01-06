import 'package:flutter/foundation.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

// 🐦 Flutter imports:

// 📦 Package imports:

class FirebaseUtils {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static Future<void> firebaseLogEvent(
      {String? eventName, String? routePath, eventArgs}) async {
    eventArgs?["routePath"] = routePath ?? "";
    await analytics.logEvent(
      name: eventName ?? "",
      parameters: eventArgs,
    );

    Get.log('logEvent succeeded');
  }

  static Future<void> setDefaultEventParameters(
      {String? eventName,
      String? routePath,
      Map<String, dynamic>? eventArgs}) async {
    if (kIsWeb) {
      Get.log(
        '"setDefaultEventParameters()" is not supported on web platform',
      );
    } else {
      if (eventArgs != null) {
        eventArgs["eventName"] = eventName;
        eventArgs["routePath"] = routePath;
      }
      await analytics.setDefaultEventParameters(eventArgs);
      Get.log('setDefaultEventParameters succeeded');
    }
  }
}
