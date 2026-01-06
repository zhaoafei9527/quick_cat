// 🌎 Project imports:
import 'package:acgn_client/plugins_utils/HttpRequester/http_requester.dart';

class UserBalanceModel extends BaseNetModel {
  @override
  UserBalanceModel fromJson(Map<String, dynamic> json) {
    return UserBalanceModel.fromJson(json);
  }

  int? code;
  String? msg;

  UserBalanceInfo? data;

  UserBalanceModel({
    this.code,
    this.msg,
    this.data,
  });

  UserBalanceModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    data =
        json['data'] != null ? UserBalanceInfo?.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final dataJson = <String, dynamic>{};
    dataJson['msg'] = msg;
    if (data != null) {
      dataJson['data'] = data?.toJson();
    }
    return dataJson;
  }
}

class UserBalanceInfo {
  String? balance;
  int? status;
  String? transferable;

  UserBalanceInfo({this.status, this.balance, this.transferable});

  UserBalanceInfo.fromJson(Map<String, dynamic> json) {
    balance = json['balance'];
    status = json['status'];
    transferable = json['transferable'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['balance'] = balance;

    data['transferable'] = transferable;
    return data;
  }
}
