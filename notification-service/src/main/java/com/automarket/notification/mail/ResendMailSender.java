package com.automarket.notification.mail;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/**
 * PLACEHOLDER for the Resend transport. Logs the message instead of sending it.
 *
 * <p>Activated with {@code automarket.mail.provider=resend} (env
 * {@code MAIL_PROVIDER=resend}). Until the HTTP call below is implemented,
 * running with this provider means no mail actually leaves the service — the
 * log line is the only record, so do not enable it in production yet.
 *
 * <p>To finish it, POST to {@code https://api.resend.com/emails} with
 * {@code Authorization: Bearer <apiKey>} and a JSON body of
 * {@code {"from": ..., "to": [...], "subject": ..., "text": ...}}. A 2xx carries
 * the message id; anything else must raise {@link MailDeliveryException} so the
 * listener retries and then dead-letters the event. Note that Resend requires
 * {@code from} to be on a verified domain — {@code automarket.mail.from} has to
 * match one, and its 2 requests/second default rate limit means a burst of
 * events needs either client-side throttling or a retry on HTTP 429.
 */
@Slf4j
@Component
@ConditionalOnProperty(name = "automarket.mail.provider", havingValue = "resend")
public class ResendMailSender implements MailSender {

    @Value("${automarket.mail.from:noreply@automarket.com}")
    private String fromAddress;

    @Value("${automarket.mail.resend.api-key:}")
    private String apiKey;

    @Override
    public void send(String to, String subject, String body) {
        if (apiKey.isBlank()) {
            log.warn("RESEND_API_KEY is not set — mail to {} will not be delivered", to);
        }

        // TODO(resend): replace this log with the real API call. See the class javadoc.
        log.info("""
                [resend placeholder] not sent
                  from:    {}
                  to:      {}
                  subject: {}
                  body:    {}""", fromAddress, to, subject, body);
    }
}
