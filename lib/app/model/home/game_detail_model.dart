// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class GameDetail extends BaseNetModel {
  @override
  GameDetail fromJson(Map<String, dynamic> json) {
    return GameDetail.fromJson(json);
  }

  int? count;
  List<DetailList>? list;

  GameDetail({this.count, this.list});

  GameDetail.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['list'] != null) {
      list = <DetailList>[];
      json['list'].forEach((v) {
        list?.add(DetailList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['count'] = count;
    if (list != null) {
      data['list'] = list?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DetailList {
  int? gamePlatform; // 游戏平台
  String? icon; // 游戏图标
  String? title; // 游戏标题
  num? totalProfit; // 总盈亏
  double? totalValidBet; // 总有效投注额
  int? count; // 下单注

  String? recordId;
  int? time;
  int? id;

  String? gameTime;

  DetailList(
      {this.gamePlatform,
      this.title,
      this.totalProfit,
      this.recordId,
      this.time,
      this.id,
      this.count,
      this.gameTime,
      this.totalValidBet});

  DetailList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    gamePlatform = json['gamePlatform'];
    title = json['title'];
    totalProfit = json['totalProfit'];
    recordId = json['recordId'];
    time = json['time'];
    count = json['count'];
    gameTime = json['gameTime'];
    totalValidBet = json['totalValidBet'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['gamePlatform'] = gamePlatform;
    data['title'] = title;
    data['count'] = count;
    data['totalProfit'] = totalProfit;
    data['recordId'] = recordId;
    data['time'] = time;
    data['gameTime'] = gameTime;
    data['totalValidBet'] = totalValidBet;
    return data;
  }
}
