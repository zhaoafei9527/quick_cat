// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/widget/common_app_bar.dart';
import '../../../../utils/dimens.dart';
import '../../../model/home/user_info_model.dart';
import '../../../themes/app_colors.dart';
import '../../user_terms_page/controllers/user_terms_page_controller.dart';
import '../controllers/sub_terms_page_controller.dart';

class SubTermsPageView extends GetView<SubTermsPageController> {
  const SubTermsPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserTermsPageController logic = Get.find<UserTermsPageController>();
    UserInfo userInfo = logic.userInfo.value;
    int vip = userInfo.vipType ?? 0;
    return Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: getCommonAppBar("全部勋章"),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
          child: Wrap(
              direction: Axis.horizontal,
              spacing: Dimens.pt10,
              runSpacing: Dimens.pt30,
              children: [
                ...List.generate(6, (index) {
                  return Column(children: [
                    GestureDetector(
                        // onTap: () => AppUtils.jumpToHome(index: 0),
                        child: Container(
                            width: Dimens.pt345,
                            height: Dimens.pt220,
                            decoration: BoxDecoration(
                                color: const Color(0xFF1D1A19),
                                borderRadius:
                                    BorderRadius.circular(Dimens.pt12)),
                            child: Image.asset("",
                                fit: BoxFit.cover))),
                    SizedBox(height: Dimens.pt25),
                    Text(
                        index == (vip - 2)
                            ? "您的勋章"
                            : "vip${index + 1}(${logic.levelCardInfo[index]["name"]})",
                        style: TextStyle(
                            fontSize: Dimens.pt22,
                            color: index == (vip - 2)
                                ? const Color(0xFFFF6213)
                                : const Color(0xFF8A8785)))
                  ]);
                })
              ]),
        ));
  }
}
