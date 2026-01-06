// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

/// 混杂工具类，包括系统向光的功能，震动反馈
class MiscUtil {
  /// 震动
  static Future<void> vibrate() async {
    return await HapticFeedback.lightImpact();

    // if (_canVibrate == null) {
    //   log.d('[VIBRATE] need test can vibrate.');
    //   _canVibrate = await Vibrate.canVibrate;
    // }
    // if (_canVibrate) {
    //   Vibrate.feedback(FeedbackType.impact);
    // }
  }

  /// 获取公用的dir目录
  static Future<Directory?> getCommonDir() async {
    Directory? dir;
    if (kIsWeb) return null;
    if (GetPlatform.isIOS) {
      // dir = await getTemporaryDirectory();
      dir = await getApplicationSupportDirectory();
    } else if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else if (Platform.isFuchsia) {
      dir = await getApplicationSupportDirectory();
    } else if (Platform.isMacOS) {
      dir = await getApplicationSupportDirectory();
    } else if (Platform.isLinux) {
      dir = await getApplicationSupportDirectory();
    } else if (Platform.isWindows) {
      dir = await getApplicationSupportDirectory();
    } else {
      dir = await getExternalStorageDirectory();
    }
    return dir;
  }
}
