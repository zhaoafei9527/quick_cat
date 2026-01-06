# dark_client

# 安装 getx-cli

```
flutter pub global activate get_cli


export FLUTTER_HOME=/Users/mac/fvm/default
export PATH=$PATH:$FLUTTER_HOME/bin
export PATH=$PATH:$FLUTTER_HOME/bin/cache/dart-sdk/bin
export PATH="$PATH":"$HOME/.pub-cache/bin"

export ANDROID_HOME=/Users/mac/Library/Android/sdk
export PATH=${PATH}:${ANDROID_HOME}/platform-tools
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

get create project:"my cool project"

get init

get create page:home 创建页面命令

get create controller:dialogcontroller on home   创建controller 

get create view:dialogview on home 

get create provider:user on home

get generate model on home with assets/models/user.json # 根据json文件生成dart类

get install http path camera # 安装模块

get sort . --skipRename # 排序整理 import, 格式化 dart 文件 ,使用 --relative 选项 相对路径 import,

flutter build web --web-renderer canvaskit

flutter build web --web-renderer html

flutter build web --web-renderer auto

get generate locales assets/locales  #生成多语言

渠道打包
java -jar VasDolly.jar put -c "channel1,channel2" /home/user/base.apk /home/user/

本地图片资源自动生成
将图片放入asstes中后执行 sh ./asstes_image.sh 

本地web-server

# assets-generator-begin
# assets/img/*
# assets-generator-end
```

#### 错误归纳

1. .ExoPlaybackException: MediaCodecVideoRenderer error,
   视频播放器报错崩溃 https://github.com/flutter/flutter/issues/81804 修复方法
   固定版本video_player_android: ^2.4.12
2. 安卓打包报错 error: resource android:attr/lStar not found. 解决：build.gradle file in your project
   directory subprojects { afterEvaluate { android { compileSdkVersion 34 } } }
3. 升级到 Flutter 3.27.0 后，使用 CachedNetworkImage 会出现错误：SecurityError: Failed to execute '
   texImage2D' on 'WebGL2RenderingContext': The image element contains cross-origin data, and may
   not be loaded.
   解决: CachedNetworkImage( imageUrl: slides[itemIndex].image.desktop.fromStringLang(
   lang), imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet, // <-- Add this line fit:
   BoxFit.cover, alignment: Alignment.center, ),



