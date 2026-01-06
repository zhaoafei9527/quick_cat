// 🐦 Flutter imports:
import 'package:acgn_client/app/views/page_pull_view.dart';
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

  @override
  void onInit() async {
    dateCodesList.value = [
      {"name": "今日", "value": 1},
      {"name": "本周", "value": 2},
      {"name": "本月", "value": 3},
      {"name": "全部", "value": 0}
    ];
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
      tabController = TabController(
          length: tabList.length,
          initialIndex: Get.arguments?['type'] ?? 0,
          vsync: this);
      tabController?.addListener(() {
        if(tabController?.index==0){
          rechargeKey.currentState?.refresh();
        }else if(tabController?.index==1){
          withdrawalKey.currentState?.refresh();
        }else if(tabController?.index==2){
          recordKey.currentState?.refresh();
        }else if(tabController?.index==3){
          gameKey.currentState?.refresh();
        }
      });
    }
    super.onInit();
  }

  chooseDate(index) {
    selectDateValue.value = index;
    showDateChoose.value = false;
    if(tabController?.index==0){
      rechargeKey.currentState?.refresh();
    }else if(tabController?.index==1){
      withdrawalKey.currentState?.refresh();
    }else if(tabController?.index==2){
      recordKey.currentState?.refresh();
    }else if(tabController?.index==3){
      gameKey.currentState?.refresh();
    }
  }

  chooseType(index) {
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
