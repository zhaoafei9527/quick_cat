import 'dart:io';
import 'package:yaml/yaml.dart';

String buildName = "91player";
String appConfigPath = "lib/app/data/pubspec.dart";

main() async {
  final file = File('pubspec.yaml');
  // 检查文件是否存在
  if (!await file.exists()) {
    print('YAML 配置文件不存在。');
    return;
  }

  try {
    final contents = await file.readAsString();
    final yamlMap = loadYaml(contents);
    String version = yamlMap['version'];
    bool debug = yamlMap['debug'];
    // 暂存工作区
    // await _cmdRun("git", args: ["stash"]);
    // 更新APP内部配置文件
    print("开始更新APP配置");
    await _matchAppConfigAndWrite(version, debug);
    print("更新APP配置完成");
    // 重写工作区所有文件，加密所有中文
    // await _cmdRun("dart", args: ["text_script.dart"]);
    // await _cmdRun("sh", args: ["build.sh", "a"]);
    // await _cmdRun("sh", args: ["build.sh", "w"]);

    // 还原工作区
    // await _cmdRun("git", args: ["checkout","."]);

    // print(app_contents);
    // configFile.writeAsStringSync(config);
  } catch (e) {
    print('读取或解析 YAML 文件时出错: $e');
  }
}

_matchAppConfigAndWrite(String version, bool debug) async {
  final configFile = File(appConfigPath);
  String config = await configFile.readAsString();
  final versionHead = version.split("+")[0];
  final versionFoot = version.split("+")[1];
  final versionFullRegex =
      RegExp(r"static\s+const\s+versionFull\s*=\s*'([^']+)';");
  final versionRegex = RegExp(r"static\s+const\s+version\s*=\s*'([^']+)';");
  final versionSmallRegex =
      RegExp(r"static\s+const\s+versionSmall\s*=\s*'([^']+)';");
  final versionDebugRegex =
      RegExp(r"static\s+const\s+debug\s*=\s*(true|false);");
  // 检查是否匹配成功
  if (versionFullRegex.hasMatch(config) && versionDebugRegex.hasMatch(config)) {
    config = config.replaceAllMapped(versionFullRegex, (match) {
      return "static const versionFull = '$version';";
    });
    config = config.replaceAllMapped(versionRegex, (match) {
      return "static const version = '$versionHead';";
    });
    config = config.replaceAllMapped(versionSmallRegex, (match) {
      return "static const versionSmall = '$versionFoot';";
    });
    config = config.replaceAllMapped(versionDebugRegex, (match) {
      return "static const debug = $debug;";
    });
    print('版本号已更新为: $version,debug已更新为 $debug');
  } else {
    print('未找到匹配的版本号行。');
  }
  configFile.writeAsStringSync(config);
}

_cmdRun(String command, {List<String>? args}) async {
  try {
    // 执行命令
    ProcessResult result = await Process.run(command, args ?? []);

    // 检查退出码
    if (result.exitCode == 0) {
      print('命令执行成功：');
      print(result.stdout);
    } else {
      print('命令执行失败，退出码：${result.exitCode}');
      print(result.stderr);
    }
  } catch (e) {
    print('执行命令时出错：$e');
  }
}
