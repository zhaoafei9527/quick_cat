// 🌎 Project imports:
import 'package:acgn_client/plugins_utils/HttpRequester/http_requester.dart';

class QrModel extends BaseNetModel {
  @override
  QrModel fromJson(Map<String, dynamic> json) {
    return QrModel.fromJson(json);
  }

  String? value;
  String? app;
  String? backup;
  String? web;

  QrModel({this.value, this.app, this.backup, this.web});

  QrModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    app = json['app'];
    backup = json['backup'];
    web = json['web'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['app'] = app;
    data['backup'] = backup;
    data['web'] = web;
    return data;
  }
}
