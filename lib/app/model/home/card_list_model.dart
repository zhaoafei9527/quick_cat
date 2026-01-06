// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class CardList extends BaseNetModel {
  @override
  CardList fromJson(Map<String, dynamic> json) {
    return CardList.fromJson(json);
  }

  List<VipList>? vipList;

  CardList({this.vipList});

  CardList.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      vipList = <VipList>[];
      json['list'].forEach((v) {
        vipList?.add(VipList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (vipList != null) {
      data['vipList'] = vipList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VipList {
  String? cardType;
  String? color;
  List<VipInfo>? itemList;

  VipList({this.cardType, this.color, this.itemList});

  VipList.fromJson(Map<String, dynamic> json) {
    cardType = json['cardType'];
    color = json['color'];
    if (json['list'] != null) {
      itemList = <VipInfo>[];
      json['list'].forEach((v) {
        itemList?.add(VipInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['cardType'] = cardType;
    data['color'] = color;
    if (itemList != null) {
      data['itemList'] = itemList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VipInfo {
  int? id;
  int? vipType;
  String? name;
  String? title;
  String? desc;
  String? rigtTitle;
  int? preMoney;
  int? money;
  bool? canUseCoin;
  int? dayCount;
  int? downLoadCount;
  int? movieTicket;
  int? giftCoin;
  int? movieRate;
  int? status;
  String? updatedAt;
  int? sort;
  dynamic banner;
  String? image;
  List<Rights>? rights;
  List<RchgType>? rchgType;
  int? rchgUse;
  String? wordColor;
  String? priceDesc;
  String? buyDesc;

  VipInfo(
      {this.id,
      this.vipType,
      this.name,
      this.title,
      this.desc,
      this.rigtTitle,
      this.preMoney,
      this.money,
      this.canUseCoin,
      this.dayCount,
      this.downLoadCount,
      this.movieTicket,
      this.giftCoin,
      this.movieRate,
      this.status,
      this.updatedAt,
      this.sort,
      this.banner,
      this.image,
      this.rights,
      this.rchgType,
      this.rchgUse,
      this.wordColor,
      this.priceDesc,
      this.buyDesc});

  VipInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vipType = json['vipType'];
    name = json['name'];
    title = json['title'];
    desc = json['desc'];
    rigtTitle = json['rigtTitle'];
    preMoney = json['preMoney'];
    money = json['money'];
    canUseCoin = json['canUseCoin'];
    dayCount = json['dayCount'];
    downLoadCount = json['downLoadCount'];
    movieTicket = json['movieTicket'];
    giftCoin = json['giftCoin'];
    movieRate = json['movieRate'];
    status = json['status'];
    updatedAt = json['updatedAt'];
    sort = json['sort'];
    banner = json['banner'];
    image = json['image'];
    if (json['rights'] != null) {
      rights = <Rights>[];
      json['rights'].forEach((v) {
        rights?.add(Rights.fromJson(v));
      });
    }
    if (json['rchgType'] != null) {
      rchgType = <RchgType>[];
      json['rchgType'].forEach((v) {
        rchgType?.add(RchgType.fromJson(v));
      });
    }
    rchgUse = json['rchgUse'];
    wordColor = json['wordColor'];
    priceDesc = json['priceDesc'];
    buyDesc = json['buyDesc'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['vipType'] = vipType;
    data['name'] = name;
    data['title'] = title;
    data['desc'] = desc;
    data['rigtTitle'] = rigtTitle;
    data['preMoney'] = preMoney;
    data['money'] = money;
    data['canUseCoin'] = canUseCoin;
    data['dayCount'] = dayCount;
    data['downLoadCount'] = downLoadCount;
    data['movieTicket'] = movieTicket;
    data['giftCoin'] = giftCoin;
    data['movieRate'] = movieRate;
    data['status'] = status;
    data['updatedAt'] = updatedAt;
    data['sort'] = sort;
    data['banner'] = banner;
    data['image'] = image;
    if (rights != null) {
      data['rights'] = rights?.map((v) => v.toJson()).toList();
    }
    if (rchgType != null) {
      data['rchgType'] = rchgType?.map((v) => v.toJson()).toList();
    }
    data['rchgUse'] = rchgUse;
    data['wordColor'] = wordColor;
    data['priceDesc'] = priceDesc;
    data['buyDesc'] = buyDesc;
    return data;
  }
}

class Rights {
  int? type;
  String? name;
  String? desc;
  bool? isOpen;
  String? image;

  Rights({this.type, this.name, this.desc, this.isOpen, this.image});

  Rights.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    name = json['name'];
    desc = json['desc'];
    isOpen = json['isOpen'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['name'] = name;
    data['desc'] = desc;
    data['isOpen'] = isOpen;
    data['image'] = image;
    return data;
  }
}

class RchgType {
  String? type;
  String? typeName;

  RchgType({this.type, this.typeName});

  RchgType.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    typeName = json['typeName'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['typeName'] = typeName;
    return data;
  }
}
