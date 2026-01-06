// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class BanksList extends BaseNetModel {
  @override
  BanksList fromJson(Map<String, dynamic> json) {
    return BanksList.fromJson(json);
  }

  int? count;
  List<ListData>? listData;

  BanksList({this.count, this.listData});

  BanksList.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['list'] != null) {
      listData = <ListData>[];
      json['list'].forEach((v) {
        listData?.add(ListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['count'] = count;
    if (listData != null) {
      data['listData'] = listData?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListData {
  String? bankCode;
  int? id;
  String? name;
  String? img;

  ListData({this.bankCode, this.id, this.name, this.img});

  ListData.fromJson(Map<String, dynamic> json) {
    bankCode = json['bankCode'];
    id = json['id'];
    name = json['name'];
    img = json['img'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['bankCode'] = bankCode;
    data['id'] = id;
    data['name'] = name;
    data['img'] = img;
    return data;
  }
}
