// 🐦 Flutter imports:
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/plugins_utils/FirebaseUtils/firebse_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/model/home/qrmodel.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/m3u8_cache_manager.dart';
import '../../../../../r.dart';
import '../../../../dialog/accont_qr_dialog.dart';
import '../../../../model/home/gold_task_model.dart';
import '../../../../model/home/user_info_model.dart';
import '../../../../notifier/bus_events.dart';
import '../../../../routes/app_pages.dart';

class HomeMineCenterController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late Rx<UserInfo> userInfo = UserInfo().obs;
  TabController? tabController;
  late RxList<GoldTaskModel> actions = <GoldTaskModel>[].obs;
  late RxList<GoldTaskModel> questions = <GoldTaskModel>[].obs;
  final count = 0.obs;
  RxBool initOk = false.obs;
  RxBool dayTimeModel = false.obs;
  RxList<GoldTaskModel> tab1List = <GoldTaskModel>[].obs;
  RxList<GoldTaskModel> tab2List = <GoldTaskModel>[].obs;

  List<int> growthList = [0, 50, 50, 1500, 9000, 50000, 300000, 800000];
  late List<LinearGradient> vipLinearGradient;
  late QrModel? qrModel;
  RxDouble getBalanceIng = .0.obs;
  RxDouble cacheSize = .0.obs;
  String baseUrl = "";

  List<GoldTaskModel> logoList = [
    GoldTaskModel(name: "default", title: "快猫APP", icon: R.assetsImgLogo),
    GoldTaskModel(name: "doule", title: "抖乐", icon: R.assetsImgLogoDoule),
    GoldTaskModel(name: "rona", title: "RONA", icon: R.assetsImgLogoRona),
    GoldTaskModel(name: "xiutan", title: "嗅探", icon: R.assetsImgLogoXiutan),
  ];

  // eventBus.on(EventsBusKey.homeVideoPause)?.listen((event) {
  //     if (event.arguments == "updated")
  // });
  @override
  void onInit() async {
    super.onInit();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    tabController = TabController(length: 2, vsync: this);
    userInfo.value = await shareKeys.getUserInfo();
    cacheSize.value = await M3u8CacheManager().getCacheSizeMB();
    eventBus.on(EventsBusKey.subUpdateUserInfo)?.listen((event) async {
      ShareKeys shareKeys = Get.find<ShareKeys>();
      userInfo.value = shareKeys.userInfo;
      baseUrl = shareKeys.baseUrl;
      update();
    });
    getTab1List();
    getTab2List();
    QrModel? model = await ApiRes.getUserQrCode();
    if (model != null) {
      qrModel = model;
    }
    initOk.value = true;
    update();
  }

  void getTab2List() {
    tab2List.value = [
      GoldTaskModel(
          name: "兑换码",
          icon: R.assetsImgIconMineExchange,
          onTap: () =>
              Get.toNamed(Routes.TICKET_MANAGE_PAGE, arguments: {"type": 3})),
      GoldTaskModel(
          name: "抽奖卷",
          icon: R.assetsImgIconMineLottery,
          onTap: () =>
              Get.toNamed(Routes.TICKET_MANAGE_PAGE, arguments: {"type": 1})),
      // GoldTaskModel(
      //     name: "观影卷",
      //     icon: R.assetsImgIconMineFree,
      //     onTap: () =>
      //         Get.toNamed(Routes.TICKET_MANAGE_PAGE, arguments: {"type": 2})),
    ];
  }

  void getTab1List() {
    tab1List.value = [
      GoldTaskModel(
          name: "我的缓存",
          icon: R.assetsImgIconMineDownload,
          onTap: () => Get.toNamed(Routes.WELFARE_TASK_PAGE)),
      GoldTaskModel(
          name: "官方活动",
          icon: R.assetsImgIconMineActivity,
          onTap: () => Get.toNamed(Routes.SHARE_APP_PAGE, arguments: {
                "shareType": "${ShareType.showTypeLongMedia.index}",
                "recordType": "${RecordType.recordTypeShare.index}",
              })),
      GoldTaskModel(
          name: "找回账号",
          icon: R.assetsImgIconMineFindback,
          onTap: () => Get.toNamed(Routes.WELFARE_TASK_PAGE)),
      GoldTaskModel(
          name: "账号凭证",
          icon: R.assetsImgIconMineCertif,
          onTap: () => showAccountQrDialog(Get.context!)),
      GoldTaskModel(
          name: "兑换码",
          icon: R.assetsImgIconMineExchange,
          onTap: () =>
              Get.toNamed(Routes.TICKET_MANAGE_PAGE, arguments: {"type": 3})),
      // GoldTaskModel(
      //     name: "游戏充值记录",
      //     icon: R.assetsImgIconMineRecharge,
      //     onTap: () => Get.toNamed(Routes.BILL_RECORD_PAGE_VIEW,
      //         arguments: {"type": 0})),
      // GoldTaskModel(
      //     name: "游戏提现记录",
      //     icon: R.assetsImgIconMineWithdraw,
      //     onTap: () => Get.toNamed(Routes.BILL_RECORD_PAGE_VIEW,
      //         arguments: {"type": 1})),
      // GoldTaskModel(
      //     name: "游戏收支明细",
      //     icon: R.assetsImgIconMineRecord,
      //     onTap: () => Get.toNamed(Routes.BILL_RECORD_PAGE_VIEW,
      //         arguments: {"type": 2})),
      // GoldTaskModel(
      //     name: "游戏记录",
      //     icon: R.assetsImgIconMineGame,
      //     onTap: () => Get.toNamed(Routes.BILL_RECORD_PAGE_VIEW,
      //         arguments: {"type": 3})),
      // GoldTaskModel(
      //     name: "我的收藏",
      //     icon: R.assetsImgIconMineCollect,
      //     onTap: () => Get.toNamed(Routes.MINE_COLLECT_PAGE)),
    ];
  }

  void changeAppIcon(String name) {
    showPlayerCommonDialog(Get.context!,
        title: "友情提示",
        content: "是否切换手机桌面图标以实现APP隐身？ ",
        btnList: ["取消", "确定"],
        btnCall: [
          () => Get.back(),
          () async {
            await FirebaseUtils.firebaseLogEvent(
                eventName: "changeAppIcon",
                routePath: Routes.SPLASH_PAGE,
                eventArgs: {"iconName": name});
            const platform = MethodChannel("com.insert/device");
            await platform.invokeMethod("changIcon", {"iconName": name});
          }
        ],
        btnActionIndex: 1);
  }

  @override
  void onReady() async {
    super.onReady();
    tabController?.addListener(() {
      count.value = tabController?.index ?? 0;
    });
  }

  Future<Advertise?> getGameAds() async {
    try {
      Advertise? ad =
          await LocalAdsStore().randomWhere(AdsType.minePageGameAds);
      return ad;
    } on PlatformException catch (e) {
      throw Exception(e.code);
    }
  }

  void increment() => count.value++;
}
