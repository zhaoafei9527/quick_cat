// 🌎 Project imports:
import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';


class BillRecordDetailModel extends BaseNetModel {
  @override
  BillRecordDetailModel fromJson(Map<String, dynamic> json) {
    return BillRecordDetailModel.fromJson(json);
  }

  String? message;
  List<EnvelopeModel>? list;
  int? total; // 总条数
  int? pageNum; // 当前页码
  int? pageSize; // 每页条数

  BillRecordDetailModel({this.message, this.list, this.total, this.pageNum, this.pageSize});

  BillRecordDetailModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json["list"] != null) {
      list = <EnvelopeModel>[];
      json['list'].forEach((e) {
        list?.add(EnvelopeModel.fromJson(e));
      });
    }
    total = json['total'];
    pageNum = json['pageNum'];
    pageSize = json['pageSize'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['list'] = list?.map((e) => e.toJson()).toList();
    data['total'] = total;
    data['pageNum'] = pageNum;
    data['pageSize'] = pageSize;
    return data;
  }
}


/// 流水记录模型
class EnvelopeModel extends BaseNetModel {
  @override
  EnvelopeModel fromJson(Map<String, dynamic> json) {
    return EnvelopeModel.fromJson(json);
  }

  String? message;
  List<EnvelopeModel>? list;
  bool? isReceive; // 今天是否已经领取
  int? receiveType; // 0领取失败，1,当日已领取，2领取成功
  int? vipType; // vip 等级
  int? money; // 红包金额
  String? createdAt; // 创建时间
  String? desc; // 描述
  int? id; // 订单号
  String? title; // 时间名称

  EnvelopeModel(
      {this.message,
      this.title,
      this.isReceive,
      this.receiveType,
      this.vipType,
      this.money,
      this.list,
      this.createdAt,
      this.desc,
      this.id});

  EnvelopeModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];

    if (json["list"] != null) {
      list = <EnvelopeModel>[];
      json['list'].forEach((e) {
        list?.add(EnvelopeModel.fromJson(e));
      });
    }
    money = json['money'];
    message = json['message'];
    isReceive = json['isReceive'];
    receiveType = json['receiveType'];
    vipType = json['vipType'];
    createdAt = json['createdAt'];
    desc = json['desc'];
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['list'] = list?.map((e) => e.toJson()).toList();
    data['isReceive'] = isReceive;
    data['receiveType'] = receiveType;
    data['vipType'] = vipType;
    data['money'] = money;
    data['createdAt'] = createdAt;
    data['desc'] = desc;
    data['id'] = id;
    data['title'] = title;
    return data;
  }
}
