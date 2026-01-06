// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/pubspec.dart';

class AppConfig {
  static const DEBUG = Pubspec.debug;

  static const PAGE_SIZE = 10;

  /// m3u8 视频解密密钥请求接口
  static const M3U8_KEY_SECRET = "/api/app/media/enkey";

  ///防重复攻击密钥
  static const ANTI_REPLAY_ATTACK_KEY = "kaFtkDJRcchRMTI9";

  ///加密密钥
  static String get encryptKey {
    //app ? "bTdlcG9VOWJCbDhJNkZPcHBzcXp4emVMOGE2RFJ5N0g=" : "aE1hMURDRzYwSVpxWmJaShZpNWVUR2VYN3NyNTFVT2EK"
    String a = kIsWeb ? "MjMxMWIxNWE0ZGEx" : "ZGtWMWEwRW1kJkUx";
    String b = kIsWeb ? "YzgwZGM1NDFiOT" : "ZWpSV1FVUXphI";
    String c = kIsWeb ? "lhYmI2MjIyMzM=" : "0ZaSTJaclQjTnU=";
    String ret = String.fromCharCodes(base64Decode(a + b + c));
    return ret;
  }
  static List<String>? get serverLines {
    List<String> lines = Pubspec.dev_h5_lines.cast<String>();
    if (!kIsWeb) {
      // app 接口线路
      lines = (DEBUG ? Pubspec.dev_app_lines : Pubspec.prod_app_lines)
          .cast<String>();
    } else {
      // web 接口线路
      lines =
          (DEBUG ? Pubspec.dev_h5_lines : Pubspec.prod_h5_lines).cast<String>();
    }
    return lines;
  }

  //上一次服务器的线路信息
  static const String KEY_SERVER_LINES = "_key_server_lines_${AppConfig.DEBUG}";

  //更新信息
  static const String KEY_VERSION_INFO = "_key_version_info_${AppConfig.DEBUG}";

  // 是否弹出账号凭证弹窗
  static const String KEY_SAVE_QR_CODE = "_key_save_qr_code_${AppConfig.DEBUG}";

  // 是否弹出验证弹窗
  static const String KEY_SHOW_CAPTCHA = "_key_show_captcha_${AppConfig.DEBUG}";

  // 搜索历史
  static const String KEY_SEARCH_HISTORYS =
      "_key_search_history_${AppConfig.DEBUG}";

  // 是否使用过体验震动
  static const String KEY_EXPERIENCE_BOOM =
      "_key_experience_boom_${AppConfig.DEBUG}";
}
