// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class QrcodeObtain extends BaseNetModel {
  @override
  QrcodeObtain fromJson(Map<String, dynamic> json) {
    return QrcodeObtain.fromJson(json);
  }

  String? app;
  String? backup;
  String? value;
  String? web;

  QrcodeObtain({this.app, this.backup, this.value, this.web});

  QrcodeObtain.fromJson(Map<String, dynamic> json) {
    app = json['app'];
    backup = json['backup'];
    value = json['value'];
    web = json['web'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['app'] = app;
    data['backup'] = backup;
    data['value'] = value;
    data['web'] = web;
    return data;
  }
}
