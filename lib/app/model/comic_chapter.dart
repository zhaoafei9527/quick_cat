import 'package:acgn_client/app/model/comic_info_model.dart';
import 'package:acgn_client/app/model/home/topic_list_model.dart';
import 'package:acgn_client/plugins_utils/HttpRequester/src/base_net_model.dart';

class ChapterDetails extends BaseNetModel {
  @override
  ChapterDetails fromJson(Map<String, dynamic> json) {
    return ChapterDetails.fromJson(json);
  }

  final int? count;
  final int? num;
  final int? id;
  final List<String>? author;
  final List<ChapterPicItem>? chapterPicItem;
  final List<Chapter>? chapterInfos;
  final String? title;
  final String? content;

  ChapterDetails({
    this.count,
    this.num,
    this.id,
    this.author,
    this.chapterPicItem,
    this.chapterInfos,
    this.title,
    this.content,
  });

  factory ChapterDetails.fromJson(Map<String, dynamic> json) {
    return ChapterDetails(
        count: json['Count'] as int?,
        num: json['Num'] as int?,
        id: json['id'] as int?,
        content: json['content'] as String?,
        author: (json['author'] as List?)?.cast<String>(),
        chapterPicItem: json['chapter'] != null
            ? (json['chapter'] as List)
                .map((e) => ChapterPicItem.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        chapterInfos: json['chapterInfos'] != null
            ? (json['chapterInfos'] as List)
                .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        title: json['title'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {
      'Count': count,
      'Num': num,
      'content': content,
      'id': id,
      'author': author,
      'chapter': chapterPicItem?.map((e) => e.toJson()).toList(),
      'chapterInfos': chapterInfos?.map((e) => e.toJson()).toList(),
      'title': title
    };
  }
}

class ChapterPicItem {
  final List<ComicBarrageInfo>? barrage;
  final int? chapterId;
  final String? comicsPic;
  final int? high;
  final int? width;
  final String? adsId;
  final bool? isAds;
  final String? adsUrl;

  ChapterPicItem({
    this.barrage,
    this.chapterId,
    this.comicsPic,
    this.high,
    this.width,
    this.isAds,
    this.adsUrl,
    this.adsId,
  });

  factory ChapterPicItem.fromJson(Map<String, dynamic> json) {
    return ChapterPicItem(
      barrage: json['barrage'] != null
          ? (json['barrage'] as List)
              .map((e) => ComicBarrageInfo.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      chapterId: json['chapterId'] as int?,
      comicsPic: json['comicsPic'] as String?,
      high: json['high'] as int?,
      width: json['width'] as int?,
      isAds: json['isAds'] as bool?,
      adsUrl: json['adsUrl'] as String?,
      adsId: json['adsId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barrage': barrage?.map((e) => e.toJson()).toList(),
      'chapterId': chapterId,
      'comicsPic': comicsPic,
      'high': high,
      'width': width,
    };
  }
}

class ComicBarrageInfo {
  final int? chapterId;
  final String? color;
  final String? content;
  final String? createdAt;
  final int? id;
  final int? idx;
  final Pos? pos;

  ComicBarrageInfo({
    this.chapterId,
    this.color,
    this.content,
    this.createdAt,
    this.id,
    this.idx,
    this.pos,
  });

  factory ComicBarrageInfo.fromJson(Map<String, dynamic> json) {
    return ComicBarrageInfo(
      chapterId: json['chapterId'] as int?,
      color: json['color'] as String?,
      content: json['content'] as String?,
      createdAt: json['createdAt'] as String?,
      id: json['id'] as int?,
      idx: json['idx'] as int?,
      pos: json['pos'] != null
          ? Pos.fromJson(json['pos'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'color': color,
      'content': content,
      'createdAt': createdAt,
      'id': id,
      'idx': idx,
      'pos': pos?.toJson(),
    };
  }
}

class Pos {
  final int? x;
  final int? y;

  Pos({
    this.x,
    this.y,
  });

  factory Pos.fromJson(Map<String, dynamic> json) {
    return Pos(
      x: json['x'] as int?,
      y: json['y'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}

// 漫画阅读记录单条信息
class ComicRecordInfo {
  final int? comicId;
  final int? chapterId;
  final MediaInfo? comicInfo;
  final String? updateAt;
  final int? readNum;
  final int? pageCount;

  ComicRecordInfo(
      {this.comicId,
      this.chapterId,
      this.updateAt,
      this.comicInfo,
      this.pageCount,
      this.readNum});

  factory ComicRecordInfo.fromJson(Map<String, dynamic> json) {
    return ComicRecordInfo(
      comicId: json['comicId'] as int?,
      chapterId: json['chapterId'] as int?,
      updateAt: json['updateAt'] as String?,
      comicInfo: json['comicInfo'] != null
          ? MediaInfo.fromJson(json['comicInfo'] as Map<String, dynamic>)
          : null,
      pageCount: json['pageCount'] as int?,
      readNum: json['readNum'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comicId': comicId,
      'chapterId': chapterId,
      'updateAt': updateAt,
      'comicInfo': comicInfo?.toJson(),
      'pageCount': pageCount,
      'readNum': readNum,
    };
  }
}
