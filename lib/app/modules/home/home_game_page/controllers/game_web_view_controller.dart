// 🐦 Flutter imports:
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/fijk_player.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/plugins_utils/FirebaseUtils/firebse_utils.dart';
import 'package:quick_cat_client/utils/app_util.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:quick_cat_client/utils/text_util.dart';

enum GameWebContentType { url, html }

class GameWebViewPayload {
  final GameWebContentType type;
  final String content;
  final int? gamePlatform;

  const GameWebViewPayload({
    required this.type,
    required this.content,
    this.gamePlatform,
  });
}

class GameWebViewPayloadStore {
  static final Map<String, GameWebViewPayload> _cache = {};

  static String put(GameWebViewPayload payload) {
    final key = '${DateTime.now().microsecondsSinceEpoch}_${payload.hashCode}';
    _cache[key] = payload;
    return key;
  }

  static GameWebViewPayload? take(String? key) {
    if (key == null || key.isEmpty) return null;
    return _cache.remove(key);
  }
}

class GameWebViewPageController extends GetxController {
  RxBool enterLoading = false.obs;
  RxString webViewUri = "".obs;
  RxString webViewHtml = "".obs;
  RxBool openGameUtils = false.obs;
  RxBool webViewLoading = true.obs;
  int? platform; // 游戏平台
  RxInt balance = 0.obs;
  InAppWebViewController? webViewController;
  Rx<Offset> floatingPosition = Offset((screen.screenWidth / 2), 100).obs;

  @override
  void onInit() async {
    super.onInit();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive,
        overlays: SystemUiOverlay.values);
    initGameWebViewPage();
    await FirebaseUtils.firebaseLogEvent(
      eventName: "ENTER_GAME_WEB_VIEW",
      routePath: Routes.ENTER_GAME_WEB_VIEW,
    );
  }

  quiteExitGame() async {
    List<String> btnList = ["否", "是"];
    ShareKeys shareKeys = Get.find<ShareKeys>();
    shareKeys.getUserBalance();
    await showPlayerCommonDialog(Get.context!,
        isGameDialog: true,
        content: "确认退出游戏？",
        btnList: btnList,
        btnCall: [
          () => Get.back(),
          () async {
            AppUtils.jumpToHome(index: 2);
            ApiRes.exitGame(gamePlatform: platform ?? 0);
          }
        ]);
  }

  exitGame() async {
    ApiRes.exitGame(gamePlatform: platform ?? 0);
  }

  static Future<void> openGameWebView({
    String? uri,
    String? html,
    int? gamePlatform,
  }) async {
    final bool hasUri = (uri ?? "").isNotEmpty;
    final bool hasHtml = (html ?? "").isNotEmpty;
    if (!hasUri && !hasHtml) {
      Get.toNamed(Routes.ENTER_GAME_WEB_VIEW, arguments: {
        "gamePlatform": gamePlatform,
      });
      return;
    }
    final payload = GameWebViewPayload(
      type: hasHtml ? GameWebContentType.html : GameWebContentType.url,
      content: hasHtml ? (html ?? "") : (uri ?? ""),
      gamePlatform: gamePlatform,
    );
    final payloadKey = GameWebViewPayloadStore.put(payload);
    await Get.toNamed(Routes.ENTER_GAME_WEB_VIEW, arguments: {
      "payloadKey": payloadKey,
      "gamePlatform": gamePlatform,
    });
  }

  bool get hasValidContent =>
      webViewUri.value.isNotEmpty || webViewHtml.value.isNotEmpty;

  bool get isHtmlMode => webViewHtml.value.isNotEmpty;

  bool _isHttpUrl(String value) {
    final lower = value.toLowerCase();
    return lower.startsWith("http://") || lower.startsWith("https://");
  }

  initGameWebViewPage() {
    FIJKPlayerManager manager = FIJKPlayerManager();
    manager.disposePlayer();
    openGameUtils.value = false;
    webViewLoading.value = true;
    webViewUri.value = "";
    webViewHtml.value = "";

    final args = (Get.arguments is Map) ? Get.arguments as Map : {};
    final payload =
        GameWebViewPayloadStore.take((args['payloadKey'] ?? "").toString());
    if (payload != null) {
      platform = payload.gamePlatform ??
          int.tryParse((args['gamePlatform'] ?? "").toString()) ??
          TextUtil.getIntArgument('gamePlatform');
      final content = payload.content;
      final bool shouldUseHtml = payload.type == GameWebContentType.html ||
          (payload.type == GameWebContentType.url && !_isHttpUrl(content));
      if (shouldUseHtml) {
        webViewHtml.value = content;
      } else {
        webViewUri.value = content;
      }
      return;
    }

    final rawUri = (args['uri'] ?? "").toString();
    final rawHtml = (args['html'] ?? "").toString();
    platform = int.tryParse((args['gamePlatform'] ?? "").toString()) ??
        TextUtil.getIntArgument('gamePlatform');
    if (rawHtml.isNotEmpty) {
      webViewHtml.value = rawHtml;
    } else if (rawUri.isNotEmpty) {
      // 兼容历史参数：uri 可能直接传 html 内容
      if (_isHttpUrl(rawUri)) {
        webViewUri.value = rawUri;
      } else {
        webViewHtml.value = rawUri;
      }
    }
  }

  @override
  void onClose() {
    super.onClose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    // webViewController?.dispose();
  }
}
