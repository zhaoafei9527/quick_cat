// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/modules/home/home_mine_center/views/home_mine_center_view.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/utils/app_util.dart';
import 'package:quick_cat_client/utils/time_util.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../../../../plugins_utils/ImageLoader/ImageLoader.dart';
import '../../../../utils/dimens.dart';
import '../../../themes/app_colors.dart';
import '../../../widget/common_widget.dart';
import '../controllers/user_terms_page_controller.dart';

class UserTermsPageView extends GetView<UserTermsPageController> {
  const UserTermsPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<UserTermsPageController>(
        builder: (UserTermsPageController logic) {
      ThemeManager theme = Get.find<ThemeManager>();
      return Scaffold(
          backgroundColor: AppColors.bgColor,
          appBar: getCommonAppBar("会员权益", actions: [
            GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => AppUtils.goToCustomServicePage(),
                child: Text("在线客服",
                    style: TextStyle(
                        fontSize: Dimens.pt28,
                        color: theme.getColor(ThemeColor.primary)))),
            SizedBox(width: Dimens.pt25)
          ]),
          body: logic.initOk.value
              ? SingleChildScrollView(
                  child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: Dimens.pt25),
                        _userInfoViewBuilder(logic, theme),
                        SizedBox(height: Dimens.pt25),
                        _buildInterestsView(),
                        SizedBox(height: Dimens.pt50),
                        GestureDetector(
                            onTap: () => Get.toNamed(Routes.VIP_CENTER_PAGE),
                            child: Container(
                                width: screen.screenWidth,
                                height: Dimens.pt80,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                      Color(0xFFFFECD6),
                                      Color(0xFFFFD6AA)
                                    ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight)),
                                child: Text("开通会员",
                                    style: TextStyle(
                                        fontSize: Dimens.pt30,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF5E3D05))))),
                        SizedBox(height: Dimens.pt50),
                        Text("服务声明",
                            style: TextStyle(
                                fontSize: Dimens.pt38,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        SizedBox(height: Dimens.pt25),
                        Text("1.充值会员送等额游戏金！可用于游戏娱乐,赢取高额奖金！提现秒到账！",
                            style: TextStyle(
                                fontSize: Dimens.pt26,
                                color: Color(0xFFFFDB9E))),
                        SizedBox(height: Dimens.pt25),
                        Text("2.会员有效期,天数可叠加累计！",
                            style: TextStyle(
                                fontSize: Dimens.pt26,
                                color: AppColors.textGrey)),
                        SizedBox(height: Dimens.pt25),
                        Text("3.我们本着用户至上的原则,在充值中遇到任何问题,请咨询在线客服！",
                            style: TextStyle(
                                fontSize: Dimens.pt26,
                                color: AppColors.textGrey)),
                        SizedBox(height: Dimens.pt25),
                        Text("4.为避免文字差异,我司保留最终解释权！",
                            style: TextStyle(
                                fontSize: Dimens.pt26,
                                color: AppColors.textGrey)),
                        SizedBox(height: screen.bottomNavBarH)
                      ]),
                ))
              : getLoadingView());
    });
  }

  Widget _buildInterestsView() {
    UserTermsPageController logic = Get.find<UserTermsPageController>();
    return Container(
      width: screen.screenWidth,
      height: Dimens.pt700,
      color: AppColors.textBlackColor,
      padding: EdgeInsets.symmetric(vertical: Dimens.pt30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text("权益列表",
            style: TextStyle(fontSize: Dimens.pt30, color: Color(0xFFFFDB9E))),
        SizedBox(height: Dimens.pt25),
        Expanded(
            child: GridView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.only(top: Dimens.pt25, bottom: Dimens.pt45),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, //横向数量
                    crossAxisSpacing: Dimens.pt30,
                    mainAxisSpacing: Dimens.pt10,
                    childAspectRatio: 167 / 199),
                itemCount: logic.rights.length,
                itemBuilder: (c, index) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(clipBehavior: Clip.none, children: [
                          SizedBox(
                              width: Dimens.pt66,
                              height: Dimens.pt66,
                              child: ImageLoader.withP(
                                      logic.rights[index].image ?? "",
                                      width: Dimens.pt40,
                                      height: Dimens.pt40,
                                      color:
                                          (logic.rights[index].isLight ?? false)
                                              ? AppColors.mainRed
                                              : AppColors.textYellowColor)
                                  .load()),
                          if ((logic.rights[index].homeName ?? "").isNotEmpty)
                            Positioned(
                                left: Dimens.pt50,
                                top: -Dimens.pt10,
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: Dimens.pt10,
                                        vertical: Dimens.pt2),
                                    decoration: BoxDecoration(
                                        color: AppColors.mainRed,
                                        borderRadius: BorderRadius.only(
                                            topLeft:
                                                Radius.circular(Dimens.pt33),
                                            topRight:
                                                Radius.circular(Dimens.pt33),
                                            bottomRight:
                                                Radius.circular(Dimens.pt33))),
                                    child: Text(
                                        logic.rights[index].homeName ?? "",
                                        style: TextStyle(
                                            fontSize: Dimens.pt20,
                                            color: AppColors.textColorWhite))))
                        ]),
                        SizedBox(height: Dimens.pt10),
                        Text(logic.rights[index].name ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: Dimens.pt26,
                                color: (logic.rights[index].isLight ?? false)
                                    ? AppColors.mainRed
                                    : Color(0xFFFFDB9E))),
                        Text(logic.rights[index].desc ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: Dimens.pt20,
                                color: (logic.rights[index].isLight ?? false)
                                    ? AppColors.mainRed
                                    : AppColors.textGrey))
                      ]);
                })),
      ]),
    );
  }

  Widget _userInfoViewBuilder(
      UserTermsPageController logic, ThemeManager theme) {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    return Stack(children: [
      Image.asset(R.assetsImgBgVipTerms,
          height: Dimens.pt120, fit: BoxFit.fill),
      GestureDetector(
          onTap: () => Get.toNamed(Routes.SETTING_PAGE),
          child: Container(
              height: Dimens.pt120,
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                ImageLoader.withP(logic.userInfo.value.avatarUrl ?? "",
                        width: Dimens.pt72,
                        height: Dimens.pt72,
                        radius: Dimens.pt72)
                    .load(),
                SizedBox(width: Dimens.pt20),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(logic.userInfo.value.nickName ?? "",
                          style: TextStyle(
                              fontSize: Dimens.pt28, color: Colors.white)),
                      SizedBox(height: Dimens.pt4),
                      if (shareKeys.isVip())
                        getVipShadowText(
                            text:
                                "会员有效期:${TimeUtil.buildChineseYYMMDD(logic.userInfo.value.vipExpireTime ?? "")}",
                            fontSize: Dimens.pt26,
                            fontWeight: FontWeight.w400)
                      else
                        getVipShadowText(
                            text: "开通会员 享专属会员特权",
                            fontSize: Dimens.pt26,
                            fontWeight: FontWeight.w400)
                    ])
              ])))
    ]);
  }
}
