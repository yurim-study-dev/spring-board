# Nginx 리버스 프록시 연동 및 다중 컨테이너 환경 구축
# 1. 기존 단일 컨테이너(board-app) 및 다중 프록시 컨테이너 강제 중지 및 완전 삭제
docker stop board-app board-app-1 board-app-2 board-proxy 2>/dev/null || true
docker rm board-app board-app-1 board-app-2 board-proxy 2>/dev/null || true

# 2. Gradle 프로젝트 재빌드 (bootJar)
./gradlew clean bootJar

# 3. Nginx 헤더 로그 로직이 포함된 시맨틱 버저닝 1.1.0 이미지 재빌드
docker build \
  -t kilyong/spring-board:1.1.0 \
  -t kilyong/spring-board:1.1 \
  -t kilyong/spring-board:1 \
  -t kilyong/spring-board:latest .

# 4. 다중 Spring Board 애플리케이션 컨테이너 구동 (8080 포트 선언, board-net 연결, 컨테이너별 독립 로그 파일 지정)
MSYS_NO_PATHCONV=1 docker run -d --name board-app-1 \
  --network board-net \
  -v "${PWD}/uploads:/app/uploads" \
  -v "${PWD}/logs:/app/logs" \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://board-db:3306/board_db?useSSL=false&allowPublicKeyRetrieval=true" \
  -e SPRING_DATASOURCE_USERNAME=board-app \
  -e SPRING_DATASOURCE_PASSWORD=Board123! \
  -e LOGGING_FILE_NAME=/app/logs/board-app-1.log \
  kilyong/spring-board:1.1

MSYS_NO_PATHCONV=1 docker run -d --name board-app-2 \
  --network board-net \
  -v "${PWD}/uploads:/app/uploads" \
  -v "${PWD}/logs:/app/logs" \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://board-db:3306/board_db?useSSL=false&allowPublicKeyRetrieval=true" \
  -e SPRING_DATASOURCE_USERNAME=board-app \
  -e SPRING_DATASOURCE_PASSWORD=Board123! \
  -e LOGGING_FILE_NAME=/app/logs/board-app-2.log \
  kilyong/spring-board:1.1

# 5. Nginx 설정 파일 바인드 마운트 및 최앞단 웹 서버 컨테이너 구동 (호스트 80 포트 바인딩)
MSYS_NO_PATHCONV=1 docker run -d --name board-proxy \
  --network board-net \
  -p 80:80 \
  -v "${PWD}/nginx.conf:/etc/nginx/nginx.conf:ro" \
  nginx:alpine