package com.automarket.notification.mail;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;

/**
 * Sends over plain SMTP — MailHog in local and in-cluster development.
 *
 * <p>The default provider, so a developer with the compose stack up needs no
 * extra configuration.
 */
@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(name = "automarket.mail.provider", havingValue = "smtp", matchIfMissing = true)
public class SmtpMailSender implements MailSender {

    private final JavaMailSender mailSender;

    @Value("${automarket.mail.from:noreply@automarket.com}")
    private String fromAddress;

    @Override
    public void send(String to, String subject, String body) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromAddress);
        message.setTo(to);
        message.setSubject(subject);
        message.setText(body);
        try {
            mailSender.send(message);
        } catch (Exception e) {
            throw new MailDeliveryException("SMTP delivery to " + to + " failed", e);
        }
        log.debug("SMTP: sent to {} — {}", to, subject);
    }
}
