// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

// 🐦 Flutter imports:

// 📦 Package imports:

// 🌎 Project imports:
import 'package:quick_cat_client/utils/isolate_manager.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';

List<Uint8List> _featuresList = [
  Uint8List.fromList([0xff, 0xd8, 0xff]), //jpg,jpeg
  Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]), //png
  Uint8List.fromList([0x47, 0x49, 0x46]), //gif
];

int _encryptedLen = 100; //加密图片的数据长度
// Uint8List _decryptKey = Uint8List.fromList('2019ysapp7527'.codeUnits); //加密key
Uint8List _decryptKey =
    Uint8List.fromList('2024yehuaapp9527'.codeUnits); //加密key

bool _isEncryptedImage(Uint8List imgBytes) {
  bool isDecrypted = false;
  int featuresLen = _featuresList.length;
  for (int i = 0; i < featuresLen; i++) {
    isDecrypted = false;
    for (int j = 0; j < _featuresList[i].length; j++) {
      if (_featuresList[i][j] != imgBytes[j]) {
        isDecrypted = true;
        break;
      }
    }
    if (isDecrypted) {
      continue;
    } else {
      break;
    }
  }

  return isDecrypted;
}

Uint8List xorBaseLength(Uint8List src, Uint8List key, int length) {
  int srcLen = src.length;
  int keyLen = key.length;
  if (length > srcLen || length <= 0) {
    length = srcLen;
  }
  for (var i = 0; i < length; i += keyLen) {
    for (var j = 0; j < keyLen && i + j < length; j++) {
      src[i + j] ^= key[j];
    }
  }
  return src;
}

/// 加密魔数头
const encryptMagicNumber = [0x88, 0xA8, 0x30, 0xCB, 0x10, 0x76];

/// 加密密钥
const ENCRYPT_KEY = 0xA3;

Uint8List xorBaseAllLength(Uint8List src) {
  var index = -1;
  var dest = Uint8List.fromList(
    src
        .map((it) {
          index++;
          if (index < encryptMagicNumber.length &&
              it == encryptMagicNumber[index]) {
            return 0;
          }
          return it ^ ENCRYPT_KEY;
        })
        .where((element) => element != 0)
        .toList(),
  );

  return dest;
}

Uint8List decryptImageOld(Uint8List imgBytes) {
  if (imgBytes.isEmpty) {
    return imgBytes;
  }
  var isAll = false;
  for (var i = 0; i < encryptMagicNumber.length; i++) {
    if (encryptMagicNumber[i] != imgBytes[i]) {
      continue;
    }
    isAll = true;
  }
  if (isAll) {
    imgBytes = xorBaseAllLength(imgBytes);
  } else {
    if (_isEncryptedImage(imgBytes)) {
      imgBytes = xorBaseLength(imgBytes, _decryptKey, _encryptedLen);
    }
  }
  return imgBytes;
}

final iosManager = IsolateManager();

// 启用携程解密图片
Future<Uint8List?> decryptImageWithIsolate(
    Uint8List imgBytes, String path) async {
  Uint8List? data;
  try {
    // final t1 = DateTime.now();
    // log.i("====decryptImageWithIsolate_start","图片$path解密开始");
    if (iosManager.isReady) {
      data = await iosManager.sendRequest({'imgBytes': imgBytes, 'path': path});
    }
    // final t2 = DateTime.now();
    // log.i("decryptImageWithIsolate_end====","图片$path解密结束,耗时：${t2.difference(t1).inMilliseconds}ms");
    return data;
  } catch (e) {
    log.i("_decryptImageWithIsolate", "图片解密失败$e");
    return null;
  }
}

void _decryptImageInIsolate(List<dynamic> params) async {
  SendPort sendPort = params[0];
  Uint8List imgBytes = params[1];
  String path = params[2];
  // 解密操作
  try {
    final result = await decryptImage({'imgBytes': imgBytes, 'path': path});
    sendPort.send(result); // 将解密后的结果发送回主线程
  } catch (e) {
    log.e("decrypt_image", '解密失败: $e');
    sendPort.send(imgBytes); // 如果解密失败，返回原始图片
  }
}

Future<Uint8List> decryptImage(Map<String, dynamic> params) async {
  Uint8List imgBytes = params['imgBytes'];
  String path = params['path'];
  if (imgBytes.isEmpty) {
    return imgBytes;
  }
  var encryptedHead = Uint8List.fromList([0x88, 0xA8, 0x30, 0xCB, 0x10, 0x76]);
  var needEncrypt = false;
  if (imgBytes.length >= encryptedHead.length) {
    bool allMatch = true;
    for (int i = 0; i < encryptedHead.length; i++) {
      if (encryptedHead[i] != imgBytes[i]) {
        allMatch = false;
        break;
      }
    }
    if (allMatch) {
      needEncrypt = true;
    }
  }
  print("needEncrypt===>${needEncrypt}");
  if (needEncrypt) {
    List<int> fileNameList = utf8.encode(path);

    /// 裁剪头部添加的字节数量
    for (var i = 0; i < encryptedHead.length; i++) {
      List<int> mutableList = imgBytes.toList();
      mutableList.remove(encryptedHead[i]);
      imgBytes = Uint8List.fromList(mutableList);
    }
    // 裁剪尾部添加的字节数量
    imgBytes.sublist(0, imgBytes.length - fileNameList.length);
  }
  return imgBytes;
}
