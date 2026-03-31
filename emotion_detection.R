# =============================================================================
# EMOTION DETECTION MODULE
# Purpose: Detect emotions using NRC lexicon (Joy, Anger, Fear, Sadness, etc.)
# Author: AI-Based Sentiment Intelligence System
# =============================================================================

# Load required libraries
library(tidyverse)
library(syuzhet)

#' Detect Emotions using NRC Lexicon
#' @param text Character vector of text
#' @param chunk_size Optional chunk size for large datasets. If NULL, auto-detects.
#' @param max_words Maximum words to keep per text before scoring (default: Inf)
#' @return Dataframe with emotion scores for each text
#' @export
detect_emotions_nrc <- function(text, chunk_size = NULL, max_words = Inf) {
  message("Detecting emotions using NRC lexicon...")

  if (is.finite(max_words) && max_words > 0) {
    text <- vapply(strsplit(text, "\\s+"), function(tokens) {
      paste(head(tokens, max_words), collapse = " ")
    }, FUN.VALUE = character(1))
  }

  if (is.null(chunk_size)) {
    chunk_size <- if (length(text) >= 100000) 50000 else length(text)
  }

  # Run in chunks for large datasets to reduce memory pressure and avoid crashes.
  if (length(text) > chunk_size) {
    message(sprintf("Using chunked emotion scoring (chunk_size=%d)...", chunk_size))
    starts <- seq(1, length(text), by = chunk_size)
    emotion_list <- vector("list", length(starts))

    for (i in seq_along(starts)) {
      start_idx <- starts[i]
      end_idx <- min(start_idx + chunk_size - 1, length(text))
      message(sprintf("  Processing chunk %d/%d (%d:%d)", i, length(starts), start_idx, end_idx))
      emotion_list[[i]] <- get_nrc_sentiment(text[start_idx:end_idx])
    }

    emotion_scores <- bind_rows(emotion_list)
  } else {
    # This returns 10 columns: anger, anticipation, disgust, fear, joy,
    # sadness, surprise, trust, negative, positive
    emotion_scores <- get_nrc_sentiment(text)
  }

  message(sprintf("✓ Emotion detection complete for %d records.", length(text)))

  return(emotion_scores)
}

#' Get Dominant Emotion for Each Text
#' @param emotion_scores Dataframe from detect_emotions_nrc()
#' @return Character vector of dominant emotions
#' @export
get_dominant_emotion <- function(emotion_scores) {
  # Select only emotion columns (exclude positive/negative)
  emotion_cols <- c(
    "anger", "anticipation", "disgust", "fear",
    "joy", "sadness", "surprise", "trust"
  )

  emotion_data <- emotion_scores[, emotion_cols]

  # Find dominant emotion (column with max value)
  dominant <- apply(emotion_data, 1, function(row) {
    if (all(row == 0)) {
      return("Neutral")
    } else {
      return(names(which.max(row)))
    }
  })

  # Capitalize first letter
  dominant <- str_to_title(dominant)

  return(dominant)
}

#' Calculate Total Emotion Intensity
#' @param emotion_scores Dataframe from detect_emotions_nrc()
#' @return Numeric vector of total emotion intensity
#' @export
calculate_emotion_intensity <- function(emotion_scores) {
  emotion_cols <- c(
    "anger", "anticipation", "disgust", "fear",
    "joy", "sadness", "surprise", "trust"
  )

  intensity <- rowSums(emotion_scores[, emotion_cols])

  return(intensity)
}

#' Perform Complete Emotion Analysis
#' @param data Dataframe with 'text' column
#' @param chunk_size Optional chunk size override for NRC scoring
#' @param fast_mode If TRUE, uses faster settings for large datasets
#' @param max_words_fast Max words per text when fast_mode is enabled
#' @return Dataframe with emotion scores and classifications
#' @export
emotion_analysis <- function(data,
                             chunk_size = NULL,
                             fast_mode = FALSE,
                             max_words_fast = 40) {
  message("Starting emotion analysis pipeline...")

  max_words <- Inf
  if (isTRUE(fast_mode) && nrow(data) > 3000) {
    if (is.null(chunk_size)) {
      chunk_size <- 5000
    }
    max_words <- max_words_fast
    message(sprintf(
      "Fast emotion mode enabled (chunk_size=%d, max_words=%d)",
      chunk_size,
      max_words_fast
    ))
  }

  # Detect emotions
  emotion_scores <- detect_emotions_nrc(
    data$text,
    chunk_size = chunk_size,
    max_words = max_words
  )

  # Replace existing NRC columns (if present) to avoid duplicated names
  nrc_cols <- colnames(emotion_scores)
  data <- data %>%
    select(-any_of(nrc_cols)) %>%
    bind_cols(emotion_scores)

  # Get dominant emotion
  message("  [1/2] Identifying dominant emotions...")
  data$dominant_emotion <- get_dominant_emotion(emotion_scores)

  # Calculate emotion intensity
  message("  [2/2] Calculating emotion intensity...")
  data$emotion_intensity <- calculate_emotion_intensity(emotion_scores)

  message("✓ Emotion analysis complete!")

  return(data)
}

#' Get Emotion Summary Statistics
#' @param data Dataframe with emotion columns
#' @return Summary of emotion distribution
#' @export
get_emotion_summary <- function(data) {
  emotion_cols <- c(
    "anger", "anticipation", "disgust", "fear",
    "joy", "sadness", "surprise", "trust"
  )

  # Calculate total for each emotion
  emotion_totals <- sapply(emotion_cols, function(col) {
    sum(data[[col]], na.rm = TRUE)
  })

  # Create summary table
  summary_table <- tibble(
    Emotion = str_to_title(names(emotion_totals)),
    Total_Count = as.numeric(emotion_totals),
    Percentage = round((Total_Count / sum(Total_Count)) * 100, 2)
  ) %>%
    arrange(desc(Total_Count))

  # Dominant emotion distribution
  dominant_dist <- data %>%
    count(dominant_emotion, name = "Count") %>%
    mutate(Percentage = round((Count / sum(Count)) * 100, 2)) %>%
    arrange(desc(Count))

  # Most common emotion
  most_common <- dominant_dist$dominant_emotion[1]

  return(list(
    emotion_totals = summary_table,
    dominant_distribution = dominant_dist,
    most_common_emotion = most_common,
    avg_intensity = mean(data$emotion_intensity, na.rm = TRUE)
  ))
}

#' Create Emotion Comparison by Polarity
#' @param data Dataframe with emotion and polarity columns
#' @return Emotion comparison across sentiment polarities
#' @export
compare_emotions_by_polarity <- function(data) {
  if (!"polarity" %in% colnames(data)) {
    stop("Error: Data must have 'polarity' column. Run sentiment analysis first.")
  }

  emotion_cols <- c(
    "anger", "anticipation", "disgust", "fear",
    "joy", "sadness", "surprise", "trust"
  )

  comparison <- data %>%
    group_by(polarity) %>%
    summarise(
      across(all_of(emotion_cols), ~ mean(.x, na.rm = TRUE)),
      .groups = "drop"
    ) %>%
    pivot_longer(
      cols = all_of(emotion_cols),
      names_to = "Emotion",
      values_to = "Avg_Score"
    ) %>%
    mutate(Emotion = str_to_title(Emotion))

  return(comparison)
}

#' Identify High Emotion Records
#' @param data Dataframe with emotion scores
#' @param threshold Minimum total emotion score (default: 5)
#' @return Subset of highly emotional records
#' @export
get_high_emotion_records <- function(data, threshold = 5) {
  high_emotion <- data %>%
    filter(emotion_intensity >= threshold) %>%
    select(
      id, text, dominant_emotion, emotion_intensity,
      anger, joy, fear, sadness
    ) %>%
    arrange(desc(emotion_intensity))

  message(sprintf(
    "Found %d high-emotion records (threshold: %d)",
    nrow(high_emotion), threshold
  ))

  return(high_emotion)
}

# Example usage
if (FALSE) {
  # Load and preprocess data
  source("data_collection.R")
  source("preprocessing.R")
  source("lexicon_sentiment.R")

  data <- load_data_from_csv("data/sample_data.csv")
  data <- preprocess_pipeline(data, remove_stops = FALSE)
  data <- lexicon_sentiment_analysis(data)

  # Perform emotion analysis
  data <- emotion_analysis(data)

  # Get summary
  summary <- get_emotion_summary(data)
  print(summary$emotion_totals)
  print(summary$dominant_distribution)

  # Compare emotions across polarities
  comparison <- compare_emotions_by_polarity(data)
  print(comparison)
}
