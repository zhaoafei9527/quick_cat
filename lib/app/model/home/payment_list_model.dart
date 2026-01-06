// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class PaymentList extends BaseNetModel {
  @override
  PaymentList fromJson(Map<String, dynamic> json) {
    return PaymentList.fromJson(json);
  }

  List<PaymentDataList>? list;

  PaymentList({this.list});

  PaymentList.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <PaymentDataList>[];
      json['list'].forEach((v) {
        list?.add(PaymentDataList.fromJson(v));
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

class PaymentDataList {
  String? rechargeName;
  int? rechargeType;
  String? icon;
  String? desc;
  int? bonusRatio; // 充值赠送比例

  PaymentDataList(
      {this.rechargeName, this.rechargeType, this.icon, this.bonusRatio});

  PaymentDataList.fromJson(Map<String, dynamic> json) {
    rechargeName = json['rechargeName'];
    rechargeType = json['rechargeType'];
    desc = json['desc'];
    icon = json['icon'];
    bonusRatio = json['bonusRatio'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['rechargeName'] = rechargeName;
    data['rechargeType'] = rechargeType;
    data['desc'] = desc;
    data['icon'] = icon;
    data['bonusRatio'] = bonusRatio;
    return data;
  }
}