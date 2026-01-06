// 🌎 Project imports:
import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';

class VipCardList extends BaseNetModel {
  @override
  VipCardList fromJson(Map<String, dynamic> json) {
    return VipCardList.fromJson(json);
  }

  List<CardInfoList>? cardInfoList;
  UserInfoVip? userInfo;
  List<RightDataList>? rightDataList;

  VipCardList({this.cardInfoList, this.userInfo, this.rightDataList});

  VipCardList.fromJson(Map<String, dynamic> json) {
    if (json['cardInfoList'] != null) {
      cardInfoList = <CardInfoList>[];
      json['cardInfoList'].forEach((v) {
        cardInfoList!.add(CardInfoList.fromJson(v));
      });
    }
    if (json['rightDataList'] != null) {
      rightDataList = <RightDataList>[];
      json['rightDataList'].forEach((v) {
        rightDataList?.add(RightDataList.fromJson(v));
      });
    }
    // userInfo = json['userInfo'] != null
    //     ? UserInfoVip.fromJson(json['userInfo'])
    //     : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (cardInfoList != null) {
      data['cardInfoList'] = cardInfoList!.map((v) => v.toJson()).toList();
    }
    if (userInfo != null) {
      data['userInfo'] = userInfo!.toJson();
    }
    return data;
  }
}

class RightDataList {
  bool? isLight;
  String? createdAt;
  String? desc;
  int? id;
  String? image;
  String? name;
  int? rank;
  int? status;
  String? updatedAt;
  String? homeName;


  RightDataList(
      {this.createdAt,
        this.isLight,
        this.desc,
        this.id,
        this.image,
        this.name,
        this.rank,
        this.status,
        this.homeName,
        this.updatedAt});

  RightDataList.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    isLight = json['isLight'];
    desc = json['desc'];
    id = json['id'];
    image = json['image'];
    name = json['name'];
    rank = json['rank'];
    homeName = json['homeName'];
    status = json['status'];
    updatedAt = json['updatedAt'];
  }


  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['isLight'] = isLight;
    data['createdAt'] = createdAt;
    data['desc'] = desc;
    data['id'] = id;
    data['image'] = image;
    data['name'] = name;
    data['rank'] = rank;
    data['status'] = status;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class CardInfoList {
  String? avatarFrame;
  Banner? banner;
  bool? canUseCoin;
  String? cardRemark;
  int? dayCount;
  String? dayMoney;
  String? desc;
  int? downLoadCount;
  int? giftCoin;
  List<int>? giftbagIds;
  List<GiftbagList>? giftbagList;
  int? id;
  String? image;
  bool? isBuy;
  int? money;
  int? movieRate;
  int? movieTicket;
  String? name;
  String? newUserGift;
  int? preMoney;
  List<RchgType>? rchgType;
  String? rewardsCountdown;
  List<Privilege>? rights;
  String? rigtTitle;
  int? sort;
  int? status;
  String? title;
  String? updatedAt;
  int? vipType;
  String? wordColor;
  String? remark;
  String? eventEndTime;
  int? eventDays;
  int? eventType;

  CardInfoList(
      {this.avatarFrame,
      this.banner,
      this.canUseCoin,
      this.cardRemark,
      this.dayCount,
      this.dayMoney,
      this.desc,
      this.downLoadCount,
      this.giftCoin,
      this.giftbagIds,
      this.giftbagList,
      this.id,
      this.image,
      this.isBuy,
      this.money,
      this.movieRate,
      this.movieTicket,
      this.name,
      this.newUserGift,
      this.preMoney,
      this.rchgType,
      this.rewardsCountdown,
      this.rights,
      this.rigtTitle,
      this.sort,
      this.status,
      this.title,
      this.updatedAt,
      this.vipType,
      this.remark,
        this.eventDays,
        this.eventType,
      this.eventEndTime,
      this.wordColor});

  CardInfoList.fromJson(Map<String, dynamic> json) {
    avatarFrame = json['avatarFrame'];
    banner = json['banner'] != null ? Banner.fromJson(json['banner']) : null;
    canUseCoin = json['canUseCoin'];
    cardRemark = json['cardRemark'];
    dayCount = json['dayCount'];
    dayMoney = json['dayMoney'];
    desc = json['desc'];
    downLoadCount = json['downLoadCount'];
    giftCoin = json['giftCoin'];
    remark = json['remark'];
    giftbagIds = json['giftbagIds'];
    if (json['giftbagList'] != null) {
      giftbagList = <GiftbagList>[];
      json['giftbagList'].forEach((v) {
        giftbagList!.add(GiftbagList.fromJson(v));
      });
    }
    id = json['id'];
    image = json['image'];
    isBuy = json['isBuy'];
    money = json['money'];
    movieRate = json['movieRate'];
    movieTicket = json['movieTicket'];
    name = json['name'];
    newUserGift = json['newUserGift'];
    preMoney = json['preMoney'];
    eventDays = json['eventDays'];
    eventType = json['eventType'];
    if (json['rchgType'] != null) {
      rchgType = <RchgType>[];
      json['rchgType'].forEach((v) {
        rchgType!.add(RchgType.fromJson(v));
      });
    }
    rewardsCountdown = json['rewardsCountdown'];
    if (json['rights'] != null) {
      rights = <Privilege>[];
      json['rights'].forEach((v) {
        rights!.add(Privilege.fromJson(v));
      });
    }
    rigtTitle = json['rigtTitle'];
    sort = json['sort'];
    status = json['status'];
    title = json['title'];
    updatedAt = json['updatedAt'];
    vipType = json['vipType'];
    wordColor = json['wordColor'];
    eventEndTime = json['eventEndTime'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['avatarFrame'] = avatarFrame;
    if (banner != null) {
      data['banner'] = banner!.toJson();
    }
    data['canUseCoin'] = canUseCoin;
    data['cardRemark'] = cardRemark;
    data['dayCount'] = dayCount;
    data['dayMoney'] = dayMoney;
    data['desc'] = desc;
    data['downLoadCount'] = downLoadCount;
    data['giftCoin'] = giftCoin;
    data['giftbagIds'] = giftbagIds;
    if (giftbagList != null) {
      data['giftbagList'] = giftbagList!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['image'] = image;
    data['isBuy'] = isBuy;
    data['money'] = money;
    data['movieRate'] = movieRate;
    data['movieTicket'] = movieTicket;
    data['name'] = name;
    data['newUserGift'] = newUserGift;
    data['preMoney'] = preMoney;
    if (rchgType != null) {
      data['rchgType'] = rchgType!.map((v) => v.toJson()).toList();
    }
    data['rewardsCountdown'] = rewardsCountdown;
    if (rights != null) {
      data['rights'] = rights!.map((v) => v.toJson()).toList();
    }
    data['rigtTitle'] = rigtTitle;
    data['sort'] = sort;
    data['status'] = status;
    data['title'] = title;
    data['updatedAt'] = updatedAt;
    data['vipType'] = vipType;
    data['wordColor'] = wordColor;
    return data;
  }
}

class Banner {
  String? backgroudColor;
  String? img;
  String? skipUrl;
  String? text;

  Banner({this.backgroudColor, this.img, this.skipUrl, this.text});

  Banner.fromJson(Map<String, dynamic> json) {
    backgroudColor = json['backgroudColor'];
    img = json['img'];
    skipUrl = json['skipUrl'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['backgroudColor'] = backgroudColor;
    data['img'] = img;
    data['skipUrl'] = skipUrl;
    data['text'] = text;
    return data;
  }
}

class GiftbagList {
  String? desc;
  int? giftbagNum;
  int? giftbagType;
  int? id;
  String? image;
  int? isHave;
  String? name;

  GiftbagList(
      {this.desc,
      this.giftbagNum,
      this.giftbagType,
      this.id,
      this.image,
      this.isHave,
      this.name});

  GiftbagList.fromJson(Map<String, dynamic> json) {
    desc = json['desc'];
    giftbagNum = json['giftbagNum'];
    giftbagType = json['giftbagType'];
    id = json['id'];
    image = json['image'];
    isHave = json['isHave'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['desc'] = desc;
    data['giftbagNum'] = giftbagNum;
    data['giftbagType'] = giftbagType;
    data['id'] = id;
    data['image'] = image;
    data['isHave'] = isHave;
    data['name'] = name;
    return data;
  }
}

class RchgType {
  String? type;
  String? typeName;
  int? rechargeType;

  RchgType({this.type, this.typeName, this.rechargeType});

  RchgType.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    typeName = json['typeName'];
    rechargeType = json['rechargeType'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['typeName'] = typeName;
    data['rechargeType'] = rechargeType;
    return data;
  }
}

class Privilege {
  String? desc;
  String? homeName;
  String? image;
  bool? isHome;
  bool? isLight;
  bool? isOpen;
  String? name;
  int? type;

  Privilege(
      {this.desc,
      this.homeName,
      this.image,
      this.isHome,
      this.isLight,
      this.isOpen,
      this.name,
      this.type});

  Privilege.fromJson(Map<String, dynamic> json) {
    desc = json['desc'];
    homeName = json['homeName'];
    image = json['image'];
    isHome = json['isHome'];
    isLight = json['isLight'];
    isOpen = json['isOpen'];
    name = json['name'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['desc'] = desc;
    data['homeName'] = homeName;
    data['image'] = image;
    data['isHome'] = isHome;
    data['isLight'] = isLight;
    data['isOpen'] = isOpen;
    data['name'] = name;
    data['type'] = type;
    return data;
  }
}

class UserInfoVip {
  String? avatar;
  int? cardId;
  int? growthValue;
  int? id;
  String? nickName;
  String? vipExpire;
  int? vipType;

  UserInfoVip(
      {this.avatar,
      this.cardId,
      this.growthValue,
      this.id,
      this.nickName,
      this.vipExpire,
      this.vipType});

  UserInfoVip.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    cardId = json['cardId'];
    growthValue = json['growthValue'];
    id = json['id'];
    nickName = json['nickName'];
    vipExpire = json['vipExpire'];
    vipType = json['vipType'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['cardId'] = cardId;
    data['growthValue'] = growthValue;
    data['id'] = id;
    data['nickName'] = nickName;
    data['vipExpire'] = vipExpire;
    data['vipType'] = vipType;
    return data;
  }
}
