import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/r_insert.dart';
import 'package:quick_cat_client/utils/dimens.dart';

Future showGameNotifyDialog(BuildContext context) {
  ShareKeys shareKeys = Get.find<ShareKeys>();
  int balance = (int.tryParse(shareKeys.userBalance.value) ?? 0) ~/ 1;
  List<int> numList = [];
  if (balance < 3) return Future.value();
  if (balance >= 10000) balance = 9999;

  String countStr = balance.toString().padLeft(2, '0');
  numList.clear();
  for (int i = 0; i < countStr.length; i++) {
    numList.add(int.parse(countStr[i]));
  }
  shareKeys.gameNotify.value = true;
  return Get.dialog(
      name: "game_notify_dialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(.7),
      Dialog(
          elevation: .5,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(children: [
                  Image.asset(R.assetsImgBgGameNotify, height: Dimens.pt440),
                  Positioned(
                      left: Dimens.pt190,
                      bottom: Dimens.pt110,
                      child: SizedBox(
                          width: Dimens.pt320,
                          height: Dimens.pt66,
                          child: Row(
                              children: List.generate(
                                  numList.length,
                                  (index) => Container(
                                      margin:
                                          EdgeInsets.only(right: Dimens.pt5),
                                      child: Image.asset(
                                          balanceTextInsert[
                                              "insert${numList[index]}"]!,
                                          width: Dimens.pt33))))))
                ]),
                SizedBox(height: Dimens.pt10),
                Container(
                    width: Dimens.pt376,
                    height: Dimens.pt76,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimens.pt76),
                        gradient: const LinearGradient(
                            colors: [Color(0xFFFCF1D1), Color(0xFFEAB92E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)),
                    child: Text("玩游戏 赢大奖",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color(0xFF710002),
                            fontSize: Dimens.pt38)))
              ])));
}
