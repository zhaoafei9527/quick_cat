flutter build web --web-renderer auto --release


tar -czvf dist/web.tar.gz build/web

cd build/web &&  http-server -g -p 8001