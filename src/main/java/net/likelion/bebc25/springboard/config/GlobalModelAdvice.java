package net.likelion.bebc25.springboard.config;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;
import java.net.InetAddress;

/**
 * 모든 Thymeleaf HTML 뷰 템플릿에 현재 응답한 WAS 서버 식별자(serverName)를 전역 주입
 */
@ControllerAdvice
public class GlobalModelAdvice {

    @ModelAttribute("serverName")
    public String getServerName() {
        String hostname = System.getenv("HOSTNAME");
        if (hostname == null || hostname.isBlank()) {
            try {
                hostname = InetAddress.getLocalHost().getHostName();
            } catch (Exception e) {
                hostname = "board-app";
            }
        }
        return hostname;
    }
}
