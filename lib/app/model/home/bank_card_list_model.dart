// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class BankCardList extends BaseNetModel {
  @override
  BankCardList fromJson(Map<String, dynamic> json) {
    return BankCardList.fromJson(json);
  }

  int? count;
  List<BankList>? bankList;

  BankCardList({this.count, this.bankList});

  BankCardList.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['list'] != null) {
      bankList = <BankList>[];
      json['list'].forEach((v) {
        bankList?.add(BankList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['count'] = count;
    if (bankList != null) {
      data['list'] = bankList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BankList {
  String? bankCode;
  int? id;
  String? name;

  BankList({this.bankCode, this.id, this.name});

  BankList.fromJson(Map<String, dynamic> json) {
    bankCode = json['bankCode'];
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['bankCode'] = bankCode;
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
