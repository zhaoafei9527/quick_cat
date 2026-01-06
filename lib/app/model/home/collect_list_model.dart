// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class CollectList extends BaseNetModel {
  @override
  CollectList fromJson(Map<String, dynamic> json) {
    return CollectList.fromJson(json);
  }

  List<MediaList>? mediaList;
  List<MiniDramaList>? miniDramaList;

  CollectList({this.mediaList, this.miniDramaList});

  CollectList.fromJson(Map<String, dynamic> json) {
    if (json['mediaList'] != null) {
      mediaList = <MediaList>[];
      json['mediaList'].forEach((v) {
        mediaList?.add(MediaList.fromJson(v));
      });
    }
    if (json['miniDramaList'] != null) {
      miniDramaList = <MiniDramaList>[];
      json['miniDramaList'].forEach((v) {
        miniDramaList?.add(MiniDramaList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (mediaList != null) {
      data['mediaList'] = mediaList?.map((v) => v.toJson()).toList();
    }
    if (miniDramaList != null) {
      data['miniDramaList'] = miniDramaList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MediaList {
  List<ActorV2>? actorV2;
  String? actors;
  String? addedTime;
  String? bango;
  int? comments;
  Companies? companies;
  String? coverImg;
  String? createdAt;
  String? desc;
  int? dislikes;
  int? episodeId;
  int? episodeNum;
  int? favs;
  int? height;
  int? id;
  bool? isBuy;
  bool? isDislike;
  bool? isLike;
  bool? isR18;
  bool? isUpNotify;
  int? likes;
  int? movieDiscount;
  int? payType;
  int? playTime;
  int? populars;
  int? preTime;
  String? preVideoUrl;
  int? price;
  Publisher? publisher;
  int? rankChange;
  int? sell;
  List<String>? tags;
  String? title;
  String? upcomingDate;
  int? videoType;
  String? videoUrl;
  int? watchTimes;
  int? width;

  MediaList(
      {this.actorV2,
      this.actors,
      this.addedTime,
      this.bango,
      this.comments,
      this.companies,
      this.coverImg,
      this.createdAt,
      this.desc,
      this.dislikes,
      this.episodeId,
      this.episodeNum,
      this.favs,
      this.height,
      this.id,
      this.isBuy,
      this.isDislike,
      this.isLike,
      this.isR18,
      this.isUpNotify,
      this.likes,
      this.movieDiscount,
      this.payType,
      this.playTime,
      this.populars,
      this.preTime,
      this.preVideoUrl,
      this.price,
      this.publisher,
      this.rankChange,
      this.sell,
      this.tags,
      this.title,
      this.upcomingDate,
      this.videoType,
      this.videoUrl,
      this.watchTimes,
      this.width});

  MediaList.fromJson(Map<String, dynamic> json) {
    if (json['actorV2'] != null) {
      actorV2 = <ActorV2>[];
      json['actorV2'].forEach((v) {
        actorV2?.add(ActorV2.fromJson(v));
      });
    }
    actors = json['actors'];
    addedTime = json['addedTime'];
    bango = json['bango'];
    comments = json['comments'];
    companies = json['companies'] != null
        ? Companies?.fromJson(json['companies'])
        : null;
    coverImg = json['coverImg'];
    createdAt = json['createdAt'];
    desc = json['desc'];
    dislikes = json['dislikes'];
    episodeId = json['episodeId'];
    episodeNum = json['episodeNum'];
    favs = json['favs'];
    height = json['height'];
    id = json['id'];
    isBuy = json['isBuy'];
    isDislike = json['isDislike'];
    isLike = json['isLike'];
    isR18 = json['isR18'];
    isUpNotify = json['isUpNotify'];
    likes = json['likes'];
    movieDiscount = json['movieDiscount'];
    payType = json['payType'];
    playTime = json['playTime'];
    populars = json['populars'];
    preTime = json['preTime'];
    preVideoUrl = json['preVideoUrl'];
    price = json['price'];
    publisher = json['publisher'] != null
        ? Publisher?.fromJson(json['publisher'])
        : null;
    rankChange = json['rankChange'];
    sell = json['sell'];
    tags = json['tags'].cast<String>();
    title = json['title'];
    upcomingDate = json['upcomingDate'];
    videoType = json['videoType'];
    videoUrl = json['videoUrl'];
    watchTimes = json['watchTimes'];
    width = json['width'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (actorV2 != null) {
      data['actorV2'] = actorV2?.map((v) => v.toJson()).toList();
    }
    data['actors'] = actors;
    data['addedTime'] = addedTime;
    data['bango'] = bango;
    data['comments'] = comments;
    if (companies != null) {
      data['companies'] = companies?.toJson();
    }
    data['coverImg'] = coverImg;
    data['createdAt'] = createdAt;
    data['desc'] = desc;
    data['dislikes'] = dislikes;
    data['episodeId'] = episodeId;
    data['episodeNum'] = episodeNum;
    data['favs'] = favs;
    data['height'] = height;
    data['id'] = id;
    data['isBuy'] = isBuy;
    data['isDislike'] = isDislike;
    data['isLike'] = isLike;
    data['isR18'] = isR18;
    data['isUpNotify'] = isUpNotify;
    data['likes'] = likes;
    data['movieDiscount'] = movieDiscount;
    data['payType'] = payType;
    data['playTime'] = playTime;
    data['populars'] = populars;
    data['preTime'] = preTime;
    data['preVideoUrl'] = preVideoUrl;
    data['price'] = price;
    if (publisher != null) {
      data['publisher'] = publisher?.toJson();
    }
    data['rankChange'] = rankChange;
    data['sell'] = sell;
    data['tags'] = tags;
    data['title'] = title;
    data['upcomingDate'] = upcomingDate;
    data['videoType'] = videoType;
    data['videoUrl'] = videoUrl;
    data['watchTimes'] = watchTimes;
    data['width'] = width;
    return data;
  }
}

class ActorV2 {
  String? avatar;
  String? background;
  int? count;
  String? country;
  String? desc;
  int? id;
  String? name;
  int? rank;
  bool? recomment;
  int? watchCount;

  ActorV2(
      {this.avatar,
      this.background,
      this.count,
      this.country,
      this.desc,
      this.id,
      this.name,
      this.rank,
      this.recomment,
      this.watchCount});

  ActorV2.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    background = json['background'];
    count = json['count'];
    country = json['country'];
    desc = json['desc'];
    id = json['id'];
    name = json['name'];
    rank = json['rank'];
    recomment = json['recomment'];
    watchCount = json['watchCount'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['background'] = background;
    data['count'] = count;
    data['country'] = country;
    data['desc'] = desc;
    data['id'] = id;
    data['name'] = name;
    data['rank'] = rank;
    data['recomment'] = recomment;
    data['watchCount'] = watchCount;
    return data;
  }
}

class Companies {
  String? background;
  int? contentType;
  int? count;
  String? cover;
  String? desc;
  int? id;
  String? name;
  int? rank;

  Companies(
      {this.background,
      this.contentType,
      this.count,
      this.cover,
      this.desc,
      this.id,
      this.name,
      this.rank});

  Companies.fromJson(Map<String, dynamic> json) {
    background = json['background'];
    contentType = json['contentType'];
    count = json['count'];
    cover = json['cover'];
    desc = json['desc'];
    id = json['id'];
    name = json['name'];
    rank = json['rank'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['background'] = background;
    data['contentType'] = contentType;
    data['count'] = count;
    data['cover'] = cover;
    data['desc'] = desc;
    data['id'] = id;
    data['name'] = name;
    data['rank'] = rank;
    return data;
  }
}

class Publisher {
  String? avatar;
  int? cares;
  String? desc;
  int? fans;
  int? id;
  bool? isFollow;
  int? level;
  int? likes;
  String? name;

  Publisher(
      {this.avatar,
      this.cares,
      this.desc,
      this.fans,
      this.id,
      this.isFollow,
      this.level,
      this.likes,
      this.name});

  Publisher.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    cares = json['cares'];
    desc = json['desc'];
    fans = json['fans'];
    id = json['id'];
    isFollow = json['isFollow'];
    level = json['level'];
    likes = json['likes'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['cares'] = cares;
    data['desc'] = desc;
    data['fans'] = fans;
    data['id'] = id;
    data['isFollow'] = isFollow;
    data['level'] = level;
    data['likes'] = likes;
    data['name'] = name;
    return data;
  }
}

class MiniDramaList {
  String? addedTime;
  int? comments;
  int? contentStatus;
  String? country;
  String? coverImg;
  String? desc;
  int? dislikes;
  int? epiCount;
  List<Episodes>? episodes;
  int? favs;
  MediaList? firstEpisode;
  List<String>? genres;
  int? id;
  bool? isBuy;
  bool? isDislike;
  bool? isFav;
  bool? isLike;
  bool? isR18;
  bool? isUpcomingNotify;
  String? lastEpiAddedAt;
  int? lastEpiNo;
  String? lastEpiSt;
  int? likes;
  int? populars;
  Publisher? publisher;
  int? rank;
  int? sells;
  String? title;
  String? upcomingDate;
  int? userLastEpiNo;
  String? userLastEpiSt;
  String? userLastEpiWatchAt;
  int? watchTimes;
  int? year;

  MiniDramaList(
      {this.addedTime,
      this.comments,
      this.contentStatus,
      this.country,
      this.coverImg,
      this.desc,
      this.dislikes,
      this.epiCount,
      this.episodes,
      this.favs,
      this.firstEpisode,
      this.genres,
      this.id,
      this.isBuy,
      this.isDislike,
      this.isFav,
      this.isLike,
      this.isR18,
      this.isUpcomingNotify,
      this.lastEpiAddedAt,
      this.lastEpiNo,
      this.lastEpiSt,
      this.likes,
      this.populars,
      this.publisher,
      this.rank,
      this.sells,
      this.title,
      this.upcomingDate,
      this.userLastEpiNo,
      this.userLastEpiSt,
      this.userLastEpiWatchAt,
      this.watchTimes,
      this.year});

  MiniDramaList.fromJson(Map<String, dynamic> json) {
    addedTime = json['addedTime'];
    comments = json['comments'];
    contentStatus = json['contentStatus'];
    country = json['country'];
    coverImg = json['coverImg'];
    desc = json['desc'];
    dislikes = json['dislikes'];
    epiCount = json['epiCount'];
    if (json['episodes'] != null) {
      episodes = <Episodes>[];
      json['episodes'].forEach((v) {
        episodes?.add(Episodes.fromJson(v));
      });
    }
    favs = json['favs'];
    firstEpisode = json['firstEpisode'] != null
        ? MediaList?.fromJson(json['firstEpisode'])
        : null;
    genres = json['genres'].cast<String>();
    id = json['id'];
    isBuy = json['isBuy'];
    isDislike = json['isDislike'];
    isFav = json['isFav'];
    isLike = json['isLike'];
    isR18 = json['isR18'];
    isUpcomingNotify = json['isUpcomingNotify'];
    lastEpiAddedAt = json['lastEpiAddedAt'];
    lastEpiNo = json['lastEpiNo'];
    lastEpiSt = json['lastEpiSt'];
    likes = json['likes'];
    populars = json['populars'];
    publisher = json['publisher'] != null
        ? Publisher?.fromJson(json['publisher'])
        : null;
    rank = json['rank'];
    sells = json['sells'];
    title = json['title'];
    upcomingDate = json['upcomingDate'];
    userLastEpiNo = json['userLastEpiNo'];
    userLastEpiSt = json['userLastEpiSt'];
    userLastEpiWatchAt = json['userLastEpiWatchAt'];
    watchTimes = json['watchTimes'];
    year = json['year'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['addedTime'] = addedTime;
    data['comments'] = comments;
    data['contentStatus'] = contentStatus;
    data['country'] = country;
    data['coverImg'] = coverImg;
    data['desc'] = desc;
    data['dislikes'] = dislikes;
    data['epiCount'] = epiCount;
    if (episodes != null) {
      data['episodes'] = episodes?.map((v) => v.toJson()).toList();
    }
    data['favs'] = favs;
    if (firstEpisode != null) {
      data['firstEpisode'] = firstEpisode?.toJson();
    }
    data['genres'] = genres;
    data['id'] = id;
    data['isBuy'] = isBuy;
    data['isDislike'] = isDislike;
    data['isFav'] = isFav;
    data['isLike'] = isLike;
    data['isR18'] = isR18;
    data['isUpcomingNotify'] = isUpcomingNotify;
    data['lastEpiAddedAt'] = lastEpiAddedAt;
    data['lastEpiNo'] = lastEpiNo;
    data['lastEpiSt'] = lastEpiSt;
    data['likes'] = likes;
    data['populars'] = populars;
    if (publisher != null) {
      data['publisher'] = publisher?.toJson();
    }
    data['rank'] = rank;
    data['sells'] = sells;
    data['title'] = title;
    data['upcomingDate'] = upcomingDate;
    data['userLastEpiNo'] = userLastEpiNo;
    data['userLastEpiSt'] = userLastEpiSt;
    data['userLastEpiWatchAt'] = userLastEpiWatchAt;
    data['watchTimes'] = watchTimes;
    data['year'] = year;
    return data;
  }
}

class Episodes {
  int? epiNo;
  String? epiSt;
  int? mediaId;
  bool? playable;

  Episodes({this.epiNo, this.epiSt, this.mediaId, this.playable});

  Episodes.fromJson(Map<String, dynamic> json) {
    epiNo = json['epiNo'];
    epiSt = json['epiSt'];
    mediaId = json['mediaId'];
    playable = json['playable'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['epiNo'] = epiNo;
    data['epiSt'] = epiSt;
    data['mediaId'] = mediaId;
    data['playable'] = playable;
    return data;
  }
}
