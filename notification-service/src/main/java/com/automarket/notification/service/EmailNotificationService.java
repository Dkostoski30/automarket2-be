package com.automarket.notification.service;

import com.automarket.notification.mail.MailSender;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.UUID;

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

    public void sendNewInquiry(String sellerEmail, String listingTitle, String senderName,
                               UUID conversationId) {
        sendSimple(
                sellerEmail,
                "New inquiry on your listing — AutoMarket",
                senderName + " sent you a message about your listing \"" + listingTitle + "\".\n\n" +
                "Reply from your inbox: " + threadUrl(conversationId)
        );
    }

    /**
     * A message in a thread that is already running. Either side can receive this —
     * the seller answering a buyer is the same notification as the other way round.
     */
    public void sendConversationReply(String recipientEmail, String listingTitle, String senderName,
                                      UUID conversationId) {
        sendSimple(
                recipientEmail,
                "New reply — AutoMarket",
                senderName + " replied to your conversation about \"" + listingTitle + "\".\n\n" +
                "Read and reply: " + threadUrl(conversationId)
        );
    }

    /** Deep link straight into the thread rather than the inbox it sits in. */
    private String threadUrl(UUID conversationId) {
        return conversationId != null
                ? frontendBaseUrl + "/inquiries/" + conversationId
                : frontendBaseUrl + "/inquiries";
    }

    private void sendSimple(String to, String subject, String text) {
        mailSender.send(to, subject, text);
    }
}
