// 🎯 Dart imports:

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:get/get.dart';

class PlatformUtils {
  static bool _isWeb() {
    return kIsWeb == true;
  }

  static bool _isAndroid() {
    return _isWeb() ? false : GetPlatform.isAndroid;
  }

  static bool _isIOS() {
    return _isWeb() ? false : GetPlatform.isIOS;
  }

  static bool _isMacOS() {
    return _isWeb() ? false : GetPlatform.isMacOS;
  }

  static bool _isWindows() {
    return _isWeb() ? false : GetPlatform.isWindows;
  }

  static bool _isFuchsia() {
    return _isWeb() ? false : GetPlatform.isFuchsia;
  }

  static bool _isLinux() {
    return _isWeb() ? false : GetPlatform.isLinux;
  }

  static bool get isWeb => _isWeb();

  static bool get isAndroid => _isAndroid();

  static bool get isIOS => _isIOS();

  static bool get isMacOS => _isMacOS();

  static bool get isWindows => _isWindows();

  static bool get isFuchsia => _isFuchsia();

  static bool get isLinux => _isLinux();
}
