// 🎯 Dart imports:
import 'dart:convert';

// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';
import '../../data/enum.dart';

class GoldTaskListModel extends BaseNetModel {
  @override
  GoldTaskListModel fromJson(Map<String, dynamic> json) {
    return GoldTaskListModel.fromJson(json);
  }

  List<GoldTaskModel>? list;

  GoldTaskListModel({this.list});

  GoldTaskListModel.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <GoldTaskModel>[];
      json['list'].forEach((v) {
        list?.add(GoldTaskModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['list'] = json.encode(list);
    return data;
  }
}

class GoldTaskModel extends BaseNetModel {
  @override
  GoldTaskModel fromJson(Map<String, dynamic> json) {
    return GoldTaskModel.fromJson(json);
  }

  int? id;
  String? name;
  String? title; // 任务标题
  int? currParam1; // 任务参数1技术
  int? currParam2; // 任务参数2计数
  String? goTo; // 完成跳转地址
  int? param1; // 任务参数1计数
  int? param2; // 任务参数2计数
  int? rewardCoins; // 奖励金币
  int? rewardVips; // 奖励Vip
  int? status; //任务状态
  GoldTaskType? type; // 类型
  int? vip; // vip天数
  String? desc;
  String? buttonText; // 任务确定按钮
  int? goldNumber; // 任务金币数额
  String? icon; // 任务Icon展示
  Function()? onTap;

  GoldTaskModel(
      {this.id,
      this.name,
      this.desc,
      this.buttonText,
      this.goldNumber,
      this.onTap,
      this.title,
      this.currParam1,
      this.currParam2,
      this.goTo,
      this.param1,
      this.param2,
      this.rewardCoins,
      this.rewardVips,
      this.status,
      this.type,
      this.vip,
      this.icon});

  GoldTaskModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    desc = json['desc'];
    title = json['title'];
    currParam1 = json['currParam1'];
    currParam2 = json['currParam2'];
    goTo = json['goTo'];
    param1 = json['param1'];
    param2 = json['param2'];
    rewardCoins = json['rewardCoins'];
    rewardVips = json['rewardVips'];
    status = json['status'];
    type = GoldTaskType.values[json['type'] ?? 0];
    vip = json['vip'];
    buttonText = json['buttonText'];
    goldNumber = json['goldNumber'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['desc'] = desc;
    data['title'] = title;
    data['currParam1'] = currParam1;
    data['currParam2'] = currParam2;
    data['goTo'] = goTo;
    data['param1'] = param1;
    data['param2'] = param2;
    data['rewardCoins'] = rewardCoins;
    data['rewardVips'] = rewardVips;
    data['status'] = status;
    data['type'] = type?.index;
    data['vip'] = vip;
    data['buttonText'] = buttonText;
    data['goldNumber'] = goldNumber;
    data['icon'] = icon;
    return data;
  }
}
