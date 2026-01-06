// 🎯 Dart imports:

// 📦 Package imports:

main() {

  String reversedBase64WithQuotes =
      "\"QXi02bj5yav9mYkFWZy5WY1lXax5SawF2LvozcwRHdoJyW==\"";

// 移除开头和结尾的引号
  String reversedBase64 =
      reversedBase64WithQuotes.replaceAll(RegExp(r'^"|"$'), '');

// 步骤 3: 反转 Base64 字符串
  String originalBase64 = reversedBase64.split('').reversed.join('');

// // 步骤 4: Base64 解码
//   List<int> decodedBytes = base64Decode(originalBase64);
  print(originalBase64);

//
// // 将字节转换为字符串
// String decodedJson = utf8.decode(originalBase64);
}
