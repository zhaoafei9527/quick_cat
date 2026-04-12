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
  RxBool enterLoading = false.obs;
  RxBool gameAreaLoading = false.obs;
  RxMap<int, List<GameInfoBean>> gameTypeList = <int, List<GameInfoBean>>{}.obs;
  final actionIndex = 0.obs;
  int categoryKey = 0;
  int platformKey = 0;
  RxDouble getBalanceIng = .0.obs;
  RxInt gamePlatformIndex = 0.obs;
  RxList<GamePlatformBean> gamePlatformList =
      <GamePlatformBean>[].obs; // 游戏平台列表
  RxList<CategoryInfoBean> categoryList = <CategoryInfoBean>[].obs; // 游戏分类列表
  RxList<GameInfoBean> gameList = <GameInfoBean>[].obs; // 游戏列表
  final Map<String, List<GameInfoBean>> _gameCache =
      <String, List<GameInfoBean>>{};

  TabController? tabController; // 首页主分类
  TabController? gameTabController; // 游戏分类
  ScrollController gameTypeScrollController = ScrollController();
  RxInt currentTabIndex = 0.obs;
  List<String> cateTopList = ["娱乐中心", "高能涩游"];
  RxList<GameInfoBean> historyGame = <GameInfoBean>[].obs;
  late Rx<UserInfo> userInfo = UserInfo().obs;
  RxDouble gameViewHeight = (12 * 120).ceil().toDouble().obs;

  @override
  void onInit() async {
    super.onInit();
    tabController = TabController(length: cateTopList.length, vsync: this);
    tabController?.addListener(() {
      currentTabIndex.value = tabController!.index;
    });
    _resetGameTabController();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    userInfo.value = await shareKeys.getUserInfo();
    await getGamePlatformData();
    changeGamePlatform(0); // 初始化游戏列表
  }

  getGamePlatformData() async {
    GamePlatformListModel? model = await ApiRes.getGamePlatformList();
    if ((model?.list ?? []).isNotEmpty) {
      gamePlatformList.value = model?.list ?? [];
      categoryList.value =
          gamePlatformList[gamePlatformIndex.value].categoryList ?? [];
    } else {
      showTypeToast(msg: "获取游戏平台列表失败");
    }
  }

  changeGamePlatform(index) async {
    gameAreaLoading.value = true;
    try {
      gamePlatformIndex.value = index;
      actionIndex.value = 0;
      categoryList.value = gamePlatformList[index].categoryList ?? [];
      _resetGameTabController();
      await _loadCurrentCategoryGames();
      // await getGamePlatformData();
    } finally {
      gameAreaLoading.value = false;
    }
  }

  void _resetGameTabController() {
    gameTabController?.dispose();
    gameTabController = TabController(length: categoryList.length, vsync: this);
    gameTabController?.addListener(() async {
      if (gameTabController == null || gameTabController!.indexIsChanging) {
        return;
      }
      actionIndex.value = gameTabController!.index;
      _updateGameViewHeight();
      gameTypeScrollController.animateTo(
          (gameTabController!.index * 60).toDouble(),
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear);
      await _loadCurrentCategoryGames();
    });
    _updateGameViewHeight();
  }

  Future<void> _loadCurrentCategoryGames() async {
    if (categoryList.isEmpty || gamePlatformList.isEmpty) {
      gameList.value = [];
      gameViewHeight.value = 0;
      return;
    }
    final int tabIndex = actionIndex.value.clamp(0, categoryList.length - 1);
    final CategoryInfoBean category = categoryList[tabIndex];
    categoryKey = category.gameCategory ?? 0;
    platformKey = gamePlatformList[gamePlatformIndex.value].gamePlatform ?? 0;
    final String cacheKey = _buildGameCacheKey(
      gameCategory: categoryKey,
      gamePlatform: platformKey,
    );
    final List<GameInfoBean>? cachedList = _gameCache[cacheKey];
    final List<GameInfoBean> list;
    if (cachedList != null) {
      list = cachedList;
    } else {
      GameListModel? model = await ApiRes.getGameList(
          gameCategory: categoryKey, gamePlatform: platformKey);
      list = model?.list ?? [];
      _gameCache[cacheKey] = list;
    }
    gameList.value = list;
    gameTypeList[categoryKey] = list;
    _updateGameViewHeight();
  }

  String _buildGameCacheKey(
      {required int gameCategory, required int gamePlatform}) {
    return "${gamePlatform}_$gameCategory";
  }

  void _updateGameViewHeight() {
    if (categoryList.isEmpty) {
      gameViewHeight.value = 0;
      return;
    }
    final int tabIndex = actionIndex.value.clamp(0, categoryList.length - 1);
    final int categoryKey = categoryList[tabIndex].gameCategory ?? 0;
    gameViewHeight.value = Dimens.pt280 *
        ((gameTypeList[categoryKey]?.length ?? 0) / 3).ceil().toDouble();
  }

  getHistoryGameList() async {
    List<GameInfoBean>? list = [];
    var history = await lightKV.getString(ShareKeys.gameHistoryKey) ?? "";
    if (history.isNotEmpty) {
      List<dynamic> historyList = json.decode(history);
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

  enterGame(String? number) async {
    GameListModel? model =
        await ApiRes.enterGame(gamePlatform: platformKey, gameType: number);

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
