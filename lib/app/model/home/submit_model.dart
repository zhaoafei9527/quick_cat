// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class Submit extends BaseNetModel {
  @override
  Submit fromJson(Map<String, dynamic> json) {
    return Submit.fromJson(json);
  }

  bool? isOpenNewBrowser;
  String? payUrl;
  String? mode;

  Submit({this.isOpenNewBrowser, this.payUrl, this.mode});

  Submit.fromJson(Map<String, dynamic> json) {
    isOpenNewBrowser = json['isOpenNewBrowser'];
    payUrl = json['payUrl'];
    mode = json['mode'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['isOpenNewBrowser'] = isOpenNewBrowser;
    data['payUrl'] = payUrl;
    data['mode'] = mode;
    return data;
  }
}
