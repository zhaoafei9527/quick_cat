// 🐦 Flutter imports:
import 'package:acgn_client/plugins_utils/VideoPlayer/fijk_player.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/share_key.dart';
import 'package:acgn_client/app/dialog/common_dialog.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/plugins_utils/FirebaseUtils/firebse_utils.dart';
import 'package:acgn_client/utils/app_util.dart';
import 'package:acgn_client/utils/screen.dart';

class GameWebViewPageController extends GetxController {
  RxBool enterLoading = false.obs;
  RxString webViewUri = "".obs;
  RxBool openGameUtils = false.obs;
  RxBool webViewLoading = true.obs;
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
        btnCall: [() => Get.back(), () async => AppUtils.jumpToHome(index: 2)]);
  }

  initGameWebViewPage() {
    FIJKPlayerManager manager = FIJKPlayerManager();
    manager.disposePlayer();
    openGameUtils.value = false;
    webViewLoading.value = true;
    webViewUri.value = Get.arguments?['uri'] ?? "";
  }

  @override
  void onClose() {
    super.onClose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    // webViewController?.dispose();
  }
}
