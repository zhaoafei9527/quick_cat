// This file is generated automatically, do not modify

// ignore_for_file: public_member_api_docs, constant_identifier_names, avoid_classes_with_only_static_members

class Pubspec {
  static final buildDate = DateTime.utc(2023, 11, 17, 4, 37, 28);

  static const name = 'gua_client';

  static const description = 'A new Flutter project.';

  static const publish_to = 'none';

  static const versionFull = '1.1.0+21';

  static const version = '1.1.0';

  static const versionSmall = '21';

  static const versionMajor = 1;

  static const versionMinor = 0;

  static const versionPatch = 0;

  static const versionBuild = 11;

  static const String versionPreRelease = '';

  static const versionIsPreRelease = false;

  static const debug = true;

  static const qiye = false;

  static const opt_tool = false;

  static const appid = '999';

  static const umeng_android_key = '615ebce6cf85ee18102102cf';

  static const umeng_ios_key = '615ebec9d884567d81a5452c';

  static const aes_key = '082650C2132D4566975AC619158694I0';

  static const ios_id = 'awclient_opera';

  static const dev_h5_lines = <dynamic>[
    // "http://192.168.100.227:21111",
    "https://catapp.htqhfqp.com"
  ];

  static const dev_app_lines = <dynamic>[
    // "http://192.168.100.227:21111",
    // "https://vapp.hxc1t.com",
    "https://catapp.htqhfqp.com"
    // "http://192.168.0.119:21111"
  ];

  static const prod_h5_lines = <dynamic>[
    "https://kmutzacn.sccw-cn.com",
    "https://kmzxsa.0913.org",
    "https://api.lbsone.com",
    "https://apikm.nineoneapp.com",
    "https://d2fztf6d01of6d.cloudfront.net",
  ];

  static const prod_app_lines = <dynamic>[
    "https://kmutzacn.sccw-cn.com",
    "https://kmzxsa.0913.org",
    "https://api.calfmedia.com",
    "https://apikm.nineoneapp.com",
    "https://d2fztf6d01of6d.cloudfront.net",
  ];

  static List<String> getBackupLine() {
    List<String> backup = [];
    String pathHead = "https://dns.alidns.com/resolve?type=16&short=1&name=";
    for (int i = 0; i < 11; i++) {
      String timestamp = "${DateTime.now().millisecondsSinceEpoch}";
      String path = "$pathHead$timestamp.juese$i.app";
      if (i == 0) {
        path = "$pathHead$timestamp.juese.app";
      }
      backup.add(path);
    }
    return backup;
  }
}
