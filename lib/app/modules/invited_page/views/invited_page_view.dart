// 🐦 Flutter imports:
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/r_insert.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/model/home/qrcode_info_model.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import '../../../../utils/time_util.dart';
import '../controllers/invited_page_controller.dart';

class InvitedPageView extends GetView<InvitedPageController> {
  const InvitedPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    InvitedPageController logic = Get.find<InvitedPageController>();
    return Stack(children: [
      Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xFF020150)),
      Image.asset(R.assetsImgBgDialogShare, width: double.infinity),
      Scaffold(
          backgroundColor: Colors.transparent,
          appBar: getCommonAppBar("邀请好友"),
          body: SingleChildScrollView(
              child: Column(children: [
            SizedBox(height: Dimens.pt30),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              getHengLine(w: Dimens.pt80, color: Colors.white),
              SizedBox(width: Dimens.pt20),
              Text("邀好友 得会员",
                  style: TextStyle(fontSize: Dimens.pt30, color: Colors.white)),
              SizedBox(width: Dimens.pt20),
              getHengLine(w: Dimens.pt80, color: Colors.white)
            ]),
            SizedBox(height: Dimens.pt30),
            Image.asset(R.assetsImgTipShareText,
                width: Dimens.pt543 + Dimens.pt3),
            SizedBox(height: Dimens.pt10),
            Text("收益金币、邀请好礼均收入囊中",
                style: TextStyle(
                    fontSize: Dimens.pt24,
                    letterSpacing: 5.2,
                    fontWeight: FontWeight.w400,
                    color: Colors.white)),
            SizedBox(height: Dimens.pt300),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              getHengLine(w: Dimens.pt160, color: Colors.white),
              SizedBox(width: Dimens.pt12),
              Text("已成功邀请",
                  style: TextStyle(fontSize: Dimens.pt30, color: Colors.white)),
              SizedBox(width: Dimens.pt12),
              Image.asset(shareTextInsert["insert${controller.count}"]!,
                  width: Dimens.pt56, height: Dimens.pt76),
              SizedBox(width: Dimens.pt17),
              Image.asset(shareTextInsert["insert3"]!,
                  width: Dimens.pt56, height: Dimens.pt76),
              SizedBox(width: Dimens.pt12),
              Text("人",
                  style: TextStyle(
                      fontSize: Dimens.pt56,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              getHengLine(w: Dimens.pt160, color: Colors.white)
            ]),
            SizedBox(height: Dimens.pt40),
            Container(
                color: Color(0xFF2A2D8A),
                padding: EdgeInsets.symmetric(
                    horizontal: Dimens.pt30, vertical: Dimens.pt30),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ...List.generate(
                          4,
                          (index) => SizedBox(
                              width: (screen.screenWidth - Dimens.pt60) / 4,
                              child: Column(children: [
                                Image.asset(R.assetsImgIconShareVip,
                                    height: Dimens.pt80),
                                SizedBox(height: Dimens.pt15),
                                Text("邀请${index * 5 + 5}位好友",
                                    style: TextStyle(
                                        fontSize: Dimens.pt22,
                                        color: Color(0xFFB3DDFC))),
                                SizedBox(height: Dimens.pt24),
                                Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      getHengLine(
                                          w: double.infinity,
                                          h: .75,
                                          color: Colors.white.withOpacity(.5)),
                                      Image.asset(R.assetsImgIconSharePoin,
                                          width: Dimens.pt15)
                                    ]),
                                SizedBox(height: Dimens.pt24),
                                Container(
                                  decoration: BoxDecoration(
                                      color: index < logic.count.value
                                          ? AppColors.primaryColor
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(Dimens.pt45)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.pt23,
                                      vertical: Dimens.pt9),
                                  child: Text("未完成",
                                      style: TextStyle(
                                          fontSize: Dimens.pt20,
                                          color: Color(0xFF020150))),
                                )
                              ])))
                    ])),
            SizedBox(height: Dimens.pt40),
            GestureDetector(
                onTap: () => showShareAccountDialog(),
                child: Stack(alignment: Alignment.center, children: [
                  Image.asset(R.assetsImgBgShareButton, height: Dimens.pt82),
                  Text("立即分享得VIP",
                      style:
                          TextStyle(fontSize: Dimens.pt32, color: Colors.white))
                ])),
            SizedBox(height: Dimens.pt60),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
              child: Row(children: [
                getHengLine(w: Dimens.pt270, color: Colors.white),
                SizedBox(width: Dimens.pt10),
                Text("规则说明",
                    style:
                        TextStyle(fontSize: Dimens.pt30, color: Colors.white)),
                SizedBox(width: Dimens.pt10),
                getHengLine(w: Dimens.pt270, color: Colors.white)
              ]),
            ),
            SizedBox(height: Dimens.pt30),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
                child: Text(
                    "1:在福利中心邀请好友中，分享推广链接或者保存推广码给好友下载即可\n2:邀请1个好友成功下载app，即可获得1天VIP，2个好友2天VIP，以此类推\n3:禁止使用非法程序，手法恶意套利，一经发现，账号永久封禁",
                    style:
                        TextStyle(fontSize: Dimens.pt24, color: Colors.white))),
            SizedBox(height: screen.paddingBottom)
          ])))
    ]);
    // return Scaffold(
    //   appBar: getCommonAppBar("邀请记录"),
    //   body: Padding(
    //       padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
    //       child: PagePullView(
    //           key: const Key("key_invited_list"),
    //           dataGetter: (int pageNum, int size) async {
    //             InvitedList? model =
    //                 await ApiRes.getUserInvitedList(pageNum: pageNum);
    //             return model?.list ?? [];
    //           },
    //           emptyView: buildCommonEmptyView("宝贝,赶快邀请好友一起来玩吧～"),
    //           widgetBuilder:
    //               (BuildContext context, List<dynamic> list, Widget? child) {
    //             return ListView.separated(
    //                 itemBuilder: (context, index) => Container(
    //                     height: Dimens.pt133,
    //                     padding: EdgeInsets.all(Dimens.pt25),
    //                     decoration: BoxDecoration(
    //                         color: const Color(0xFF1D1A19),
    //                         borderRadius: BorderRadius.circular(Dimens.pt12)),
    //                     child: Row(children: [
    //                       Column(children: [
    //                         Text('成功邀请${list[index].name}',
    //                             style: TextStyle(
    //                                 fontSize: Dimens.pt28,
    //                                 color: Colors.white,
    //                                 fontWeight: FontWeight.w600)),
    //                         SizedBox(height: Dimens.pt10),
    //                         Text("已获得1天VIP会员",
    //                             style: TextStyle(
    //                                 fontSize: Dimens.pt24,
    //                                 color: AppColors.primaryColor))
    //                       ]),
    //                       const Spacer(),
    //                       Column(children: [
    //                         Container(
    //                           padding: EdgeInsets.symmetric(
    //                               vertical: Dimens.pt5,
    //                               horizontal: Dimens.pt20),
    //                           alignment: Alignment.center,
    //                           decoration: BoxDecoration(
    //                               color: const Color(0xFF2C2A29),
    //                               borderRadius:
    //                                   BorderRadius.circular(Dimens.pt45)),
    //                           child: Text(list[index].userId,
    //                               style: TextStyle(
    //                                   fontSize: Dimens.pt24,
    //                                   color: const Color(0xFFADB5BD))),
    //                         ),
    //                         SizedBox(height: Dimens.pt10),
    //                         Text(TimeUtil.buildChineseYYMMDD(
    //                             list[index].createAt ?? ''),
    //                             style: TextStyle(
    //                                 fontSize: Dimens.pt20,
    //                                 color: const Color(0xFFADB5BD)))
    //                       ])
    //                     ])),
    //                 separatorBuilder: (context, index) =>
    //                     SizedBox(height: Dimens.pt20),
    //                 itemCount: list.length);
    //           })),
    // );
  }
}
