// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class GetPaidUrl extends BaseNetModel {
  @override
  GetPaidUrl fromJson(Map<String, dynamic> json) {
    return GetPaidUrl.fromJson(json);
  }

  bool? isOpenNewBrowser;
  String? mode;
  String? payUrl;

  GetPaidUrl({this.isOpenNewBrowser, this.mode, this.payUrl});

  GetPaidUrl.fromJson(Map<String, dynamic> json) {
    isOpenNewBrowser = json['isOpenNewBrowser'];
    mode = json['mode'];
    payUrl = json['payUrl'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['isOpenNewBrowser'] = isOpenNewBrowser;
    data['mode'] = mode;
    data['payUrl'] = payUrl;
    return data;
  }
}
