
flutter build web --web-renderer auto --release

tar -czvf dist/web.tar.gz build/web
#端口3001的更新
scp -P 22889 dist/web.tar.gz root@121.127.231.205:/server/h5/
ssh -p 22889 root@121.127.231.205 "cd /server/h5/ && /usr/bin/tar xf web.tar.gz"