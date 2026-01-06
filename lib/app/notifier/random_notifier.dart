//  恭喜ID 328311用户在 幸运大转盘活动中 获得超级大奖 188元

//  恭喜ID 328311用户当日成功提现 150000 元

//  恭喜ID 328311用户在 捕鱼游戏中打倒BOSS 获得超级大奖14555彩金
//  恭喜ID 328311用户在 百人牛牛游戏中抽中牛牛 获得超级大奖14555彩金
//  恭喜ID 328311用户在 炸金花游戏中抽到豹子 获得超级大奖14555彩金
//  恭喜ID 328311用户在 抢庄牛牛游戏中抽到豹子 获得超级大奖14555彩金
//  恭喜ID 328311用户在 骰宝游戏中押中豹子 获得超级大奖14555彩金
//  恭喜ID 328311用户在 21点游戏中凑齐5牌21点 获得超级大奖14555彩金
//  恭喜ID 328311用户在 百家乐游戏中拿到最大9点 获得超级大奖14555彩金

import 'dart:math';

import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/widget/fire_work_animation.dart';
import 'package:quick_cat_client/app/widget/gloab_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String baseUrl = "";
List<String> events = [
  "在幸运大转盘活动中 获得超级大奖^webView://web_view?title=超级大转盘&uri=$baseUrl/zoudoboh-webview/^",
  "当日成功提现^insert:/vip_center_page^",
  "在捕鱼游戏中打倒BOSS 获得超级大奖^game://in_game_page?number=1^",
  "在百人牛牛游戏中抽中牛牛 获得超级大奖^game://in_game_page?number=4^",
  "在炸金花游戏中抽到豹子 获得超级大奖^game://in_game_page?number=3^",
  "在抢庄牛牛游戏中抽到豹子 获得超级大奖^game://in_game_page?number=5^",
  "在骰宝游戏中押中豹子 获得超级大奖^game://in_game_page?number=17^",
  "在21点游戏中凑齐5牌21点 获得超级大奖^game://in_game_page?number=25^",
  "在百家乐游戏中拿到最大9点 获得超级大奖^game://in_game_page?number=82^",
];

class NotifierManager {
  final Random _random = Random();

  void startNotifier() {
    int time = (_random.nextInt(15) + 5);
    Future.delayed(Duration(minutes: time), () {
      randomNotifier(); // 弹出随机通知
      startNotifier(); // 开始新的等待通知
    });
  }

  randomNotifier() {
    if (baseUrl.isEmpty) {
      ShareKeys shareKeys = Get.find<ShareKeys>();
      baseUrl = shareKeys.baseUrl;
    }
    String currentRoute = Get.currentRoute;
    const List<String> exclude = [
      Routes.SPLASH_PAGE,
      Routes.ENTER_GAME_WEB_VIEW,
    ];
    if (exclude.contains(currentRoute)) return;
    String notifier = "恭喜ID ${randomId()}用户";
    int eventInt = _random.nextInt(events.length);
    notifier = "$notifier ${events[eventInt]} ${randomPrice(eventInt)} 元";
    GlobalFirework.show(Get.context!);
    Future.delayed(Duration(milliseconds: 500), () {
      GlobalFirework.show(Get.context!);
    });
    // Future.delayed(Duration(seconds: 2), () {
    MarqueeNotification.show(
      context: Get.context!,
      message: notifier,
      duration: const Duration(seconds: 10),
      backgroundColor: Colors.greenAccent,
      textColor: Colors.black,
    );
    // });
  }

  randomId() {
    return _random.nextInt(2240322) + 20000;
  }

  int randomPrice(index) {
    int number = 1;
    // 提现成功为 1500的倍数
    if (index == 1) {
      number = (_random.nextInt(10) + 4) * 1500;
    } else if (index == 0) {
      number = 188;
    } else {
      number = _random.nextInt(100000) + 2000;
    }
    return number;
  }
}
