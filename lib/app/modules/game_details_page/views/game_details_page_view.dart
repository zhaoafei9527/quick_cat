// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/bill_info_model.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
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
    return GetX<GameDetailsPageController>(
        builder: (GameDetailsPageController logic) {
      if (logic.billType == BillInfoType.billTypeGame.index) {
        return logic.initOk.value
            ? _buildGameBillInfo(logic)
            : getLoadingWidget();
      } else {
        return Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: getCommonAppBar("详情"),
            body: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                child: _buildView(logic)));
      }
    });
  }
}

Widget _buildView(GameDetailsPageController logic) {
  if (logic.billType == BillInfoType.billTypeWithdraw.index) {
    return logic.initOk.value ? _buildWithDrawInfo(logic) : getLoadingWidget();
  } else if (logic.billType == BillInfoType.billTypeRecharge.index) {
    return logic.initOk.value ? _buildRechargeInfo(logic) : getLoadingWidget();
  } else {
    return Container();
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
    _buildDetailsRow(
        label: "提现方式",
        content: TimeUtil.withdrawalOrderType(wlGameData?.orderType)),
    _buildDetailsRow(label: "银行卡号", content: wlGameData?.accountNo ?? ""),
    _buildDetailsRow(label: "开户名称", content: wlGameData?.accountName ?? ""),
    _buildDetailsRow(label: "所属银行", content: wlGameData?.bankName ?? ""),
    _buildDetailsRow(label: "支行", content: wlGameData?.bankBranch ?? ""),
  ]);
}

Widget _buildGameBillInfo(GameDetailsPageController logic) {
  return Column(children: [
    SizedBox(height: screen.paddingTop),
    SizedBox(
        height: Dimens.pt88,
        child: Row(children: [
          GestureDetector(
            onTap: () {
              if (logic.gameBillId.value > 0) {
                logic.gameBillId.value = 0;
              } else {
                Get.back();
              }
            },
            child: SizedBox(
                width: Dimens.pt100,
                child: Icon(Icons.arrow_back_ios_new,
                    size: Dimens.pt38, weight: 100, color: Colors.white)),
          ),
          Spacer(),
          ImageLoader.withP(logic.icon, height: Dimens.pt32).load(),
          SizedBox(width: Dimens.pt10),
          Text(logic.gameName ?? "",
              style: TextStyle(fontSize: Dimens.pt30, color: Colors.white)),
          Spacer(),
          if (logic.gameBillId.value == 0)
            Obx(() => CommonDropdownSelector(
                listData: logic.dateCodesList,
                selectedIndex: logic.selectDateValue.value,
                onItemTap: logic.chooseDate,
                width: Dimens.pt100,
                borderColor: const Color(0xFFFFB715),
                backgroundColor: const Color(0xFF171F20),
                dropDownSpacing: Dimens.pt12)),
          SizedBox(width: Dimens.pt25)
        ])),
    if (logic.gameBillId.value > 0)
      OldDetailView(gameId: logic.gameBillId.value)
    else
      Expanded(
          child: PagePullView(
              key: Key("game_bill_${logic.selectDateValue.value}"),
              dataGetter: (int pageNum, int size) async {
                gameRecordsList? model = await ApiRes.getGameBillDetails(
                    pageNum: pageNum,
                    gamePlatform: logic.gamePlatform ?? 0,
                    dayType: logic.dateCodesList[logic.selectDateValue.value]
                        ["value"]);
                return model?.list ?? [];
              },
              emptyView: buildCommonEmptyView("宝贝,赶快下注一把游戏吧～"),
              widgetBuilder:
                  (BuildContext context, List<dynamic> list, Widget? child) {
                return ListView.separated(
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimens.pt25, vertical: Dimens.pt30),
                    itemBuilder: (c, index) => Container(
                        height: Dimens.pt195,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                        decoration: BoxDecoration(
                            color: Color(0xFF222433),
                            borderRadius: BorderRadius.circular(Dimens.pt10)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(children: [
                                Text(list[index].gameName ?? "",
                                    style: TextStyle(
                                        fontSize: Dimens.pt24,
                                        color: Colors.white)),
                                Spacer(),
                                GestureDetector(
                                    onTap: () => logic.gameBillId.value =
                                        list[index].id ?? 0,
                                    child: Row(children: [
                                      Text("详情",
                                          style: TextStyle(
                                              fontSize: Dimens.pt22,
                                              color: Colors.white)),
                                      Icon(Icons.arrow_forward_ios,
                                          size: Dimens.pt24)
                                    ]))
                              ]),
                              SizedBox(height: Dimens.pt40),
                              Row(children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text("下注金额",
                                          style: TextStyle(
                                              fontSize: Dimens.pt24,
                                              color: Color(0xFFA3A3A7))),
                                      SizedBox(height: Dimens.pt10),
                                      Text("¥${list[index].validBet ?? 0}",
                                          style: TextStyle(
                                              fontSize: Dimens.pt24,
                                              color: Color(0xFFFFB715)))
                                    ]),
                                Spacer(),
                                Column(children: [
                                  Text("结算金额",
                                      style: TextStyle(
                                          fontSize: Dimens.pt22,
                                          color: Color(0xFFA3A3A7))),
                                  SizedBox(height: Dimens.pt10),
                                  Text("¥${list[index].profit ?? 0}",
                                      style: TextStyle(
                                          fontSize: Dimens.pt22,
                                          color: (list[index].profit ?? 0) < 0
                                              ? Color(0xFF1CCD21)
                                              : Color(0xFFF52C56)))
                                ])
                              ])
                            ])),
                    separatorBuilder: (c, index) =>
                        SizedBox(height: Dimens.pt25),
                    itemCount: list.length);
              }))
  ]);
}

class OldDetailView extends StatefulWidget {
  final int gameId;

  const OldDetailView({super.key, required this.gameId});

  @override
  State<OldDetailView> createState() => _OldDetailViewState();
}

class _OldDetailViewState extends State<OldDetailView> {
  late Future<BillDetailsInfo?> _future;

  @override
  void initState() {
    super.initState();
    GameDetailsPageController logic = Get.find<GameDetailsPageController>();

    _future = ApiRes.getBillInfo(id: widget.gameId, billType: logic.billType);
  }

  void _reload() {
    setState(() {
      GameDetailsPageController logic = Get.find<GameDetailsPageController>();
      _future = ApiRes.getBillInfo(id: widget.gameId, billType: logic.billType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BillDetailsInfo?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: getLoadingView());
          }
          if (snapshot.hasError) {
            return Center(
                child: TextButton(
                    onPressed: _reload,
                    child: const Text("加载失败，点击重试",
                        style: TextStyle(color: Colors.white70))));
          }
          WlGameData? wlGameData = snapshot.data?.wlGameData;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt22),
            child: Column(children: [
              _buildDetailsRow(
                  label: "订单ID",
                  content: widget.gameId.toString(),
                  option: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: "${widget.gameId}"))
                          .then((_) {
                        showToast(msg: "ID已复制到剪切板");
                      });
                    },
                    child: Container(
                        margin: EdgeInsets.only(right: Dimens.pt30),
                        child: Text("复制",
                            style: TextStyle(
                                fontSize: Dimens.pt26,
                                color: const Color(0xFF66BBFF)))),
                  )),
              // _buildDetailsRow(
              //     label: "订单号",
              //     content: "${wlGameData?.recordId}",
              //     option: GestureDetector(
              //       onTap: () {
              //         Clipboard.setData(
              //                 ClipboardData(text: "${wlGameData?.recordId}"))
              //             .then((_) {
              //           showToast(msg: "订单号已复制到剪切板");
              //         });
              //       },
              //       child: Container(
              //           margin: EdgeInsets.only(right: Dimens.pt30),
              //           child: Text("复制",
              //               style: TextStyle(
              //                   fontSize: Dimens.pt26,
              //                   color: const Color(0xFF66BBFF)))),
              //     )),
              _buildDetailsRow(
                  label: "下注金额",
                  content: (wlGameData?.validBet ?? 0).toStringAsFixed(2)),
              _buildDetailsRow(
                  label: "结算金额",
                  content: (wlGameData?.profit ?? 0).toStringAsFixed(2)),
              _buildDetailsRow(label: "状态", content: "成功"),
              _buildDetailsRow(
                  label: "下注时间",
                  content:
                      TimeUtil.buildYYMMDDHHNN(wlGameData?.createdAt ?? "")),
              _buildDetailsRow(
                  label: "结算时间",
                  content:
                      TimeUtil.buildYYMMDDHHNN(wlGameData?.updatedAt ?? "")),
              // _buildDetailsRow(label: "游戏平台", content: "瓦力"),
              _buildDetailsRow(label: "游戏ID", content: wlGameData?.gameId ?? "")
            ]),
          );
        });
  }
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
