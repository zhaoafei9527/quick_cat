#!/bin/bash

# TrainDriver H5 正式服发布脚本

set -eu

rm -rf dist/web.tar.gz
flutter build web --web-renderer auto --release

tar -czvf dist/web.tar.gz build/web
scp -P 22998 dist/web.tar.gz root@121.127.231.139:/server/reelshort/h5
ssh -p 22998 root@121.127.231.139 "cd /server/reelshort/h5/ && /usr/bin/tar xf web.tar.gz"

if  [ $? -eq 0 ];then
  curl -s -X POST -o /dev/null https://api.telegram.org/bot6934463146:AAGHrfwZnumOGvG6quBj_h30OJSH_IiGe-s/sendMessage -d chat_id=-1002002465717 -d text="TrainDriver H5 正式服更新成功"
  echo -e "\033[32m TrainDriver 正式服H5 更新成功 \033[0m"
else
  echo -e "\033[31m TrainDriver 正式服H5 更新失败 \033[0m"
fi
