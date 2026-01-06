// 🌎 Project imports:
import 'package:acgn_client/plugins_utils/HttpRequester/http_requester.dart';

/// 单个广告
class GameListModel extends BaseNetModel {
  @override
  GameListModel fromJson(Map<String, dynamic> json) {
    return GameListModel.fromJson(json);
  }

  int? count;
  List<GameInfoBean>? list;
  int? code;
  String? msg;
  GameInfoBean? data;


  GameListModel({this.count, this.code,this.data,this.msg, this.list});

  GameListModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    code = json['code'];
    msg = json['msg'];
    if (null != json['data']) {
      data = GameInfoBean.fromJson(json["data"]);
    }
    if (json['list'] != null) {
      list = <GameInfoBean>[];
      json['list'].forEach((v) {
        list?.add(GameInfoBean.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> datas = <String, dynamic>{};
    datas['data'] = data?.toJson();
    datas['count'] = count;
    if (list != null) {
      datas['list'] = list?.map((v) => v.toJson()).toList();
    }
    return datas;
  }
}

class GameInfoBean extends BaseNetModel {
  @override
  GameInfoBean fromJson(Map<String, dynamic> json) {
    return GameInfoBean.fromJson(json);
  }

  int? id;
  int? number;
  int? gameCategory;
  String? introduce; // 简介
  String? title;
  String? coverImg;
  String? gameReason;
  String? gameUrl;
  String? selectedIcon;

  GameInfoBean(
      {this.id,
      this.title,
      this.introduce,
      this.number,
      this.gameReason,
      this.gameUrl,
      this.gameCategory,
      this.coverImg,
      this.selectedIcon});

  GameInfoBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    number = json['number'];
    gameReason = json['gameReason'];
    gameUrl = json['gameUrl'];
    introduce = json['introduce'];
    gameCategory = json['gameCategory'];
    coverImg = json['coverImg'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data["number"] = number;
    data['gameCategory'] = gameCategory;
    data['introduce'] = introduce;
    data['coverImg'] = coverImg;

    return data;
  }
}
