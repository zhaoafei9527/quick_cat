// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/home/user_info_model.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import '../../../../utils/dimens.dart';
import '../../../themes/app_colors.dart';
import '../controllers/setting_page_controller.dart';

class SetUserAvatarPage extends GetView<SettingPageController> {
  const SetUserAvatarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetBuilder<SettingPageController>(builder: (logic) {
      logic.getUserAvatarList();
      return Scaffold(
          backgroundColor: theme.getColor(ThemeColor.bg),
          appBar: getCommonAppBar("修改头像"),
          body: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                  child: SizedBox(
                    width: screen.screenWidth,
                    child: Obx(() => Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ImageLoader.withP(logic.userAvatar.value,
                                      width: Dimens.pt190,
                                      height: Dimens.pt190,
                                      radius: Dimens.pt190)
                                  .load(),
                              SizedBox(height: Dimens.pt25),
                              ...logic.avatarList.entries.map((entry) {
                                String groupName = entry.key;
                                List<AvatarInfo> avatars = entry.value;
                                if (groupName.isEmpty) return const SizedBox();
                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: Dimens.pt60),
                                      Text(groupName,
                                          style: TextStyle(
                                              fontSize: Dimens.pt32,
                                              color: Colors.white)),
                                      SizedBox(height: Dimens.pt25),
                                      GridView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 4, //横向数量
                                                  crossAxisSpacing: Dimens.pt40,
                                                  mainAxisSpacing: Dimens.pt20,
                                                  childAspectRatio: 80 / 80),
                                          itemCount: avatars.length ?? 0,
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return _buildAvatarItem(
                                                logic, avatars, index);
                                          })
                                    ]);
                              })
                            ])),
                  ))));
    });
  }

  GestureDetector _buildAvatarItem(
      SettingPageController logic, List<AvatarInfo> avatars, int index) {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    return GestureDetector(
        onTap: () async {
          if (shareKeys.isVip()) {
            await ApiRes.setUserInformation(
                onSuccess: () {
                  logic.userAvatar.value = avatars[index].avatar ?? "";
                  showTypeToast(msg: "更换头像成功", toastType: ToastType.SUCCESS);
                  ApiRes.getUpdateUserInfo();
                },
                onError: (err) {
                  showTypeToast(msg: "更换头像失败，错误：$err");
                },
                avatar: avatars[index].avatar);
          } else {
            var result = await showPlayerCommonDialog(Get.context!,
                title: "友情提示",
                content: "该功能仅会员用户可使用,请先获得会员！",
                btnCall: [
                  () => logic.goVipRecharge(),
                ],
                btnActionIndex: 0);
          }
        },
        child: ImageLoader.withP(avatars[index].avatar,
                width: Dimens.pt140, height: Dimens.pt140,radius: Dimens.pt140)
            .load());
  }
}
