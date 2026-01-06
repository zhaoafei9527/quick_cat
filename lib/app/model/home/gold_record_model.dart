// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class GoldRecord extends BaseNetModel {
  @override
  GoldRecord fromJson(Map<String, dynamic> json) {
    return GoldRecord.fromJson(json);
  }

  List<Goldlist>? goldlist;
  int? total;

  GoldRecord({this.goldlist, this.total});

  GoldRecord.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      goldlist = <Goldlist>[];
      json['list'].forEach((v) {
        goldlist?.add(Goldlist.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (goldlist != null) {
      data['Goldlist'] = goldlist?.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    return data;
  }
}

class Goldlist {
  int? coinAmount;
  String? createdAt;
  int? currencyType;
  String? desc;
  String? orderNo;

  Goldlist(
      {this.coinAmount,
      this.createdAt,
      this.currencyType,
      this.desc,
      this.orderNo});

  Goldlist.fromJson(Map<String, dynamic> json) {
    coinAmount = json['coinAmount'];
    createdAt = json['createdAt'];
    currencyType = json['currencyType'];
    desc = json['desc'];
    orderNo = json['orderNo'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['coinAmount'] = coinAmount;
    data['createdAt'] = createdAt;
    data['currencyType'] = currencyType;
    data['desc'] = desc;
    data['orderNo'] = orderNo;
    return data;
  }
}
