// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/bill_info_model.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/time_util.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/game_details_page_controller.dart';

class GameDetailsPageView extends GetView<GameDetailsPageController> {
  const GameDetailsPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: getCommonAppBar("详情"),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
          child: GetX<GameDetailsPageController>(
              builder: (GameDetailsPageController logic) {
                if (logic.billType == BillInfoType.billTypeGame.index) {
                  return logic.initOk.value
                      ? _buildGameBillInfo(logic)
                      : getLoadingWidget();
                } else if (logic.billType == BillInfoType.billTypeWithdraw.index) {
                  return logic.initOk.value
                      ? _buildWithDrawInfo(logic)
                      : getLoadingWidget();
                } else if (logic.billType == BillInfoType.billTypeRecharge.index) {
                  return logic.initOk.value
                      ? _buildRechargeInfo(logic)
                      : getLoadingWidget();
                } else {
                  return Container();
                }
              }),
        ));
  }
}

Widget _buildRechargeInfo(GameDetailsPageController logic) {
  RechargeData? wlGameData = logic.billInfo?.value.rechargeData;
  return Column(children: [
    _buildDetailsRow(
        label: "订单号",
        content: "${wlGameData?.tradeNo}",
        option: GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: "${wlGameData?.id}"))
                .then((_) {
              showToast(msg: "ID已复制到剪切板");
            });
          },
          child: Container(
              margin: EdgeInsets.only(right: Dimens.pt30),
              child: Text("复制",
                  style: TextStyle(
                      fontSize: Dimens.pt26, color: const Color(0xFF66BBFF)))),
        )),
    _buildDetailsRow(
        label: "充值金额", content: (wlGameData?.amount ?? 0).toStringAsFixed(2)),
    _buildDetailsRow(
        label: "到账金额",
        content: (wlGameData?.realAmount ?? 0).toStringAsFixed(2)),
    _buildDetailsRow(
        label: "状态",
        content: TimeUtil.topUpStatusType(wlGameData?.status ?? 0)),
    _buildDetailsRow(
        label: "发起时间",
        content: TimeUtil.buildYYMMDDHHNN(wlGameData?.createdAt ?? "")),
    _buildDetailsRow(
        label: "完成时间",
        content: TimeUtil.buildYYMMDDHHNN(wlGameData?.finishedAt ?? "")),
  ]);
}

Widget _buildWithDrawInfo(GameDetailsPageController logic) {
  WithdrawData? wlGameData = logic.billInfo?.value.withdrawData;
  return Column(children: [
    _buildDetailsRow(
        label: "订单号",
        content: "${wlGameData?.tradeNo}",
        option: GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: "${wlGameData?.id}"))
                .then((_) {
              showToast(msg: "ID已复制到剪切板");
            });
          },
          child: Container(
              margin: EdgeInsets.only(right: Dimens.pt30),
              child: Text("复制",
                  style: TextStyle(
                      fontSize: Dimens.pt26, color: const Color(0xFF66BBFF)))),
        )),
    _buildDetailsRow(
        label: "提现金额",
        content: ((wlGameData?.amount ?? 0) / 100).toStringAsFixed(2)),
    _buildDetailsRow(
        label: "到账金额",
        content: ((wlGameData?.realAmount ?? 0) / 100).toStringAsFixed(2)),
    _buildDetailsRow(
        label: "状态",
        content: TimeUtil.withdrawalStatusType(wlGameData?.status ?? 0)),
    _buildDetailsRow(
        label: "发起时间",
        content: TimeUtil.buildYYMMDDHHNN(wlGameData?.createdAt ?? "")),
    _buildDetailsRow(
        label: "完成时间",
        content: TimeUtil.buildYYMMDDHHNN(wlGameData?.finishedAt ?? "")),
    _buildDetailsRow(label: "备注信息", content: wlGameData?.checkMark ?? ""),
    _buildDetailsRow(label: "提现方式", content: wlGameData?.mode),
    _buildDetailsRow(label: "银行卡号", content: wlGameData?.accountNo ?? ""),
    _buildDetailsRow(label: "开户名称", content: wlGameData?.accountName ?? ""),
    _buildDetailsRow(label: "所属银行", content: wlGameData?.bankName ?? ""),
    _buildDetailsRow(label: "支行", content: wlGameData?.bankBranch ?? ""),
  ]);
}

Widget _buildGameBillInfo(GameDetailsPageController logic) {
  WlGameData? wlGameData = logic.billInfo?.value.wlGameData;
  return Column(children: [
    _buildDetailsRow(
        label: "订单ID",
        content: logic.id.toString(),
        option: GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: "${logic.id}")).then((_) {
              showToast(msg: "ID已复制到剪切板");
            });
          },
          child: Container(
              margin: EdgeInsets.only(right: Dimens.pt30),
              child: Text("复制",
                  style: TextStyle(
                      fontSize: Dimens.pt26, color: const Color(0xFF66BBFF)))),
        )),
    _buildDetailsRow(
        label: "订单号",
        content: "${wlGameData?.recordId}",
        option: GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: "${wlGameData?.recordId}"))
                .then((_) {
              showToast(msg: "订单号已复制到剪切板");
            });
          },
          child: Container(
              margin: EdgeInsets.only(right: Dimens.pt30),
              child: Text("复制",
                  style: TextStyle(
                      fontSize: Dimens.pt26, color: const Color(0xFF66BBFF)))),
        )),
    _buildDetailsRow(
        label: "下注金额", content: (wlGameData?.validBet ?? 0).toStringAsFixed(2)),
    _buildDetailsRow(
        label: "结算金额", content: (wlGameData?.profit ?? 0).toStringAsFixed(2)),
    _buildDetailsRow(label: "状态", content: "成功"),
    _buildDetailsRow(
        label: "下注时间",
        content: TimeUtil.buildYYMMDDHHNN(wlGameData?.createdAt ?? "")),
    _buildDetailsRow(
        label: "结算时间",
        content: TimeUtil.buildYYMMDDHHNN(wlGameData?.updatedAt ?? "")),
    _buildDetailsRow(label: "游戏平台", content: "瓦力"),
    _buildDetailsRow(label: "游戏ID", content: wlGameData?.gameId ?? "")
  ]);
}

Widget _buildDetailsRow({String? label, Widget? option, String? content}) {
  return Container(
      height: Dimens.pt90,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(.1))),
      ),
      child: Row(children: [
        Text(label ?? "",
            style: TextStyle(
                fontSize: Dimens.pt26, color: const Color(0xFFC5C1BE))),
        const Spacer(),
        option ?? const SizedBox(),
        Text(content ?? "",
            style: TextStyle(fontSize: Dimens.pt26, color: Colors.white))
      ]));
}
