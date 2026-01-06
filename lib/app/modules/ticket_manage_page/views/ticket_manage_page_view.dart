// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/model/recharge_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import '../../../../r.dart';
import '../../../../utils/app_util.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/screen.dart';
import '../../../widget/text_field.dart';
import '../controllers/ticket_manage_page_controller.dart';

class TicketManagePageView extends GetView<TicketManagePageController> {
  const TicketManagePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TicketManagePageController logic = Get.find();
    ThemeManager theme = Get.find<ThemeManager>();
    return Scaffold(
        backgroundColor: theme.getColor(ThemeColor.bg),
        appBar: getCommonAppBar(logic.title.value),
        body: GestureDetector(
          onTap: () => logic.redeemFocusNode.unfocus(),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              child: logic.type.value == 1
                  ? _buildLotteryTicket()
                  : logic.type.value == 2
                      ? _buildMovieTicket()
                      : _buildRedeemPageView()),
        ));
  }

  _buildRedeemPageView() {
    ThemeManager theme = Get.find<ThemeManager>();
    TicketManagePageController logic = Get.find();
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
          height: Dimens.pt80,
          margin: EdgeInsets.only(bottom: Dimens.pt10),
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
          decoration: BoxDecoration(
              color: Color(0xFF151517),
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(Dimens.pt45)),
          child: Row(children: [
            Expanded(
                child: GetCommonTextField(
                    focusNode: logic.redeemFocusNode,
                    controller: logic.redeemField,
                    maxLength: 20,
                    hintText: "请输入兑换码",
                    onSubmitted: (String text) => {}))
          ])),
      // SizedBox(height: Dimens.pt10),
      // _buildRedeemTipText(),
      SizedBox(height: Dimens.pt60),
      _buildRedeemSubmitBtn(),
      SizedBox(height: Dimens.pt150),
      // Text("兑换记录",
      //     style: TextStyle(
      //         fontSize: Dimens.pt32,
      //         fontWeight: FontWeight.w600,
      //         color: theme.getColor(ThemeColor.primary))),

      // SizedBox(height: Dimens.pt30),

      Expanded(
          child: Stack(alignment: Alignment.topCenter, children: [
        Container(
          color: Color(0xFF24242F),
          padding: EdgeInsets.symmetric(vertical: Dimens.pt40),
          child: Column(children: [
            SizedBox(
                height: Dimens.pt55,
                child: Row(children: [
                  _getTableRow(text: "兑换码"),
                  const Spacer(),
                  _getTableRow(text: "兑换类型"),
                  const Spacer(),
                  _getTableRow(text: "兑换时间")
                ])),
            Expanded(
                child: PagePullView(
                    key: logic.redeemKey,
                    dataGetter: (int pageNum, int size) async {
                      RechargeModel? model =
                          await ApiRes.getRedeemList(pageNum: pageNum);
                      return model?.redeemList ?? [];
                    },
                    emptyView: buildCommonEmptyView("宝宝还没有兑换过哟～"),
                    widgetBuilder: (BuildContext context, List<dynamic> list,
                        Widget? child) {
                      return ListView.separated(
                          itemBuilder: (c, index) => Container(
                              height: Dimens.pt110,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color:
                                              Colors.white.withOpacity(.1)))),
                              child: Row(children: [
                                _getTableRow(text: list[index].code),
                                const Spacer(),
                                _getTableRow(text: list[index].desc),
                                const Spacer(),
                                _getTableRow(text: list[index].activedAt),
                              ])),
                          separatorBuilder: (c, index) =>
                              SizedBox(height: Dimens.pt10),
                          itemCount: list.length);
                    }))
          ]),
        ),
        Transform.translate(
            offset: Offset(0, -Dimens.pt35),
            child: Image.asset(R.assetsImgTipRedeem, height: Dimens.pt80))
      ])),
    ]);
  }

  Widget _getTableRow({double? width, String? text, Color? color}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return SizedBox(
        width: width ?? Dimens.pt160,
        child: Center(
            child: Text(text ?? "",
                style: TextStyle(
                    fontSize: Dimens.pt34, color: color ?? Colors.white))));
  }

  Widget _buildRedeemSubmitBtn() {
    ThemeManager theme = Get.find<ThemeManager>();
    TicketManagePageController logic = Get.find();
    return GestureDetector(
        onTap: () => logic.useRedeemCode(),
        child: Container(
          width: Dimens.pt550,
          height: Dimens.pt86,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColors.mainRed,
              borderRadius: BorderRadius.circular(Dimens.pt86)),
          child: Text("立即兑换",
              style: TextStyle(
                  fontSize: Dimens.pt26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ));
  }

  Widget _buildRedeemTipText() {
    ThemeManager theme = Get.find<ThemeManager>();
    return Text("1.输入激活码即可完成激活\n2.激活成功后，即可享受对应的权益与服务\n3.请在兑换码有效期内使用，逾期作废",
        style: TextStyle(
            fontSize: Dimens.pt22,
            color: theme.getColor(ThemeColor.textYellow)));
  }

  _buildMovieTicket() {
    TicketManagePageController logic = Get.find();
    int total = logic.movieTicket.value + logic.recentMovie.value;
    if (total <= 0) {
      return _buildEmptyView("观影券");
    }
    return ListView.separated(
      itemBuilder: (c, index) => GestureDetector(
        onTap: () {
          index < logic.recentMovie.value
              ? AppUtils.jumpToHome(index: 0)
              : showToast(msg: "该兑换券已被使用");
        },
        child: Image.asset(
          index < logic.recentMovie.value
              ? R.assetsImgTicketMovieView
              : R.assetsImgTicketMovieUsed,
          width: screen.screenWidth,
        ),
      ),
      separatorBuilder: (c, index) => SizedBox(height: Dimens.pt25),
      itemCount: total,
    );
  }

  _buildLotteryTicket() {
    TicketManagePageController logic = Get.find();
    int total = logic.lotteryTicket.value + logic.recentLottery.value;
    if (total <= 0) {
      return _buildEmptyView("抽奖券");
    }

    return ListView.separated(
        itemBuilder: (c, index) => GestureDetector(
              onTap: () {
                ShareKeys shareKeys = Get.find<ShareKeys>();
                index < logic.recentLottery.value
                    ? AppPages.jumpRouter(
                        path:
                            'webView://web_view?title=超级大转盘&uri=${shareKeys.baseUrl}/zoudoboh-webview/')
                    : showToast(msg: "该抽奖券已被使用");
              },
              child: Image.asset(
                  index < logic.recentLottery.value
                      ? R.assetsImgTicketRaffleView
                      : R.assetsImgTicketRaffleUsed,
                  width: screen.screenWidth),
            ),
        separatorBuilder: (c, index) => SizedBox(
              height: Dimens.pt25,
            ),
        itemCount: total);
  }

  Center _buildEmptyView(String text) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(R.assetsImgIconSerchEmpty,
                width: Dimens.pt200, height: Dimens.pt200),
            Text("什么也没找到～快去充值获取更多$text吧",
                style: TextStyle(
                    fontSize: Dimens.pt26, color: const Color(0xFF565454)))
          ]),
    );
  }
}
