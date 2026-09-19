# 1. 멀티 스테이지 빌드 수행 (spring-board 1.2.0 이미지 생성)
docker build -t spring-board:1.2.0 .

# 2. 빌드된 경량화 이미지 용량 확인
docker images spring-board:1.1.0
docker images spring-board:1.2.0

# 3. 기존 컨테이너 삭제 후 포트 매핑(8080:8080) 백그라운드 구동
docker rm -f board-app
MSYS_NO_PATHCONV=1 docker run -d --name board-app \
--network board-net \
-p 8080:8080 \
-v "${PWD}/uploads://app/uploads" \
-v "${PWD}/logs://app/logs" \
-e SPRING_DATASOURCE_URL="jdbc:mysql://board-db:3306/board_db?useSSL=false&allowPublicKeyRetrieval=true" \
-e SPRING_DATASOURCE_USERNAME=board-app \
-e SPRING_DATASOURCE_PASSWORD=Board123! \
-e SPRING_SQL_INIT_MODE=always \
spring-board:1.2.0

# 4. 애플리케이션 수신 응답 상태 확인
curl http://localhost:8080/post/list