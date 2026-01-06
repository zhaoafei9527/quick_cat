import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

// 🌎 Project imports:
import 'package:quick_cat_client/utils/text_util.dart';

// 延迟初始化实例
late final LightModel lightKV;

class LightModel {
  // 定义一个盒子名，这将是你的数据存储的名称
  static const _boxName = 'lightKVBox';

  // 延迟加载盒子
  late final Future<Box> _boxFuture;

  LightModel() {
    _boxFuture = Hive.openBox(_boxName);
  }

  Future<Box> get _box async => _boxFuture;

  // 静态初始化方法
  static Future<void> init(String appDocumentPath) async {
    Hive.init(appDocumentPath);
    // 在Hive初始化完成后再创建实例
    lightKV = LightModel();
  }

  // 注意：Hive使用异步方法进行大部分操作
  Future<bool> remove(String key) async {
    if (TextUtil.isEmpty(key)) return false;
    final box = await _box;
    await box.delete(key);
    return true; // Hive没有直接返回是否成功的方法，但抛出异常会表示失败
  }

  Future<String?> getString(String key) async {
    if (TextUtil.isEmpty(key)) return null;
    final box = await _box;
    return box.get(key, defaultValue: null);
  }

  Future<bool> setString(String key, String value) async {
    if (TextUtil.isEmpty(key)) return false;
    final box = await _box;
    await box.put(key, value);
    return true;
  }

  Future<int?> getInt(String key) async {
    if (TextUtil.isEmpty(key)) return null;
    final box = await _box;
    return box.get(key, defaultValue: null);
  }

  Future<bool> setInt(String key, int value) async {
    if (TextUtil.isEmpty(key)) return false;
    final box = await _box;
    await box.put(key, value);
    return true;
  }

  Future<bool?> getBool(String key) async {
    if (TextUtil.isEmpty(key)) return null;
    final box = await _box;
    return box.get(key, defaultValue: null);
  }

  Future<bool> setBool(String key, bool value) async {
    if (TextUtil.isEmpty(key)) return false;
    final box = await _box;
    await box.put(key, value);
    return true;
  }

  Future<List<String>> getStringList(String key) async {
    if (TextUtil.isEmpty(key)) return [];
    final box = await _box;
    // Hive没有直接的List<String>存储，需要自己处理
    final list = box.get(key, defaultValue: <String>[]);
    return list.cast<String>();
  }

  Future<bool> setStringList(String key, List<String> list) async {
    if (TextUtil.isEmpty(key)) return false;
    final box = await _box;
    await box.put(key, list);
    return true;
  }

  Future<bool> clear() async {
    final box = await _box;
    await box.clear();
    return true;
  }
}
