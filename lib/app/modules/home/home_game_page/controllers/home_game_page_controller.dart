// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:quick_cat_client/r_insert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/game_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import '../../../../../utils/light_model.dart';
import '../../../../model/home/user_info_model.dart';

class HomeGamePageController extends GetxController
    with GetTickerProviderStateMixin {
  RxList<GameInfoBean> btnIconList = <GameInfoBean>[].obs;
  RxList<String> btnSelIconList = <String>[].obs;
  RxBool enterLoading = false.obs;
  RxMap<int, List<GameInfoBean>> gameTypeList = <int, List<GameInfoBean>>{}.obs;
  final actionIndex = 0.obs;
  RxDouble getBalanceIng = .0.obs;
  List<GameInfoBean> gameList = [];
  TabController? tabController; // 首页主分类
  TabController? gameTabController; // 游戏分类
  ScrollController gameTypeScrollController = ScrollController();
  RxInt currentTabIndex = 0.obs;
  List<String> cateTopList = ["娱乐中心", "高能涩游"];
  RxList<GameInfoBean> historyGame = <GameInfoBean>[].obs;
  late Rx<UserInfo> userInfo = UserInfo().obs;
  GameCategory actionGameCategory = GameCategory.gameCategoryQP; // 当前选择的游戏分类
  RxDouble gameViewHeight = (12 * 120).ceil().toDouble().obs;
  List<GameCategory> sortList = [
    GameCategory.gameCategoryQP,
    GameCategory.gameCategoryBY,
    GameCategory.gameCategorySX,
    GameCategory.gameCategoryDZ,
    GameCategory.gameCategoryTY
  ];

  @override
  void onInit() async {
    super.onInit();
    tabController = TabController(length: cateTopList.length, vsync: this);
    gameTabController =
        TabController(length: GameCategory.values.length - 2, vsync: this);
    tabController?.addListener(() {
      currentTabIndex.value = tabController!.index;
    });
    gameTabController?.addListener(() {
      actionIndex.value = gameTabController!.index;
      gameViewHeight.value = Dimens.pt280 *
          ((gameTypeList[sortList[actionIndex.value].index]?.length ?? 0) / 3)
              .ceil()
              .toDouble();

      gameTypeScrollController.animateTo(
          (gameTabController!.index * 60).toDouble(),
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear);
    });
    const gameTypesName = ["棋牌", "捕鱼", "真人视讯", "电子游戏", "体育"];
    for (int i = 0; i < gameTypesName.length; i++) {
      btnIconList.add(GameInfoBean(
          title: gameTypesName[i],
          coverImg: gameIconInsert["insert${i + 1}"] ?? "",
          selectedIcon: gameIconSelInsert["insert${i + 1}"] ?? ""));
    }
    ShareKeys shareKeys = Get.find<ShareKeys>();
    userInfo.value = await shareKeys.getUserInfo();
    GameListModel? model = await ApiRes.getGameList();
    gameList = model?.list ?? [];
    Map<int, List<GameInfoBean>> gameType = {};

    if ((model?.list ?? []).isNotEmpty) {
      for (GameInfoBean item in model?.list ?? []) {
        if (gameType[item.gameCategory] != null) {
          gameType[item.gameCategory]?.add(item);
        } else {
          gameType[item.gameCategory ?? 0] = [item];
        }
      }
    }
    gameTypeList.value = gameType;
    update();
    await getHistoryGameList();
  }

  getHistoryGameList() async {
    List<GameInfoBean>? list = [];
    var history = await lightKV.getString(ShareKeys.gameHistoryKey) ?? "";
    if (history.isNotEmpty) {
      List<dynamic> historyList = json.decode(history ?? "");
      for (int i = 0; i < historyList.length; i++) {
        list.add(GameInfoBean.fromJson(historyList[i]));
      }
      historyGame.value = list;
      gameTypeList[GameCategory.gameCategoryHT.index] = list;
    }
  }

  setHistoryGameList(GameInfoBean? model) async {
    List<GameInfoBean> history = [];
    if (model != null) {
      int index = historyGame.indexWhere((ele) => model.number == ele.number);
      if (index == -1) historyGame.add(model);
      for (GameInfoBean item in historyGame) {
        history.insert(0, item);
      }
      lightKV.setString(ShareKeys.gameHistoryKey, json.encode(history));
    }
  }

  enterGame(number) async {
    GameListModel? model = await ApiRes.enterGame(gameNumber: number);
    if ((model?.code ?? 1) != 0 || (model?.data?.gameUrl ?? "").isEmpty) {
      showTypeToast(msg: "进入游戏错误:${model?.msg ?? ""}");
    }
    ApiRes.addTaskRecord(recordType: RecordType.recordTypeEnterGame.index);
    int index = gameList.indexWhere((ele) => ele.number == number);
    if (index != -1) {
      setHistoryGameList(gameList[index]);
    }
    // Get.toNamed(Routes.ENTER_GAME_WEB_VIEW, arguments: {"uri": ""});
    Get.toNamed(Routes.ENTER_GAME_WEB_VIEW,
        arguments: {"uri": model?.data?.gameUrl ?? ""});
  }

  void goWithdrawCash() {
    if ((userInfo.value.mobile ?? "").isNotEmpty) {
      Get.toNamed(Routes.WITHDRAW_CASH_BANK);
    } else {
      showPlayerCommonDialog(Get.context!,
          title: "友情提示",
          content:
              "当前为游客账号,为避免账号丢失,请绑定手\n机号码升级成正式账号！\n正式账号特权：\n1.立即获得3元现金\n2.可提现APP余额\n3.可通过手机登陆",
          btnList: ["立即绑定"],
          btnCall: [
            () {
              Get.back();
              Get.toNamed(Routes.BIND_MOBILE_PAGE);
            }
          ],
          btnActionIndex: 0);
    }
  }

  void changeTabIndex(int index) {
    currentTabIndex.value = index;
    tabController?.animateTo(index);
  }

  void increment() {
    actionIndex.value++;
  }
}
