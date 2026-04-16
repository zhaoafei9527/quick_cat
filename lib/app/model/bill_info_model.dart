// 🌎 Project imports:
import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';

class BillDetailsInfo extends BaseNetModel {
  @override
  BillDetailsInfo fromJson(Map<String, dynamic> json) {
    return BillDetailsInfo.fromJson(json);
  }

  RechargeData? rechargeData;
  WithdrawData? withdrawData;
  WlGameData? wlGameData;

  BillDetailsInfo({this.rechargeData, this.withdrawData, this.wlGameData});

  BillDetailsInfo.fromJson(Map<String, dynamic> json) {
    rechargeData = json['rechargeData'] != null
        ? RechargeData?.fromJson(json['rechargeData'])
        : null;
    withdrawData = json['withdrawData'] != null
        ? WithdrawData?.fromJson(json['withdrawData'])
        : null;
    wlGameData = json['wlGameData'] != null
        ? WlGameData?.fromJson(json['wlGameData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (rechargeData != null) {
      data['rechargeData'] = rechargeData?.toJson();
    }
    if (withdrawData != null) {
      data['withdrawData'] = withdrawData?.toJson();
    }
    if (wlGameData != null) {
      data['wlGameData'] = wlGameData?.toJson();
    }
    return data;
  }
}

class RechargeData {
  int? amount;
  String? createdAt;
  String? finishedAt;
  int? id;
  int? realAmount;
  int? status;
  String? tradeNo;

  RechargeData(
      {this.amount,
      this.createdAt,
      this.finishedAt,
      this.id,
      this.realAmount,
      this.status,
      this.tradeNo});

  RechargeData.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    createdAt = json['createdAt'];
    finishedAt = json['finishedAt'];
    id = json['id'];
    realAmount = json['realAmount'];
    status = json['status'];
    tradeNo = json['tradeNo'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['amount'] = amount;
    data['createdAt'] = createdAt;
    data['finishedAt'] = finishedAt;
    data['id'] = id;
    data['realAmount'] = realAmount;
    data['status'] = status;
    data['tradeNo'] = tradeNo;
    return data;
  }
}

class WithdrawData {
  String? accountName;
  String? accountNo;
  int? amount;
  String? bankBranch;
  String? bankCode;
  String? bankName;
  String? createdAt;
  String? finishedAt;
  int? id;
  String? mode;
  int? orderType;
  String? phoneNo;
  int? realAmount;
  int? status;
  String? tradeNo;
  int? userId;
  String? userName;
  int? wtdrStatusType;
  String? checkMark;

  WithdrawData(
      {this.accountName,
      this.accountNo,
      this.amount,
      this.bankBranch,
      this.bankCode,
      this.bankName,
      this.createdAt,
      this.finishedAt,
      this.id,
      this.mode,
      this.orderType,
      this.phoneNo,
      this.realAmount,
      this.status,
      this.tradeNo,
      this.userId,
      this.userName,
      this.checkMark,
      this.wtdrStatusType});

  WithdrawData.fromJson(Map<String, dynamic> json) {
    accountName = json['accountName'];
    accountNo = json['accountNo'];
    amount = json['amount'];
    bankBranch = json['bankBranch'];
    bankCode = json['bankCode'];
    bankName = json['bankName'];
    createdAt = json['createdAt'];
    finishedAt = json['finishedAt'];
    id = json['id'];
    mode = json['mode'];
    orderType = json['orderType'];
    phoneNo = json['phoneNo'];
    realAmount = json['realAmount'];
    status = json['status'];
    tradeNo = json['tradeNo'];
    userId = json['userId'];
    userName = json['userName'];
    checkMark = json['checkMark'];
    wtdrStatusType = json['wtdrStatusType'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['accountName'] = accountName;
    data['accountNo'] = accountNo;
    data['amount'] = amount;
    data['bankBranch'] = bankBranch;
    data['bankCode'] = bankCode;
    data['bankName'] = bankName;
    data['createdAt'] = createdAt;
    data['finishedAt'] = finishedAt;
    data['id'] = id;
    data['mode'] = mode;
    data['orderType'] = orderType;
    data['phoneNo'] = phoneNo;
    data['realAmount'] = realAmount;
    data['status'] = status;
    data['tradeNo'] = tradeNo;
    data['userId'] = userId;
    data['userName'] = userName;
    data['checkMark'] = checkMark;
    data['wtdrStatusType'] = wtdrStatusType;
    return data;
  }
}

class WlGameData {
  int? category;
  String? createdAt;
  int? game;
  String? gameId;
  int? gameStartTime;
  int? id;
  double? profit;
  String? recordId;
  int? time;
  String? updatedAt;
  int? userId;
  double? validBet;

  WlGameData(
      {this.category,
      this.createdAt,
      this.game,
      this.gameId,
      this.gameStartTime,
      this.id,
      this.profit,
      this.recordId,
      this.time,
      this.updatedAt,
      this.userId,
      this.validBet});

  WlGameData.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    createdAt = json['createdAt'];
    game = json['game'];
    gameId = json['gameId'];
    gameStartTime = json['gameStartTime'];
    id = json['id'];
    profit = json['profit'];
    recordId = json['recordId'];
    time = json['time'];
    updatedAt = json['updatedAt'];
    userId = json['userId'];
    validBet = json['validBet'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['category'] = category;
    data['createdAt'] = createdAt;
    data['game'] = game;
    data['gameId'] = gameId;
    data['gameStartTime'] = gameStartTime;
    data['id'] = id;
    data['profit'] = profit;
    data['recordId'] = recordId;
    data['time'] = time;
    data['updatedAt'] = updatedAt;
    data['userId'] = userId;
    data['validBet'] = validBet;
    return data;
  }
}

// {
// "count": 0,
// "list": [
// {
// "game": 0,
// "gameName": "string",
// "gameTime": "string",
// "id": 0,
// "profit": 0,
// "recordId": "string",
// "time": 0,
// "validBet": "string"
// }
// ]
// }

class gameRecordsBean {
  int? game;
  String? gameName;
  String? gameTime;
  int? id;
  num? profit;
  String? recordId;
  int? time;
  String? validBet;

  gameRecordsBean(
      {this.game,
      this.gameName,
      this.gameTime,
      this.id,
      this.profit,
      this.recordId,
      this.time,
      this.validBet});

  gameRecordsBean.fromJson(Map<String, dynamic> json) {
    game = json['game'];
    gameName = json['gameName'];
    gameTime = json['gameTime'];
    id = json['id'];
    profit = json['profit'];
    recordId = json['recordId'];
    time = json['time'];
    validBet = json['validBet'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['game'] = game;
    data['gameName'] = gameName;
    data['gameTime'] = gameTime;
    data['id'] = id;
    data['profit'] = profit;
    data['recordId'] = recordId;
    data['time'] = time;
    data['validBet'] = validBet;
    return data;
  }
}

class gameRecordsList extends BaseNetModel {
  @override
  gameRecordsList fromJson(Map<String, dynamic> json) {
    return gameRecordsList.fromJson(json);
  }

  int? count;
  List<gameRecordsBean>? list;

  gameRecordsList({this.count, this.list});

  gameRecordsList.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['list'] != null) {
      list = <gameRecordsBean>[];
      json['list'].forEach((v) {
        list?.add(gameRecordsBean.fromJson(v));
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
