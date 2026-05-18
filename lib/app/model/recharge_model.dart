// 🌎 Project imports:
import 'package:quick_cat_client/app/routes/app_pages.dart';
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

class WithdrawTypeBean {
  String? name;
  String? icon;
  int? wtype;

  /// 客户端路由；未下发时统一走 [Routes.WITHDRAW_CASH_BANK]，由 query 参数区分渠道
  String? path;
  int? maxNum;
  int? minNum;

  WithdrawTypeBean({this.name, this.icon, this.wtype, this.path});

  WithdrawTypeBean.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    icon = json['icon']?.toString();
    maxNum = _readInt(json['maxNum']) ~/ 100;
    minNum = _readInt(json['minNum']) ~/ 100;
    final t = json['wtype'];
    if (t is int) {
      wtype = t;
    } else if (t != null) {
      wtype = int.tryParse(t.toString());
    }
    final String? fromServer = json['path']?.toString();
    if (fromServer != null && fromServer.isNotEmpty) {
      path = fromServer;
    } else {
      path = Routes.WITHDRAW_CASH_BANK;
    }
    path ??= json['jumpPath']?.toString();
    path ??= json['route']?.toString();
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class WithdrawTypeListModel extends BaseNetModel {
  @override
  WithdrawTypeListModel fromJson(Map<String, dynamic> json) {
    return WithdrawTypeListModel.fromJson(json);
  }

  List<WithdrawTypeBean>? list;

  WithdrawTypeListModel({this.list});

  WithdrawTypeListModel.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <WithdrawTypeBean>[];
      for (final v in (json['list'] as List)) {
        if (v is Map<String, dynamic>) {
          list?.add(WithdrawTypeBean.fromJson(v));
        }
      }
    }
  }
}
