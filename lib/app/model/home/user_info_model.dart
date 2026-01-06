// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class UserInfo extends BaseNetModel {
  @override
  UserInfo fromJson(Map<String, dynamic> json) {
    return UserInfo.fromJson(json);
  }

  int? id;
  int? cardType;
  int? userType;
  int? balance; // 金币余额
  int? recharge;
  int? income;
  String? region;
  String? userBackgroud;
  String? actressBackgroud;
  String? avatarUrl;
  String? nickName;
  String? introduction;
  int? lastLoginAt;
  int? vipExpire;
  String? vipExpireTime;
  String? createdAt;
  int? vipType;
  String? cardName;
  String? mobile;
  String? email;
  String? country;
  int? age;
  int? gender;
  int? invites;
  String? inviteCode;
  String? dicCodePromSeqe;
  String? inviteUrl;
  int? leftWatchTimes;
  int? totalWatchTimes;
  int? movieTickets;
  int? useMovieTickets;
  int? lotteryFreeCount;
  int? lotteryUsedCount;
  String? token;
  int? loginType;
  String? districtCode;
  int? leftDownloadTimes;
  int? totalDownloadTimes;
  bool? newMsg;
  List<UserInterestsInfo>? rights;
  String? vipImage;
  String? avatarFrame;
  int? cardAllNum;
  int? cardTopicNum;
  String? logo;
  int? careCount;
  int? fans;
  int? downLoadTotal;
  String? promotionExpiredAt;
  int? giftGold;
  int? vipExpireDay;
  bool? isVip;
  bool? haveFreeTickets;
  String? newUserDesc;
  bool? isNewUser;
  int? growthValue; // 成长值
  bool? isActiveMember; // 会员是否活跃
  int? currentWatchNum; // 剩余观看次数

  UserInfo(
      {this.id,
      this.cardType,
      this.userType,
      this.balance,
      this.recharge,
      this.income,
      this.region,
      this.email,
      this.userBackgroud,
      this.actressBackgroud,
      this.avatarUrl,
      this.nickName,
      this.introduction,
      this.lastLoginAt,
      this.vipExpire,
      this.vipExpireTime,
      this.vipType,
      this.cardName,
      this.mobile,
      this.country,
      this.age,
      this.gender,
      this.invites,
      this.inviteCode,
      this.dicCodePromSeqe,
      this.inviteUrl,
      this.leftWatchTimes,
      this.totalWatchTimes,
      this.movieTickets,
      this.useMovieTickets,
      this.lotteryFreeCount,
      this.lotteryUsedCount,
      this.token,
      this.loginType,
      this.districtCode,
      this.leftDownloadTimes,
      this.totalDownloadTimes,
      this.newMsg,
      this.rights,
      this.vipImage,
      this.avatarFrame,
      this.cardAllNum,
      this.cardTopicNum,
      this.logo,
      this.careCount,
      this.fans,
      this.downLoadTotal,
      this.promotionExpiredAt,
      this.haveFreeTickets,
      this.isVip,
      this.growthValue,
      this.isActiveMember,
      this.giftGold,
      this.createdAt,
      this.newUserDesc,
      this.currentWatchNum,
      this.isNewUser,
      this.vipExpireDay});

  UserInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cardType = json['cardType'];
    userType = json['userType'];
    balance = json['balance'];
    recharge = json['recharge'];
    income = json['income'];
    region = json['region'];
    userBackgroud = json['userBackgroud'];
    actressBackgroud = json['actressBackgroud'];
    avatarUrl = json['avatarUrl'];
    nickName = json['nickName'];
    introduction = json['introduction'];
    lastLoginAt = json['lastLoginAt'];
    vipExpire = json['vipExpire'];
    vipExpireTime = json['vipExpireTime'];
    createdAt = json['createdAt'];
    vipType = json['vipType'];
    cardName = json['cardName'];
    mobile = json['mobile'];
    email = json['email'];
    country = json['country'];
    age = json['age'];
    gender = json['gender'];
    invites = json['invites'];
    inviteCode = json['inviteCode'];
    dicCodePromSeqe = json['dicCodePromSeqe'];
    inviteUrl = json['inviteUrl'];
    leftWatchTimes = json['leftWatchTimes'];
    totalWatchTimes = json['totalWatchTimes'];
    movieTickets = json['movieTickets'];
    haveFreeTickets = (json['movieTickets'] ?? 0) > 0;
    useMovieTickets = json['useMovieTickets'];
    lotteryFreeCount = json['lotteryFreeCount'];
    lotteryUsedCount = json['lotteryUsedCount'];
    currentWatchNum = json['currentWatchNum'];
    token = json['token'];
    loginType = json['loginType'];
    districtCode = json['districtCode'];
    newMsg = json['newMsg'];
    if (json['rights'] != null) {
      rights = <UserInterestsInfo>[];
      json['rights'].forEach((v) {
        rights?.add(UserInterestsInfo.fromJson(v));
      });
    }
    vipImage = json['vipImage'];
    avatarFrame = json['avatarFrame'];
    cardAllNum = json['cardAllNum'];
    cardTopicNum = json['cardTopicNum'];
    logo = json['logo'];
    careCount = json['careCount'];
    fans = json['fans'];
    downLoadTotal = json['downLoadTotal'];
    promotionExpiredAt = json['promotionExpiredAt'];
    giftGold = json['giftGold'];
    vipExpireDay = json['vipExpireDay'];
    growthValue = json['growthValue'];
    isActiveMember = json['isActiveMember'];
    isVip = json['isVip'];
    isNewUser = json['isNewUser'];
    newUserDesc = json['newUserDesc'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['cardType'] = cardType;
    data['userType'] = userType;
    data['balance'] = balance;
    data['recharge'] = recharge;
    data['income'] = income;
    data['region'] = region;
    data['growthValue'] = growthValue;
    data['isActiveMember'] = isActiveMember;
    data['userBackgroud'] = userBackgroud;
    data['actressBackgroud'] = actressBackgroud;
    data['avatarUrl'] = avatarUrl;
    data['nickName'] = nickName;
    data['introduction'] = introduction;
    data['lastLoginAt'] = lastLoginAt;
    data['vipExpire'] = vipExpire;
    data['vipExpireTime'] = vipExpireTime;
    data['createdAt'] = createdAt;
    data['vipType'] = vipType;
    data['cardName'] = cardName;
    data['mobile'] = mobile;
    data['email'] = email;
    data['country'] = country;
    data['age'] = age;
    data['gender'] = gender;
    data['invites'] = invites;
    data['inviteCode'] = inviteCode;
    data['dicCodePromSeqe'] = dicCodePromSeqe;
    data['inviteUrl'] = inviteUrl;
    data['leftWatchTimes'] = leftWatchTimes;
    data['totalWatchTimes'] = totalWatchTimes;
    data['movieTickets'] = movieTickets;
    data['useMovieTickets'] = useMovieTickets;
    data['lotteryFreeCount'] = lotteryFreeCount;
    data['lotteryUsedCount'] = lotteryUsedCount;
    data['token'] = token;
    data['loginType'] = loginType;
    data['districtCode'] = districtCode;
    data['leftDownloadTimes'] = leftDownloadTimes;
    data['totalDownloadTimes'] = totalDownloadTimes;
    data['newMsg'] = newMsg;
    if (rights != null) {
      data['rights'] = rights?.map((v) => v.toJson()).toList();
    }
    data['vipImage'] = vipImage;
    data['avatarFrame'] = avatarFrame;
    data['cardAllNum'] = cardAllNum;
    data['cardTopicNum'] = cardTopicNum;
    data['logo'] = logo;
    data['careCount'] = careCount;
    data['fans'] = fans;
    data['downLoadTotal'] = downLoadTotal;
    data['promotionExpiredAt'] = promotionExpiredAt;
    data['giftGold'] = giftGold;
    data['vipExpireDay'] = vipExpireDay;
    data['newUserDesc'] = newUserDesc;
    return data;
  }
}

/// 用户VIP权益列表信息
class UserInterestsInfo {
  String? desc;
  String? homeName;
  int? type;
  bool? isHome;
  bool? isLight;
  bool? isOpen;
  String? image;
  String? name;

  UserInterestsInfo(
      {this.desc,
      this.homeName,
      this.type,
      this.isHome,
      this.isLight,
      this.isOpen,
      this.image,
      this.name});

  UserInterestsInfo.fromJson(Map<String, dynamic> json) {
    desc = json['desc'];
    homeName = json['homeName'];
    type = json['type'];
    isHome = json['isHome'];
    isLight = json['isLight'];
    isOpen = json['isOpen'];
    image = json['image'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['desc'] = desc;
    data['homeName'] = homeName;
    data['type'] = type;
    data['isHome'] = isHome;
    data['isLight'] = isLight;
    data['isOpen'] = isOpen;
    data['image'] = image;
    data['name'] = name;
    return data;
  }
}

class UserAvatarList extends BaseNetModel {
  @override
  UserAvatarList fromJson(Map<String, dynamic> json) {
    return UserAvatarList.fromJson(json);
  }

  List<AvatarInfo>? list;

  UserAvatarList({this.list});

  UserAvatarList.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <AvatarInfo>[];
      json['list'].forEach((v) {
        list?.add(AvatarInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (list != null) {
      data['topicList'] = list?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AvatarInfo extends BaseNetModel {
  @override
  AvatarInfo fromJson(Map<String, dynamic> json) {
    return AvatarInfo.fromJson(json);
  }

  int? id;
  bool? isVip;
  String? avatar;
  String? avatarType;

  AvatarInfo({this.id, this.avatar, this.isVip, this.avatarType});

  AvatarInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    isVip = json['isVip'];
    avatar = json['avatar'];
    avatarType = json['avatarType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['isVip'] = isVip;
    data['avatar'] = avatar;
    data['avatarType'] = avatarType;
    return data;
  }
}
