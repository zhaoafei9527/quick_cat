// 🎯 Dart imports:
import 'dart:convert';
import 'dart:typed_data';

// 📦 Package imports:
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart' hide Response;

// 🌎 Project imports:
import 'package:quick_cat_client/conf/config.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:quick_cat_client/utils/text_util.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import '../HttpRequester.dart';
import '../http_requester.dart';
import 'base_resp_bean.dart';
import 'code.dart';

/// 默认解码器
class DefaultNetDecoder extends NetDecoder {
  /// 单例对象
  static final DefaultNetDecoder _instance = DefaultNetDecoder._internal();

  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  DefaultNetDecoder._internal();

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory DefaultNetDecoder.getInstance() => _instance;

  @override
  K decode<T, K>({required Response<dynamic> response, T? decodeType}) {
    BaseRespBean? baseResp;

    if (response.data is Map) {
      baseResp = BaseRespBean.fromJson(response.data);
    } else if (response.data is String) {
      baseResp = BaseRespBean.fromJson(json.decode(response.data));
    } else {
      return response.data as K;
    }

    int? code = baseResp.code;
    String? tip = baseResp.tip;

    if (code == Code.SUCCESS) {
      dynamic data = baseResp.data;
      if (baseResp.hash ?? false) {
        var decryptData = aesDecryptEx(data, AppConfig.encryptKey);
        if (decryptData == "") {
          return baseResp.data as K;
        }
        data = json.decode(decryptData);
      }
      baseResp.data = data;
      if (TextUtil.isNotEmpty(baseResp.time ?? "")) {
        NetWorkCreator.setServerTime(baseResp.time ?? "");
      }
    } else {
      if (code == Code.FORCE_UPDATE_VERSION && decodeType != null) {
        showToast(msg: "toast_text10".tr);
      } else if (code == Code.ACCOUNT_INVISIBLE && decodeType != null) {
        // 账户被封禁了 todo 弹窗提示账号被封禁 联系管理
      } else if (code == Code.TOKEN_ABNORMAL && decodeType != null) {
        showToast(msg: "toast_text11".tr);
      } else {
        showToast(msg: "请求出现错误，错误码：$code，提示信息：$tip");
      }
      if (decodeType is BaseNetModel) {
        return decodeType.fromJson(baseResp.toJson()) as K;
      } else {
        return {"code": code, "tip": tip} as K;
      }
    }

    if (decodeType is BaseNetModel) {
      if (baseResp.data is List) {
        List<T> dataList = <T>[];
        for (int i = 0; i < baseResp.data.length; i++) {
          dataList.add(decodeType.fromJson(baseResp.data[i]));
        }
        return dataList as K;
      } else {
        var model = decodeType.fromJson(baseResp.data) as K;
        return model;
      }
    } else {
      return baseResp.data as K;
    }
  }
}

/// 新版本解密
String aesDecryptEx(String cipher, String key) {
  try {
    final t1 = DateTime.now();
    const nonceLen = 12;
    final cipherBytes = base64Decode(cipher);
    final nonce = cipherBytes.sublist(0, nonceLen);
    final largeShaRaw = <int>[...utf8.encode(key), ...nonce];
    final largeShaRawMid = largeShaRaw.length ~/ 2;
    final msgKeyLarge = sha256.convert(largeShaRaw).bytes;
    final msgKey = msgKeyLarge.sublist(8, 24);

    final shaRawA = <int>[...msgKey, ...largeShaRaw.sublist(0, largeShaRawMid)];
    final sha256a = sha256.convert(shaRawA).bytes;

    final shaRawB = <int>[...largeShaRaw.sublist(largeShaRawMid), ...msgKey];
    final sha256b = sha256.convert(shaRawB).bytes;

    final aesKey = <int>[
      ...sha256a.sublist(0, 8),
      ...sha256b.sublist(8, 24),
      ...sha256a.sublist(24)
    ];

    final aesIV = <int>[
      ...sha256b.sublist(0, 4),
      ...sha256a.sublist(12, 20),
      ...sha256b.sublist(28)
    ];

    final encrypter =
        Encrypter(AES(Key(Uint8List.fromList(aesKey)), mode: AESMode.cbc));
    final decrypted = encrypter.decryptBytes(
        Encrypted(cipherBytes.sublist(nonceLen)),
        iv: IV(Uint8List.fromList(aesIV)));
    final text = const Utf8Decoder().convert(decrypted);
    final t2 = DateTime.now();
    log.i("deEncrypt_data",
        "deEncrypt cost time==========>:${t2.difference(t1).inMilliseconds}ms");
    return text;
  } catch (error) {
    print("解密失败，客服端非法进入。");
    return "";
  }
}
