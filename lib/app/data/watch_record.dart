import 'dart:convert';

import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/model/home/topic_list_model.dart';
import 'package:acgn_client/app/model/post_list_model.dart';
import 'package:acgn_client/conf/config.dart';
import 'package:acgn_client/utils/light_model.dart';
import 'package:acgn_client/utils/logger_utils.dart';

class WatchRecord {
  static const String storageRelease = "_key_watch_record_";
  static const String storageDebug = "_key_watch_record_debug_";

  static const int maxRecordCount = 200;
  static Map<MediaType, dynamic> records = {};

  // 添加观看记录
  static Future<void> addWatchRecord(dynamic media, MediaType type) async {
    // 确定存储的键名
    String storage = AppConfig.DEBUG ? storageDebug : storageRelease;
    String? dataStr = await lightKV.getString(storage);
    // 如果没有记录，初始化一个空的记录

    if (dataStr == null || dataStr.isEmpty) records = {};
    // 解析已有的记录
    records = parseMediaMap(dataStr);
    if (records[type] == null) {
      records[type] = type == MediaType.post ? <PostBrief>[] : <MediaInfo>[];
    }

    // 检查记录是否已存在
    bool exists = false;
    if (type == MediaType.post) {
      List<PostBrief> postList = records[type] as List<PostBrief>;
      exists = postList.any((e) => e.base?.id == (media as PostBrief).base?.id);
    } else {
      List<MediaInfo> mediaList = records[type] as List<MediaInfo>;
      exists = mediaList.any((e) => e.id == (media as MediaInfo).id);
    }

    if (exists) {
      log.i("add_watch_record",
          '记录已存在，覆盖资源: ${type == MediaType.post ? (media as PostBrief).base?.id : (media as MediaInfo).id}');
      // 如果记录已存在，覆盖资源
      if (type == MediaType.post) {
        List<PostBrief> postList = records[type] as List<PostBrief>;
        postList
            .removeWhere((e) => e.base?.id == (media as PostBrief).base?.id);
        postList.add(media);
      } else {
        List<MediaInfo> mediaList = records[type] as List<MediaInfo>;
        mediaList.removeWhere((e) => e.id == (media as MediaInfo).id);
        mediaList.add(media);
      }
    } else {
      log.i("add_watch_record",
          '添加新的记录: ${type == MediaType.post ? (media as PostBrief).base?.id : (media as MediaInfo).id}');
      // 如果记录不存在，检查是否超过最大记录数
      if (records[type]!.length >= maxRecordCount) {
        // 如果超过最大记录数，删除最旧的记录
        records[type]!.removeAt(0);
      }
      // 添加新的记录
      records[type]!.add(media);
    }

    // 将更新后的记录转换为JSON字符串
    String updatedDataStr = json.encode(
      records.map((key, value) {
        if (key == MediaType.post) {
          List<PostBrief> postList = value as List<PostBrief>;
          return MapEntry(key.name, postList.map((e) => e.toJson()).toList());
        } else {
          List<MediaInfo> mediaList = value as List<MediaInfo>;
          return MapEntry(key.name, mediaList.map((e) => e.toJson()).toList());
        }
      }),
    );
    // 保存更新后的记录
    await lightKV.setString(storage, updatedDataStr);
    log.i("add_watch_record",
        '记录已更新: ${type == MediaType.post ? (media as PostBrief).base?.id : (media as MediaInfo).id}');
  }

  // 获取观看记录
  static Future<dynamic> getWatchRecord(MediaType type) async {
    // 确定存储的键名
    String storage = AppConfig.DEBUG ? storageDebug : storageRelease;
    // if (records.isEmpty) {
    //   log.i("get_watch_record", '记录为空，尝试从存储中获取');
    // }
    // // 从存储中获取记录
    // if (records.isNotEmpty && records[type] != null) {
    //   log.i("get_watch_record", '记录已存在，直接返回');
    //   return records[type]!;
    // }
    // 如果记录为空，从存储中分页获取数据
    // log.i("get_watch_record", '从存储中获取记录');
    String? dataStr = await lightKV.getString(storage);
    // 如果没有记录，返回空列表
    if (dataStr == null || dataStr.isEmpty) {
      log.i("get_watch_record", '没有观看记录');
      return type == MediaType.post ? <PostBrief>[] : <MediaInfo>[];
    }
    records = parseMediaMap(dataStr);
    return records[type] ??
        (type == MediaType.post ? <PostBrief>[] : <MediaInfo>[]);
  }

  // 删除观看记录
  static Future<void> removeWatchRecord(List<int> ids, MediaType type) async {
    // 确定存储的键名
    String storage = AppConfig.DEBUG ? storageDebug : storageRelease;
    String? dataStr = await lightKV.getString(storage);
    if (dataStr == null || dataStr.isEmpty) {
      log.i("remove_watch_record", '没有观看记录');
      return;
    }
    records = parseMediaMap(dataStr);
    if (records[type] != null) {
      // 从对应类型的列表中批量删除记录
      if (type == MediaType.post) {
        List<PostBrief> postList = records[type] as List<PostBrief>;
        postList.removeWhere((e) => ids.contains(e.base?.id));
      } else {
        List<MediaInfo> mediaList = records[type] as List<MediaInfo>;
        mediaList.removeWhere((e) => ids.contains(e.id));
      }
      // 将更新后的记录转换为JSON字符串
      String updatedDataStr = json.encode(
        records.map((key, value) {
          if (key == MediaType.post) {
            List<PostBrief> postList = value as List<PostBrief>;
            return MapEntry(key.name, postList.map((e) => e.toJson()).toList());
          } else {
            List<MediaInfo> mediaList = value as List<MediaInfo>;
            return MapEntry(
                key.name, mediaList.map((e) => e.toJson()).toList());
          }
        }),
      );
      // 保存更新后的记录
      await lightKV.setString(storage, updatedDataStr);
      log.i("remove_watch_record", '记录已删除: $ids');
    } else {
      log.i("remove_watch_record", '没有找到对应类型的记录: ${type.name}');
    }
  }

  static Future<void> clearAllWatchRecord() async {
    // 确定存储的键名
    String storage = AppConfig.DEBUG ? storageDebug : storageRelease;
    await lightKV.remove(storage);
    records.clear();
    log.i("clear_watch_record", '所有观看记录已清除');
  }

  static Map<MediaType, dynamic> parseMediaMap(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) return {};

    // 解析 JSON 字符串
    final decoded = json.decode(jsonString);

    if (decoded is! Map<String, dynamic>) return {};

    final Map<MediaType, dynamic> result = {};
    // 遍历解析后的 Map
    for (final entry in decoded.entries) {
      final mediaTypeStr = entry.key;
      final mediaList = entry.value;

      try {
        // 将字符串转换为 MediaType 枚举
        final mediaType = MediaType.values.firstWhere(
          (e) => e.name == mediaTypeStr,
          orElse: () => throw Exception('未知 MediaType: $mediaTypeStr'),
        );

        if (mediaList is List) {
          if (mediaType == MediaType.post) {
            result[mediaType] = mediaList
                .map((item) => PostBrief.fromJson(item as Map<String, dynamic>))
                .toList()
                .cast<PostBrief>();
          } else {
            result[mediaType] = mediaList
                .map((item) => MediaInfo.fromJson(item as Map<String, dynamic>))
                .toList()
                .cast<MediaInfo>();
          }
        }
      } catch (e) {
        log.i("_parse_media_map", '⚠️ 忽略无效字段: $mediaTypeStr - $e');
      }
    }
    return result.isEmpty ? {} : result;
  }
}
