# 모든 기존 컨테이너 강제 중지 및 전체 삭제
docker rm -f $(docker ps -aq) 2>/dev/null || true

# 모든 기존 이미지 강제 전체 삭제
docker rmi -f $(docker images -q) 2>/dev/null || true

# 모든 기존 Named Volumes 및 네트워크 전체 삭제
docker volume rm -f $(docker volume ls -q) 2>/dev/null || true
docker network rm -f $(docker network ls -q) 2>/dev/null || true


# Spring Board 애플리케이션 전용 사용자 정의 네트워크 생성
docker network create board-net

# DB 데이터 영속성 보존용 Named Volume 생성
docker volume create board-db-data

# 게시판 첨부파일(uploads) 및 시스템 로그(logs) 바인드 마운트 전용 호스트 디렉터리 사전 생성
mkdir -p uploads logs

# MySQL DB 컨테이너 백그라운드 구동, 볼륨 마운트 및 환경 변수 설정
docker run -d --name board-db \
  --network board-net \
  -p 3306:3306 \
  -v board-db-data:/var/lib/mysql \
  -e MYSQL_DATABASE=board_db \
  -e MYSQL_USER=board-app \
  -e MYSQL_PASSWORD=Board123! \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  mysql:9.7

# 1단계 이미지 빌드
docker build -t board-app-step1 .

# 컨테이너 구동 후 작업 디렉터리(/app) 생성 상태 확인
docker run --rm board-app-step1 pwd


# 로컬 Gradle 빌드 실행 (JAR 파일 생성)
./gradlew clean bootJar

# 2단계 이미지 빌드
docker build -t board-app-step2 .

# 컨테이너 내부에 복사한 파일 존재 여부 확인
docker run --rm board-app-step2 ls -la //app


# 3단계 이미지 빌드
docker build -t board-app-step3 .

# 컨테이너 내부 주입된 환경 변수 설정값 확인
docker run --rm board-app-step3 printenv SPRING_PROFILES_ACTIVE


# 4단계 spring-board 이미지 빌드
docker build -t spring-board:1.1.0 .

# 1. 기본 설정(8080 포트, prod 프로파일)으로 백그라운드 구동
docker rm -f board-app
MSYS_NO_PATHCONV=1 docker run -d --name board-app \
-p 8080:8080 \
--network board-net \
-e SPRING_DATASOURCE_URL="jdbc:mysql://board-db:3306/board_db?useSSL=false&allowPublicKeyRetrieval=true" \
-e SPRING_DATASOURCE_USERNAME=board-app \
-e SPRING_DATASOURCE_PASSWORD=Board123! \
-e SPRING_SQL_INIT_MODE=always \
-v "${PWD}/uploads:/app/uploads" \
-v "${PWD}/logs:/app/logs" \
spring-board:1.1.0

# 8080 포트 수신 응답 상태 확인
curl http://localhost:8080/post/list

# 2. -e 옵션으로 포트(9090) 및 프로파일(dev)을 런타임 오버라이드하여 구동
docker rm -f board-app
MSYS_NO_PATHCONV=1 docker run -d --name board-app \
-p 9090:9090 \
--network board-net \
-e SERVER_PORT=9090 \
-e SPRING_PROFILES_ACTIVE=dev \
-e SPRING_DATASOURCE_URL="jdbc:mysql://board-db:3306/board_db?useSSL=false&allowPublicKeyRetrieval=true" \
-e SPRING_DATASOURCE_USERNAME=board-app \
-e SPRING_DATASOURCE_PASSWORD=Board123! \
-e SPRING_SQL_INIT_MODE=never \
-v "${PWD}/uploads:/app/uploads" \
-v "${PWD}/logs:/app/logs" \
spring-board:1.1.0

# 9090 포트 수신 응답 상태 확인
curl http://localhost:9090/post/list