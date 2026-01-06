// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/http_requester.dart';

/// 在线客服配置
class ServicesModel extends BaseNetModel {
  @override
  ServicesModel fromJson(Map<String, dynamic> json) {
    return ServicesModel.fromJson(json);
  }

  String? faq;
  String? sign;
  String? check;
  bool? isVoiceActive;

  ServicesModel({this.faq, this.sign, this.check});

  ServicesModel.fromJson(Map<String, dynamic> json) {
    faq = json['faq'];
    sign = json['endpoint'];
    check = json['check'];
    isVoiceActive = json['isVoiceActive'] ?? true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['faq'] = faq;
    data['endpoint'] = sign;
    data['check'] = check;
    data['isVoiceActive'] = isVoiceActive;
    return data;
  }
}
