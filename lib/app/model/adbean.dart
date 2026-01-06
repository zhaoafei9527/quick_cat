// 🌎 Project imports:
import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';

/// 单个广告
class AdBean extends BaseNetModel {
  @override
  AdBean fromJson(Map<String, dynamic> json) {
    return AdBean.fromJson(json);
  }

  String? id;
  int? position;
  String? title;
  String? description;
  String? cover;
  String? href;
  int? sortCode;
  bool? isVip;
  String? avatar;
  String? avatarType;

  AdBean(
      {this.id,
      this.title,
      this.description,
      this.cover,
      this.href,
      this.avatar,
      this.avatarType,
      this.sortCode});

  AdBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    cover = json['cover'];
    position = json['position'];
    href = json['href'];
    isVip = json['isVip'];
    avatar = json['avatar'];
    avatarType = json['avatarType'];
    sortCode = json['sortCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['cover'] = cover;
    data['href'] = href;
    data['positon'] = position;
    data['sortCode'] = sortCode;
    return data;
  }
}
