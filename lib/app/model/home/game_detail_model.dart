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
  int? game;
  String? gameName;
  num? profit;
  String? recordId;
  int? time;
  int? id;
  String? gameTime;
  String? validBet;

  DetailList(
      {this.game,
      this.gameName,
      this.profit,
      this.recordId,
      this.time,
      this.id,
      this.gameTime,
      this.validBet});

  DetailList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    game = json['game'];
    gameName = json['gameName'];
    profit = json['profit'];
    recordId = json['recordId'];
    time = json['time'];
    gameTime = json['gameTime'];
    validBet = json['validBet'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['game'] = game;
    data['gameName'] = gameName;
    data['profit'] = profit;
    data['recordId'] = recordId;
    data['time'] = time;
    data['gameTime'] = gameTime;
    data['validBet'] = validBet;
    return data;
  }
}
