// 🐦 Flutter imports:

// 🌎 Project imports:

import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';
import '../../data/enum.dart';

class ConfigModel extends BaseNetModel {
  @override
  ConfigModel fromJson(Map<String, dynamic> json) {
    return ConfigModel.fromJson(json);
  }

  List<Domain>? domain;
  VersionBean? version;
  List<Advertise>? advertise;
  Announcement? announcement;

  List<MediaCategory>? comicsCategory;
  List<MediaCategory>? cartoonCategory;
  List<MediaCategory>? mediaCategory;

  List<MediaCategory>? novelCategory;
  List<MediaCategory>? dMediaCategory;
  List<MediaCategory>? postCategory;
  List<MediaCategory>? mediaTagType;
  List<MediaCategory>? hGameTypeList;
  Map<MediaType, List<gridItemModel>>? gridItemMap;
  String? cdnKey;
  RunningLight? runningLight;
  List<NotificationInfo>? notificationInfo;

  ConfigModel(
      {this.domain,
      this.version,
      this.advertise,
      this.announcement,
      this.comicsCategory,
      this.cartoonCategory,
      this.novelCategory,
      this.mediaCategory,
      this.dMediaCategory,
      this.mediaTagType,
      this.postCategory,
      this.runningLight,
      this.cdnKey,
      this.notificationInfo,
      this.gridItemMap,
      this.hGameTypeList});

  ConfigModel.fromJson(Map<String, dynamic> json) {
    if (json['domain'] != null) {
      domain = <Domain>[];
      json['domain'].forEach((v) {
        domain?.add(Domain.fromJson(v));
      });
    }
    version =
        json['version'] != null ? VersionBean.fromJson(json['version']) : null;
//https://kohgusip.spirivision.com/res/v2/
    if (json['advertise'] != null) {
      advertise = <Advertise>[];
      json['advertise'].forEach((v) {
        advertise?.add(Advertise.fromJson(v));
      });
    }
    if (json["kongKingCfgMap"] != null) {
      gridItemMap = <MediaType, List<gridItemModel>>{};
      json["kongKingCfgMap"].forEach((String key, value) {
        List<gridItemModel> list = [];
        for (var item in value) {
          list.add(gridItemModel.fromJson(item));
        }

        gridItemMap![MediaType.values[int.tryParse(key) ?? 1]] = list;
      });
    }
    announcement = json['announcement'] != null
        ? Announcement?.fromJson(json['announcement'])
        : null;

    if (json['postCategory'] != null) {
      postCategory = <MediaCategory>[];
      json['postCategory'].forEach((v) {
        postCategory?.add(MediaCategory.fromJson(v));
      });
    }

    if (json['comicsCategory'] != null) {
      comicsCategory = <MediaCategory>[];
      json['comicsCategory'].forEach((v) {
        comicsCategory?.add(MediaCategory.fromJson(v));
      });
    }
    if (json['hGameTypeList'] != null) {
      hGameTypeList = <MediaCategory>[];
      json['hGameTypeList'].forEach((v) {
        hGameTypeList?.add(MediaCategory.fromJson(v));
      });
    }

    if (json['cartoonCategory'] != null) {
      cartoonCategory = <MediaCategory>[];
      json['cartoonCategory'].forEach((v) {
        cartoonCategory?.add(MediaCategory.fromJson(v));
      });
    }
    if (json['novelCategoryList'] != null) {
      novelCategory = <MediaCategory>[];
      json['novelCategoryList'].forEach((v) {
        novelCategory?.add(MediaCategory.fromJson(v));
      });
    }

    if (json['mediaCategory'] != null) {
      mediaCategory = <MediaCategory>[];
      json['mediaCategory'].forEach((v) {
        mediaCategory?.add(MediaCategory.fromJson(v));
      });
    }

    if (json['dMediaCategory'] != null) {
      dMediaCategory = <MediaCategory>[];
      json['dMediaCategory'].forEach((v) {
        dMediaCategory?.add(MediaCategory.fromJson(v));
      });
    }

    if (json['mediaTagType'] != null) {
      mediaTagType = <MediaCategory>[];
      json['mediaTagType'].forEach((v) {
        mediaTagType?.add(MediaCategory.fromJson(v));
      });
    }

    if (json['runningLight'] != null) {
      runningLight = RunningLight?.fromJson(json['runningLight']);
    }
    cdnKey = json['cdnKey'];

    if (json['notificationInfo'] != null) {
      notificationInfo = <NotificationInfo>[];
      json['notificationInfo'].forEach((v) {
        notificationInfo?.add(NotificationInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (domain != null) {
      data['domain'] = domain?.map((v) => v.toJson()).toList();
    }
    if (version != null) {
      data['version'] = version?.toJson();
    }

    if (advertise != null) {
      data['advertise'] = advertise?.map((v) => v.toJson()).toList();
    }
    if (announcement != null) {
      data['announcement'] = announcement?.toJson();
    }

    if (comicsCategory != null) {
      data['comicsCategory'] = comicsCategory?.map((v) => v.toJson()).toList();
    }
    if (cartoonCategory != null) {
      data['cartoonCategory'] =
          cartoonCategory?.map((v) => v.toJson()).toList();
    }

    if (novelCategory != null) {
      data['novelCategoryList'] =
          novelCategory?.map((v) => v.toJson()).toList();
    }
    if (mediaCategory != null) {
      data['mediaCategory'] = mediaCategory?.map((v) => v.toJson()).toList();
    }

    if (dMediaCategory != null) {
      data['dMediaCategory'] = dMediaCategory?.map((v) => v.toJson()).toList();
    }
    if (postCategory != null) {
      data['postCategory'] = postCategory?.map((v) => v.toJson()).toList();
    }

    if (runningLight != null) {
      data['runningLight'] = runningLight?.toJson();
    }
    data['cdnKey'] = cdnKey;
    //
    if (notificationInfo != null) {
      data['notificationInfo'] =
          notificationInfo?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Domain {
  List<String>? urls;
  String? type;

  Domain({this.urls, this.type});

  Domain.fromJson(Map<String, dynamic> json) {
    urls = json['urls'].cast<String>();
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['urls'] = urls;
    data['type'] = type;
    return data;
  }
}

class Advertise {
  String? id;
  String? title;
  String? description;
  String? remark;
  String? cover;
  String? href;
  int? sortCode;
  int? position;
  String? ambientColor;
  bool? vipShow;
  bool? newUserAds;

  Advertise(
      {this.id,
      this.title,
      this.description,
      this.remark,
      this.cover,
      this.href,
      this.sortCode,
      this.vipShow,
      this.position,
      this.newUserAds,
      this.ambientColor});

  Advertise.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['remark'] ?? "没有广告说明";
    remark = json['remark'];
    cover = json['cover'];
    href = json['href'];
    sortCode = json['sortCode'];
    position = json['position'];
    ambientColor = json['ambientColor'];
    vipShow = (json['isNotVip'] ?? 0) == 0;
    newUserAds = (json['isNotVip'] ?? 0) == 2;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['remark'] = remark;
    data['cover'] = cover;
    data['href'] = href;
    data['sortCode'] = sortCode;
    data['position'] = position;
    data['ambientColor'] = ambientColor;
    return data;
  }
}

class Announcement {
  String? title;
  String? content;
  String? cover;
  String? jumpUrl;

  Announcement({this.title, this.content, this.cover, this.jumpUrl});

  Announcement.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
    cover = json['cover'];
    jumpUrl = json['jumpUrl'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['content'] = content;
    data['cover'] = cover;
    data['jumpUrl'] = jumpUrl;
    return data;
  }
}

class MediaCategory {
  int? id;
  String? name;
  CategoryShowType? showType;
  String? imageUrl;
  int? type;
  String? desc;
  bool? isRandom;
  int? line;

  MediaCategory({this.id, this.name, this.showType, this.imageUrl, this.type,this.desc, this.isRandom,this.line});

  MediaCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    desc = json['desc'];
    isRandom = json['isRandom'] ?? false;
    line = json['line'] ?? 0;
    if (json['showType'] != null) {
      showType = CategoryShowType.values[json['showType']];
    }
    imageUrl = json['imageUrl'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['desc'] = desc;
    data['isRandom'] = isRandom;
    data['line'] = line;
    data['showType'] = showType?.index;
    data['imageUrl'] = imageUrl;
    data['type'] = type;
    return data;
  }
}

class NotificationInfo {
  String? title;
  String? content;
  String? jumpUrl;

  NotificationInfo({this.title, this.content, this.jumpUrl});

  NotificationInfo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
    jumpUrl = json['jumpUrl'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['content'] = content;
    data['jumpUrl'] = jumpUrl;
    return data;
  }
}

class RunningLight {
  String? content;
  String? jumpUrl;
  String? wordColor;
  String? title;

  RunningLight({this.content, this.jumpUrl, this.title, this.wordColor});

  RunningLight.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    jumpUrl = json['jumpUrl'];
    title = json['title'];
    if (json["wordColor"] != null) {
      wordColor = json['wordColor'];
      // wordColor = ColorUtil.strToColor(json['wordColor']);
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['content'] = content;
    data['jumpUrl'] = jumpUrl;
    data['title'] = title;
    data['wordColor'] = wordColor;
    return data;
  }
}

class PostSection {
  int? postCategoryId;
  int? id;
  String? name;
  int? totalPost;
  String? imageUrl;
  int? totalCollects;
  int? totalWatches;

  PostSection(
      {this.postCategoryId,
      this.id,
      this.name,
      this.totalPost,
      this.imageUrl,
      this.totalCollects,
      this.totalWatches});

  PostSection.fromJson(Map<String, dynamic> json) {
    postCategoryId = json['postCategoryId'];
    id = json['id'];
    name = json['name'];
    totalPost = json['totalPost'];
    imageUrl = json['imageUrl'];
    totalCollects = json['totalCollects'];
    totalWatches = json['totalWatches'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['postCategoryId'] = postCategoryId;
    data['id'] = id;
    data['name'] = name;
    data['totalPost'] = totalPost;
    data['imageUrl'] = imageUrl;
    data['totalCollects'] = totalCollects;
    data['totalWatches'] = totalWatches;
    return data;
  }
}

class StatConfigApp {
  List<NineList>? nineList;
  List<NineList>? recreationList;

  StatConfigApp({this.nineList, this.recreationList});

  StatConfigApp.fromJson(Map<String, dynamic> json) {
    if (json['nineList'] != null) {
      nineList = <NineList>[];
      json['nineList'].forEach((v) {
        nineList?.add(NineList.fromJson(v));
      });
    }
    if (json['recreationList'] != null) {
      recreationList = <NineList>[];
      json['recreationList'].forEach((v) {
        recreationList?.add(NineList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (nineList != null) {
      data['nineList'] = nineList?.map((v) => v.toJson()).toList();
    }
    if (recreationList != null) {
      data['recreationList'] = recreationList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NineList {
  String? id;
  String? name;
  int? tag;
  String? desc;
  String? downloadUrl;
  String? iosUrl;
  String? androidUrl;
  String? avatar;
  int? rank;
  int? downTotal;

  NineList(
      {this.id,
      this.name,
      this.tag,
      this.desc,
      this.downloadUrl,
      this.iosUrl,
      this.androidUrl,
      this.avatar,
      this.rank,
      this.downTotal});

  NineList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    tag = json['tag'];
    desc = json['desc'];
    downloadUrl = json['download_url'];
    iosUrl = json['iosUrl'];
    androidUrl = json['androidUrl'];
    avatar = json['avatar'];
    rank = json['rank'];
    downTotal = json['downTotal'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['tag'] = tag;
    data['desc'] = desc;
    data['download_url'] = downloadUrl;
    data['iosUrl'] = iosUrl;
    data['androidUrl'] = androidUrl;
    data['avatar'] = avatar;
    data['rank'] = rank;
    data['downTotal'] = downTotal;
    return data;
  }
}

// 版本更新
class VersionBean {
  bool? hasNewVersion;
  String? serverVersion;
  String? downloadLink;
  String? description;
  bool? forcedUpdate;
  String? landpageLink;

  VersionBean(
      {this.hasNewVersion,
      this.serverVersion,
      this.downloadLink,
      this.description,
      this.landpageLink,
      this.forcedUpdate});

  VersionBean.fromJson(Map<String, dynamic> json) {
    hasNewVersion = json['hasNewVersion'];
    serverVersion = json['serverVersion'];
    downloadLink = json['downloadLink'];
    description = json['description'];
    landpageLink = json['landpageLink'];
    forcedUpdate = json['forcedUpdate'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hasNewVersion'] = hasNewVersion;
    data['serverVersion'] = serverVersion;
    data['downloadLink'] = downloadLink;
    data['description'] = description;
    data['landpageLink'] = landpageLink;
    data['forcedUpdate'] = forcedUpdate;
    return data;
  }
}

class gridItemModel {
  int? id;
  String? name;
  String? icon;
  String? url;
  int? rank;

  gridItemModel({this.id, this.name, this.icon, this.url, this.rank});

  gridItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
    url = json['url'];
    rank = json['rank'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['icon'] = icon;
    data['url'] = url;
    data['rank'] = rank;
    return data;
  }
}

class HGameResult extends BaseNetModel {
  @override
  HGameResult fromJson(Map<String, dynamic> json) {
    return HGameResult.fromJson(json);
  }

  List<HGameInfo>? list;
  int? total;

  HGameResult({this.list, this.total});

  HGameResult.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <HGameInfo>[];
      json['list'].forEach((v) {
        list?.add(HGameInfo.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list?.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    return data;
  }
}

class HGameInfo {
  String? cover;
  String? desc;
  String? gameAvatar;
  int? id;
  String? name;
  int? number;

  // List<GameTag>? tags;
  String? url;
  int? showType;
  int? typeId;
  List<GameTag>? tags;
  List<String>? imgs;

  HGameInfo(
      {this.cover,
      this.desc,
      this.gameAvatar,
      this.id,
      this.name,
      this.number,
      this.tags,
      this.showType,
      this.typeId,
      this.imgs,
      this.url});

  HGameInfo.fromJson(Map<String, dynamic> json) {
    cover = json['cover'];
    desc = json['desc'];
    gameAvatar = json['gameAvatar'];
    id = json['id'];
    name = json['name'];
    number = json['number'];
    showType = json['showType'];
    typeId = json['typeId'];
    if (json['tags'] != null) {
      tags = <GameTag>[];
      json['tags'].forEach((v) {
        tags?.add(GameTag.fromJson(v));
      });
    }
    if (json['imgs'] != null) {
      imgs = <String>[];
      json['imgs'].forEach((v) {
        imgs?.add(v);
      });
    }

    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['cover'] = cover;
    data['desc'] = desc;
    data['gameAvatar'] = gameAvatar;
    data['id'] = id;
    data['name'] = name;
    data['number'] = number;
    data['showType'] = showType;
    data['typeId'] = typeId;
    if (imgs != null) {
      data['imgs'] = imgs;
    }

    data['url'] = url;
    return data;
  }
}

class GameTag {
  String? color;
  String? tagName;

  GameTag({this.color, this.tagName});

  GameTag.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    tagName = json['tagName'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['color'] = color;
    data['tagName'] = tagName;
    return data;
  }
}
