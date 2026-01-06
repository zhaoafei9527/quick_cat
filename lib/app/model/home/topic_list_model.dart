// 🌎 Project imports:
import 'package:acgn_client/app/model/comic_info_model.dart';
import 'package:acgn_client/app/model/home/video_play_model.dart';
import 'package:acgn_client/app/model/post_list_model.dart';
import 'package:acgn_client/plugins_utils/HttpRequester/http_requester.dart';
import '../../data/enum.dart';

class CategoryTopics extends BaseNetModel {
  @override
  CategoryTopics fromJson(Map<String, dynamic> json) {
    return CategoryTopics.fromJson(json);
  }

  List<TopicList>? list;

  CategoryTopics({this.list});

  CategoryTopics.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <TopicList>[];
      json['list'].forEach((v) {
        list?.add(TopicList.fromJson(v));
      });
    }
  }
}

class TopicList extends BaseNetModel {
  @override
  TopicList fromJson(Map<String, dynamic> json) {
    return TopicList.fromJson(json);
  }

  int? id;
  String? name;
  String? desc;
  int? contentType;
  TopicShowType? showType;
  int? price;
  int? sells;
  bool? isBuy;
  int? defaultType;
  int? watchTimes;
  int? movieCount;
  List<MediaInfo>? list;
  String? background;
  dynamic tags;
  String? cover;
  bool? isChange; // 主题是否支持换一换
  int? coverType; // 主题封面类型 1:横版 2：竖版
  String? backgroundColor;
  List<Null>? advertiseMediaList;
  int? advertiseMediaCount;
  int? showStatus;
  List<TopicList>? topicList;
  List<AppTopicInfo>? appList;

  TopicList(
      {this.id,
      this.name,
      this.desc,
      this.contentType,
      this.showType,
      this.price,
      this.sells,
      this.isBuy,
      this.defaultType,
      this.watchTimes,
      this.movieCount,
      this.list,
      this.background,
      this.tags,
      this.cover,
      this.isChange,
      this.topicList,
      this.coverType,
      this.backgroundColor,
      this.advertiseMediaList,
      this.advertiseMediaCount,
      this.showStatus});

  TopicList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    desc = json['desc'];
    isChange = json['isChange'];
    coverType = json['coverType'];
    contentType = json['contentType'];
    showType = TopicShowType.values[json['showType'] ?? 0];
    price = json['price'];
    sells = json['sells'];
    isBuy = json['isBuy'];
    defaultType = json['defaultType'];
    watchTimes = json['watchTimes'];
    movieCount = json['movieCount'];

    if (json['topicList'] != null) {
      topicList = <TopicList>[];
      json['topicList'].forEach((v) {
        topicList?.add(TopicList.fromJson(v));
      });
    }
    if (json['appList'] != null) {
      appList = <AppTopicInfo>[];
      json['appList'].forEach((v) {
        appList?.add(AppTopicInfo.fromJson(v));
      });
    }

    if (json['list'] != null) {
      list = <MediaInfo>[];
      json['list'].forEach((v) {
        list?.add(MediaInfo.fromJson(v));
      });
    }

    background = json['background'];
    tags = json['tags'];
    cover = json['cover'];
    backgroundColor = json['backgroundColor'];
    // if (json['advertiseMediaList'] != null) {
    //   advertiseMediaList = <Null>[];
    //   json['advertiseMediaList'].forEach((v) {
    //     advertiseMediaList?.add(Null.fromJson(v));
    //   });
    // }
    advertiseMediaCount = json['advertiseMediaCount'];
    showStatus = json['showStatus'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['desc'] = desc;
    data['contentType'] = contentType;
    data['showType'] = showType?.index;
    data['price'] = price;
    data['sells'] = sells;
    data['isBuy'] = isBuy;
    data['defaultType'] = defaultType;
    data['watchTimes'] = watchTimes;
    data['movieCount'] = movieCount;
    if (topicList != null) {
      data['topicList'] = topicList?.map((v) => v.toJson()).toList();
    }
    if (list != null) {
      data['mediaList'] = list?.map((v) => v.toJson()).toList();
    }

    if (appList != null) {
      data['appList'] = appList?.map((v) => v.toJson()).toList();
    }
    data['background'] = background;
    data['tags'] = tags;
    data['cover'] = cover;
    data['backgroundColor'] = backgroundColor;
    // if (advertiseMediaList != null) {
    //   data['advertiseMediaList'] =
    //       advertiseMediaList?.map((v) => v.toJson()).toList();
    // }
    data['advertiseMediaCount'] = advertiseMediaCount;
    data['showStatus'] = showStatus;
    return data;
  }
}

class Episodes extends BaseNetModel {
  @override
  Episodes fromJson(Map<String, dynamic> json) {
    return Episodes.fromJson(json);
  }

  String? epiSt;
  int? epiNo;
  bool? playable;
  int? mediaId;
  String? cover;

  Episodes.fromJson(Map<String, dynamic> json) {
    epiSt = json['epiSt'];
    epiNo = json['epiNo'];
    playable = json['playable'];
    mediaId = json['mediaId'];
    cover = json['cover'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['epiSt'] = epiSt;
    data['epiNo'] = epiNo;
    data['playable'] = playable;
    data['mediaId'] = mediaId;
    data['cover'] = cover;
    return data;
  }
}

// 顶级媒体属性 适用所有类型
class MediaInfo extends BaseNetModel {
  @override
  MediaInfo fromJson(Map<String, dynamic> json) {
    return MediaInfo.fromJson(json);
  }

  int? id; // 公共属性
  String? title; // 公共属性
  String? coverImg; // 公共属性
  String? desc; // 公共属性
  int? price; // 公共属性
  int? watchTimes; // 公共属性
  bool? isBuy; // 公共属性
  List<TagList>? tagList; // 公共属性

  int? comments; // 公共属性 评论数量
  bool? isLike; // 公共属性 是否点赞
  bool? isCollect; // 公共属性 是否收藏
  int? collects; // 公共属性 收藏数量
  int? likes; // 公共属性 点赞数量
  String? addedTime; // 公共属性
  String? createdAt; // 公共属性
  bool? isVip; //  公共属性 是否会员
  String? lastWatchTime; // 公共属性 最近观看时间

  int? newChapter; // 漫画属性 最新章节
  int? pageCount; // 漫画属性 章节数
  bool? isSerial; // 是否连载
  int? comicsNumber; // 漫画属性 漫画数量
  List<String>? author; // 漫画作者
  PaymentType? comicsPayType; // 漫画付费类型
  int? bulletscreens; // 漫画 弹幕数量
  int? chapterNum; // 漫画 章节数
  List<MediaInfo>? lookComics; // 漫画 推荐观看漫画列表
  int? updateStatus; // 漫画 更新状态
  int? updateWeek; // 漫画 更新周期
  int? weekWatchTimes; // 漫画 周观看次数
  int? monthWatchTimes; // 漫画 月观看次数
  List<Tag>? comicTags; // 漫画标签

  PaymentType? novelPayType; // 小说属性 付费类型
  int? chapterCount; // 小说属性 章节数量
  int? wordTotalCount; // 小说属性 字数
  int? novelNumber; // 小说属性 小说数量
  List<Tag>? novelTags; // 漫画标签
  List<MediaInfo>? lookNovel; // 小说 推荐观看小说列表

  int? videoType; // 视频属性 长短视频
  int? playTime; // 视频属性 视频时间
  int? preTime; // 视频属性 预览时间
  PaymentType? payType; // 公共属性
  String? videoUrl; // 视频属性  视频播放地址
  String? preVideoUrl; // 视频属性  视频预览地址
  List<String>? videoTags; // 视频属性  视频标签
  List<SecondsPlayInfoModel>? showTime; // 视频属性 断点时间
  CoverData? coverData; // 视频属性，封面宽高

  int? width;
  int? height;
  String? actor; //视频属性  视频演员
  String? bango; // 视频属性 视频番号
  bool? playable = true; // 视频属性  默认能播放
  int? coverType; // 视频属性  封面类型 1：横版 2：竖版
  String? releaseTime; // 发布时间

  int? mediaNumber;
  int? episodeNum;
  int? episodeId;
  String? adsPath;
  String? adsId;
  int? readNum; // 阅读的图片下标位置
  int? readChapterId; // 当前漫画章节的位置
  EditStatusType editStatus = EditStatusType.none;

  bool? isAds = false;

  MediaInfo(
      {this.id,
      this.title,
      this.videoType,
      this.videoUrl,
      this.preVideoUrl,
      this.showTime,
      this.tagList,
      this.coverImg,
      this.desc,
      this.actor,
      this.payType,
      this.playTime,
      this.preTime,
      this.comicsNumber,
      this.newChapter,
      this.pageCount,
      this.isSerial,
      this.author,
      this.price,
      this.likes,
      this.comicsPayType,
      this.collects,
      this.watchTimes,
      this.comments,
      this.isLike,
      this.isBuy,
      this.isCollect,
      this.bango,
      this.addedTime,
      this.createdAt,
      this.coverType,
      this.mediaNumber,
      this.episodeId,
      this.episodeNum,
      this.adsPath,
      this.isAds,
      this.playable,
      this.chapterNum,
      this.lookComics,
      this.lookNovel,
      this.updateStatus,
      this.updateWeek,
      this.weekWatchTimes,
      this.monthWatchTimes,
      this.bulletscreens,
      this.lastWatchTime,
      this.isVip,
        this.width,
        this.height,
      this.comicTags,
      this.novelPayType,
      this.chapterCount,
      this.wordTotalCount,
      this.novelNumber,
      this.novelTags,
      this.videoTags,
      this.readChapterId,
      this.readNum,
      this.coverData,
      this.releaseTime,
      this.adsId});

  MediaInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // ============ 分割每日精选 =======-=======
    title = json['title'];
    videoType = json['videoType'];
    videoUrl = json['videoUrl'];
    width = json['width'];
    height = json['height'];
    preVideoUrl = json['preVideoUrl'];
    releaseTime = json['releaseTime'];
    // tags = json['tags'].cast<String>();
    if (json['tagList'] != null) {
      tagList = <TagList>[];
      json['tagList'].forEach((v) {
        tagList?.add(TagList.fromJson(v));
      });
    }
    if (json['tags'] != null) {
      novelTags = <Tag>[];
      comicTags = <Tag>[];
      videoTags = <String>[];
      json['tags'].forEach((v) {
        if (v is String) {
          videoTags?.add(v);
        } else if (v is Map<String, dynamic>) {
          comicTags?.add(Tag.fromJson(v));
          novelTags?.add(Tag.fromJson(v));
        }
      });
    }
    if (json['showTime'] != null) {
      showTime = <SecondsPlayInfoModel>[];
      json['showTime'].forEach((v) {
        showTime?.add(SecondsPlayInfoModel.fromJson(v));
      });
    }

    if (json['coverData'] != null) {
      coverData = CoverData.fromJson(json['coverData']);
    }

    isVip = json['isVip'];
    lastWatchTime = json['lastWatchTime'];
    if (json['lookComics'] != null) {
      json['lookComics'].forEach((v) {
        lookComics?.add(MediaInfo.fromJson(v));
      });
    }
    if (json['lookNovel'] != null) {
      json['lookNovel'].forEach((v) {
        lookNovel?.add(MediaInfo.fromJson(v));
      });
    }
    updateStatus = json['updateStatus'];
    updateWeek = json['updateWeek'];
    weekWatchTimes = json['weekWatchTimes'];
    monthWatchTimes = json['monthWatchTimes'];
    bulletscreens = json['bulletscreens'];
    chapterNum = json['chapterNum'];

    comicsPayType = PaymentType.values[json['comicsPayType'] ?? 0];
    novelPayType = PaymentType.values[json['novelPayType'] ?? 0];
    payType = PaymentType.values[json['payType'] ?? 0];
    chapterCount = json['chapterCount'];
    wordTotalCount = json['wordTotalCount'];
    novelNumber = json['novelNumber'];

    coverImg = json['coverImg'];
    desc = json['desc'];
    actor = json['actor'];
    playTime = json['playTime'];
    preTime = json['preTime'];
    price = json['price'];
    likes = json['likes'];
    collects = json['collects'];
    watchTimes = json['watchTimes'];
    comments = json['comments'];
    isLike = json['isLike'];
    isBuy = json['isBuy'];
    isCollect = json['isCollect'];
    bango = json['bango'];
    addedTime = json['addedTime'];
    createdAt = json['createdAt'];
    coverType = json['coverType'];
    mediaNumber = json['mediaNumber'];
    episodeNum = json['episodeNum'];
    episodeId = json['episodeId'];
    if (json['author'] != null) {
      author = json['author'].cast<String>();
    }
    comicsNumber = json['comicsNumber'];
    newChapter = json['newChapter'];
    pageCount = json['pageCount'];
    isSerial = json['isSerial'];
    readChapterId = json['readChapterId'];
    readNum = json['readNum'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['videoType'] = videoType;
    data['videoUrl'] = videoUrl;
    data['preVideoUrl'] = preVideoUrl;
    if (tagList != null) {
      data['tagList'] = tagList?.map((v) => v.toJson()).toList();
    }
    if (showTime != null) {
      data['showTime'] = showTime?.map((v) => v.toJson()).toList();
    }
    if (comicTags != null) {
      data['tags'] = comicTags?.map((v) => v.toJson()).toList();
    }
    if (videoTags != null) {
      data['tags'] = videoTags;
    }
    data['isVip'] = isVip;
    data['lastWatchTime'] = lastWatchTime;
    if (lookComics != null) {
      data['lookComics'] = lookComics?.map((v) => v.toJson()).toList();
    }
    if (lookNovel != null) {
      data['lookNovel'] = lookNovel?.map((v) => v.toJson()).toList();
    }
    data['updateStatus'] = updateStatus;
    data['updateWeek'] = updateWeek;
    data['weekWatchTimes'] = weekWatchTimes;
    data['monthWatchTimes'] = monthWatchTimes;
    data['bulletscreens'] = bulletscreens;
    data['chapterNum'] = chapterNum;
    data['comicsPayType'] = comicsPayType?.index;
    data['novelPayType'] = novelPayType?.index;
    data['payType'] = payType?.index;
    data['chapterCount'] = chapterCount;
    data['wordTotalCount'] = wordTotalCount;
    data['novelNumber'] = novelNumber;
    if (novelTags != null) {
      data['tags'] = novelTags?.map((v) => v.toJson()).toList();
    }
    if (author != null) {
      data['author'] = author;
    }
    data['coverImg'] = coverImg;
    data['desc'] = desc;
    data['actor'] = actor;
    data['playTime'] = playTime;
    data['preTime'] = preTime;
    data['price'] = price;
    data['likes'] = likes;
    data['collects'] = collects;
    data['watchTimes'] = watchTimes;
    data['comments'] = comments;
    data['isLike'] = isLike;
    data['isBuy'] = isBuy;
    data['isCollect'] = isCollect;
    data['bango'] = bango;
    data['addedTime'] = addedTime;
    data['createdAt'] = createdAt;
    data['coverType'] = coverType;
    data['mediaNumber'] = mediaNumber;
    data['episodeNum'] = episodeNum;
    data['episodeId'] = episodeId;
    data['adsPath'] = adsPath;
    data['adsId'] = adsId;
    data['isAds'] = isAds;
    data['playable'] = playable;
    data['isSerial'] = isSerial;
    data['readChapterId'] = readChapterId;
    data['readNum'] = readNum;
    return data;
  }
}

class CoverData {
  final int? width;
  final int? height;
  final int? high;

  CoverData({
    this.width,
    this.height,
    this.high,
  });

  factory CoverData.fromJson(Map<String, dynamic> json) {
    return CoverData(
      width: json['width'] as int?,
      height: json['height'] as int?,
      high: json['high'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'high': high,
    };
  }
}

// Tag 类
class Tag {
  final String? cover;
  final int? id;
  final String? name;
  final int? watchTimes;

  Tag({
    this.cover,
    this.id,
    this.name,
    this.watchTimes,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      cover: json['cover'] as String?,
      id: json['id'] as int?,
      name: json['name'] as String?,
      watchTimes: json['watchTimes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cover': cover,
      'id': id,
      'name': name,
      'watchTimes': watchTimes,
    };
  }
}

class TagList {
  int? id;
  int? showType;
  String? name;
  String? cover;
  int? defaultType;

  TagList({this.id, this.showType, this.name, this.cover, this.defaultType});

  TagList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    showType = json['showType'];
    name = json['name'];
    cover = json['cover'];
    defaultType = json['defaultType'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['showType'] = showType;
    data['name'] = name;
    data['cover'] = cover;
    data['defaultType'] = defaultType;
    return data;
  }
}

class Publisher {
  int? id;
  String? name;
  String? avatar;
  bool? isFollow;
  String? desc;
  int? fans;
  int? collects;

  Publisher(
      {this.id,
      this.name,
      this.avatar,
      this.isFollow,
      this.desc,
      this.fans,
      this.collects});

  Publisher.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar'];
    isFollow = json['isFollow'];
    desc = json['desc'];
    fans = json['fans'];
    collects = json['collects'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['avatar'] = avatar;
    data['isFollow'] = isFollow;
    data['desc'] = desc;
    data['fans'] = fans;
    data['collects'] = collects;
    return data;
  }
}

class AppTopicInfo {
  int? id;
  String? name;
  String? desc;
  int? rank;
  int? score;
  String? cover;
  String? link;
  int? downloads;
  String? districtCode;
  bool? isDownloadDirectly;
  int? appId;

  AppTopicInfo(
      {this.id,
      this.name,
      this.desc,
      this.rank,
      this.score,
      this.cover,
      this.link,
      this.downloads,
      this.districtCode,
      this.isDownloadDirectly,
      this.appId});

  AppTopicInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    desc = json['desc'];
    rank = json['rank'];
    score = json['score'];
    cover = json['cover'];
    link = json['link'];
    downloads = json['downloads'];
    districtCode = json['districtCode'];
    isDownloadDirectly = json['isDownloadDirectly'];
    appId = json['appId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['desc'] = desc;
    data['rank'] = rank;
    data['score'] = score;
    data['cover'] = cover;
    data['link'] = link;
    data['downloads'] = downloads;
    data['districtCode'] = districtCode;
    data['isDownloadDirectly'] = isDownloadDirectly;
    data['appId'] = appId;
    return data;
  }
}

class MediaList extends BaseNetModel {
  @override
  MediaList fromJson(Map<String, dynamic> json) {
    return MediaList.fromJson(json);
  }

  List<MediaInfo>? mediaList;
  List<MediaInfo>? comicsList;
  List<MediaInfo>? comicList;
  List<MediaInfo>? novelList;
  List<MediaInfo>? longMediaList;
  List<MediaInfo>? shortMediaList;
  List<MediaInfo>? list;

  List<PostBrief>? postList;

  MediaList(
      {this.list,
      this.mediaList,
      this.postList,
      this.comicsList,
      this.comicList,
      this.longMediaList,
      this.novelList,
      this.shortMediaList});

  MediaList.fromJson(Map<String, dynamic> json) {
    if (json['mediaList'] != null) {
      mediaList = <MediaInfo>[];
      json['mediaList'].forEach((v) {
        mediaList?.add(MediaInfo.fromJson(v));
      });
    }
    if (json['comicsList'] != null) {
      comicsList = <MediaInfo>[];
      json['comicsList'].forEach((v) {
        comicsList?.add(MediaInfo.fromJson(v));
      });
    }
    if (json['comicList'] != null) {
      comicList = <MediaInfo>[];
      json['comicList'].forEach((v) {
        comicList?.add(MediaInfo.fromJson(v));
      });
    }
    if (json['novelList'] != null) {
      novelList = <MediaInfo>[];
      json['novelList'].forEach((v) {
        novelList?.add(MediaInfo.fromJson(v));
      });
    }
    if (json['shortMediaList'] != null) {
      shortMediaList = <MediaInfo>[];
      json['shortMediaList'].forEach((v) {
        shortMediaList?.add(MediaInfo.fromJson(v));
      });
    }
    if (json['longMediaList'] != null) {
      longMediaList = <MediaInfo>[];
      json['longMediaList'].forEach((v) {
        longMediaList?.add(MediaInfo.fromJson(v));
      });
    }
    if (json['list'] != null) {
      list = <MediaInfo>[];
      json['list'].forEach((v) {
        list?.add(MediaInfo.fromJson(v));
      });
    }
    if (null != json['postList']) {
      postList = <PostBrief>[];
      json['postList'].forEach((e) {
        postList?.add(PostBrief.fromJson(e));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (mediaList != null) {
      data['mediaList'] = mediaList?.map((v) => v.toJson()).toList();
    }
    if (list != null) {
      data['list'] = list?.map((v) => v.toJson()).toList();
    }
    if (postList != null) {
      data['postList'] = postList?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class TagTypeModel {
  int? id;
  String? name;
  List<TagList>? list;

  TagTypeModel({this.id, this.name, this.list});

  TagTypeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['list'] != null) {
      list = <TagList>[];
      json['list'].forEach((v) {
        list?.add(TagList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (list != null) {
      data['list'] = list?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TagTypeNetModel extends BaseNetModel {
  @override
  TagTypeNetModel fromJson(Map<String, dynamic> json) {
    return TagTypeNetModel.fromJson(json);
  }

  List<TagTypeModel>? tagTypeList;

  TagTypeNetModel({this.tagTypeList});

  TagTypeNetModel.fromJson(Map<String, dynamic> json) {
    if (json['tagTypeList'] != null) {
      tagTypeList = <TagTypeModel>[];
      json['tagTypeList'].forEach((v) {
        tagTypeList?.add(TagTypeModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (tagTypeList != null) {
      data['tagTypeList'] = tagTypeList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryTagModel extends BaseNetModel {
  @override
  CategoryTagModel fromJson(Map<String, dynamic> json) {
    return CategoryTagModel.fromJson(json);
  }

  Map<MediaType, List<Tag>>? tagModel;

  CategoryTagModel({this.tagModel});

  CategoryTagModel.fromJson(Map<String, dynamic> json) {
    tagModel = <MediaType, List<Tag>>{};
    json["tagsMap"].forEach((String key, value) {
      List<Tag> list = [];
      for (var item in value) {
        list.add(Tag.fromJson(item));
      }

      tagModel![MediaType.values[int.tryParse(key) ?? 1]] = list;
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    tagModel?.forEach((key, value) {
      data[key.toString().split('.').last] =
          value.map((e) => e.toJson()).toList();
    });
    return data;
  }
}

class WishedListModel extends BaseNetModel {
  @override
  WishedListModel fromJson(Map<String, dynamic> json) {
    return WishedListModel.fromJson(json);
  }

  List<TopicList>? topicList;
  WishedInfoModel? activity;

  WishedListModel({this.topicList, this.activity});

  WishedListModel.fromJson(Map<String, dynamic> json) {
    if (json['topicList'] != null) {
      topicList = <TopicList>[];
      json['topicList'].forEach((v) {
        topicList?.add(TopicList.fromJson(v));
      });
    }
    if (json['activity'] != null) {
      activity = WishedInfoModel.fromJson(json['activity']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (topicList != null) {
      data['topicList'] = topicList?.map((v) => v.toJson()).toList();
    }
    if (activity != null) {
      data['activity'] = activity?.toJson();
    }
    return data;
  }
}

class WishedInfoModel {
  int? id;
  String? cover;
  String? end;
  String? name;
  String? start;

  WishedInfoModel({
    this.id,
    this.cover,
    this.end,
    this.name,
    this.start,
  });

  WishedInfoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cover = json['cover'];
    end = json['end'];
    name = json['name'];
    start = json['start'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cover'] = cover;
    data['end'] = end;
    data['name'] = name;
    data['start'] = start;
    return data;
  }
}

class WishedActiveInfoDetail extends BaseNetModel {
  @override
  WishedActiveInfoDetail fromJson(Map<String, dynamic> json) {
    return WishedActiveInfoDetail.fromJson(json);
  }

  List<WishedActiveMember>? list;
  WishedInfoModel? activity;

  WishedActiveInfoDetail({this.list, this.activity});

  WishedActiveInfoDetail.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <WishedActiveMember>[];
      json['list'].forEach((v) {
        list?.add(WishedActiveMember.fromJson(v));
      });
    }
    if (json['activity'] != null) {
      activity = WishedInfoModel.fromJson(json['activity']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list?.map((v) => v.toJson()).toList();
    }
    if (activity != null) {
      data['activity'] = activity?.toJson();
    }
    return data;
  }
}

class WishedActiveMember {
  int? id;
  int? activityType;
  int? hopeNum;
  bool? isCollet;
  String? name;
  int? objectId;

  String? reason;
  String? userName;
  int? userId;
  int? updateStatus;

  WishedActiveMember({
    this.id,
    this.name,
    this.activityType,
    this.hopeNum,
    this.isCollet,
    this.objectId,
    this.reason,
    this.userName,
    this.userId,
    this.updateStatus,
  });

  WishedActiveMember.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    activityType = json['activityType'];
    hopeNum = json['hopeNum'];
    isCollet = json['isCollet'];
    objectId = json['objectId'];
    reason = json['reason'];
    userName = json['userName'];
    userId = json['userId'];
    updateStatus = json['updateStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['activityType'] = activityType;
    data['hopeNum'] = hopeNum;
    data['isCollet'] = isCollet;
    data['objectId'] = objectId;
    data['reason'] = reason;
    data['userName'] = userName;
    data['userId'] = userId;
    data['updateStatus'] = updateStatus;
    return data;
  }
}
