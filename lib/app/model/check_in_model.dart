// 🌎 Project imports:

import '../../plugins_utils/HttpRequester/src/base_net_model.dart';

/// 签到模型
class CheckInModel extends BaseNetModel {
  @override
  CheckInModel fromJson(Map<String, dynamic> json) {
    return CheckInModel.fromJson(json);
  }

  String? message;
  CheckInInfoModel? checkin;
  List<CheckInInfoModel>? checkInfo;
  bool? todayChecked; // 今天是否已经签到
  int? continuouslyDays; // 连续签到天数
  bool? lotteryTickets;
  bool? movieTickets;
  bool? isMoney;
  bool? isMondayRewards;
  int? money;

  bool? isYesCheckin;
  bool? isTodayCheckin;

  CheckInModel(
      {this.message,
        this.checkin,
        this.checkInfo,
        this.movieTickets,
        this.lotteryTickets,
        this.continuouslyDays,
        this.isYesCheckin,
        this.isMoney,
        this.money,
        this.isMondayRewards,
        this.isTodayCheckin,
        this.todayChecked});

  CheckInModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json["checkin"] != null) {
      checkin = CheckInInfoModel.fromJson(json["checkin"]);
    }
    if (json["checkinInfo"] != null) {
      checkInfo = <CheckInInfoModel>[];
      json['checkinInfo'].forEach((e) {
        checkInfo?.add(CheckInInfoModel.fromJson(e));
      });
    }
    message = json['message'];
    isMoney = json['isMoney'];
    isMondayRewards = json['isMondayRewards'];
    money = json['money'];
    todayChecked = json['todayChecked'];
    isYesCheckin = json['isYesCheckin'];
    isTodayCheckin = json['isTodayCheckin'];
    continuouslyDays = json['continuouslyDays'];
    lotteryTickets = json['lotteryTickets'];
    movieTickets = json['movieTickets'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['checkin'] = checkin?.toJson();
    data['checkInfo'] = checkInfo?.map((e) => e.toJson()).toList();
    data['todayChecked'] = todayChecked;
    data['isMoney'] = isMoney;
    data['money'] = money;
    data['isYesCheckin'] = isYesCheckin;
    data['isTodayCheckin'] = isTodayCheckin;
    data['continuouslyDays'] = continuouslyDays;
    data['lotteryTickets'] = lotteryTickets;
    data['movieTickets'] = movieTickets;
    return data;
  }
}

class CheckInInfoModel {
  String? date;
  bool? isCheckin;
  int? weekday;
  bool? lotteryTickets;
  bool? movieTickets;
  int? continuouslyDays; // 连续签到天数
  int? cumulativeDays; // 本周连续签到天数
  bool? todayChecked; // 今天是否已经签到

  CheckInInfoModel({
    this.date,
    this.isCheckin,
    this.weekday,
    this.continuouslyDays,
    this.cumulativeDays,
    this.lotteryTickets,
    this.movieTickets,
  });

  CheckInInfoModel.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    isCheckin = json['isCheckin'];
    weekday = json['weekday'];
    lotteryTickets = json['lotteryTickets'];
    movieTickets = json['movieTickets'];
    continuouslyDays = json["continuouslyDays"];
    cumulativeDays = json["cumulativeDays"];
    todayChecked = json["todayChecked"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['lotteryTickets'] = lotteryTickets;
    data['movieTickets'] = movieTickets;
    data['continuouslyDays'] = date;
    data['cumulativeDays'] = lotteryTickets;
    data['todayChecked'] = movieTickets;

    return data;
  }
}
