# MySql DB 컨테이너 구동
docker run -d --name mydb --network my-net -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root mysql:9.7

# temurin 25 jre 컨테이너 구동
docker run -d --name board-web -p 80:8080 --network my-net eclipse-temurin:25-jre-alpine tail -f //dev/null

# 로컬의 빌드된 최종 코드를 컨테이너에 복사(로그인한 계정의 홈디렉토리로 복사)
docker cp ./build/libs/spring-board-0.0.1-SNAPSHOT.jar board-web:/root/board.jar

# 컨테이너 내부의 대화형 쉘 접속 후 java 명령어로 board.jar 실행
docker exec -it board-web //bin/sh
cd ~
java -jar board.jar


# 스프링 프로젝트 빌드
./gradlew clean bootJar

# 프로젝트를 도커 이미지로 빌드
./gradlew bootBuildImage --imageName=yurimweb/spring-board:1.0


# jar 파일 생성  -   (bootJar 더블클릭으로 생성해도 됨) - 인텔리제이 로컬 터미널
./gradlew clean bootJar

# 이미지 생성 - 인텔리제이 로컬 터미널
docker build -t yurimweb/spring-board:1.0 .


# spring-board 배포
# 1. 기존 컨테이너들 중지 및 삭제
docker stop spring-board db-server
docker rm spring-board db-server

# 2. 네트워크 삭제
docker network rm myapp-net

# 3. 네트워크 새로 생성
docker network create myapp-net

# Named Volume 생성
docker volume create spring-board-db-data

# 4. MySQL 컨테이너 먼저 실행
docker run --name db-server --network myapp-net -p 3306:3306 \
  -v spring-board-db-data:/var/lib/mysql \
  -e MYSQL_DATABASE=board_db \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_USER=board-app \
  -e MYSQL_PASSWORD=Board123! \
  mysql:9.7

# (ready for connections 문구가 뜨면 Ctrl+C로 빠져나오기, 안되면 엔터 ~ . 순서로 입력하면 SSH 연결을 끊을 수 있음)

# uploads,logs 폴더생성
mkdir -p uploads logs


# 5. 스프링 부트 컨테이너 실행
#MSYS_NO_PATHCONV=1 docker run -d --name spring-board --network myapp-net -p 80:8080 \
#-v "${PWD}\uploads:\app\uploads" \
#-v "${PWD}\logs:\app\logs" \
#  -e SPRING_DATASOURCE_USERNAME=board-app \
#  -e SPRING_DATASOURCE_PASSWORD=Board123! \
#    -e SPRING_SQL_INIT_MODE=never \
#  yurimweb/spring-board:1.0


MSYS_NO_PATHCONV=1 docker run -d --name spring-board --network myapp-net -p 80:8080 \
  -v "${PWD}/uploads:/app/uploads" \
  -v "${PWD}/logs:/app/logs" \
  -e SPRING_DATASOURCE_USERNAME=board-app \
  -e SPRING_DATASOURCE_PASSWORD=Board123! \
  -e SPRING_SQL_INIT_MODE=never \
  yurimweb/spring-board:1.0


# 테스트 완료된 spring-board 이미지를 운영 서버에 배포하기 위해서 docker hub에 업로드
# 로그인
docker login

# docker hub에 이미지 업로드
docker push kilyong/spring-board:1.0