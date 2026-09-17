package com.automarket.notification.mail;

/**
 * Thrown when a message could not be handed to the mail provider.
 *
 * <p>Propagates out of the Kafka listener on purpose so the delivery is retried
 * and, if it keeps failing, lands on the dead-letter topic.
 */
public class MailDeliveryException extends RuntimeException {

    public MailDeliveryException(String message, Throwable cause) {
        super(message, cause);
    }

    public MailDeliveryException(String message) {
        super(message);
    }
}
