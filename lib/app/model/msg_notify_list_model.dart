// 🌎 Project imports:
import 'package:acgn_client/plugins_utils/HttpRequester/http_requester.dart';

class MsgNotifyListModel extends BaseNetModel{

  @override
  MsgNotifyListModel fromJson(Map<String, dynamic> json) {
    return MsgNotifyListModel.fromJson(json);
  }
  List<MsgNotifyModel>? list;

  MsgNotifyListModel({this.list});

  MsgNotifyListModel.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <MsgNotifyModel>[];
      json['list'].forEach((v) {
        list?.add(MsgNotifyModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MsgNotifyModel {
  String? title;
  String? content;
  String? link;
  int? circleId;
  String? circleName;
  String? circleAvatar;
  String? createdAt;
  String? img;

  MsgNotifyModel(
      {this.title,
      this.content,
      this.link,
      this.circleId,
      this.circleName,
      this.circleAvatar,
      this.img,
      this.createdAt});

  MsgNotifyModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
    link = json['link'];
    img = json['img'];
    circleId = json['circleId'];
    circleName = json['circleName'];
    circleAvatar = json['circleAvatar'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['content'] = content;
    data['link'] = link;
    data['img'] = img;
    data['circleId'] = circleId;
    data['circleName'] = circleName;
    data['circleAvatar'] = circleAvatar;
    data['createdAt'] = createdAt;
    return data;
  }
}
