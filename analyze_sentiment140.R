# =============================================================================
# SENTIMENT140 DATASET ANALYSIS
# Dataset: training.1600000.processed.noemoticon.csv
# Size: 1.6 million tweets
# =============================================================================

# Clear environment
rm(list = ls())

cat("\n")
cat("╔══════════════════════════════════════════════════════════╗\n")
cat("║     SENTIMENT140 DATASET ANALYSIS (1.6M TWEETS)         ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n\n")

# Load required libraries
cat("Loading required libraries...\n")
suppressPackageStartupMessages({
  library(tidyverse)
  library(tm)
  library(stringr)
  library(syuzhet)
  library(caret)
  library(e1071)
  library(topicmodels)
  library(ggplot2)
  library(wordcloud)
  library(fmsb)
  library(DT)
  library(zoo)
  library(lubridate)
})
cat("✓ Libraries loaded\n\n")

# Source all analysis modules
cat("Loading analysis modules...\n")
source("data_collection.R")
source("preprocessing.R")
source("lexicon_sentiment.R")
source("emotion_detection.R")
source("sarcasm_detection.R")
source("topic_modeling.R")
source("time_series_analysis.R")
source("machine_learning_models.R")
source("visualization.R")
cat("✓ All modules loaded\n\n")

# =============================================================================
# CONFIGURATION
# =============================================================================

# File path
DATASET_FILE <- "training.1600000.processed.noemoticon.csv"

# Sampling configuration
USE_SAMPLE <- TRUE           # Set to FALSE to use full 1.6M dataset (will take hours!)
SAMPLE_SIZE <- 5000          # Number of tweets to analyze (recommended: 5000-50000)
BALANCED_SAMPLE <- TRUE      # Equal positive/negative samples

# Analysis configuration
RUN_MACHINE_LEARNING <- TRUE
NUM_TOPICS <- 5
EXPORT_RESULTS <- TRUE
MAX_ML_FEATURES <- 200       # Limit DTM features for faster ML training

# =============================================================================
# LOAD SENTIMENT140 DATASET
# =============================================================================

load_sentiment140_dataset <- function(file_path, sample_size = NULL, balanced = TRUE) {

  cat("\n[STEP 1/10] LOADING SENTIMENT140 DATASET\n")
  cat("─────────────────────────────────────────────────────\n")

  # Dataset column names
  col_names <- c("sentiment", "tweet_id", "date", "query", "user", "text")

  if (is.null(sample_size)) {
    # Load full dataset
    cat("Loading full dataset (1.6M tweets)...\n")
    cat("⚠ Warning: This will take several minutes and require significant RAM\n")

    data <- read.csv(
      file_path,
      header = FALSE,
      col.names = col_names,
      stringsAsFactors = FALSE,
      encoding = "UTF-8"
    )

  } else {
    # Load sample
    cat(sprintf("Loading sample of %d tweets...\n", sample_size))

    if (balanced) {
      # Try to get balanced positive/negative samples
      cat("Creating balanced sample (equal positive/negative)...\n")

      # Read in chunks and sample
      chunk_size <- 100000
      max_chunks <- 16  # 1.6M / 100k

      positive_samples <- data.frame()
      negative_samples <- data.frame()
      target_per_class <- ceiling(sample_size / 2)

      for (i in 1:max_chunks) {
        skip_rows <- (i - 1) * chunk_size

        chunk <- tryCatch({
          read.csv(
            file_path,
            header = FALSE,
            col.names = col_names,
            stringsAsFactors = FALSE,
            skip = skip_rows,
            nrows = chunk_size,
            encoding = "UTF-8"
          )
        }, error = function(e) NULL)

        if (is.null(chunk) || nrow(chunk) == 0) break

        # Separate by sentiment
        pos <- chunk[chunk$sentiment == 4, ]
        neg <- chunk[chunk$sentiment == 0, ]

        # Add samples
        if (nrow(positive_samples) < target_per_class && nrow(pos) > 0) {
          needed <- target_per_class - nrow(positive_samples)
          positive_samples <- rbind(positive_samples, head(pos, needed))
        }

        if (nrow(negative_samples) < target_per_class && nrow(neg) > 0) {
          needed <- target_per_class - nrow(negative_samples)
          negative_samples <- rbind(negative_samples, head(neg, needed))
        }

        # Check if we have enough
        if (nrow(positive_samples) >= target_per_class &&
            nrow(negative_samples) >= target_per_class) {
          break
        }

        cat(sprintf("  Processed chunk %d/%d (Pos: %d, Neg: %d)\n",
                    i, max_chunks, nrow(positive_samples), nrow(negative_samples)))
      }

      data <- rbind(positive_samples, negative_samples)
      data <- data[sample(nrow(data)), ]  # Shuffle

    } else {
      # Random sample
      cat("Creating random sample...\n")
      total_lines <- 1600000
      skip_rows <- sample(1:(total_lines - sample_size), 1)

      data <- read.csv(
        file_path,
        header = FALSE,
        col.names = col_names,
        stringsAsFactors = FALSE,
        skip = skip_rows,
        nrows = sample_size,
        encoding = "UTF-8"
      )
    }
  }

  # Convert sentiment labels (0 = negative, 4 = positive)
  data$original_sentiment <- data$sentiment
  data$sentiment <- ifelse(data$sentiment == 0, "Negative", "Positive")

  # Parse dates
  data$date <- as.Date(data$date, format = "%a %b %d %H:%M:%S PDT %Y")

  # Prepare for analysis
  analysis_data <- data.frame(
    id = seq_len(nrow(data)),
    text = data$text,
    date = data$date,
    original_text = data$text,
    source = "Twitter_Sentiment140",
    ground_truth = data$sentiment,  # Original labels from dataset
    user = data$user,
    stringsAsFactors = FALSE
  )

  cat(sprintf("\n✓ Loaded %d tweets\n", nrow(analysis_data)))
  cat(sprintf("  Positive: %d (%.1f%%)\n",
              sum(data$sentiment == "Positive"),
              100 * sum(data$sentiment == "Positive") / nrow(data)))
  cat(sprintf("  Negative: %d (%.1f%%)\n",
              sum(data$sentiment == "Negative"),
              100 * sum(data$sentiment == "Negative") / nrow(data)))
  cat(sprintf("  Date range: %s to %s\n",
              min(data$date, na.rm = TRUE),
              max(data$date, na.rm = TRUE)))
  cat("\n")

  return(analysis_data)
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

start_time <- Sys.time()

# Load dataset
if (USE_SAMPLE) {
  cat(sprintf("Configuration: Using sample of %d tweets\n", SAMPLE_SIZE))
  if (BALANCED_SAMPLE) {
    cat("Sample type: Balanced (equal positive/negative)\n")
  }
} else {
  cat("Configuration: Using FULL dataset (1.6M tweets)\n")
  cat("⚠ This will take considerable time and memory!\n")
}

data <- load_sentiment140_dataset(
  DATASET_FILE,
  sample_size = if (USE_SAMPLE) SAMPLE_SIZE else NULL,
  balanced = BALANCED_SAMPLE
)

# Run complete analysis pipeline
cat("\n")
cat("╔══════════════════════════════════════════════════════════╗\n")
cat("║         STARTING COMPLETE ANALYSIS PIPELINE              ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n\n")

# Step 2: Preprocessing
cat("[STEP 2/10] TEXT PREPROCESSING\n")
cat("─────────────────────────────────────────────────────\n")
data <- preprocess_pipeline(data, remove_nums = TRUE, remove_stops = FALSE)
cat("\n")

# Step 3: Lexicon-based sentiment
cat("[STEP 3/10] LEXICON-BASED SENTIMENT ANALYSIS\n")
cat("─────────────────────────────────────────────────────\n")
data <- lexicon_sentiment_analysis(data)

# Compare with ground truth
if ("ground_truth" %in% names(data)) {
  cat("\nComparison with Ground Truth Labels:\n")

  # Convert polarity to match ground truth
  data$predicted_sentiment <- ifelse(
    data$polarity == "Positive", "Positive",
    ifelse(data$polarity == "Negative", "Negative", NA)
  )

  # Calculate accuracy (excluding neutral predictions)
  valid_predictions <- !is.na(data$predicted_sentiment)
  if (sum(valid_predictions) > 0) {
    matches <- data$predicted_sentiment[valid_predictions] ==
               data$ground_truth[valid_predictions]
    accuracy <- sum(matches) / length(matches) * 100

    cat(sprintf("  Lexicon-based Accuracy: %.2f%%\n", accuracy))
    cat(sprintf("  Valid predictions: %d/%d\n", sum(valid_predictions), nrow(data)))
  }
}
cat("\n")

# Step 4: Emotion detection
cat("[STEP 4/10] EMOTION DETECTION\n")
cat("─────────────────────────────────────────────────────\n")
data <- emotion_analysis(data)
cat("\n")

# Step 5: Sarcasm detection
cat("[STEP 5/10] SARCASM DETECTION\n")
cat("─────────────────────────────────────────────────────\n")
data <- sarcasm_analysis(data)
cat("\n")

# Step 6: Topic modeling
cat("[STEP 6/10] TOPIC MODELING\n")
cat("─────────────────────────────────────────────────────\n")
topic_results <- topic_modeling_analysis(data, k = NUM_TOPICS, n_terms = 10)
data <- topic_results$data

cat("\nTop Keywords per Topic:\n")
topic_keywords <- get_topic_keywords_table(topic_results$top_terms)
print(topic_keywords)
cat("\n")

# Step 7: Time-series analysis
cat("[STEP 7/10] TIME-SERIES ANALYSIS\n")
cat("─────────────────────────────────────────────────────\n")
ts_results <- time_series_analysis(data)
cat("\n")

# Step 8: Machine learning
if (RUN_MACHINE_LEARNING) {
  cat("[STEP 8/10] MACHINE LEARNING CLASSIFICATION\n")
  cat("─────────────────────────────────────────────────────\n")

  # Use ground truth labels for training
  if ("ground_truth" %in% names(data)) {
    ml_results <- machine_learning_analysis(
      data,
      label_column = "ground_truth",  # Use original Sentiment140 labels
      max_features = MAX_ML_FEATURES
    )

    if (!is.null(ml_results)) {
      cat("\nModel Performance on Sentiment140:\n")
      cat("─────────────────────────────────────────────────────\n")

      cat(sprintf("\nNaive Bayes Accuracy: %.2f%%\n",
                  ml_results$nb_metrics$accuracy * 100))
      cat(sprintf("SVM Accuracy: %.2f%%\n",
                  ml_results$svm_metrics$accuracy * 100))

      cat("\nNaive Bayes Confusion Matrix:\n")
      print(ml_results$nb_metrics$confusion_matrix)

      cat("\nSVM Confusion Matrix:\n")
      print(ml_results$svm_metrics$confusion_matrix)
    }
  }
} else {
  cat("[STEP 8/10] MACHINE LEARNING - SKIPPED\n")
}
cat("\n")

# Step 9: Visualizations
cat("[STEP 9/10] CREATING VISUALIZATIONS\n")
cat("─────────────────────────────────────────────────────\n")

tryCatch({
  # Generate word clouds
  create_wordcloud(data, sentiment_filter = "positive", max_words = 50)
  create_wordcloud(data, sentiment_filter = "negative", max_words = 50)
  create_wordcloud(data, sentiment_filter = "all", max_words = 100)

  cat("✓ Visualizations created and saved\n")
}, error = function(e) {
  cat(sprintf("✓ Visualization generation skipped (optional)\n"))
})
cat("\n")

# Step 10: Export results
if (EXPORT_RESULTS) {
  cat("[STEP 10/10] EXPORTING RESULTS\n")
  cat("─────────────────────────────────────────────────────\n")

  # Remove any list columns that can't be exported
  export_data <- data %>%
    select(-any_of(c("vectors", "tokens", "wordslist")))

  # Convert any factor/complex columns to character
  for (col in names(export_data)) {
    if (class(export_data[[col]]) %in% c("list", "matrix")) {
      export_data[[col]] <- NULL
    }
  }

  output_file <- paste0("sentiment140_analysis_",
                        format(Sys.time(), "%Y%m%d_%H%M%S"),
                        ".csv")

  write.csv(export_data, output_file, row.names = FALSE)
  cat(sprintf("✓ Results exported to: %s\n", output_file))
  cat(sprintf("  Records: %d\n", nrow(export_data)))
  cat(sprintf("  Columns: %d\n", ncol(export_data)))
}

# =============================================================================
# FINAL SUMMARY
# =============================================================================

end_time <- Sys.time()
elapsed_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

cat("\n")
cat("╔══════════════════════════════════════════════════════════╗\n")
cat("║              SENTIMENT140 ANALYSIS COMPLETE              ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n\n")

cat("📊 SUMMARY STATISTICS\n")
cat("─────────────────────────────────────────────────────\n")
cat(sprintf("Total Tweets Analyzed: %d\n", nrow(data)))
cat(sprintf("Time Period: %s to %s\n",
            min(data$date, na.rm = TRUE),
            max(data$date, na.rm = TRUE)))

# Sentiment distribution
sentiment_dist <- table(data$polarity)
cat(sprintf("\nSentiment Distribution:\n"))
for (pol in names(sentiment_dist)) {
  cat(sprintf("  %s: %d (%.1f%%)\n",
              pol, sentiment_dist[pol],
              100 * sentiment_dist[pol] / nrow(data)))
}

# Top emotions
if ("dominant_emotion" %in% names(data)) {
  emotion_dist <- table(data$dominant_emotion)
  emotion_dist <- sort(emotion_dist, decreasing = TRUE)
  cat(sprintf("\nTop 3 Emotions:\n"))
  for (i in 1:min(3, length(emotion_dist))) {
    cat(sprintf("  %d. %s: %d tweets\n", i, names(emotion_dist)[i], emotion_dist[i]))
  }
}

# Sarcasm rate
if ("is_sarcasm" %in% names(data)) {
  sarcasm_count <- sum(data$is_sarcasm, na.rm = TRUE)
  cat(sprintf("\nSarcasm Detected: %d tweets (%.2f%%)\n",
              sarcasm_count, 100 * sarcasm_count / nrow(data)))
}

cat(sprintf("\n⏱  Processing Time: %.2f seconds\n", elapsed_time))
cat(sprintf("📁 Output File: %s\n", output_file))

cat("\n")
cat("╔══════════════════════════════════════════════════════════╗\n")
cat("║  Analysis complete! Check the visualizations and CSV.   ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n\n")
