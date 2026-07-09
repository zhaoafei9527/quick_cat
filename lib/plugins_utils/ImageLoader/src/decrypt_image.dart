import 'dart:convert';
import 'dart:typed_data';

/// hex 旧方案魔数头
final Uint8List kEncryptedImageHead = Uint8List.fromList(
  [0x88, 0xA8, 0x30, 0xCB, 0x10, 0x76],
);

/// dex 新方案魔数头（/res/v3 读图统一返回）
final Uint8List dexMagic = Uint8List.fromList([
  0x44,
  0x45,
  0x58,
  0x01,
  0xA3,
  0x7F,
]);

const int _headLen = 6;

bool _hasMagic(Uint8List data, Uint8List magic) {
  if (data.length < magic.length) return false;
  for (var i = 0; i < magic.length; i++) {
    if (data[i] != magic[i]) return false;
  }
  return true;
}

/// 是否为 /res/v3 或 /v3 新版读图链接
bool isV3ImageRequest(String input) {
  var p = input.trim();
  if (p.isEmpty) return false;
  if (p.startsWith('http://') || p.startsWith('https://')) {
    p = Uri.parse(p).path;
  }
  if (!p.startsWith('/')) p = '/$p';
  return RegExp(r'/(?:res/)?v3(/|$)').hasMatch(p);
}

/// 解析 S3 存储路径（hex/image/... 或 dex/image/...）
String resolveDecryptPath(String input, {String? override}) {
  final raw = (override != null && override.isNotEmpty) ? override : input;
  var p = raw.trim();
  if (p.isEmpty) return p;

  if (p.startsWith('http://') || p.startsWith('https://')) {
    p = Uri.parse(p).path;
  }
  p = p.replaceFirst(RegExp(r'^/+'), '');
  p = p.replaceFirst(RegExp(r'^(?:res/)?v3/'), '');

  if (p.startsWith('hex/image/') || p.startsWith('dex/image/')) {
    return p;
  }

  for (final prefix in ['hex/image/', 'dex/image/']) {
    final idx = p.indexOf(prefix);
    if (idx >= 0) return p.substring(idx);
  }
  return p;
}

/// hex/image/... -> dex/image/...（与服务端 toDexStorageKey 一致）
String toDexStorageKey(String storageKey) {
  if (storageKey.startsWith('hex/image/')) {
    return 'dex/image/${storageKey.substring('hex/image/'.length)}';
  }
  if (storageKey.startsWith('dex/image/')) {
    return storageKey;
  }
  if (storageKey.startsWith('image/')) {
    return 'dex/${storageKey.substring('image/'.length)}';
  }
  return storageKey.replaceFirst(RegExp(r'^hex/'), 'dex/');
}

String _extractDexKeyMaterial(String path) {
  final normalized = resolveDecryptPath(path);
  final parts = normalized.split('/');
  if (parts.length >= 7 && parts[0] == 'dex' && parts[1] == 'image') {
    final filename = parts[6];
    final dot = filename.indexOf('.');
    final hexHash = dot >= 0 ? filename.substring(0, dot) : filename;
    return '${parts[2]}/${parts[3]}/${parts[4]}/${parts[5]}/$hexHash';
  }
  return normalized;
}

int _fnv1a32(String str) {
  int hash = 0x811c9dc5;
  for (int i = 0; i < str.length; i++) {
    hash ^= str.codeUnitAt(i);
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}

int _xorshift32(int state) {
  state = (state ^ ((state << 13) & 0xFFFFFFFF)) & 0xFFFFFFFF;
  state = (state ^ (state >>> 17)) & 0xFFFFFFFF;
  state = (state ^ ((state << 5) & 0xFFFFFFFF)) & 0xFFFFFFFF;
  return state;
}

Uint8List _xorWithKeystream(Uint8List data, String keyMaterial) {
  final out = Uint8List(data.length);
  int state = _fnv1a32(keyMaterial);
  for (int i = 0; i < data.length; i++) {
    if (i % 4 == 0) state = _xorshift32(state);
    out[i] = data[i] ^ ((state >> ((i % 4) * 8)) & 0xFF);
  }
  return out;
}

bool _isValidImageHeader(Uint8List bytes) {
  if (bytes.length < 3) return false;
  if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return true;
  }
  if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true;
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return true;
  }
  return false;
}

String? _tailPathFromBytes(Uint8List bytes) {
  if (bytes.length <= _headLen) return null;
  final tailText = utf8.decode(bytes.sublist(_headLen), allowMalformed: true);
  final match = RegExp(r'(?:hex|dex)/image/[\w/]+\.\w+$').firstMatch(tailText);
  return match?.group(0);
}

List<String> _decryptPathCandidates(String path, Uint8List bytes) {
  final seen = <String>{};
  final list = <String>[];

  void add(String? p) {
    if (p == null || p.isEmpty || !seen.add(p)) return;
    list.add(p);
  }

  add(resolveDecryptPath(path));
  add(_tailPathFromBytes(bytes));
  final normalized = path.trim();
  if (normalized.startsWith('/')) {
    add(normalized.replaceFirst(RegExp(r'^/+'), ''));
  }
  return list;
}

/// 旧版 hex：去头 + 去尾 path
Uint8List _decryptHexImage(Uint8List bytes, String path) {
  if (!_hasMagic(bytes, kEncryptedImageHead)) return bytes;

  for (final candidate in _decryptPathCandidates(path, bytes)) {
    final tailLen = utf8.encode(candidate).length;
    final end = bytes.length - tailLen;
    if (end <= _headLen) continue;
    final result = bytes.sublist(_headLen, end);
    if (_isValidImageHeader(result)) return result;
  }

  return bytes.sublist(_headLen);
}

/// 新版 dex：路径派生密钥流 XOR
Uint8List _decryptDexImage(Uint8List bytes, String dexPath) {
  if (!_hasMagic(bytes, dexMagic)) return bytes;
  return _xorWithKeystream(
    bytes.sublist(dexMagic.length),
    _extractDexKeyMaterial(dexPath),
  );
}

/// 同步解密
///
/// [path] API 相对路径或完整下载 URL。
/// [url] 完整下载 URL，用于识别 /res/v3。
Uint8List decryptImageSync(
  Uint8List imgBytes,
  String path, {
  String? url,
}) {
  if (imgBytes.isEmpty) return imgBytes;

  final isV3 = isV3ImageRequest(url ?? '') || isV3ImageRequest(path);
  final storageKey = resolveDecryptPath(path);

  // /res/v3：服务端统一返回 dex 密文，密钥路径用 dex/image/...
  if (isV3) {
    final dexKey = toDexStorageKey(storageKey);
    if (_hasMagic(imgBytes, dexMagic)) {
      return _decryptDexImage(imgBytes, dexKey);
    }
    // 兜底：v3 下若仍收到 hex 密文，走旧解密。
    if (_hasMagic(imgBytes, kEncryptedImageHead)) {
      return _decryptHexImage(imgBytes, storageKey);
    }
    return imgBytes;
  }

  // 旧版 /res：按魔数自动识别。
  if (_hasMagic(imgBytes, dexMagic)) {
    return _decryptDexImage(imgBytes, toDexStorageKey(storageKey));
  }
  return _decryptHexImage(imgBytes, path);
}

/// 解密网络图片字节
///
/// [params] 需包含：
/// - `imgBytes`：图片字节
/// - `path`：API 相对路径或完整下载 URL
/// - `url`（可选）：完整下载 URL，含 /res/v3 时走 dex 解密
Future<Uint8List> decryptImage(Map<String, dynamic> params) async {
  final Uint8List imgBytes = params['imgBytes'] as Uint8List;
  final String path = params['path'] as String;
  final String? url = params['url'] as String?;

  return decryptImageSync(imgBytes, path, url: url);
}

@Deprecated('Use resolveDecryptPath')
String normalizeDecryptPath(String path) => resolveDecryptPath(path);
