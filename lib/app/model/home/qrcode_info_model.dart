// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class QrcodeInfo extends BaseNetModel {
  @override
  QrcodeInfo fromJson(Map<String, dynamic> json) {
    return QrcodeInfo.fromJson(json);
  }

  String? actressBackgroud;
  int? age;
  String? avatarUrl;
  int? balance;
  int? cardId;
  String? cardName;
  int? careCount;
  String? country;
  String? dicCodePromSeqe;
  String? districtCode;
  int? fakeFanCount;
  int? fanClubCount;
  int? fanCount;
  int? gender;
  int? id;
  int? income;
  String? introduction;
  String? inviteCode;
  String? inviteUrl;
  int? invites;
  int? lastLoginAt;
  int? leftDownloadTimes;
  int? leftWatchTimes;
  int? level;
  int? like;
  int? loginType;
  String? mobile;
  int? movieTickets;
  bool? newMsg;
  String? nickName;
  int? realFanCount;
  int? recharge;
  String? region;
  List<Rights>? rights;
  String? token;
  int? totalDownloadTimes;
  int? totalWatchTimes;
  String? userBackgroud;
  int? userType;
  int? vipExpire;
  String? vipExpireTime;
  String? vipImage;
  int? vipType;
  int? vipVer;
  bool? weekVipCountDown;
  String? weekVipExpireAt;

  QrcodeInfo(
      {this.actressBackgroud,
      this.age,
      this.avatarUrl,
      this.balance,
      this.cardId,
      this.cardName,
      this.careCount,
      this.country,
      this.dicCodePromSeqe,
      this.districtCode,
      this.fakeFanCount,
      this.fanClubCount,
      this.fanCount,
      this.gender,
      this.id,
      this.income,
      this.introduction,
      this.inviteCode,
      this.inviteUrl,
      this.invites,
      this.lastLoginAt,
      this.leftDownloadTimes,
      this.leftWatchTimes,
      this.level,
      this.like,
      this.loginType,
      this.mobile,
      this.movieTickets,
      this.newMsg,
      this.nickName,
      this.realFanCount,
      this.recharge,
      this.region,
      this.rights,
      this.token,
      this.totalDownloadTimes,
      this.totalWatchTimes,
      this.userBackgroud,
      this.userType,
      this.vipExpire,
      this.vipExpireTime,
      this.vipImage,
      this.vipType,
      this.vipVer,
      this.weekVipCountDown,
      this.weekVipExpireAt});

  QrcodeInfo.fromJson(Map<String, dynamic> json) {
    actressBackgroud = json['actressBackgroud'];
    age = json['age'];
    avatarUrl = json['avatarUrl'];
    balance = json['balance'];
    cardId = json['cardId'];
    cardName = json['cardName'];
    careCount = json['careCount'];
    country = json['country'];
    dicCodePromSeqe = json['dicCodePromSeqe'];
    districtCode = json['districtCode'];
    fakeFanCount = json['fakeFanCount'];
    fanClubCount = json['fanClubCount'];
    fanCount = json['fanCount'];
    gender = json['gender'];
    id = json['id'];
    income = json['income'];
    introduction = json['introduction'];
    inviteCode = json['inviteCode'];
    inviteUrl = json['inviteUrl'];
    invites = json['invites'];
    lastLoginAt = json['lastLoginAt'];
    leftDownloadTimes = json['leftDownloadTimes'];
    leftWatchTimes = json['leftWatchTimes'];
    level = json['level'];
    like = json['like'];
    loginType = json['loginType'];
    mobile = json['mobile'];
    movieTickets = json['movieTickets'];
    newMsg = json['newMsg'];
    nickName = json['nickName'];
    realFanCount = json['realFanCount'];
    recharge = json['recharge'];
    region = json['region'];
    if (json['rights'] != null) {
      rights = <Rights>[];
      json['rights'].forEach((v) {
        rights?.add(Rights.fromJson(v));
      });
    }
    token = json['token'];
    totalDownloadTimes = json['totalDownloadTimes'];
    totalWatchTimes = json['totalWatchTimes'];
    userBackgroud = json['userBackgroud'];
    userType = json['userType'];
    vipExpire = json['vipExpire'];
    vipExpireTime = json['vipExpireTime'];
    vipImage = json['vipImage'];
    vipType = json['vipType'];
    vipVer = json['vipVer'];
    weekVipCountDown = json['weekVipCountDown'];
    weekVipExpireAt = json['weekVipExpireAt'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['actressBackgroud'] = actressBackgroud;
    data['age'] = age;
    data['avatarUrl'] = avatarUrl;
    data['balance'] = balance;
    data['cardId'] = cardId;
    data['cardName'] = cardName;
    data['careCount'] = careCount;
    data['country'] = country;
    data['dicCodePromSeqe'] = dicCodePromSeqe;
    data['districtCode'] = districtCode;
    data['fakeFanCount'] = fakeFanCount;
    data['fanClubCount'] = fanClubCount;
    data['fanCount'] = fanCount;
    data['gender'] = gender;
    data['id'] = id;
    data['income'] = income;
    data['introduction'] = introduction;
    data['inviteCode'] = inviteCode;
    data['inviteUrl'] = inviteUrl;
    data['invites'] = invites;
    data['lastLoginAt'] = lastLoginAt;
    data['leftDownloadTimes'] = leftDownloadTimes;
    data['leftWatchTimes'] = leftWatchTimes;
    data['level'] = level;
    data['like'] = like;
    data['loginType'] = loginType;
    data['mobile'] = mobile;
    data['movieTickets'] = movieTickets;
    data['newMsg'] = newMsg;
    data['nickName'] = nickName;
    data['realFanCount'] = realFanCount;
    data['recharge'] = recharge;
    data['region'] = region;
    if (rights != null) {
      data['rights'] = rights?.map((v) => v.toJson()).toList();
    }
    data['token'] = token;
    data['totalDownloadTimes'] = totalDownloadTimes;
    data['totalWatchTimes'] = totalWatchTimes;
    data['userBackgroud'] = userBackgroud;
    data['userType'] = userType;
    data['vipExpire'] = vipExpire;
    data['vipExpireTime'] = vipExpireTime;
    data['vipImage'] = vipImage;
    data['vipType'] = vipType;
    data['vipVer'] = vipVer;
    data['weekVipCountDown'] = weekVipCountDown;
    data['weekVipExpireAt'] = weekVipExpireAt;
    return data;
  }
}

class InvitedList extends BaseNetModel {
  @override
  InvitedList fromJson(Map<String, dynamic> json) {
    return InvitedList.fromJson(json);
  }

  List<InvitedInfo>? list;
  int? total;

  InvitedList({this.list, this.total});

  InvitedList.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    if (json['list'] != null) {
      list = <InvitedInfo>[];
      json['list'].forEach((v) {
        list?.add(InvitedInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class InvitedInfo {
  String? avatar;
  String? name;
  bool? userId;
  String? createAt;
  int? type;

  InvitedInfo({this.avatar, this.userId, this.createAt, this.name, this.type});

  InvitedInfo.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    userId = json['userId'];
    createAt = json['createAt'];
    name = json['name'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['userId'] = userId;
    data['createAt'] = createAt;
    data['name'] = name;
    data['type'] = type;
    return data;
  }
}

class Rights {
  String? desc;
  String? image;
  bool? isOpen;
  String? name;
  int? type;

  Rights({this.desc, this.image, this.isOpen, this.name, this.type});

  Rights.fromJson(Map<String, dynamic> json) {
    desc = json['desc'];
    image = json['image'];
    isOpen = json['isOpen'];
    name = json['name'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['desc'] = desc;
    data['image'] = image;
    data['isOpen'] = isOpen;
    data['name'] = name;
    data['type'] = type;
    return data;
  }
}
