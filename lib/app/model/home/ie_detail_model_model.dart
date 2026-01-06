// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class IeDetailModel extends BaseNetModel {
  @override
  IeDetailModel fromJson(Map<String, dynamic> json) {
    return IeDetailModel.fromJson(json);
  }


  int? count;
  List<IeDetailList>? list;

  IeDetailModel({this.count, this.list});

  IeDetailModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['list'] != null) {
      list = <IeDetailList>[];
      json['list'].forEach((v) {
        list?.add(IeDetailList.fromJson(v));
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

class IeDetailList {
  int? coinAmount;
  String? createdAt;
  int? markType;
  int? recharge;
  int? tranType;

  IeDetailList(
      {this.coinAmount,
      this.createdAt,
      this.markType,
      this.recharge,
      this.tranType});

  IeDetailList.fromJson(Map<String, dynamic> json) {
    coinAmount = json['coinAmount'];
    createdAt = json['createdAt'];
    markType = json['markType'];
    recharge = json['recharge'];
    tranType = json['tranType'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['coinAmount'] = coinAmount;
    data['createdAt'] = createdAt;
    data['markType'] = markType;
    data['recharge'] = recharge;
    data['tranType'] = tranType;
    return data;
  }
}
