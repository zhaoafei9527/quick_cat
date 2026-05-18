// 🐦 Flutter imports:
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:

class BillRecordController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var recordList = [].obs;
  final count = 0.obs;
  TabController? tabController;
  RxInt selectDateValue = 0.obs;
  RxInt selectTypeValue = 0.obs;
  RxInt selectSysTypeValue = 0.obs;
  RxBool showDateChoose = false.obs;
  RxBool showTypeChoose = false.obs;
  RxBool showSysTypeChoose = false.obs;
  RxList<Map<String, dynamic>> typeCodeList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> sysTypeCodeList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> dateCodesList = <Map<String, dynamic>>[].obs;
  List<String> tabList = ["充值记录", "提现记录", "收支记录", "游戏记录"];
  GlobalKey<PagePullViewState> rechargeKey = GlobalKey();
  GlobalKey<PagePullViewState> withdrawalKey = GlobalKey();
  GlobalKey<PagePullViewState> recordKey = GlobalKey();
  GlobalKey<PagePullViewState> gameKey = GlobalKey();
  int _lastTabIndex = 0;
  final Map<int, int> _selectedDateIndexByTab = {};

  static const List<Map<String, dynamic>> _commonDateCodes = [
    {"name": "今日", "value": 1},
    {"name": "本周", "value": 2},
    {"name": "本月", "value": 3},
    {"name": "全部", "value": 0}
  ];

  static const List<Map<String, dynamic>> _gameDateCodes = [
    {"name": "今日", "value": 1},
    {"name": "昨日", "value": 2},
  ];

  int get selectedDateCodeValue {
    if (dateCodesList.isEmpty) return 0;
    if (selectDateValue.value < 0 ||
        selectDateValue.value >= dateCodesList.length) {
      return dateCodesList.first["value"] ?? 0;
    }
    return dateCodesList[selectDateValue.value]["value"] ?? 0;
  }

  @override
  void onInit() async {
    dateCodesList.assignAll(_commonDateCodes);
    typeCodeList.value = [
      {"name": "全部", "value": 0},
      {"name": "收入", "value": 1},
      {"name": "支出", "value": 2}
    ];
    sysTypeCodeList.value = [
      {"name": "全部", "value": 0},
      {"name": "充值", "value": 1},
      {"name": "充值赠送", "value": 2},
      {"name": "转运金", "value": 3},
      {"name": "流水返利", "value": 4},
      {"name": "签到", "value": 5},
      {"name": "排行榜", "value": 6},
      {"name": "注册", "value": 7},
      {"name": "抽奖", "value": 8},
      {"name": "首存", "value": 9},
      {"name": "人工", "value": 10}
    ];
    if ((Get.arguments?['type'] ?? 0) >= 0) {
      final int initialIndex = Get.arguments?['type'] ?? 0;
      _lastTabIndex = initialIndex;
      _selectedDateIndexByTab[initialIndex] = selectDateValue.value;
      tabController = TabController(
          length: tabList.length, initialIndex: initialIndex, vsync: this);
      _syncDateCodesForTab(initialIndex);
      tabController?.addListener(() {
        final int currentIndex = tabController?.index ?? 0;
        if (currentIndex == _lastTabIndex) return;
        _lastTabIndex = currentIndex;
        _syncDateCodesForTab(currentIndex);
        _refreshTab(currentIndex);
      });
    }
    super.onInit();
  }

  chooseTab(int index) {
    _lastTabIndex = index;
    _syncDateCodesForTab(index);
    _refreshTab(index);
  }

  chooseDate(index) {
    selectDateValue.value = index;
    _selectedDateIndexByTab[tabController?.index ?? 0] = index;
    showDateChoose.value = false;
    _refreshTab(tabController?.index ?? 0);
  }

  void _syncDateCodesForTab(int tabIndex) {
    final List<Map<String, dynamic>> nextDateCodes =
        tabIndex == 3 ? _gameDateCodes : _commonDateCodes;
    dateCodesList.assignAll(nextDateCodes);
    final int savedIndex = _selectedDateIndexByTab[tabIndex] ?? 0;
    selectDateValue.value =
        savedIndex >= 0 && savedIndex < nextDateCodes.length ? savedIndex : 0;
  }

  void _refreshTab(int tabIndex) {
    if (tabIndex == 0) {
      rechargeKey.currentState?.refresh();
    } else if (tabIndex == 1) {
      withdrawalKey.currentState?.refresh();
    } else if (tabIndex == 2) {
      recordKey.currentState?.refresh();
    } else if (tabIndex == 3) {
      gameKey.currentState?.refresh();
    }
  }

  chooseBillType(index) {
    selectTypeValue.value = index;
    showTypeChoose.value = false;
    recordKey.currentState?.refresh();
  }

  chooseSysType(index) {
    selectSysTypeValue.value = index;
    showSysTypeChoose.value = false;
    recordKey.currentState?.refresh();
  }

  closeAllDropdown() {
    showDateChoose.value = false;
    showTypeChoose.value = false;
    showSysTypeChoose.value = false;
  }

  void increment() => count.value++;
}
