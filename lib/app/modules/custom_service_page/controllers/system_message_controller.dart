// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/model/msg_notify_list_model.dart';
import '../../../../conf/api_res.dart';

class SystemMessageController extends GetxController {
  late RxString customerUri = "".obs;
  RxList<MsgNotifyModel> messageList = <MsgNotifyModel>[].obs;


  Future<List<MsgNotifyModel>?> getSystemMessageData() async {
    MsgNotifyListModel? model = await ApiRes.getSystemMessageList(type: 2);
    return model?.list;
  }


}
