// 📦 Package imports:
import 'package:get/get.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/task_center_model.dart';
import 'package:quick_cat_client/conf/api_res.dart';

class InvitedPageController extends GetxController {
  RxInt count = 0.obs;
  RxList<InvitedModel> invitedList = <InvitedModel>[].obs;
  RxList<int> numList = <int>[].obs;


  @override
  void onReady() async{
    showLoadingDialog();

    InvitedListModel? model = await ApiRes.getInvitedList();
    dismissDialog();
    if (model != null) {
      invitedList.value = model.list ?? <InvitedModel>[];
      count.value = model.shareGiftTotal ?? 0;

      // 将count 拆分 小于10补0 生成 numList
      String countStr = count.value.toString().padLeft(2, '0');
      numList.clear();
      for (int i = 0; i < countStr.length; i++) {
        numList.add(int.parse(countStr[i]));
      }
    }
    super.onReady();
  }
}
