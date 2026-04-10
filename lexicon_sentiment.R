# =============================================================================
# LEXICON-BASED SENTIMENT ANALYSIS MODULE
# Purpose: Compute sentiment polarity and intensity using lexicon approach
# Author: AI-Based Sentiment Intelligence System
# =============================================================================

# Load required libraries
library(tidyverse)
library(stringr)

#' Load Positive and Negative Word Lexicons
#' @return List containing positive and negative word vectors
#' @export
load_lexicons <- function() {
    # Positive words lexicon
    positive_words <- c(
        "good", "great", "excellent", "amazing", "wonderful", "fantastic",
        "awesome", "love", "loved", "loving", "best", "perfect", "beautiful",
        "happy", "joy", "joyful", "glad", "pleased", "delighted", "satisfied",
        "brilliant", "superb", "outstanding", "exceptional", "magnificent",
        "incredible", "terrific", "fabulous", "nice", "pleasant", "positive",
        "favorable", "advantageous", "beneficial", "valuable", "worthwhile",
        "appreciate", "appreciated", "inspiring", "motivated", "confident",
        "comfortable", "excited", "exciting", "enthusiastic", "optimistic",
        "success", "successful", "win", "winning", "winner", "achieve",
        "achievement", "accomplish", "improve", "improved", "improvement"
    )

    # Negative words lexicon
    negative_words <- c(
        "bad", "terrible", "horrible", "awful", "worst", "poor", "disappointing",
        "disappointed", "sad", "angry", "hate", "hated", "hating", "dislike",
        "annoying", "annoyed", "frustrating", "frustrated", "upset", "unhappy",
        "depressed", "miserable", "useless", "worthless", "pathetic", "disgusting",
        "ridiculous", "stupid", "dumb", "idiotic", "fake", "fraud", "scam",
        "problem", "issue", "error", "mistake", "fail", "failure", "failed",
        "broken", "damage", "damaged", "defective", "wrong", "incorrect",
        "difficult", "hard", "complicated", "confusing", "confused", "unclear",
        "slow", "waste", "wasted", "expensive", "overpriced", "cheap", "boring",
        "bored", "tired", "exhausted", "painful", "hurt", "harm", "negative"
    )

    # Create intensifiers
    intensifiers <- c(
        "very", "extremely", "highly", "absolutely", "totally",
        "completely", "really", "so", "quite", "particularly"
    )

    # Create negation words
    negations <- c(
        "not", "no", "never", "neither", "nobody", "nothing",
        "nowhere", "cannot", "cant", "dont", "doesnt", "wont",
        "wouldnt", "shouldnt", "didnt", "isnt", "arent", "wasnt",
        "werent", "havent", "hasnt", "hadnt"
    )

    return(list(
        positive = positive_words,
        negative = negative_words,
        intensifiers = intensifiers,
        negations = negations
    ))
}

#' Calculate Sentiment Score for Text
#' @param text Character vector of text
#' @param lexicons Lexicon list from load_lexicons()
#' @return Sentiment score (positive = positive, negative = negative)
#' @export
calculate_sentiment_score <- function(text, lexicons = NULL) {
    if (is.null(lexicons)) {
        lexicons <- load_lexicons()
    }

    scores <- sapply(text, function(sentence) {
        # Tokenize
        words <- unlist(str_split(tolower(sentence), "\\s+"))

        # Count positive and negative words
        pos_count <- sum(words %in% lexicons$positive)
        neg_count <- sum(words %in% lexicons$negative)

        # Check for intensifiers
        intensifier_count <- sum(words %in% lexicons$intensifiers)
        intensifier_multiplier <- 1 + (intensifier_count * 0.5)

        # Check for negations (flip sentiment if present)
        negation_count <- sum(words %in% lexicons$negations)

        # Calculate base score
        score <- (pos_count - neg_count) * intensifier_multiplier

        # Apply negation (flip score if odd number of negations)
        if (negation_count %% 2 == 1) {
            score <- -score
        }

        return(score)
    }, USE.NAMES = FALSE)

    return(scores)
}

#' Classify Sentiment Polarity
#' @param score Numeric sentiment score
#' @return Character vector: "Positive", "Negative", or "Neutral"
#' @export
classify_polarity <- function(score) {
    polarity <- case_when(
        score > 0 ~ "Positive",
        score < 0 ~ "Negative",
        TRUE ~ "Neutral"
    )
    return(polarity)
}

#' Calculate Sentiment Intensity
#' @param score Numeric sentiment score
#' @return Character vector describing intensity level
#' @export
calculate_intensity <- function(score) {
    intensity <- case_when(
        score > 5 ~ "Strong Positive",
        score >= 1 & score <= 5 ~ "Mild Positive",
        score == 0 ~ "Neutral",
        score <= -1 & score >= -5 ~ "Mild Negative",
        score < -5 ~ "Strong Negative",
        TRUE ~ "Neutral"
    )
    return(intensity)
}

#' Detect first available sentiment label column from input data
#' @param data Input dataframe
#' @return Column name or NULL
#' @export
detect_existing_label_column <- function(data) {
    candidates <- c("polarity", "sentiment", "label", "ground_truth")
    found <- candidates[candidates %in% names(data)]
    if (length(found) == 0) {
        return(NULL)
    }
    return(found[1])
}

#' Add external lexicon-based scores (tidytext, sentimentr, syuzhet)
#' @param data Dataframe with text column
#' @param text_column Text column name (default: "text")
#' @param existing_label_column Optional existing sentiment label column
#' @return Dataframe with additional lexicon score columns
#' @export
add_external_lexicon_scores <- function(data,
                                        text_column = "text",
                                        existing_label_column = NULL) {
    if (!text_column %in% names(data)) {
        stop(sprintf("Error: '%s' column required for lexicon scoring", text_column))
    }

    input_text <- as.character(data[[text_column]])
    input_text[is.na(input_text)] <- ""

    data$row_id_internal <- seq_len(nrow(data))

    # tidytext score using Bing lexicon: positive - negative token counts.
    if (requireNamespace("tidytext", quietly = TRUE)) {
        tidy_input <- tibble(row_id_internal = data$row_id_internal, text = input_text)
        tidy_scores <- tidy_input %>%
            tidytext::unnest_tokens(word, text) %>%
            inner_join(tidytext::get_sentiments("bing"), by = "word") %>%
            mutate(score_component = ifelse(sentiment == "positive", 1, -1)) %>%
            group_by(row_id_internal) %>%
            summarise(tidytext_score = sum(score_component, na.rm = TRUE), .groups = "drop")

        data <- data %>%
            left_join(tidy_scores, by = "row_id_internal")
        data$tidytext_score[is.na(data$tidytext_score)] <- 0
    } else {
        data$tidytext_score <- 0
        message("Info: Package 'tidytext' not installed. tidytext_score set to 0.")
    }

    # sentimentr sentence-aware sentiment score.
    if (requireNamespace("sentimentr", quietly = TRUE)) {
        sentimentr_tbl <- sentimentr::sentiment_by(input_text)
        data$sentimentr_score <- sentimentr_tbl$ave_sentiment
        data$sentimentr_score[is.na(data$sentimentr_score)] <- 0
    } else {
        data$sentimentr_score <- 0
        message("Info: Package 'sentimentr' not installed. sentimentr_score set to 0.")
    }

    # syuzhet lexicon score.
    if (requireNamespace("syuzhet", quietly = TRUE)) {
        data$syuzhet_score <- syuzhet::get_sentiment(input_text, method = "syuzhet")
        data$syuzhet_score[is.na(data$syuzhet_score)] <- 0
    } else {
        data$syuzhet_score <- 0
        message("Info: Package 'syuzhet' not installed. syuzhet_score set to 0.")
    }

    # Composite score to stabilize one-lexicon biases.
    data$lexicon_composite_score <- rowMeans(
        cbind(data$tidytext_score, data$sentimentr_score, data$syuzhet_score),
        na.rm = TRUE
    )

    data$lexicon_based_polarity <- classify_polarity(data$lexicon_composite_score)

    if (is.null(existing_label_column)) {
        existing_label_column <- detect_existing_label_column(data)
    }

    if (!is.null(existing_label_column) && existing_label_column %in% names(data)) {
        data$lexicon_label_match <- data$lexicon_based_polarity == as.character(data[[existing_label_column]])
    } else {
        data$lexicon_label_match <- NA
    }

    data$row_id_internal <- NULL
    return(data)
}

#' Perform Complete Lexicon-Based Sentiment Analysis
#' @param data Dataframe with 'text' column
#' @return Dataframe with sentiment scores and classifications
#' @export
lexicon_sentiment_analysis <- function(data) {
    message("Performing lexicon-based sentiment analysis...")

    # Load lexicons
    lexicons <- load_lexicons()

    # Calculate sentiment scores
    message("  [1/3] Calculating sentiment scores...")
    data$sentiment_score <- calculate_sentiment_score(data$text, lexicons)

    # Classify polarity
    message("  [2/3] Classifying polarity...")
    computed_polarity <- classify_polarity(data$sentiment_score)
    data$analysis_polarity <- computed_polarity

    # Preserve input sentiment labels if already present.
    if (!("polarity" %in% names(data))) {
        data$polarity <- computed_polarity
    } else if (!("input_polarity" %in% names(data))) {
        data$input_polarity <- data$polarity
    }

    data$lexicon_polarity <- computed_polarity

    # Calculate intensity
    message("  [3/3] Computing intensity levels...")
    computed_intensity <- calculate_intensity(data$sentiment_score)
    data$analysis_intensity <- computed_intensity
    if (!("intensity" %in% names(data))) {
        data$intensity <- computed_intensity
    }

    # External lexicon scoring block aligned to Sentometrics-style methodology.
    data <- add_external_lexicon_scores(
        data,
        text_column = "text",
        existing_label_column = detect_existing_label_column(data)
    )

    message(sprintf("✓ Sentiment analysis complete! Processed %d records.", nrow(data)))

    return(data)
}

#' Get Sentiment Distribution Summary
#' @param data Dataframe with sentiment results
#' @return Summary statistics
#' @export
get_sentiment_summary <- function(data) {
    summary_stats <- list(
        total_records = nrow(data),
        positive_count = sum(data$polarity == "Positive"),
        negative_count = sum(data$polarity == "Negative"),
        neutral_count = sum(data$polarity == "Neutral"),
        positive_pct = round(mean(data$polarity == "Positive") * 100, 2),
        negative_pct = round(mean(data$polarity == "Negative") * 100, 2),
        neutral_pct = round(mean(data$polarity == "Neutral") * 100, 2),
        avg_score = mean(data$sentiment_score, na.rm = TRUE),
        median_score = median(data$sentiment_score, na.rm = TRUE),
        score_sd = sd(data$sentiment_score, na.rm = TRUE)
    )

    # Create summary table
    summary_table <- tibble(
        Polarity = c("Positive", "Negative", "Neutral", "Total"),
        Count = c(
            summary_stats$positive_count,
            summary_stats$negative_count,
            summary_stats$neutral_count,
            summary_stats$total_records
        ),
        Percentage = c(
            summary_stats$positive_pct,
            summary_stats$negative_pct,
            summary_stats$neutral_pct,
            100.0
        )
    )

    return(list(stats = summary_stats, table = summary_table))
}

# Example usage
if (FALSE) {
    # Load and preprocess data
    source("data_collection.R")
    source("preprocessing.R")

    data <- load_data_from_csv("data/sample_data.csv")
    data <- preprocess_pipeline(data, remove_stops = FALSE)

    # Perform sentiment analysis
    data <- lexicon_sentiment_analysis(data)

    # Get summary
    summary <- get_sentiment_summary(data)
    print(summary$table)
}
