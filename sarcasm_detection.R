# =============================================================================
# SARCASM DETECTION MODULE
# Purpose: Rule-based sarcasm detection using sentiment and linguistic patterns
# Author: AI-Based Sentiment Intelligence System
# =============================================================================

# Load required libraries
library(tidyverse)
library(stringr)

# Shared regex patterns for sarcasm indicators
SARCASM_PATTERNS <- list(
    excessive_punct = "!{2,}|\\?{2,}",
    laughter = "😂|🤣|😆|lol|haha|lmao|rofl|hahaha",
    sarcasm_words = "yeah right|as if|sure|obviously|totally|absolutely|certainly|definitely|great\\s+job",
    quotes = "\\\"[^\\\"]*\\\"|\\'[^\\']*\\'",
    negative_context = "but|however|unfortunately|sadly|too bad|wish|if only|thanks for nothing",
    exaggeration = "best|worst|ever|never|always|perfect|totally|absolutely|completely|literally",
    caps = "\\b[A-Z]{3,}\\b",
    trailing_not = "([,\\.!?]\\s*not$)|\\snot$"
)

#' Detect Sarcasm using Rule-Based Approach
#' @param text Character vector of original text
#' @param sentiment_score Numeric sentiment score
#' @return Logical vector indicating sarcasm (TRUE/FALSE)
#' @export
detect_sarcasm <- function(text, sentiment_score) {
    # Initialize sarcasm flag
    is_sarcasm <- rep(FALSE, length(text))

    for (i in seq_along(text)) {
        current_text <- ifelse(is.na(text[i]), "", text[i])
        current_text_lc <- tolower(current_text)
        current_score <- sentiment_score[i]

        # Rule 1: Positive words with excessive punctuation
        has_excessive_punct <- str_detect(current_text, SARCASM_PATTERNS$excessive_punct)

        # Rule 2: Positive words with laughing emojis/expressions
        has_laughter <- str_detect(current_text_lc, SARCASM_PATTERNS$laughter)

        # Rule 3: Presence of sarcasm indicators
        has_sarcasm_words <- str_detect(current_text_lc, SARCASM_PATTERNS$sarcasm_words)

        # Rule 4: Quotation marks around positive words
        has_quotes <- str_detect(current_text, SARCASM_PATTERNS$quotes)

        # Rule 5: Mixed signals - positive score but negative context
        negative_context <- str_detect(current_text_lc, SARCASM_PATTERNS$negative_context)

        # Rule 6: Exaggeration words
        has_exaggeration <- str_detect(current_text_lc, SARCASM_PATTERNS$exaggeration)

        # Rule 7: All caps words (shouting)
        has_caps <- str_detect(current_text, SARCASM_PATTERNS$caps)

        # Rule 8: Contrastive ending (e.g., "great service... not")
        has_trailing_not <- str_detect(current_text_lc, SARCASM_PATTERNS$trailing_not)

        # Sarcasm detection logic
        sarcasm_score <- 0

        if (current_score > 0) {
            # Positive sentiment scenarios
            if (has_excessive_punct) sarcasm_score <- sarcasm_score + 2
            if (has_laughter) sarcasm_score <- sarcasm_score + 2
            if (has_sarcasm_words) sarcasm_score <- sarcasm_score + 3
            if (has_quotes) sarcasm_score <- sarcasm_score + 1
            if (has_exaggeration && (has_excessive_punct || has_laughter)) {
                sarcasm_score <- sarcasm_score + 2
            }
            if (has_caps) sarcasm_score <- sarcasm_score + 1
            if (negative_context) sarcasm_score <- sarcasm_score + 2
            if (has_trailing_not) sarcasm_score <- sarcasm_score + 3
        } else if (current_score == 0) {
            # Neutral sentiment with sarcasm indicators
            if (has_sarcasm_words) sarcasm_score <- sarcasm_score + 3
            if (has_quotes) sarcasm_score <- sarcasm_score + 1
            if (has_excessive_punct) sarcasm_score <- sarcasm_score + 1
            if (has_laughter) sarcasm_score <- sarcasm_score + 1
            if (has_trailing_not) sarcasm_score <- sarcasm_score + 2
        } else {
            # Negative sentiment can still be sarcastic with explicit cues
            if (has_sarcasm_words) sarcasm_score <- sarcasm_score + 2
            if (has_quotes) sarcasm_score <- sarcasm_score + 1
            if (has_excessive_punct && has_exaggeration) sarcasm_score <- sarcasm_score + 1
            if (has_trailing_not) sarcasm_score <- sarcasm_score + 2
        }

        # Strengthen signal when explicit sarcasm phrase appears with any secondary cue
        if (has_sarcasm_words && (has_excessive_punct || has_laughter || has_quotes || has_caps || negative_context)) {
            sarcasm_score <- sarcasm_score + 1
        }

        # If sarcasm score >= 3, flag as sarcastic
        if (sarcasm_score >= 3) {
            is_sarcasm[i] <- TRUE
        }
    }

    return(is_sarcasm)
}

#' Calculate Sarcasm Confidence Score
#' @param text Character vector of text
#' @param sentiment_score Numeric sentiment score
#' @return Numeric confidence score (0-100)
#' @export
calculate_sarcasm_confidence <- function(text, sentiment_score) {
    confidence <- rep(0, length(text))

    for (i in seq_along(text)) {
        current_text <- ifelse(is.na(text[i]), "", text[i])
        current_text_lc <- tolower(current_text)

        indicators <- 0
        max_indicators <- 8

        # Check all indicators
        if (str_detect(current_text, SARCASM_PATTERNS$excessive_punct)) indicators <- indicators + 1
        if (str_detect(current_text_lc, SARCASM_PATTERNS$laughter)) indicators <- indicators + 1
        if (str_detect(current_text_lc, SARCASM_PATTERNS$sarcasm_words)) indicators <- indicators + 1
        if (str_detect(current_text, SARCASM_PATTERNS$quotes)) indicators <- indicators + 1
        if (str_detect(current_text_lc, SARCASM_PATTERNS$negative_context)) indicators <- indicators + 1
        if (str_detect(current_text_lc, SARCASM_PATTERNS$exaggeration)) indicators <- indicators + 1
        if (str_detect(current_text, SARCASM_PATTERNS$caps)) indicators <- indicators + 1
        if (str_detect(current_text_lc, SARCASM_PATTERNS$trailing_not)) indicators <- indicators + 1

        # Calculate confidence percentage
        confidence[i] <- round((indicators / max_indicators) * 100, 2)
    }

    return(confidence)
}

#' Perform Complete Sarcasm Analysis
#' @param data Dataframe with 'original_text' and 'sentiment_score' columns
#' @return Dataframe with sarcasm detection results
#' @export
sarcasm_analysis <- function(data) {
    message("Performing sarcasm detection...")

    # Check required columns
    if (!"original_text" %in% colnames(data)) {
        warning("'original_text' column not found. Using 'text' column.")
        data$original_text <- data$text
    }

    if (!"sentiment_score" %in% colnames(data)) {
        stop("Error: 'sentiment_score' column required. Run sentiment analysis first.")
    }

    # Detect sarcasm
    message("  [1/2] Applying rule-based sarcasm detection...")
    data$is_sarcasm <- detect_sarcasm(data$original_text, data$sentiment_score)

    # Calculate confidence
    message("  [2/2] Computing sarcasm confidence scores...")
    data$sarcasm_confidence <- calculate_sarcasm_confidence(
        data$original_text,
        data$sentiment_score
    )

    sarcasm_count <- sum(data$is_sarcasm)
    sarcasm_pct <- round(mean(data$is_sarcasm) * 100, 2)

    message(sprintf(
        "✓ Sarcasm detection complete! Found %d sarcastic texts (%.2f%%)",
        sarcasm_count, sarcasm_pct
    ))

    return(data)
}

#' Get Sarcasm Summary Statistics
#' @param data Dataframe with sarcasm detection results
#' @return Summary statistics
#' @export
get_sarcasm_summary <- function(data) {
    total <- nrow(data)
    sarcastic <- sum(data$is_sarcasm)
    non_sarcastic <- total - sarcastic

    summary_stats <- list(
        total_records = total,
        sarcastic_count = sarcastic,
        non_sarcastic_count = non_sarcastic,
        sarcasm_rate = round((sarcastic / total) * 100, 2),
        avg_confidence = mean(data$sarcasm_confidence[data$is_sarcasm], na.rm = TRUE),
        high_confidence = sum(data$sarcasm_confidence >= 50)
    )

    # Create summary table
    summary_table <- tibble(
        Category = c("Sarcastic", "Non-Sarcastic", "Total"),
        Count = c(sarcastic, non_sarcastic, total),
        Percentage = round(c(
            (sarcastic / total) * 100,
            (non_sarcastic / total) * 100,
            100
        ), 2)
    )

    return(list(stats = summary_stats, table = summary_table))
}

#' Get Sarcastic Records
#' @param data Dataframe with sarcasm detection results
#' @param min_confidence Minimum confidence threshold (default: 30)
#' @return Subset of sarcastic records
#' @export
get_sarcastic_records <- function(data, min_confidence = 30) {
    sarcastic <- data %>%
        filter(is_sarcasm == TRUE, sarcasm_confidence >= min_confidence) %>%
        select(
            id, original_text, sentiment_score, polarity,
            is_sarcasm, sarcasm_confidence
        ) %>%
        arrange(desc(sarcasm_confidence))

    message(sprintf(
        "Found %d sarcastic records with confidence >= %d%%",
        nrow(sarcastic), min_confidence
    ))

    return(sarcastic)
}

#' Analyze Sarcasm by Sentiment Polarity
#' @param data Dataframe with sarcasm and polarity columns
#' @return Sarcasm distribution by polarity
#' @export
analyze_sarcasm_by_polarity <- function(data) {
    if (!"polarity" %in% colnames(data)) {
        stop("Error: 'polarity' column required.")
    }

    analysis <- data %>%
        group_by(polarity, is_sarcasm) %>%
        summarise(Count = n(), .groups = "drop") %>%
        spread(key = is_sarcasm, value = Count, fill = 0) %>%
        rename(Non_Sarcastic = `FALSE`, Sarcastic = `TRUE`) %>%
        mutate(
            Total = Non_Sarcastic + Sarcastic,
            Sarcasm_Rate = round((Sarcastic / Total) * 100, 2)
        )

    return(analysis)
}

# Example usage
if (FALSE) {
    # Load and analyze data
    source("data_collection.R")
    source("preprocessing.R")
    source("lexicon_sentiment.R")

    data <- load_data_from_csv("data/sample_data.csv")
    data <- preprocess_pipeline(data, remove_stops = FALSE)
    data <- lexicon_sentiment_analysis(data)

    # Perform sarcasm detection
    data <- sarcasm_analysis(data)

    # Get summary
    summary <- get_sarcasm_summary(data)
    print(summary$table)

    # Get sarcastic records
    sarcastic <- get_sarcastic_records(data)
    print(sarcastic)
}
