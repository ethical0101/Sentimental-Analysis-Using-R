# =============================================================================
# MAIN ORCHESTRATION SCRIPT
# Purpose: Execute complete sentiment analysis pipeline
# Author: AI-Based Sentiment Intelligence System
# Project: AI-Based Multi-Dimensional Sentiment & Behavioral Intelligence System
# =============================================================================

# Clear environment
rm(list = ls())

# Load required libraries
cat("Loading required libraries...\n")
suppressPackageStartupMessages({
    library(tidyverse)
    library(tm)
    library(stringr)
    library(syuzhet)
    if (requireNamespace("tidytext", quietly = TRUE)) library(tidytext)
    if (requireNamespace("sentimentr", quietly = TRUE)) library(sentimentr)
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

cat("✓ Libraries loaded successfully\n\n")

# Source all modules
cat("Loading analysis modules...\n")
source("data_collection.R")
source("preprocessing.R")
source("lexicon_sentiment.R")
source("emotion_detection.R")
source("sarcasm_detection.R")
source("fake_review_detection.R")
source("topic_modeling.R")
source("time_series_analysis.R")
source("machine_learning_models.R")
source("visualization.R")
cat("✓ All modules loaded\n\n")

# =============================================================================
# MAIN ANALYSIS FUNCTION
# =============================================================================

#' Run Complete Sentiment Analysis Pipeline
#' @param file_path Path to CSV file or NULL for sample data
#' @param run_ml Whether to run machine learning models (default: TRUE)
#' @param k_topics Number of topics for LDA (default: 3)
#' @param train_ratio Train split ratio for ML (default: 0.8)
#' @param ml_max_features Maximum features for ML vectorization (default: 1200)
#' @param fast_mode If TRUE, enables faster ML settings on large datasets
#' @param use_gpu If TRUE, checks GPU availability and reports status
#' @return List containing all analysis results
#' @export
run_complete_analysis <- function(file_path = NULL,
                                  run_ml = TRUE,
                                  k_topics = 3,
                                  train_ratio = 0.8,
                                  ml_max_features = 1200,
                                  fast_mode = TRUE,
                                  use_gpu = TRUE) {
    cat("\n")
    cat("==========================================\n")
    cat("  AI SENTIMENT INTELLIGENCE SYSTEM v1.0  \n")
    cat("==========================================\n\n")

    start_time <- Sys.time()

    # ============================================================================
    # STEP 1: DATA COLLECTION
    # ============================================================================

    cat("[STEP 1/10] DATA COLLECTION\n")
    cat("--------------------------------------------\n")

    if (!is.null(file_path)) {
        data <- load_data_from_csv(file_path)
    } else {
        # Use sample data if no file provided
        cat("No file provided. Using sample data...\n")
        sample_texts <- c(
            "I absolutely love this product! It's amazing and works perfectly.",
            "This is the worst service I've ever experienced. Terrible!",
            "The item is okay, nothing special but does the job.",
            "I'm so happy with my purchase! Best decision ever.",
            "Disappointed with the quality. Not worth the price.",
            "Great customer support! They were very helpful and responsive.",
            "The product broke after one day. What a waste of money!",
            "It's decent. Not great but not bad either.",
            "Absolutely fantastic! I highly recommend this to everyone.",
            "Horrible experience. Will never buy from here again."
        )
        sample_dates <- seq(as.Date("2026-02-01"), by = "day", length.out = 10)
        data <- create_manual_dataset(sample_texts, sample_dates)
    }

    data_summary <- get_data_summary(data)
    cat(sprintf("\n✓ Loaded %d records\n\n", data_summary$total_records))

    # ============================================================================
    # STEP 2: TEXT PREPROCESSING
    # ============================================================================

    cat("[STEP 2/10] TEXT PREPROCESSING\n")
    cat("--------------------------------------------\n")

    data <- preprocess_pipeline(data, remove_nums = TRUE, remove_stops = FALSE)

    preprocess_stats <- get_preprocessing_stats(data)
    cat("\nPreprocessing Statistics:\n")
    print(preprocess_stats)
    cat("\n")

    # ============================================================================
    # STEP 3: LEXICON-BASED SENTIMENT ANALYSIS
    # ============================================================================

    cat("\n[STEP 3/10] LEXICON-BASED SENTIMENT ANALYSIS\n")
    cat("--------------------------------------------\n")

    data <- lexicon_sentiment_analysis(data)

    sentiment_summary <- get_sentiment_summary(data)
    cat("\nSentiment Distribution:\n")
    print(sentiment_summary$table)
    cat("\n")

    # ============================================================================
    # STEP 4: EMOTION DETECTION
    # ============================================================================

    cat("\n[STEP 4/10] EMOTION DETECTION\n")
    cat("--------------------------------------------\n")

    data <- emotion_analysis(
        data,
        chunk_size = if (fast_mode) 5000 else NULL,
        fast_mode = fast_mode,
        max_words_fast = 40
    )

    emotion_summary <- get_emotion_summary(data)
    cat("\nEmotion Summary:\n")
    print(emotion_summary$emotion_totals)
    cat(sprintf("\nMost Common Emotion: %s\n", emotion_summary$most_common_emotion))
    cat(sprintf("Average Emotion Intensity: %.2f\n\n", emotion_summary$avg_intensity))

    # ============================================================================
    # STEP 5: SARCASM DETECTION
    # ============================================================================

    cat("\n[STEP 5/10] SARCASM DETECTION\n")
    cat("--------------------------------------------\n")

    data <- sarcasm_analysis(data)

    sarcasm_summary <- get_sarcasm_summary(data)
    cat("\nSarcasm Summary:\n")
    print(sarcasm_summary$table)
    cat("\n")

    # ============================================================================
    # STEP 6: FAKE REVIEW DETECTION
    # ============================================================================

    cat("\n[STEP 6/10] FAKE REVIEW DETECTION\n")
    cat("--------------------------------------------\n")

    data <- fake_review_analysis(data)
    fake_review_summary <- get_fake_review_summary(data)

    cat("\nFake Review Summary:\n")
    print(fake_review_summary)
    cat("\n")

    # ============================================================================
    # STEP 6: TOPIC MODELING
    # ============================================================================

    cat("\n[STEP 7/10] TOPIC MODELING\n")
    cat("--------------------------------------------\n")

    topic_results <- topic_modeling_analysis(data, k = k_topics, n_terms = 5)
    data <- topic_results$data

    topic_keywords <- get_topic_keywords_table(topic_results$top_terms)
    cat("\nTopic Keywords:\n")
    print(topic_keywords)
    cat("\n")

    topic_distribution <- get_topic_summary(data)
    cat("Topic Distribution:\n")
    print(topic_distribution)
    cat("\n")

    # ============================================================================
    # STEP 7: TIME-SERIES ANALYSIS
    # ============================================================================

    cat("\n[STEP 8/10] TIME-SERIES ANALYSIS\n")
    cat("--------------------------------------------\n")

    ts_results <- time_series_analysis(data)

    if (ts_results$has_time_variation) {
        ts_summary <- get_timeseries_summary(ts_results)
        cat("\nTime-Series Summary:\n")
        cat(sprintf("  Date Range: %s\n", ts_summary$date_range))
        cat(sprintf("  Total Days: %d\n", ts_summary$total_days))
        cat(sprintf("  Overall Trend: %s\n", ts_summary$overall_trend))
        cat(sprintf("  Most Negative Date: %s\n", ts_summary$most_negative_date))
        cat(sprintf("  Most Positive Date: %s\n", ts_summary$most_positive_date))
        cat("\n")
    } else {
        cat("No time variation detected in data.\n\n")
    }

    # ============================================================================
    # STEP 8: MACHINE LEARNING MODELS
    # ============================================================================

    ml_results <- NULL
    ml_comparison <- NULL

    if (run_ml) {
        cat("\n[STEP 9/10] MACHINE LEARNING CLASSIFICATION\n")
        cat("--------------------------------------------\n")

        # Check if sufficient data for ML
        num_positive <- sum(data$polarity == "Positive")
        num_negative <- sum(data$polarity == "Negative")

        if (num_positive >= 5 && num_negative >= 5) {
            ml_results <- machine_learning_analysis(
                data,
                train_ratio = train_ratio,
                max_features = ml_max_features,
                fast_mode = fast_mode,
                use_gpu = use_gpu
            )

            cat("\nModel Performance Comparison:\n")
            ml_comparison <- create_model_comparison(ml_results)
            print(ml_comparison)
            cat("\n")
        } else {
            cat("Insufficient data for ML training (need at least 5 positive and 5 negative samples)\n")
            cat("Skipping machine learning step.\n\n")
        }
    } else {
        cat("\n[STEP 9/10] MACHINE LEARNING CLASSIFICATION\n")
        cat("--------------------------------------------\n")
        cat("Skipped (run_ml = FALSE)\n\n")
    }

    # ============================================================================
    # STEP 9: VISUALIZATION
    # ============================================================================

    cat("\n[STEP 10/10] CREATING VISUALIZATIONS\n")
    cat("--------------------------------------------\n")

    create_visualization_dashboard(
        data = data,
        daily_sentiment = ts_results$daily_sentiment,
        ml_comparison = ml_comparison
    )

    # ============================================================================
    # BEHAVIORAL ANALYTICS INSIGHTS
    # ============================================================================

    cat("\n")
    cat("==========================================\n")
    cat("      BEHAVIORAL ANALYTICS INSIGHTS      \n")
    cat("==========================================\n\n")

    # Identify topic with highest negativity
    if (!is.null(topic_results)) {
        topic_sentiment_analysis <- analyze_topics_by_sentiment(data)

        if (nrow(topic_sentiment_analysis) > 0) {
            most_negative_topic <- topic_sentiment_analysis %>%
                filter(topic > 0) %>%
                slice_max(Negative_Pct, n = 1)

            cat(sprintf(
                "🔍 Topic with Highest Negativity: Topic %d (%.1f%% negative)\n",
                most_negative_topic$topic,
                most_negative_topic$Negative_Pct
            ))
        }
    }

    # Peak negative date
    if (ts_results$has_time_variation) {
        cat(sprintf(
            "📉 Peak Negative Date: %s (Score: %.2f)\n",
            ts_results$critical_dates$most_negative_date,
            ts_results$critical_dates$most_negative_score
        ))
    }

    # Most common emotion
    cat(sprintf("😊 Most Common Emotion: %s\n", emotion_summary$most_common_emotion))

    # Sarcasm insights
    if (sarcasm_summary$stats$sarcastic_count > 0) {
        cat(sprintf(
            "🎭 Sarcasm Detection Rate: %.1f%% (%d instances)\n",
            sarcasm_summary$stats$sarcasm_rate,
            sarcasm_summary$stats$sarcastic_count
        ))
    }

    # Overall sentiment
    overall_sentiment <- case_when(
        sentiment_summary$stats$avg_score > 1 ~ "Generally Positive",
        sentiment_summary$stats$avg_score < -1 ~ "Generally Negative",
        TRUE ~ "Mixed/Neutral"
    )

    cat(sprintf(
        "\n📊 Overall Sentiment: %s (Avg Score: %.2f)\n",
        overall_sentiment,
        sentiment_summary$stats$avg_score
    ))

    # ============================================================================
    # COMPLETION
    # ============================================================================

    end_time <- Sys.time()
    elapsed_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

    cat("\n")
    cat("==========================================\n")
    cat("✓ ANALYSIS COMPLETE\n")
    cat(sprintf("⏱  Time Elapsed: %.2f seconds\n", elapsed_time))
    cat("==========================================\n\n")

    # Return all results
    return(list(
        data = data,
        data_summary = data_summary,
        preprocess_stats = preprocess_stats,
        sentiment_summary = sentiment_summary,
        emotion_summary = emotion_summary,
        sarcasm_summary = sarcasm_summary,
        fake_review_summary = fake_review_summary,
        topic_results = topic_results,
        topic_keywords = topic_keywords,
        ts_results = ts_results,
        ml_results = ml_results,
        ml_comparison = ml_comparison,
        elapsed_time = elapsed_time
    ))
}

# =============================================================================
# EXPORT RESULTS TO CSV
# =============================================================================

#' Export Analysis Results to CSV
#' @param results Results from run_complete_analysis()
#' @param output_file Output CSV filename
#' @export
export_results_to_csv <- function(results, output_file = "sentiment_analysis_results.csv") {
    cat(sprintf("\nExporting results to %s...\n", output_file))

    # Select key columns (only if they exist)
    export_data <- results$data %>%
        select(any_of(c(
            "id",
            "original_text",
            "text",
            "date",
            "user",
            "sentiment_score",
            "polarity",
            "intensity",
            "dominant_emotion",
            "anger", "anticipation", "disgust", "fear", "joy", "sadness", "surprise", "trust",
            "is_sarcasm",
            "sarcasm_confidence",
            "fake_review_flag",
            "credibility_score",
            "credibility_band",
            "topic",
            "topic_probability"
        )))

    # Convert list columns to character (to avoid write.csv errors)
    list_cols <- sapply(export_data, is.list)
    if (any(list_cols)) {
        for (col_name in names(export_data)[list_cols]) {
            export_data[[col_name]] <- as.character(export_data[[col_name]])
        }
    }

    # Write to CSV
    tryCatch(
        {
            write.csv(export_data, output_file, row.names = FALSE)
            cat(sprintf(
                "✓ Results exported successfully (%d records, %d columns)\n",
                nrow(export_data),
                ncol(export_data)
            ))
        },
        error = function(e) {
            cat(sprintf("✗ Export failed: %s\n", e$message))
            cat("Attempting simplified export...\n")

            # Fallback: only export simple columns
            simple_data <- export_data %>%
                select(where(~ !is.list(.)))

            write.csv(simple_data, output_file, row.names = FALSE)
            cat(sprintf(
                "✓ Simplified export complete (%d records, %d columns)\n",
                nrow(simple_data),
                ncol(simple_data)
            ))
        }
    )
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

if (sys.nframe() == 0) {
    # This block runs when script is executed directly

    cat("\n")
    cat("╔══════════════════════════════════════════════════════════╗\n")
    cat("║  AI-BASED MULTI-DIMENSIONAL SENTIMENT ANALYSIS SYSTEM   ║\n")
    cat("║                    Version 1.0                           ║\n")
    cat("╚══════════════════════════════════════════════════════════╝\n\n")

    # Prioritize main project dataset for real analysis runs
    if (file.exists("mail_dataset_1000.csv")) {
        results <- run_complete_analysis(
            "mail_dataset_1000.csv",
            run_ml = TRUE,
            k_topics = 3,
            train_ratio = 0.8,
            ml_max_features = 1200,
            fast_mode = TRUE,
            use_gpu = TRUE
        )
    } else if (file.exists("data/sample_data.csv")) {
        results <- run_complete_analysis("data/sample_data.csv", run_ml = TRUE, k_topics = 3)
    } else {
        cat("Sample data file not found. Running with built-in sample data.\n")
        results <- run_complete_analysis(NULL, run_ml = TRUE, k_topics = 3)
    }

    # Export results
    export_results_to_csv(results, "sentiment_analysis_results.csv")

    cat("\n")
    cat("╔══════════════════════════════════════════════════════════╗\n")
    cat("║  To view interactive dashboard, run:                     ║\n")
    cat("║  > source('dashboard_app.R')                             ║\n")
    cat("╚══════════════════════════════════════════════════════════╝\n\n")
}
