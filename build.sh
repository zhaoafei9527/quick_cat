#!/bin/bash

set -e

if [ $# -ne 1 ]; then
    printf -- "Build Paofu_Yinse release package.\n\n"
    printf -- "Usage: $0 <target>  a:apk | i:ios | all:api and ios \n"
    exit
fi

set -e
projectPath=""

projectPath=`pwd`
echo "工程路径:$projectPath"
cd $projectPath
ver=`grep 'version:' pubspec.yaml`
ver=${ver##'version: '}
curDate=$(date "+%y%m%d")
projectName='quickCat_client'
projectName=${projectName##'name: '}
namePrefix=${projectName//'client'/''}
namePrefix=${namePrefix//'_'/''}
# if [ "$namePrefix" = "fuli" ];then
#   namePrefix='bili'
# fi
mkdir  -p ./dist/
echo "> 完成项目初始化...100% 当前项目: '$projectName'版本: '$ver'."
debug=`grep 'debug:' pubspec.yaml`
echo "> 项目环境:'$debug'"
echo ">Are you sure? (Press any key to continue.)"
read aChar
dart build_all.dart
#if [[ -n $(git status --porcelain) ]]; then
#    # 有更改，执行提交
#    git commit -am "${ver}"
#    echo "已提交更改：${ver}"
#fi



# echo "正在备份和打包资源文件assets..."
# cd $projectPath
# mkdir  -p ./dist/assets/$projectName/$ver
# `cp -rf ./assets/$projectName/img/ ./dist/assets/$projectName/$ver/img`
# `cp -rf ./assets/$projectName/svg/ ./dist/assets/$projectName/$ver/svg`
# `cp -rf ./assets/$projectName/def/ ./dist/assets/$projectName/$ver/def`
# cd ./dist/
# zip -r assets.zip ./assets/
# cd $projectPath
# `rm -rf ./assets/$projectName/img`
# `rm -rf ./assets/$projectName/svg`
# `rm -rf ./assets/$projectName/def`
# echo "正在备份和打包资源文件assets...100%"


checkEnv() {
  key=$1
  script_dir=$( cd "$( dirname "$0"  )" && pwd )
  script_name=$(basename ${0})
  keyPath=${script_dir}$2
  line=`grep "$key" $keyPath`
  echo ">>>>>>>>>>>>>>>>>>>>>>>"
  echo ">$line"
  echo ">>>>>>>>>>>>>>>>>>>>>>>"
  echo ">Are you sure? (Press any key to continue.)"
  read aChar
  # while read line; do
  #   # if [ "$config" = echo $line|awk '{print $config}' ];then
  #   if [[ line =~ $config ]];then
  #      echo "the $config 's find in line is `echo $line|awk '{print $2}'`"
  #      break;
  #   fi
  #   # echo "${line}"
  # done
}

android() {
  # checkEnv "DEBUG =" "/lib/common/config/config.dart";
  # checkEnv "PROXY =" "/lib/common/config/config.dart";
#  dart text_script.dart

  # flutter build apk --shrink --obfuscate --split-debug-info=./build/debuginfo
#  flutter build apk --shrink  --obfuscate  --split-debug-info=./build/debuginfo
    shorebird release android --flutter-version=3.27.1 --artifact apk
#  git reset --hard HEAD^
  # 服务器批量打包需求，请按照 “项目_日期_版本.apk来命名，日期不能包含下划线
  echo "> Coping to dist."

    echo "> Now begin building apk."
   if [[ "$debug" =~ "false" ]];then
    mv ./build/app/outputs/apk/release/app-release.apk ./dist/''$namePrefix'_'$curDate'_'$ver'.apk'
    echo '> Built apk done. path:./dist/'$namePrefix'_'$curDate'_'$ver'.apk'
    else
    mv ./build/app/outputs/apk/release/app-release.apk ./dist/''$namePrefix'_'$curDate'_'$ver'_debug.apk'
    echo '> Built apk done. path:./dist/'$namePrefix'_'$curDate'_'$ver'_debug.apk'
  fi

}

ios() {
  echo "> Building ios by flutuer."
  flutter build ios --obfuscate --split-debug-info=./build/debuginfo
#  git reset --hard HEAD^

  echo "> Building ios by xcode."
  xcodebuild -quiet -workspace ./ios/Runner.xcworkspace -scheme Runner -configuration Release archive -archivePath ./build/ios/Runner.xcarchive

  echo "> export ipa."
  xcodebuild -quiet -exportArchive -archivePath ./build/ios/Runner.xcarchive -exportPath ./build/ios -exportOptionsPlist ./ios/ExportOptions.plist

  mv ./build/ios/Runner.ipa ./dist/im_$ver.ipa

  echo "> Built ios done. './dist/im_$ver.ipa'"
}

web(){
    echo "> Building web by flutuer."
    flutter build web --release --web-renderer=html
#    git reset --hard HEAD^
    mkdir ./dist/''$namePrefix'_'$curDate'_'$ver''
    mv ./build/web/* ./dist/''$namePrefix'_'$curDate'_'$ver''/
    echo '> Built web done. path:./dist/'$namePrefix'_'$curDate'_'$ver''
}


case "$1" in
  a)   android;;
  i)   ios;;
  w)   web;;
  all) android;ios;;
  *)   printf -- '\n';exit;;
esac

printf -- '\n'
# cd ${p_path}
# git pull


# echo "> Start commit to git..."
# cd ${p_path}
# git pull
# git add .
# git commit -m "IM Android online release [$1]"
# git push
# echo "> Commit to git completed..."
