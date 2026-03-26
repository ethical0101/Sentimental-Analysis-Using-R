# =============================================================================
# TEXT PREPROCESSING MODULE
# Purpose: Clean and prepare text data for sentiment analysis
# Author: AI-Based Sentiment Intelligence System
# =============================================================================

# Load required libraries
library(tidyverse)
library(tm)
library(stringr)

#' Clean Text Data
#' @param text Character vector of text to clean
#' @return Cleaned text vector
#' @export
clean_text <- function(text) {
  
  # Store original for comparison
  original_text <- text
  
  # Remove URLs
  text <- str_replace_all(text, "http\\S+|www\\.\\S+", "")
  
  # Remove email addresses
  text <- str_replace_all(text, "\\S+@\\S+", "")
  
  # Remove mentions (@username)
  text <- str_replace_all(text, "@\\w+", "")
  
  # Remove hashtags but keep the text
  text <- str_replace_all(text, "#", "")
  
  # Remove punctuation (except apostrophes in contractions)
  text <- str_replace_all(text, "[^[:alnum:][:space:]'!?]", " ")
  
  # Remove extra whitespace
  text <- str_replace_all(text, "\\s+", " ")
  
  # Trim leading/trailing whitespace
  text <- str_trim(text)
  
  return(text)
}

#' Convert Text to Lowercase
#' @param text Character vector
#' @return Lowercase text
#' @export
to_lowercase <- function(text) {
  return(tolower(text))
}

#' Remove Numbers from Text
#' @param text Character vector
#' @param preserve_alphanumeric Keep alphanumeric words (e.g., COVID19)
#' @return Text without numbers
#' @export
remove_numbers <- function(text, preserve_alphanumeric = TRUE) {
  if (preserve_alphanumeric) {
    # Only remove standalone numbers
    text <- str_replace_all(text, "\\b\\d+\\b", "")
  } else {
    # Remove all digits
    text <- str_replace_all(text, "\\d+", "")
  }
  
  # Clean up extra spaces
  text <- str_replace_all(text, "\\s+", " ")
  text <- str_trim(text)
  
  return(text)
}

#' Remove Stopwords
#' @param text Character vector
#' @param custom_stopwords Additional stopwords to remove
#' @return Text without stopwords
#' @export
remove_stopwords <- function(text, custom_stopwords = NULL) {
  
  # Get standard English stopwords
  stopwords_list <- tm::stopwords("english")
  
  # Add custom stopwords if provided
  if (!is.null(custom_stopwords)) {
    stopwords_list <- c(stopwords_list, custom_stopwords)
  }
  
  # Remove stopwords
  text <- sapply(text, function(sentence) {
    words <- unlist(str_split(sentence, " "))
    words <- words[!words %in% stopwords_list]
    paste(words, collapse = " ")
  }, USE.NAMES = FALSE)
  
  return(text)
}

#' Tokenize Text into Words
#' @param text Character vector
#' @return List of word tokens for each text
#' @export
tokenize_text <- function(text) {
  tokens <- str_split(text, "\\s+")
  return(tokens)
}

#' Complete Preprocessing Pipeline
#' @param data Dataframe with 'text' column
#' @param remove_nums Remove numbers (default: TRUE)
#' @param remove_stops Remove stopwords (default: TRUE)
#' @param custom_stopwords Custom stopwords list
#' @return Dataframe with original and cleaned text
#' @export
preprocess_pipeline <- function(data, 
                                 remove_nums = TRUE, 
                                 remove_stops = TRUE,
                                 custom_stopwords = NULL) {
  
  message("Starting text preprocessing pipeline...")
  
  # Store original text
  data$original_text <- data$text
  
  # Step 1: Clean text
  message("  [1/5] Cleaning text (URLs, emails, special characters)...")
  data$text <- clean_text(data$text)
  
  # Step 2: Convert to lowercase
  message("  [2/5] Converting to lowercase...")
  data$text <- to_lowercase(data$text)
  
  # Step 3: Remove numbers
  if (remove_nums) {
    message("  [3/5] Removing numbers...")
    data$text <- remove_numbers(data$text)
  } else {
    message("  [3/5] Keeping numbers...")
  }
  
  # Step 4: Remove stopwords
  if (remove_stops) {
    message("  [4/5] Removing stopwords...")
    data$text <- remove_stopwords(data$text, custom_stopwords)
  } else {
    message("  [4/5] Keeping stopwords...")
  }
  
  # Step 5: Tokenize
  message("  [5/5] Tokenizing text...")
  data$tokens <- tokenize_text(data$text)
  data$word_count <- sapply(data$tokens, length)
  
  # Remove any empty text rows
  empty_rows <- data$text == "" | is.na(data$text)
  if (sum(empty_rows) > 0) {
    warning(sprintf("Removed %d rows with empty text after preprocessing", sum(empty_rows)))
    data <- data[!empty_rows, ]
  }
  
  message(sprintf("✓ Preprocessing complete! %d records processed.", nrow(data)))
  
  return(data)
}

#' Get Preprocessing Statistics
#' @param data Dataframe with original_text and text columns
#' @return Statistics about the preprocessing
#' @export
get_preprocessing_stats <- function(data) {
  
  if (!"original_text" %in% colnames(data)) {
    stop("Error: Dataframe must have 'original_text' column")
  }
  
  stats <- tibble(
    metric = c(
      "Total Records",
      "Avg Original Length",
      "Avg Cleaned Length",
      "Avg Words After Cleaning",
      "Total Words",
      "Unique Words",
      "Reduction (%)"
    ),
    value = c(
      nrow(data),
      mean(nchar(data$original_text), na.rm = TRUE),
      mean(nchar(data$text), na.rm = TRUE),
      mean(data$word_count, na.rm = TRUE),
      sum(data$word_count),
      length(unique(unlist(data$tokens))),
      round((1 - mean(nchar(data$text)) / mean(nchar(data$original_text))) * 100, 2)
    )
  )
  
  return(stats)
}

# Example usage
if (FALSE) {
  # Load data
  source("data_collection.R")
  data <- load_data_from_csv("data/sample_data.csv")
  
  # Preprocess
  data <- preprocess_pipeline(data)
  
  # Get stats
  stats <- get_preprocessing_stats(data)
  print(stats)
}
