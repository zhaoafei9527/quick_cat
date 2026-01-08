import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ComicWishedPageController extends GetxController {
  RxBool loading = true.obs;
  Rx<WishedListModel> wishedList = WishedListModel().obs;
  Rx<WishedInfoModel> active = WishedInfoModel().obs;
  RxList<WishedActiveMember> activeMemberList = <WishedActiveMember>[].obs;
  TextEditingController titleController = TextEditingController();
  TextEditingController wishContentController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    loading.value = true;
    WishedListModel? model = await ApiRes.getWishedList();
    loading.value = false;
    if (model != null) {
      wishedList.value = model;
      active.value = model.activity ?? WishedInfoModel();
    } else {
      wishedList.value = WishedListModel();
    }
    getActiveMemberList(active.value.id ?? 0);
  }

  Future<void> getActiveMemberList(int id) async {
    WishedActiveInfoDetail? model =
        await ApiRes.getWishedActiveInfoData(id: id);
    if (model != null) {
      activeMemberList.value = model.list ?? [];
      active.value = model.activity ?? WishedInfoModel();
    }
  }

  Future<void> clickWishSponsor(int id, int index) async {
    await ApiRes.wishSponsor(id: id);
    showTypeToast(msg: "助力成功");
    activeMemberList[index].isCollet = true;
    activeMemberList.refresh();
  }

  Future<void> submitWishContent() async {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    String title = titleController.text.trim();
    String content = wishContentController.text.trim();

    if (title.isEmpty) {
      showTypeToast(msg: "标题不能为空");
      return;
    }
    if (content.isEmpty) {
      showTypeToast(msg: "内容不能为空");
      return;
    }
    if (!((shareKeys.userInfo.vipType ?? 0) > 0)) {
      return showPlayerCommonDialog(Get.context!,
          title: "友情提示",
          content: "该功能仅会员用户可使用,请先获得会员！",
          btnCall: [
            () => Get.toNamed(Routes.VIP_CENTER_PAGE),
            () => Get.back()
          ],
          btnActionIndex: 0);
    }

    await ApiRes.submitWishContent(
        id: active.value.id, title: title, reason: content);
    showTypeToast(msg: "许愿成功", toastType: ToastType.SUCCESS);
    titleController.clear();
    wishContentController.clear();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
