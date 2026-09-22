package com.automarket.inquiry.dto;

import com.automarket.common.dto.PageResponse;

/**
 * An open thread: its inbox header plus one page of messages.
 *
 * <p>The page is indexed newest-first (page 0 holds the most recent messages) but
 * its content is ordered oldest-first, so a client renders a page top-to-bottom and
 * prepends each older page above the last.
 */
public record ConversationDetailDto(
        ConversationDto conversation,
        PageResponse<MessageDto> messages
) {}
