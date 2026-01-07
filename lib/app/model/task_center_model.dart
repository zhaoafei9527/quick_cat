// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';

class WelfareTaskCenter extends BaseNetModel {
  @override
  WelfareTaskCenter fromJson(Map<String, dynamic> json) {
    return WelfareTaskCenter.fromJson(json);
  }

  int? checkedDays;
  int? countPoints;
  bool? todayChecked;
  int? todayPoints;
  int? totalCheckin;
  List<CheckInRuleInfo>? todaySetup;
  List<PrizeInfoList>? prizeList;
  List<TaskInfoList>? taskList;

  WelfareTaskCenter(
      {this.totalCheckin,
      this.checkedDays,
      this.todayChecked,
      this.todayPoints,
      this.countPoints,
      this.prizeList,
      this.taskList,
      this.todaySetup});

  WelfareTaskCenter.fromJson(Map<String, dynamic> json) {
    checkedDays = json['checkedDays'];
    countPoints = json['countPoints'];
    todayChecked = json['todayChecked'];
    todayPoints = json['todayPoints'];
    totalCheckin = json['totalCheckin'];

    if (json['prizeList'] != null) {
      prizeList = <PrizeInfoList>[];
      json['prizeList'].forEach((v) {
        prizeList?.add(PrizeInfoList.fromJson(v));
      });
    }
    if (json['taskList'] != null) {
      taskList = <TaskInfoList>[];
      json['taskList'].forEach((v) {
        taskList?.add(TaskInfoList.fromJson(v));
      });
    }
    if (json['todaySetup'] != null) {
      todaySetup = <CheckInRuleInfo>[];
      json['todaySetup'].forEach((v) {
        todaySetup?.add(CheckInRuleInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (prizeList != null) {
      data['prizeList'] = prizeList?.map((v) => v.toJson()).toList();
    }
    if (taskList != null) {
      data['taskList'] = taskList?.map((v) => v.toJson()).toList();
    }
    if (todaySetup != null) {
      data['todaySetup'] = todaySetup?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CheckInRuleInfo {
  int? awardPointNum;
  int? day_num;
  bool? isHave;
  int? pointsNum;

  CheckInRuleInfo(
      {this.pointsNum, this.awardPointNum, this.day_num, this.isHave});

  CheckInRuleInfo.fromJson(Map<String, dynamic> json) {
    pointsNum = json['pointsNum'];
    awardPointNum = json['awardPointNum'];
    day_num = json['day_num'];
    isHave = json['isHave'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['pointsNum'] = pointsNum;
    data['awardPointNum'] = awardPointNum;
    data['day_num'] = day_num;
    data['isHave'] = isHave;

    return data;
  }
}

class PrizeInfoList {
  int? id;
  String? image;
  String? name;
  int? pointsNum;
  int? prizeType;
  int? prizesNum;
  int? rank;
  String? remark;
  int? vipType;

  PrizeInfoList(
      {this.id,
      this.image,
      this.name,
      this.vipType,
      this.remark,
      this.pointsNum,
      this.prizesNum,
      this.prizeType,
      this.rank});

  PrizeInfoList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'];
    vipType = json['vipType'];
    pointsNum = json['pointsNum'];
    prizeType = json['prizeType'];
    prizesNum = json['prizesNum'];
    remark = json['remark'];
    rank = json['rank'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['name'] = name;
    data['vipType'] = vipType;
    data['pointsNum'] = pointsNum;
    data['prizesNum'] = prizeType;
    data['prizesNum'] = prizesNum;
    data['remark'] = remark;
    data['rank'] = rank;
    return data;
  }
}

class TaskInfoList {
  int? currParam;
  String? desc;
  String? goTo;
  int? id;
  int? param;
  int? rewardPoint;
  int? status;
  int? taskType;
  String? title;

  TaskInfoList(
      {this.rewardPoint,
      this.currParam,
      this.desc,
      this.goTo,
      this.id,
      this.param,
      this.status,
      this.taskType,
      this.title});

  TaskInfoList.fromJson(Map<String, dynamic> json) {
    rewardPoint = json['rewardPoint'];
    currParam = json['currParam'];
    desc = json['desc'];
    goTo = json['goTo'];
    id = json['id'];
    param = json['param'];
    status = json['status'];
    taskType = json['taskType'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['rewardPoint'] = rewardPoint;
    data['currParam'] = currParam;
    data['desc'] = desc;
    data['goTo'] = goTo;
    data['id'] = id;
    data['param'] = param;
    data['status'] = status;
    data['taskType'] = taskType;
    data['title'] = title;
    return data;
  }
}

class InvitedListModel extends BaseNetModel {
  @override
  InvitedListModel fromJson(Map<String, dynamic> json) {
    return InvitedListModel.fromJson(json);
  }

  List<InvitedModel>? list;
  int? shareGiftTotal; // 今天是否已经领取

  InvitedListModel({this.shareGiftTotal, this.list});

  InvitedListModel.fromJson(Map<String, dynamic> json) {
    shareGiftTotal = json['shareGiftTotal'];
    if (json['list'] != null) {
      list = <InvitedModel>[];
      json['list'].forEach((v) {
        list?.add(InvitedModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shareGiftTotal'] = shareGiftTotal;
    if (list != null) {
      data['list'] = list?.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class InvitedModel extends BaseNetModel {
  @override
  InvitedModel fromJson(Map<String, dynamic> json) {
    return InvitedModel.fromJson(json);
  }

  int? id;
  String? title;
  int? num;
  int? vipDays;
  String? remark;
  InviteReceiveStatus? receiveStatus;

  InvitedModel(
      {this.id,
      this.title,
      this.num,
      this.vipDays,
      this.remark,
      this.receiveStatus});

  InvitedModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    id = json['id'];
    num = json['num'];
    vipDays = json['vipDays'];
    remark = json['remark'];
    receiveStatus = InviteReceiveStatus.values.firstWhere(
        (e) => e.index == (json['receiveStatus'] ?? 0),
        orElse: () => InviteReceiveStatus.notInvite);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['id'] = id;
    data['num'] = num;
    data['vipDays'] = vipDays;
    data['remark'] = remark;
    data['receiveStatus'] = receiveStatus?.index;
    return data;
  }
}
