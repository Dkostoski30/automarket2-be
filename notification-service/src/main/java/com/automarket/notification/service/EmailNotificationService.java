package com.automarket.notification.service;

import com.automarket.notification.mail.MailSender;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Composes the transactional messages the service sends.
 *
 * <p>Body text and addressing live here; handing the message to a provider is
 * the {@link MailSender} implementation's job.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EmailNotificationService {

    private final MailSender mailSender;

    @Value("${automarket.frontend.base-url:http://localhost:4200}")
    private String frontendBaseUrl;

    public void sendListingApproved(String sellerEmail, String listingTitle, String listingSlug) {
        sendSimple(
                sellerEmail,
                "Your listing has been approved — AutoMarket",
                "Great news! Your listing \"" + listingTitle + "\" has been approved and is now live.\n\n" +
                "View it at: " + frontendBaseUrl + "/listings/" + listingSlug
        );
    }

    public void sendListingRejected(String sellerEmail, String listingTitle, String reason) {
        sendSimple(
                sellerEmail,
                "Your listing requires changes — AutoMarket",
                "Your listing \"" + listingTitle + "\" was not approved.\n\n" +
                "Reason: " + (reason != null ? reason : "Does not meet our guidelines.") + "\n\n" +
                "Please review our posting guidelines and resubmit."
        );
    }

    public void sendNewInquiry(String sellerEmail, String listingTitle, String senderName) {
        sendSimple(
                sellerEmail,
                "New inquiry on your listing — AutoMarket",
                senderName + " sent you a message about your listing \"" + listingTitle + "\".\n\n" +
                "Log in to AutoMarket to view and respond: " + frontendBaseUrl + "/inquiries"
        );
    }

    private void sendSimple(String to, String subject, String text) {
        mailSender.send(to, subject, text);
    }
}
