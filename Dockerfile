# Stage 1: Build stage (JDK 25 환경에서 spring-board 소스 코드 빌드)
FROM eclipse-temurin:25-jdk-alpine AS builder
WORKDIR /app

# Gradle 래퍼 및 빌드 설정 파일 복사 (레이어 캐싱 활용)
COPY gradlew .
COPY gradle/ gradle/
COPY build.gradle .
COPY settings.gradle .

# 실행 권한 부여 및 의존성 라이브러리 사전 다운로드
# (소스코드 변경 시 매번 무거운 라이브러리를 다시 다운로드받는 것을 방지하여 레이어 캐시 활용을 높임)
RUN chmod +x ./gradlew
RUN ./gradlew dependencies --no-daemon

# 스프링 부트 소스 코드 복사 및 실행 가능한 Executable JAR 생성
COPY src/ src/
RUN ./gradlew bootJar --no-daemon

# Stage 2: Runtime stage (경량화된 JRE 25 런타임 환경 구성)
FROM eclipse-temurin:25-jre-alpine
WORKDIR /app

# 보안 강화를 위한 비루트(non-root) 전용 시스템 계정 생성
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Stage 1(builder)에서 빌드된 최종 jar 파일만 추출하여 복사
COPY --from=builder /app/build/libs/*.jar spring-board.jar

# 소유권 변경 및 보안 계정 전환
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "spring-board.jar"]