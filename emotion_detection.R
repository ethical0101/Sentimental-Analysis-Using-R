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
#' @return Dataframe with emotion scores for each text
#' @export
detect_emotions_nrc <- function(text) {
  
  message("Detecting emotions using NRC lexicon...")
  
  # Get NRC sentiment scores
  # This returns 10 columns: anger, anticipation, disgust, fear, joy, 
  # sadness, surprise, trust, negative, positive
  emotion_scores <- get_nrc_sentiment(text)
  
  message(sprintf("✓ Emotion detection complete for %d records.", length(text)))
  
  return(emotion_scores)
}

#' Get Dominant Emotion for Each Text
#' @param emotion_scores Dataframe from detect_emotions_nrc()
#' @return Character vector of dominant emotions
#' @export
get_dominant_emotion <- function(emotion_scores) {
  
  # Select only emotion columns (exclude positive/negative)
  emotion_cols <- c("anger", "anticipation", "disgust", "fear", 
                    "joy", "sadness", "surprise", "trust")
  
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
  
  emotion_cols <- c("anger", "anticipation", "disgust", "fear", 
                    "joy", "sadness", "surprise", "trust")
  
  intensity <- rowSums(emotion_scores[, emotion_cols])
  
  return(intensity)
}

#' Perform Complete Emotion Analysis
#' @param data Dataframe with 'text' column
#' @return Dataframe with emotion scores and classifications
#' @export
emotion_analysis <- function(data) {
  
  message("Starting emotion analysis pipeline...")
  
  # Detect emotions
  emotion_scores <- detect_emotions_nrc(data$text)
  
  # Add emotion scores to dataframe
  data <- cbind(data, emotion_scores)
  
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
  
  emotion_cols <- c("anger", "anticipation", "disgust", "fear", 
                    "joy", "sadness", "surprise", "trust")
  
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
  
  emotion_cols <- c("anger", "anticipation", "disgust", "fear", 
                    "joy", "sadness", "surprise", "trust")
  
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
    select(id, text, dominant_emotion, emotion_intensity, 
           anger, joy, fear, sadness) %>%
    arrange(desc(emotion_intensity))
  
  message(sprintf("Found %d high-emotion records (threshold: %d)", 
                  nrow(high_emotion), threshold))
  
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
