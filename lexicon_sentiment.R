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
  intensifiers <- c("very", "extremely", "highly", "absolutely", "totally", 
                    "completely", "really", "so", "quite", "particularly")
  
  # Create negation words
  negations <- c("not", "no", "never", "neither", "nobody", "nothing", 
                 "nowhere", "cannot", "cant", "dont", "doesnt", "wont",
                 "wouldnt", "shouldnt", "didnt", "isnt", "arent", "wasnt",
                 "werent", "havent", "hasnt", "hadnt")
  
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
  data$polarity <- classify_polarity(data$sentiment_score)
  
  # Calculate intensity
  message("  [3/3] Computing intensity levels...")
  data$intensity <- calculate_intensity(data$sentiment_score)
  
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
