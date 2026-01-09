// 📦 Package imports:
import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/dialog/accont_qr_dialog.dart';
import 'package:quick_cat_client/app/dialog/advertise_dialog.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/model/home/bottom_bar_model_model.dart';
import 'package:quick_cat_client/app/modules/home/home_mine_center/controllers/home_mine_center_controller.dart';
import 'package:quick_cat_client/app/modules/home/home_post_page/controllers/home_post_page_controller.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/fijk_player.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/m3u8_cache_manager.dart';
import 'package:quick_cat_client/r.dart';

class HomeController extends GetxController {
  final count = 0.obs;
  final tabIndex = 0.obs;
  RxBool developer = false.obs;
  DateTime? lastBackTime;
  Duration gap = Duration(seconds: 3);
  RxList<BottomBarModel> bottomList = [BottomBarModel()].obs;

  void changeTabIndex(int index) async {
    tabIndex.value = index;
    ShareKeys shareKeys = Get.find<ShareKeys>();
    shareKeys.tabIndex.value = index;
    HomePostPageController tiktok = Get.find<HomePostPageController>();
    // ===========跳转进入我的页面重新更新用户信息 ==========
    if (index == 2) {
      FIJKPlayerManager manager = FIJKPlayerManager();
      manager.disposePlayer();

      tiktok.tiktokPlayer.togglePause(false);
    } else {
      tiktok.tiktokPlayer.togglePause(true);
    }

    if (index == 4) {
      if(!shareKeys.showAccounted){
        shareKeys.showAccounted = true;
        showAccountQrDialog(Get.context!);
      }
      await ApiRes.getUpdateUserInfo();
      HomeMineCenterController mine = Get.find<HomeMineCenterController>();
      mine.cacheSize.value =
          await M3u8CacheManager().getCacheSizeMB();
    } else if (index == 0 || index == 2 || index == 1) {
      showDialogAds();
    } else if (index == 3) {
      showDialogAds();
    }
  }

  @override
  void onInit() {
    super.onInit();
    createButton();
  }

  showDialogAds() async {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    if (!(shareKeys.userInfo.isActiveMember ?? false)) {
      List<Advertise> adsList =
          await LocalAdsStore().where(AdsType.homePopUpsAds);
      for (Advertise item in adsList) {
        await showAdvertiseDialog(Get.context!, item);
      }
    }
  }

  createButton() {
    bottomList.value = [
      BottomBarModel(
          title: "首页",
          icon: R.assetsImgHomeIndexIcon,
          selectIcon: R.assetsImgHomeIndexIconSel),
      BottomBarModel(
          title: "视频",
          icon: R.assetsImgHomeIndexPlayer,
          selectIcon: R.assetsImgHomeIndexPlayerSel),
      BottomBarModel(
          title: "抖音",
          icon: R.assetsImgHomeIndexCircle,
          selectIcon: R.assetsImgHomeIndexCircleSel),
      BottomBarModel(
          title: "娱乐",
          icon: R.assetsImgHomeIndexGame,
          selectIcon: R.assetsImgHomeIndexGameSel),
      BottomBarModel(
          title: "我的",
          icon: R.assetsImgHomeIndexMine,
          selectIcon: R.assetsImgHomeIndexMineSel),
    ];
  }

  void increment() => count.value++;
}
