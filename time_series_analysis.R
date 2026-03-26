# =============================================================================
# TIME-SERIES SENTIMENT ANALYSIS MODULE
# Purpose: Analyze sentiment trends over time
# Author: AI-Based Sentiment Intelligence System
# =============================================================================

# Load required libraries
library(tidyverse)
library(lubridate)
library(zoo)

#' Aggregate Sentiment by Date
#' @param data Dataframe with 'date' and 'sentiment_score' columns
#' @return Daily aggregated sentiment
#' @export
aggregate_sentiment_by_date <- function(data) {
  
  if (!"date" %in% colnames(data)) {
    stop("Error: 'date' column required for time-series analysis")
  }
  
  if (!"sentiment_score" %in% colnames(data)) {
    stop("Error: 'sentiment_score' column required")
  }
  
  message("Aggregating sentiment by date...")
  
  daily_sentiment <- data %>%
    mutate(date = as.Date(date)) %>%
    group_by(date) %>%
    summarise(
      count = n(),
      avg_sentiment = mean(sentiment_score, na.rm = TRUE),
      median_sentiment = median(sentiment_score, na.rm = TRUE),
      sd_sentiment = sd(sentiment_score, na.rm = TRUE),
      min_sentiment = min(sentiment_score, na.rm = TRUE),
      max_sentiment = max(sentiment_score, na.rm = TRUE),
      positive_count = sum(polarity == "Positive", na.rm = TRUE),
      negative_count = sum(polarity == "Negative", na.rm = TRUE),
      neutral_count = sum(polarity == "Neutral", na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(date)
  
  message(sprintf("✓ Aggregated sentiment for %d days", nrow(daily_sentiment)))
  
  return(daily_sentiment)
}

#' Calculate Moving Average
#' @param sentiment_series Numeric sentiment scores
#' @param window Window size for moving average (default: 3)
#' @return Moving average series
#' @export
calculate_moving_average <- function(sentiment_series, window = 3) {
  
  ma <- rollmean(sentiment_series, k = window, fill = NA, align = "right")
  return(ma)
}

#' Detect Sentiment Trends
#' @param daily_sentiment Aggregated daily sentiment data
#' @return Trend analysis results
#' @export
detect_sentiment_trends <- function(daily_sentiment) {
  
  message("Detecting sentiment trends...")
  
  # Calculate moving average
  daily_sentiment$ma_3 <- calculate_moving_average(daily_sentiment$avg_sentiment, 3)
  daily_sentiment$ma_7 <- calculate_moving_average(daily_sentiment$avg_sentiment, 7)
  
  # Detect trend direction
  if (nrow(daily_sentiment) >= 2) {
    last_sentiment <- tail(daily_sentiment$avg_sentiment, 1)
    prev_sentiment <- tail(daily_sentiment$avg_sentiment, 2)[1]
    
    trend <- case_when(
      last_sentiment > prev_sentiment + 0.5 ~ "Improving",
      last_sentiment < prev_sentiment - 0.5 ~ "Declining",
      TRUE ~ "Stable"
    )
  } else {
    trend <- "Insufficient Data"
  }
  
  # Find peaks and valleys
  peaks <- daily_sentiment %>%
    slice_max(avg_sentiment, n = 3) %>%
    select(date, avg_sentiment) %>%
    rename(peak_date = date, peak_sentiment = avg_sentiment)
  
  valleys <- daily_sentiment %>%
    slice_min(avg_sentiment, n = 3) %>%
    select(date, avg_sentiment) %>%
    rename(valley_date = date, valley_sentiment = avg_sentiment)
  
  message("✓ Trend detection complete!")
  
  return(list(
    data = daily_sentiment,
    overall_trend = trend,
    peaks = peaks,
    valleys = valleys
  ))
}

#' Identify Critical Dates
#' @param data Original dataframe with dates
#' @param daily_sentiment Aggregated daily sentiment
#' @return Critical dates with analysis
#' @export
identify_critical_dates <- function(data, daily_sentiment) {
  
  # Most negative day
  most_negative <- daily_sentiment %>%
    slice_min(avg_sentiment, n = 1) %>%
    select(date, avg_sentiment, negative_count)
  
  # Most positive day
  most_positive <- daily_sentiment %>%
    slice_max(avg_sentiment, n = 1) %>%
    select(date, avg_sentiment, positive_count)
  
  # Highest activity day
  highest_activity <- daily_sentiment %>%
    slice_max(count, n = 1) %>%
    select(date, count, avg_sentiment)
  
  critical_dates <- list(
    most_negative_date = most_negative$date[1],
    most_negative_score = most_negative$avg_sentiment[1],
    most_positive_date = most_positive$date[1],
    most_positive_score = most_positive$avg_sentiment[1],
    highest_activity_date = highest_activity$date[1],
    highest_activity_count = highest_activity$count[1]
  )
  
  return(critical_dates)
}

#' Perform Complete Time-Series Analysis
#' @param data Dataframe with sentiment and date columns
#' @return Time-series analysis results
#' @export
time_series_analysis <- function(data) {
  
  message("Starting time-series sentiment analysis...")
  
  # Check if date variation exists
  unique_dates <- length(unique(data$date))
  
  if (unique_dates == 1) {
    warning("All records have the same date. Time-series analysis not meaningful.")
    return(list(
      data = data,
      daily_sentiment = NULL,
      trends = NULL,
      critical_dates = NULL,
      has_time_variation = FALSE
    ))
  }
  
  # Aggregate by date
  daily_sentiment <- aggregate_sentiment_by_date(data)
  
  # Detect trends
  trends <- detect_sentiment_trends(daily_sentiment)
  
  # Identify critical dates
  critical_dates <- identify_critical_dates(data, daily_sentiment)
  
  message("✓ Time-series analysis complete!")
  
  return(list(
    data = data,
    daily_sentiment = trends$data,
    trends = list(
      overall = trends$overall_trend,
      peaks = trends$peaks,
      valleys = trends$valleys
    ),
    critical_dates = critical_dates,
    has_time_variation = TRUE
  ))
}

#' Get Time-Series Summary
#' @param ts_results Results from time_series_analysis()
#' @return Summary statistics
#' @export
get_timeseries_summary <- function(ts_results) {
  
  if (!ts_results$has_time_variation) {
    return("No time variation in data")
  }
  
  daily <- ts_results$daily_sentiment
  
  summary_stats <- list(
    date_range = paste(min(daily$date), "to", max(daily$date)),
    total_days = nrow(daily),
    avg_daily_sentiment = mean(daily$avg_sentiment, na.rm = TRUE),
    overall_trend = ts_results$trends$overall,
    most_negative_date = ts_results$critical_dates$most_negative_date,
    most_positive_date = ts_results$critical_dates$most_positive_date,
    sentiment_volatility = sd(daily$avg_sentiment, na.rm = TRUE)
  )
  
  return(summary_stats)
}

#' Calculate Sentiment Momentum
#' @param daily_sentiment Daily aggregated sentiment
#' @return Momentum indicators
#' @export
calculate_sentiment_momentum <- function(daily_sentiment) {
  
  if (nrow(daily_sentiment) < 2) {
    return(NULL)
  }
  
  # Calculate day-over-day change
  daily_sentiment$sentiment_change <- c(0, diff(daily_sentiment$avg_sentiment))
  
  # Calculate momentum (percentage change)
  daily_sentiment$momentum <- c(0, diff(daily_sentiment$avg_sentiment) / 
                                   (abs(lag(daily_sentiment$avg_sentiment)[-1]) + 1) * 100)
  
  # Classify momentum
  daily_sentiment$momentum_category <- case_when(
    daily_sentiment$momentum > 10 ~ "Strong Positive",
    daily_sentiment$momentum > 0 ~ "Mild Positive",
    daily_sentiment$momentum == 0 ~ "Stable",
    daily_sentiment$momentum > -10 ~ "Mild Negative",
    TRUE ~ "Strong Negative"
  )
  
  return(daily_sentiment)
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
  
  # Perform time-series analysis
  ts_results <- time_series_analysis(data)
  
  # Get summary
  if (ts_results$has_time_variation) {
    summary <- get_timeseries_summary(ts_results)
    print(summary)
    
    print(ts_results$trends$peaks)
    print(ts_results$trends$valleys)
  }
}
