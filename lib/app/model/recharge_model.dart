// 🌎 Project imports:
import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';

class RechargeModel extends BaseNetModel {
  @override
  RechargeModel fromJson(Map<String, dynamic> json) {
    return RechargeModel.fromJson(json);
  }

  List<RechargeInfo>? list = [];

  List<RedeemInfo>? redeemList = [];

  RechargeModel({this.list, this.redeemList});

  RechargeModel.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <RechargeInfo>[];
      redeemList = <RedeemInfo>[];
      json['list'].forEach((v) {
        list?.add(RechargeInfo.fromJson(v));
        redeemList?.add(RedeemInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list?.map((v) => v.toJson()).toList();
      data['redeemList'] = redeemList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RechargeInfo {
  int? amount; // 提现金额
  int? coinAmount; // 充值金额
  int? currencyType;
  int? id; // 提现ID
  int? status; // 提现状态
  String? tradeNo; // 提现订单号
  String? desc;
  String? orderNo; // 充值订单号
  String? createdAt; // 创建时间
  String? payMode;

  RechargeInfo(
      {this.amount,
      this.coinAmount,
      this.currencyType,
      this.id,
      this.status,
      this.tradeNo,
      this.desc,
      this.orderNo,
      this.createdAt,
      this.payMode});

  RechargeInfo.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    coinAmount = json['coinAmount'];
    currencyType = json['currencyType'];
    id = json['id'];
    status = json['status'];
    tradeNo = json['tradeNo'];
    desc = json['desc'];
    orderNo = json['orderNo'];
    createdAt = json['createdAt'];
    payMode = json['payMode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['coinAmount'] = coinAmount;
    data['currencyType'] = currencyType;
    data['id'] = id;
    data['status'] = status;
    data['tradeNo'] = tradeNo;
    data['desc'] = desc;
    data['createdAt'] = createdAt;
    data['orderNo'] = orderNo;
    data['payMode'] = payMode;
    return data;
  }
}

class RedeemInfo {
  int? id; // 提现ID
  int? prizeId; // 兑换ID
  int? usePoint; // 充值金额
  int? userId; // 用户
  String? prizeName; // 兑换名称
  String? remark;
  String? desc;
  String? code;
  String? activedAt;
  String? createdAt; // 创建时间
  String? updatedAt; // 创建时间
  String? payMode;

  RedeemInfo(
      {this.prizeId,
      this.usePoint,
      this.userId,
      this.id,
      this.code,
      this.activedAt,
      this.desc,
      this.prizeName,
      this.remark,
      this.updatedAt,
      this.createdAt,
      this.payMode});

  RedeemInfo.fromJson(Map<String, dynamic> json) {
    prizeId = json['prizeId'];
    usePoint = json['usePoint'];
    userId = json['userId'];
    id = json['id'];
    code = json['code'];
    activedAt = json['activedAt'];
    desc = json['desc'];
    prizeName = json['prizeName'];
    remark = json['remark'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
    payMode = json['payMode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['activedAt'] = activedAt;
    data['desc'] = desc;
    data['prizeId'] = prizeId;
    data['usePoint'] = usePoint;
    data['userId'] = userId;
    data['id'] = id;
    data['prizeName'] = prizeName;
    data['remark'] = remark;
    data['updatedAt'] = updatedAt;
    data['createdAt'] = createdAt;
    data['payMode'] = payMode;
    return data;
  }
}
