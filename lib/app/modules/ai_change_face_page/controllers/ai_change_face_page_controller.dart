import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/data/share_key.dart';
import 'package:acgn_client/app/dialog/common_dialog.dart';
import 'package:acgn_client/app/model/ai_generate_model.dart';
import 'package:acgn_client/app/model/cut_info.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:acgn_client/utils/app_util.dart';
import 'package:acgn_client/utils/text_util.dart';
import 'package:acgn_client/utils/toast_util.dart';
import 'package:get/get.dart';

class AiChangeFacePageController extends GetxController {
  RxString localPath = "".obs;
  RxString imageUrl = "".obs;
  RxBool uploadComplete = false.obs;
  int price = 0;
  String desc = "";
  String faceImageUrl = "";

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    price = TextUtil.getIntArgument("price");
    desc = Get.arguments["desc"] ?? "";
    faceImageUrl = Get.arguments["faceImageUrl"] ?? "";
  }

  Future<void> startAddTask() async {
    AiTaskRequestModel args = AiTaskRequestModel(
      aiType: AiTaskType.aiChangeFace,
      image: imageUrl.value,
      price: price,
      stencilPic: faceImageUrl,
      taskStatus: AiTaskStatus.aiTaskWaiting,
    );
    await ApiRes.addAiTaskToGenerate(aiTaskReq: args);
    localPath.value = "";
    imageUrl.value = "";
    uploadComplete.value = false;
    Get.back();
    showTypeToast(msg: "任务已添加到生成队列，请到脱衣记录中查看", toastType: ToastType.SUCCESS);
  }

  void onUploadImage() async {
    uploadComplete.value = false;
    ShareKeys shareKeys = Get.find<ShareKeys>();
    if (!((shareKeys.userInfo.vipType ?? 0) > 0)) {
      UploadImageRep? rep = await AppUtils.uploadSingleImage(
          onLocalPath: (String path) => localPath.value = path);
      if (rep != null && rep.path != null) {
        uploadComplete.value = true;
        imageUrl.value = rep.path!;
      }
    } else {
      showPlayerCommonDialog(Get.context!,
          title: "友情提示",
          content: "该功能仅会员用户可使用,请先获得会员！",
          btnList: ["获得会员", "忍住不脱"],
          btnCall: [
            () => Get.toNamed(Routes.VIP_CENTER_PAGE),
            () => Get.back()
          ],
          btnActionIndex: 0);
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
