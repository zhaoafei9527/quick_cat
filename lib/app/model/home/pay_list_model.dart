// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class PayList extends BaseNetModel {
  @override
  PayList fromJson(Map<String, dynamic> json) {
    return PayList.fromJson(json);
  }

  List<PayModes>? payModes;

  PayList({this.payModes});

  PayList.fromJson(Map<String, dynamic> json) {
    if (json['payModes'] != null) {
      payModes = <PayModes>[];
      json['payModes'].forEach((v) {
        payModes?.add(PayModes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (payModes != null) {
      data['payModes'] = payModes?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OnlineChargeModes {
  String? desc;
  String? id;
  String? nickname;
  String? avatar;
  int? type;
  bool? status;

  OnlineChargeModes({
    this.desc,
    this.id,
    this.nickname,
    this.type,
    this.avatar,
    this.status,
  });

  OnlineChargeModes.fromJson(Map<String, dynamic> json) {
    desc = json['desc'];
    id = json['id'];
    nickname = json['nickname'];
    type = json['type'];
    avatar = json['avatar'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['desc'] = desc;
    data['id'] = id;
    data['nickname'] = nickname;
    data['type'] = type;
    data['avatar'] = avatar;
    data['status'] = status;
    return data;
  }
}

class OnlineRecharge extends BaseNetModel {
  @override
  OnlineRecharge fromJson(Map<String, dynamic> json) {
    return OnlineRecharge.fromJson(json);
  }

  List<OnlineChargeModes>? list;

  OnlineRecharge({this.list});

  OnlineRecharge.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      if (json['data']['list'] != null) {
        list = <OnlineChargeModes>[];
        json['data']['list'].forEach((v) {
          list?.add(OnlineChargeModes.fromJson(v));
        });
      }
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

class vipDayRange {
  int? days;
  int? amountRange;

  vipDayRange({this.days, this.amountRange});

  vipDayRange.fromJson(Map<String, dynamic> json) {
    days = json['days'];
    amountRange = json['amountRange'] ?? json['desc'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['days'] = days;
    data['amountRange'] = amountRange;
    data['desc'] = amountRange;
    return data;
  }
}

class PayModes {
  String? desc;
  int? giftGold;
  int? goldBase;
  int? id;
  String? nickname;
  String? avatar;
  String? type;
  bool? status;
  String? name;
  int? payAmount;
  int? rchgUse;
  int? vipDay;
  int? rechargeRangeType;
  List<vipDayRange>? vipDayRangeList;

  PayModes(
      {this.desc,
      this.giftGold,
      this.goldBase,
      this.id,
      this.name,
      this.nickname,
      this.type,
      this.avatar,
      this.status,
      this.payAmount,
      this.rchgUse,
      this.rechargeRangeType,
      this.vipDayRangeList,
      this.vipDay});

  PayModes.fromJson(Map<String, dynamic> json) {
    desc = json['desc'];
    giftGold = json['giftGold'];
    goldBase = json['goldBase'];
    id = json['id'];
    name = json['name'];
    rechargeRangeType = json['rechargeRangeType'];
    if (json["vipList"] != null) {
      vipDayRangeList = <vipDayRange>[];
      json['vipList'].forEach((v) {
        vipDayRangeList?.add(vipDayRange.fromJson(v));
      });
    }
    nickname = json['nickname'];
    type = json['type'];
    avatar = json['avatar'];
    status = json['status'];
    payAmount = json['payAmount'];
    rchgUse = json['rchgUse'];
    vipDay = json['vipDay'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['desc'] = desc;
    data['giftGold'] = giftGold;
    data['goldBase'] = goldBase;
    data['id'] = id;
    data['rechargeRangeType'] = rechargeRangeType;
    data['name'] = name;
    data['nickname'] = nickname;
    data['type'] = type;
    data['avatar'] = avatar;
    data['status'] = status;
    data['payAmount'] = payAmount;
    data['rchgUse'] = rchgUse;
    data['vipDay'] = vipDay;
    data["vipList"] = vipDayRangeList?.map((v) => v.toJson()).toList();
    return data;
  }
}
