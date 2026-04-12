// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';

/// 游戏平台列表
/// @gamePlatform 1
/// @icon
/// title

class GamePlatformListModel extends BaseNetModel {
  @override
  GamePlatformListModel fromJson(Map<String, dynamic> json) {
    return GamePlatformListModel.fromJson(json);
  }

  int? count;
  List<GamePlatformBean>? list;

  GamePlatformListModel({this.count, this.list});

  GamePlatformListModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['list'] != null) {
      list = <GamePlatformBean>[];
      json['list'].forEach((v) {
        list?.add(GamePlatformBean.fromJson(v));
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

class GamePlatformBean extends BaseNetModel {
  @override
  GamePlatformBean fromJson(Map<String, dynamic> json) {
    return GamePlatformBean.fromJson(json);
  }

  int? gamePlatform;
  String? icon;
  String? title;
  List<CategoryInfoBean>? categoryList;

  GamePlatformBean({
    this.gamePlatform,
    this.icon,
    this.title,
    this.categoryList,
  });

  GamePlatformBean.fromJson(Map<String, dynamic> json) {
    gamePlatform = json['gamePlatform'];
    icon = json['icon'];
    title = json['title'];
    final rawCategoryList = json['typeList'];
    if (rawCategoryList is List) {
      final validIndexes = rawCategoryList
          .map((e) => e is int ? e : int.tryParse(e.toString()))
          .whereType<int>()
          .where((e) => e > 0 && e < GameCategory.values.length)
          .toSet();

      final cateList = validIndexes.map((e) => GameCategory.values[e]).toList();
      categoryList = <CategoryInfoBean>[];
      for (final item in cateList) {
        final bean = gameCategoryToName[item];
        if (bean != null) {
          categoryList?.add(bean);
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['gamePlatform'] = gamePlatform;
    data['icon'] = icon;
    data['title'] = title;
    return data;
  }
}

/// 游戏劣币啊详情
class GameListModel extends BaseNetModel {
  @override
  GameListModel fromJson(Map<String, dynamic> json) {
    return GameListModel.fromJson(json);
  }

  int? count;
  List<GameInfoBean>? list;
  int? code;
  String? msg;
  GameInfoBean? data;

  GameListModel({this.count, this.code, this.data, this.msg, this.list});

  GameListModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    code = json['code'];
    msg = json['msg'];
    if (null != json['data']) {
      data = GameInfoBean.fromJson(json["data"]);
    }
    if (json['list'] != null) {
      list = <GameInfoBean>[];
      json['list'].forEach((v) {
        list?.add(GameInfoBean.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> datas = <String, dynamic>{};
    datas['data'] = data?.toJson();
    datas['count'] = count;
    if (list != null) {
      datas['list'] = list?.map((v) => v.toJson()).toList();
    }
    return datas;
  }
}

class CategoryInfoBean extends BaseNetModel {
  @override
  CategoryInfoBean fromJson(Map<String, dynamic> json) {
    return CategoryInfoBean.fromJson(json);
  }

  int? gameCategory;
  String? title;
  String? icon;
  String? sleIcon;

  CategoryInfoBean({this.title, this.icon, this.sleIcon, this.gameCategory});

  CategoryInfoBean.fromJson(Map<String, dynamic> json) {
    gameCategory = json['gameCategory'];
    title = json['title'];
    icon = json['icon'];
    sleIcon = json['sleIcon'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['gameCategory'] = gameCategory;
    data['title'] = title;
    data['icon'] = icon;
    data['sleIcon'] = sleIcon;
    return data;
  }
}

class GameInfoBean extends BaseNetModel {
  @override
  GameInfoBean fromJson(Map<String, dynamic> json) {
    return GameInfoBean.fromJson(json);
  }

  int? id;
  int? number;
  int? gameCategory;
  String? introduce; // 简介
  String? title;
  String? coverImg;
  String? gameReason;
  String? gameUrl;
  String? gameType;
  String? selectedIcon;

  GameInfoBean(
      {this.id,
      this.title,
      this.introduce,
      this.number,
      this.gameReason,
      this.gameUrl,
      this.gameType,
      this.gameCategory,
      this.coverImg,
      this.selectedIcon});

  GameInfoBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    number = json['number'];
    gameReason = json['gameReason'];
    gameUrl = json['gameUrl'];
    gameType = json['gameType'];
    introduce = json['introduce'];
    gameCategory = json['gameCategory'];
    coverImg = json['coverImg'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data["number"] = number;
    data['gameReason'] = gameReason;
    data['gameUrl'] = gameUrl;
    data['gameType'] = gameType;
    data['gameCategory'] = gameCategory;
    data['introduce'] = introduce;
    data['coverImg'] = coverImg;

    return data;
  }
}
