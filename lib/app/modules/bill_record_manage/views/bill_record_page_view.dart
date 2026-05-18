// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/recharge_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../../../utils/dimens.dart';
import '../../../../utils/time_util.dart';
import '../../../model/home/game_detail_model.dart';
import '../../../model/home/ie_detail_model_model.dart';
import '../../../widget/common_widget.dart';
import '../controllers/bill_record_controller.dart';

class BillRecordPageView extends GetView<BillRecordController> {
  const BillRecordPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BillRecordController>(builder: (logic) {
      ThemeManager theme = Get.find<ThemeManager>();
      return Scaffold(
          backgroundColor: theme.getColor(ThemeColor.bg),
          appBar: getCommonAppBar("我的账单"),
          body: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => logic.closeAllDropdown(),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Column(children: [
                      Row(children: [
                        Expanded(
                          child: buildCommonTabBar(
                              distance: Dimens.pt2,
                              controller: logic.tabController,
                              onTap: logic.chooseTab,
                              alignment: TabAlignment.start,
                              insets: Dimens.pt35,
                              fontSize: Dimens.pt28,
                              tabs: logic.tabList.map((e) => Text(e)).toList()),
                        ),
                        SizedBox(width: Dimens.pt15),
                        Obx(() => CommonDropdownSelector(
                            listData: logic.dateCodesList,
                            selectedIndex: logic.selectDateValue.value,
                            onItemTap: logic.chooseDate,
                            width: Dimens.pt100,
                            borderColor: const Color(0xFFFFB715),
                            backgroundColor: const Color(0xFF171F20),
                            dropDownSpacing: Dimens.pt12))
                        // Obx(() => _buildDropdownView(
                        //     width: Dimens.pt100,
                        //     onTap: () => logic.showDateChoose.value =
                        //         !logic.showDateChoose.value,
                        //     value:
                        //         logic.dateCodesList[logic.selectDateValue.value]
                        //             ["name"]))
                      ]),
                      SizedBox(height: Dimens.pt25),
                      Expanded(
                          child: TabBarView(
                              controller: logic.tabController,
                              children: [
                            _buildRechargeRecord(),
                            _buildWithdrawalRecords(),
                            _buildAllRecordList(),
                            _buildGameRecordsList(),
                          ]))
                    ]),
                    // _buildDateChooseView(),
                    // _buildTypeChooseView(),
                    // _buildSysTypeChooseView(),
                  ],
                ),
              )));
    });
  }

  Widget _buildGameRecordsList() {
    BillRecordController logic = Get.find<BillRecordController>();
    return Column(children: [
      Expanded(
          child: PagePullView(
              key: logic.gameKey,
              dataGetter: (int pageNum, int size) async {
                GameDetail? model = await ApiRes.getGameDetailList(
                    pageNum: pageNum, dayType: logic.selectedDateCodeValue);
                return model?.list ?? [];
              },
              emptyView: buildCommonEmptyView("宝贝,赶快下注一把游戏吧～"),
              widgetBuilder:
                  (BuildContext context, List<dynamic> list, Widget? child) {
                return ListView.separated(
                    itemBuilder: (c, index) => Container(
                        height: Dimens.pt195,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                        decoration: BoxDecoration(color: Color(0xFF222433)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(children: [
                                ImageLoader.withP(list[index].icon,
                                        height: Dimens.pt31)
                                    .load(),
                                SizedBox(width: Dimens.pt10),
                                Text(list[index].title ?? "",
                                    style: TextStyle(
                                        fontSize: Dimens.pt24,
                                        color: Colors.white)),
                                Spacer(),
                                GestureDetector(
                                  onTap: () => Get.toNamed(
                                      Routes.GAME_DETAILS_PAGE,
                                      arguments: {
                                        "gamePlatform":
                                            "${list[index].gamePlatform}",
                                        "gameName":
                                            "${list[index].title ?? ''}",
                                        "icon": "${list[index].icon ?? ''}",
                                        "billType":
                                            "${BillInfoType.billTypeGame.index}"
                                      }),
                                  child: Row(children: [
                                    Text("详情",
                                        style: TextStyle(
                                            fontSize: Dimens.pt22,
                                            color: Colors.white)),
                                    Icon(Icons.arrow_forward_ios,
                                        size: Dimens.pt24)
                                  ]),
                                )
                              ]),
                              SizedBox(height: Dimens.pt40),
                              Row(children: [
                                Column(children: [
                                  Text("下注注量",
                                      style: TextStyle(
                                          fontSize: Dimens.pt22,
                                          color: Color(0xFFA3A3A7))),
                                  SizedBox(height: Dimens.pt10),
                                  Text("${list[index].count ?? 0}",
                                      style: TextStyle(
                                          fontSize: Dimens.pt22,
                                          color: Colors.white))
                                ]),
                                Spacer(),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text("下注金额",
                                          style: TextStyle(
                                              fontSize: Dimens.pt24,
                                              color: Color(0xFFA3A3A7))),
                                      SizedBox(height: Dimens.pt10),
                                      Text("¥${list[index].totalValidBet ?? 0}",
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
                                  Text("${list[index].totalProfit ?? 0}",
                                      style: TextStyle(
                                          fontSize: Dimens.pt22,
                                          color:
                                              (list[index].totalProfit ?? 0) < 0
                                                  ? Color(0xFF1CCD21)
                                                  : Color(0xFFF52C56)))
                                ])
                              ])
                            ])),
                    separatorBuilder: (c, index) => SizedBox(
                          height: Dimens.pt10,
                        ),
                    itemCount: list.length);
              })),
      SizedBox(height: screen.paddingBottom)
    ]);
  }

  Widget _buildAllRecordList() {
    BillRecordController logic = Get.find<BillRecordController>();
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Obx(() => _buildDropdownView(
        //     onTap: () =>
        //         logic.showTypeChoose.value = !logic.showTypeChoose.value,
        //     value: logic.typeCodeList[logic.selectTypeValue.value]["name"])),

        Obx(() => CommonDropdownSelector(
            listData: logic.typeCodeList,
            selectedIndex: logic.selectTypeValue.value,
            onItemTap: logic.chooseBillType,
            width: Dimens.pt170,
            triggerHeight: Dimens.pt55,
            borderColor: const Color(0xFFFFB715),
            backgroundColor: Colors.transparent,
            itemBackground: const Color(0xFF171F20),
            dropDownSpacing: Dimens.pt12)),

        SizedBox(width: Dimens.pt80),

        Obx(() => CommonDropdownSelector(
            listData: logic.sysTypeCodeList,
            selectedIndex: logic.selectSysTypeValue.value,
            onItemTap: logic.chooseSysType,
            width: Dimens.pt170,
            triggerHeight: Dimens.pt55,
            borderColor: const Color(0xFFFFB715),
            backgroundColor: Colors.transparent,
            itemBackground: const Color(0xFF171F20),
            dropDownSpacing: Dimens.pt12)),
      ]),
      SizedBox(height: Dimens.pt25),
      Container(
          height: Dimens.pt55,
          color: const Color(0xFF222433),
          child: Row(children: [
            _getTableRow(text: "帐变金额"),
            SizedBox(width: Dimens.pt20),
            _getTableRow(text: "帐变后金额", width: Dimens.pt140),
            SizedBox(width: Dimens.pt20),
            _getTableRow(text: "时间", width: Dimens.pt140),
            SizedBox(width: Dimens.pt20),
            _getTableRow(text: "收支类型", width: Dimens.pt110),
            SizedBox(width: Dimens.pt20),
            _getTableRow(text: "帐变类型", width: Dimens.pt110),
          ])),
      Expanded(
          child: PagePullView(
              key: logic.recordKey,
              dataGetter: (int pageNum, int size) async {
                IeDetailModel? model = await ApiRes.getIeDetailList(
                    pageNum: pageNum,
                    dayType: logic.selectedDateCodeValue,
                    ieType: logic.selectSysTypeValue.value,
                    markType: logic.selectTypeValue.value);
                return model?.list ?? [];
              },
              emptyView: buildCommonEmptyView("宝贝,赶快充值一点点🤏吧～"),
              widgetBuilder:
                  (BuildContext context, List<dynamic> list, Widget? child) {
                return ListView.separated(
                    itemBuilder: (c, index) => Container(
                        height: Dimens.pt110,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.white.withOpacity(.1)))),
                        child: Row(children: [
                          _getTableRow(
                              text: ((list[index].coinAmount ?? 0) / 100)
                                  .toStringAsFixed(2)),
                          SizedBox(width: Dimens.pt20),
                          _getTableRow(
                              text: ((list[index].recharge ?? 0) / 100)
                                  .toStringAsFixed(2),
                              width: Dimens.pt140),
                          SizedBox(width: Dimens.pt20),
                          _getTableRow(
                              text: TimeUtil.buildChineseYYMMDD(
                                  list[index].createdAt ?? ""),
                              width: Dimens.pt160),
                          SizedBox(width: Dimens.pt20),
                          _getTableRow(
                              text: list[index].markType == 1 ? '收入' : '支出',
                              width: Dimens.pt80),
                          const Spacer(),
                          _getTableRow(
                              text: TimeUtil.tranType(list[index].tranType),
                              width: Dimens.pt80),
                        ])),
                    separatorBuilder: (c, index) => SizedBox(
                          height: Dimens.pt10,
                        ),
                    itemCount: list.length);
              }))
    ]);
  }

  Widget _buildDropdownView(
      {VoidCallback? onTap, double? width, String? value}) {
    return GestureDetector(
        onTap: () => onTap?.call(),
        child: Container(
            width: width ?? Dimens.pt170,
            padding: EdgeInsets.symmetric(vertical: Dimens.pt10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFFFB715)),
                borderRadius: BorderRadius.circular(Dimens.pt12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(value ?? "",
                  style: TextStyle(fontSize: Dimens.pt24, color: Colors.white)),
              SizedBox(width: Dimens.pt10),
              Image.asset(R.assetsImgIconDropDown,
                  width: Dimens.pt13, color: AppColors.textYellowColor)
            ])));
  }

  Widget _buildWithdrawalRecords() {
    BillRecordController logic = Get.find<BillRecordController>();
    return Column(children: [
      Container(
          height: Dimens.pt55,
          color: const Color(0xFF222433),
          child: Row(children: [
            _getTableRow(text: "提现金额"),
            SizedBox(width: Dimens.pt45),
            _getTableRow(text: "提现类型"),
            SizedBox(width: Dimens.pt45),
            _getTableRow(text: "提现时间"),
            SizedBox(width: Dimens.pt45),
            _getTableRow(text: "状态", width: Dimens.pt80),
            const Spacer(),
            _getTableRow(text: "操作", width: Dimens.pt80),
          ])),
      Expanded(
          child: PagePullView(
              key: logic.withdrawalKey,
              dataGetter: (int pageNum, int size) async {
                RechargeModel? model = await ApiRes.getWithdrawalList(
                    pageNum: pageNum, dayType: logic.selectedDateCodeValue);
                return model?.list ?? [];
              },
              emptyView: buildCommonEmptyView("宝贝,赶快充值一点点吧～"),
              widgetBuilder:
                  (BuildContext context, List<dynamic> list, Widget? child) {

                return ListView.separated(
                    itemBuilder: (c, index) => Container(
                          height: Dimens.pt110,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.white.withOpacity(.1)))),
                          child: Row(children: [
                            _getTableRow(
                                text: TimeUtil.amountConversion(
                                    list[index].amount ?? 0)),
                            SizedBox(width: Dimens.pt45),
                            _getTableRow(
                                text: TimeUtil.withdrawalOrderType(
                                    list[index].orderType)),

                            SizedBox(width: Dimens.pt45),
                            _getTableRow(
                                text: TimeUtil.buildYYMMDDPunctuate(
                                    list[index].createdAt ?? "",
                                    sp: "-"),
                                fontSize: Dimens.pt22),
                            SizedBox(width: Dimens.pt45),
                            _getTableRow(
                                text: TimeUtil.withdrawalStatusType(
                                    list[index].status ?? ""),
                                width: Dimens.pt80),
                            const Spacer(),
                            _getTableRow(
                                text: "详情",
                                onTap: () => Get.toNamed(
                                        Routes.GAME_DETAILS_PAGE,
                                        arguments: {
                                          "id": "${list[index].id}",
                                          "billType":
                                              "${BillInfoType.billTypeWithdraw.index}"
                                        }),
                                color: AppColors.textYellowColor,
                                width: Dimens.pt80),
                          ]),
                        ),
                    separatorBuilder: (c, index) =>
                        SizedBox(height: Dimens.pt10),
                    itemCount: list.length);
              }))
    ]);
  }

  Widget _getTableRow(
      {double? width,
      String? text,
      double? fontSize,
      Color? color,
      Function? onTap}) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: SizedBox(
          width: width ?? Dimens.pt120,
          child: Center(
              child: Text(text ?? "",
                  style: TextStyle(
                      fontSize: fontSize ?? Dimens.pt24,
                      color: color ?? Colors.white)))),
    );
  }

  Widget _buildRechargeRecord() {
    BillRecordController logic = Get.find<BillRecordController>();
    return Column(children: [
      Container(
          height: Dimens.pt55,
          color: const Color(0xFF222433),
          child: Row(children: [
            _getTableRow(text: "充值金额"),
            SizedBox(width: Dimens.pt45),
            _getTableRow(text: "充值类型"),
            SizedBox(width: Dimens.pt45),
            _getTableRow(text: "充值时间", width: Dimens.pt200),
            const Spacer(),
            _getTableRow(text: "状态")
          ])),
      Expanded(
          child: PagePullView(
              key: logic.rechargeKey,
              dataGetter: (int pageNum, int size) async {
                RechargeModel? model = await ApiRes.getRechargeList(
                    pageNum: pageNum, dayType: logic.selectedDateCodeValue);
                return model?.list ?? [];
              },
              emptyView: buildCommonEmptyView("宝贝,赶快充值一点点吧～"),
              widgetBuilder:
                  (BuildContext context, List<dynamic> list, Widget? child) {
                return ListView.separated(
                    itemBuilder: (c, index) => Container(
                          height: Dimens.pt110,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.white.withOpacity(.1)))),
                          child: Row(children: [
                            _getTableRow(
                                text: TimeUtil.amountConversion(
                                    list[index].coinAmount ?? 0)),
                            SizedBox(width: Dimens.pt45),
                            _getTableRow(
                                text:
                                    TimeUtil.paymentType(list[index].payMode)),
                            SizedBox(width: Dimens.pt45),
                            _getTableRow(
                                text: TimeUtil.buildChineseYYMMDD(
                                    list[index].createdAt ?? ""),
                                width: Dimens.pt200),
                            const Spacer(),
                            _getTableRow(
                                text: TimeUtil.topUpStatusType(
                                    list[index].status ?? "")),
                          ]),
                        ),
                    separatorBuilder: (c, index) => SizedBox(
                          height: Dimens.pt10,
                        ),
                    itemCount: list.length);
              }))
    ]);
  }

  GestureDetector _buildDropdownItem(
      {List<Map<String, dynamic>>? list, VoidCallback? onTap, int index = 0}) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Container(
          height: Dimens.pt70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: index != (list ?? []).length - 1
                  ? Border(
                      bottom: BorderSide(
                          color: const Color(0xFFFFB715), width: Dimens.pt2))
                  : null),
          child: Text(list?[index]["name"] ?? "",
              style: TextStyle(fontSize: Dimens.pt24, color: Colors.white))),
    );
  }

  Widget _buildSysTypeChooseView() {
    BillRecordController logic = Get.find<BillRecordController>();
    return Positioned(
        top: Dimens.pt55 + Dimens.pt80,
        left: screen.screenWidth / 2 + Dimens.pt16,
        child: Obx(() => AnimatedOpacity(
            duration: Durations.short4,
            opacity: logic.showSysTypeChoose.value ? 1 : 0,
            child: IgnorePointer(
                ignoring: !logic.showSysTypeChoose.value,
                child: Container(
                    width: Dimens.pt170,
                    decoration: BoxDecoration(
                        color: Color(0xFF171F20),
                        border: Border.all(color: Color(0xFFFFB715)),
                        borderRadius: BorderRadius.circular(Dimens.pt6)),
                    child: Column(children: [
                      ...List.generate(
                          logic.sysTypeCodeList.length,
                          (index) => _buildDropdownItem(
                              list: logic.sysTypeCodeList,
                              onTap: () => logic.chooseSysType(index),
                              index: index))
                    ]))))));
  }

  Widget _buildDateChooseView() {
    BillRecordController logic = Get.find<BillRecordController>();
    return Positioned(
        top: Dimens.pt65,
        child: Obx(() => AnimatedOpacity(
            duration: Durations.short4,
            opacity: logic.showDateChoose.value ? 1 : 0,
            child: IgnorePointer(
              ignoring: !logic.showDateChoose.value,
              child: Container(
                  width: Dimens.pt100,
                  decoration: BoxDecoration(
                      color: Color(0xFF171F20),
                      border: Border.all(color: Color(0xFFFFB715)),
                      borderRadius: BorderRadius.circular(Dimens.pt6)),
                  child: Column(children: [
                    ...List.generate(
                        logic.dateCodesList.length,
                        (index) => GestureDetector(
                            onTap: () => logic.chooseDate(index),
                            child: _buildDropdownItem(
                                list: logic.dateCodesList,
                                onTap: () => logic.chooseDate(index),
                                index: index)))
                  ])),
            ))));
  }
}
