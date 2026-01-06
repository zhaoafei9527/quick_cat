import 'dart:convert';
import 'dart:io';

import 'package:pinyin/pinyin.dart';

const exclude = [
  "locales.g",
  "firebase",
  "api_res",
  "vpn_client/lib/r.dart",
  "vpn_conf",
  "app_pages",
  "HttpRequester",
  "ImageLoader",
  "lib/conf",
  "lib/app/routes",
  "lib/app/model",
  "lib/app/data/",
  "color_util",
  "base_code_text"
];

main() async {
  final currentDir = Directory.current.path;
  final libDir = Directory('$currentDir/lib');

  await replaceWithBaseCodeText(libDir.path);
}

final regexChinese = RegExp(r'([\u4e00-\u9fa5a-zA-Z]+)');
final importExportPartPattern = RegExp(r'^\s*(?:import|export|part(\s+of)?)\b');
final regex = RegExp("([\"'])"
    "(?:\\\\.|(?!\\1).)*"
    "\\1"
    "(?=(.))");

Future<void> replaceWithBaseCodeText(String directoryPath) async {
  try {
    // 获取当前工作目录
    final currentDir = Directory.current.path;

    // 查找目标文件夹下所有 Dart 文件
    final dir = Directory(directoryPath);
    final dartFiles = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    final Map<String, String> base64Map = {};
    final Map<String, String> originalTextMap = {}; // 保存原始文本
    for (final file in dartFiles) {
      // 用于保存生成的 Base64 编码和变量名
      bool fileModified = false;
      bool containsAny = exclude.any((keyword) => file.path.contains(keyword));
      if (containsAny) continue;
      String content = await file.readAsString();
      final lines = content.split('\n');
      String newContent = "";
      for (var line in lines) {
        String newLine = _deleteConstOption(line);
        if (!importExportPartPattern.hasMatch(newLine)) {
          line = newLine.replaceAllMapped(regex, (match) {
            String originalText = match.group(0) ?? "";
            if (_excludeCanNot(newLine, originalText)) {
              originalText = _removeQuotes(originalText);

              final variableName =
                  _generateVariableName(originalText, base64Map);

              final base64Text = base64Encode(utf8.encode(originalText));
              base64Map[variableName] = base64Text;
              originalTextMap[variableName] = originalText; // 保存原始文本
              fileModified = true;
              return 'BaseCodeText.$variableName';
            } else {
              return originalText;
            }
          });
        }

        newContent += "$line\n";
      }
      content = newContent;
      // 只有当文件有修改时才添加导入语句
      if (fileModified) {
        // 在文件头部添加导入语句（使用绝对路径）
        if (!content.contains('base_code_text.dart')) {
          const baseCodeTextImport =
              "import 'package:acgn_client/base_code_text.dart';";
          content = '$baseCodeTextImport\n$content';
        }

        // 将替换后的内容写回文件
        await file.writeAsString(content);
        print('已处理文件: ${file.path}');
      }
    }
    // 生成 BaseCodeText 类
    await _writeBaseCodeTextClass(base64Map, originalTextMap, directoryPath);
    print('已生成 BaseCodeText 类到 base_code_text.dart');
  } catch (e) {
    print('处理出错: $e');
  }
}

String _removeQuotes(String text) {
  String newText = text;
  if (newText.length >= 2 &&
      ((newText.startsWith('"') && newText.endsWith('"')) ||
          (newText.startsWith("'") && newText.endsWith("'")))) {
    newText = newText.substring(1, text.length - 1);
  }
  return newText;
}

String _deleteConstOption(String line) {
  String newLine = line;
  if (newLine.contains("const TextSpan") ||
      newLine.contains("const Row") ||
      newLine.contains("const Text") ||
      newLine.contains("const BoxDecoration") ||
      newLine.contains("const Column") ||
      newLine.contains("const Padding") ||
      newLine.contains("const Position") ||
      newLine.contains("const Container")) {
    newLine = newLine.replaceAll("const", "");
  }
  return newLine;
}

bool _excludeCanNot(String line, String text) {
  final regex = RegExp(".*[a-zA-z].*");
  return text != '""' &&
      text != "''" &&
      !line.contains("const ") &&
      !(line.contains("String tip =")) &&
      // !(line.contains("\[")) &&
      !(line.contains("]")) &&
      !(line.contains("{")) &&
      !(line.contains("}")) &&
      !(line.contains(".tr")) &&
      !(line.contains("path")) &&
      text.length >= 4 &&
      !((text.contains(":")) && (regex.hasMatch(text))) &&
      !(text.contains("/ ")) &&
      !(text.contains("Network error")) &&
      !(text.contains("httpDecode")) &&
      !(text.contains("CachedImage")) &&
      !(text.contains("-")) &&
      !(text.contains("?")) &&
      !(text.contains("&")) &&
      !(text.contains("\$"));
}

String _generateVariableName(String text, Map<String, String> existing) {
  // 将文本转为变量名（去掉特殊字符并加前缀）
  text = PinyinHelper.getShortPinyin(text);
  String baseName = text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  String variableName = 'text_$baseName';
  int counter = 1;

  // 防止变量名重复
  while (existing.containsKey(variableName)) {
    variableName = 'text_${baseName}_${counter++}';
  }
  return variableName;
}

Future<void> _writeBaseCodeTextClass(Map<String, String> base64Map,
    Map<String, String> originalTextMap, String directoryPath) async {
  final filePath = '$directoryPath/base_code_text.dart';
  final buffer = StringBuffer();
  // 写入解码方法和变量
  buffer.writeln('// 自动生成的 BaseCodeText 类');
  buffer.writeln('import \'dart:convert\';\n');
  buffer.writeln('class BaseCodeText {');
  buffer.writeln('  static String decodeBase64(String base64Text) =>');
  buffer.writeln('      utf8.decode(base64Decode(base64Text)).replaceAll("\\\\n", "\\n");\n');

  // 写入变量并在变量名上方添加注释，注释为原始文本
  base64Map.forEach((key, value) {
    // 在变量定义前添加注释，内容为原始文本
    final originalText = originalTextMap[key] ?? "";
    buffer.writeln('  // 原始文本: $originalText');
    buffer.writeln('  static final String $key = decodeBase64(\'$value\');');
  });

  buffer.writeln('}');

  // 写入到文件
  final file = File(filePath);
  await file.writeAsString(buffer.toString());
}
