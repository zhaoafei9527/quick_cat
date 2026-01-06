// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class MessageCenter extends BaseNetModel {
  @override
  MessageCenter fromJson(Map<String, dynamic> json) {
    return MessageCenter.fromJson(json);
  }

  List<MessageInfo>? list;

  MessageCenter({this.list});

  MessageCenter.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <MessageInfo>[];
      json['list'].forEach((v) {
        list?.add(MessageInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MessageInfo {
  String? content;
  String? createdAt;
  String? title;

  MessageInfo({this.content, this.createdAt, this.title});

  MessageInfo.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    createdAt = json['createdAt'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['content'] = content;
    data['createdAt'] = createdAt;
    data['title'] = title;
    return data;
  }
}
