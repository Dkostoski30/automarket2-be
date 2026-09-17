package com.automarket.notification.mail;

/**
 * Transport for outbound transactional mail.
 *
 * <p>One implementation is active at a time, selected by
 * {@code automarket.mail.provider}: {@code smtp} (MailHog locally) or
 * {@code resend} (the intended production transport).
 *
 * <p>Implementations must NOT swallow delivery failures. The Kafka listener in
 * {@code NotificationEventConsumer} relies on an exception propagating so the
 * record is retried and then dead-lettered, rather than the notification being
 * silently dropped.
 */
public interface MailSender {

    void send(String to, String subject, String body);
}
