# =============================================================================
# FAKE REVIEW DETECTION MODULE
# Purpose: Rule-based fake/spam review detection with credibility scoring
# =============================================================================

library(tidyverse)
library(stringr)

# Small lexicons for extreme sentiment detection
EXTREME_POSITIVE_WORDS <- c(
    "amazing", "awesome", "best", "excellent", "fantastic", "incredible",
    "love", "perfect", "outstanding", "superb", "wonderful"
)

EXTREME_NEGATIVE_WORDS <- c(
    "awful", "bad", "disgusting", "horrible", "hate", "poor", "terrible",
    "worst", "useless", "scam", "fraud"
)

#' Detect fake review label for a single text
#' @param text Character string
#' @return Character: "Fake" or "Genuine"
#' @export
detect_fake_review <- function(text) {
    details <- get_fake_review_details(text)
    details$fake_review_flag
}

#' Compute credibility score for a single text
#' @param text Character string
#' @return Numeric score in [0, 1]
#' @export
compute_credibility_score <- function(text) {
    details <- get_fake_review_details(text)
    details$credibility_score
}

#' Internal helper to evaluate indicators and score
#' @param text Character string
#' @return Named list with detection details
get_fake_review_details <- function(text) {
    raw_text <- ifelse(is.na(text), "", as.character(text))
    text_lc <- str_to_lower(str_squish(raw_text))

    words <- str_split(text_lc, "\\s+")[[1]]
    words <- words[words != ""]
    word_count <- length(words)

    if (word_count == 0) {
        return(list(
            fake_review_flag = "Fake",
            credibility_score = 0,
            credibility_band = "Low",
            indicators_count = 4
        ))
    }

    # Indicator 1: repeated words (including consecutive repeats)
    word_freq <- table(words)
    max_repeat <- max(as.numeric(word_freq))
    has_repetition <- max_repeat >= 3 || str_detect(text_lc, "\\b(\\w+)\\s+\\1\\b")

    # Indicator 2: excessive punctuation
    exclamation_count <- str_count(raw_text, "!")
    has_excessive_punct <- str_detect(raw_text, "!{2,}") || exclamation_count >= 3

    # Indicator 3: excessive positive/negative wording
    pos_count <- sum(words %in% EXTREME_POSITIVE_WORDS)
    neg_count <- sum(words %in% EXTREME_NEGATIVE_WORDS)
    extreme_ratio <- (pos_count + neg_count) / word_count
    has_extreme_sentiment <- pos_count >= 4 || neg_count >= 4 || extreme_ratio >= 0.6

    # Indicator 4: very short review
    is_too_short <- word_count < 3

    # Indicator 5: very long exaggerated review
    has_exaggeration_words <- str_detect(
        text_lc,
        "absolutely|literally|totally|completely|always|never|perfect|best|worst"
    )
    is_too_long_exaggerated <- word_count > 80 && has_exaggeration_words

    # Credibility starts at 1 and decreases by rule penalties
    credibility_score <- 1
    if (has_repetition) credibility_score <- credibility_score - 0.25
    if (has_excessive_punct) credibility_score <- credibility_score - 0.20
    if (has_extreme_sentiment) credibility_score <- credibility_score - 0.25
    if (is_too_short) credibility_score <- credibility_score - 0.20
    if (is_too_long_exaggerated) credibility_score <- credibility_score - 0.20

    credibility_score <- max(0, min(1, round(credibility_score, 2)))

    indicators_count <- sum(c(
        has_repetition,
        has_excessive_punct,
        has_extreme_sentiment,
        is_too_short,
        is_too_long_exaggerated
    ))

    fake_review_flag <- ifelse(credibility_score < 0.60 || indicators_count >= 2, "Fake", "Genuine")

    credibility_band <- case_when(
        credibility_score < 0.4 ~ "Low",
        credibility_score < 0.75 ~ "Medium",
        TRUE ~ "High"
    )

    list(
        fake_review_flag = fake_review_flag,
        credibility_score = credibility_score,
        credibility_band = credibility_band,
        indicators_count = indicators_count
    )
}

#' Apply fake review detection to a dataframe
#' @param data Dataframe containing review text
#' @param text_col Name of text column (default: original_text)
#' @return Dataframe with fake_review_flag, credibility_score, credibility_band
#' @export
fake_review_analysis <- function(data, text_col = "original_text") {
    if (!text_col %in% colnames(data)) {
        if ("text" %in% colnames(data)) {
            text_col <- "text"
        } else {
            stop("Error: Data must have 'original_text' or 'text' column.")
        }
    }

    details <- lapply(data[[text_col]], get_fake_review_details)

    data$fake_review_flag <- sapply(details, function(x) x$fake_review_flag)
    data$credibility_score <- as.numeric(sapply(details, function(x) x$credibility_score))
    data$credibility_band <- sapply(details, function(x) x$credibility_band)

    data
}

#' Summary table for fake review detection
#' @param data Dataframe with fake_review_flag
#' @return Tibble summary
#' @export
get_fake_review_summary <- function(data) {
    data %>%
        count(fake_review_flag, name = "Count") %>%
        mutate(Percentage = round((Count / sum(Count)) * 100, 2)) %>%
        arrange(desc(Count))
}
