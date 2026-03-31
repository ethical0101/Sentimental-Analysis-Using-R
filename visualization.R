# =============================================================================
# VISUALIZATION MODULE
# Purpose: Create comprehensive visualizations for sentiment analysis results
# Author: AI-Based Sentiment Intelligence System
# =============================================================================

# Load required libraries
library(tidyverse)
library(ggplot2)
library(wordcloud)
library(RColorBrewer)
library(fmsb)
library(gridExtra)

#' Create Sentiment Distribution Bar Chart
#' @param data Dataframe with polarity column
#' @return ggplot object
#' @export
plot_sentiment_distribution <- function(data) {

  sentiment_counts <- data %>%
    count(polarity) %>%
    mutate(percentage = round(n / sum(n) * 100, 1))

  p <- ggplot(sentiment_counts, aes(x = polarity, y = n, fill = polarity)) +
    geom_bar(stat = "identity", width = 0.7) +
    geom_text(aes(label = paste0(n, "\n(", percentage, "%)")),
              vjust = -0.5, size = 4.5, fontface = "bold") +
    scale_fill_manual(values = c(
      "Positive" = "#2ecc71",
      "Negative" = "#e74c3c",
      "Neutral" = "#95a5a6"
    )) +
    labs(
      title = "Sentiment Distribution",
      subtitle = paste("Total Records:", nrow(data)),
      x = "Sentiment Polarity",
      y = "Count"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 12, hjust = 0.5),
      legend.position = "none",
      axis.text = element_text(size = 11)
    )

  return(p)
}

#' Create Sentiment Intensity Bar Chart
#' @param data Dataframe with intensity column
#' @return ggplot object
#' @export
plot_sentiment_intensity <- function(data) {

  intensity_counts <- data %>%
    count(intensity) %>%
    mutate(
      intensity = factor(intensity, levels = c(
        "Strong Negative", "Mild Negative", "Neutral",
        "Mild Positive", "Strong Positive"
      ))
    ) %>%
    arrange(intensity)

  p <- ggplot(intensity_counts, aes(x = intensity, y = n, fill = intensity)) +
    geom_bar(stat = "identity", width = 0.7) +
    geom_text(aes(label = n), vjust = -0.5, size = 4) +
    scale_fill_manual(values = c(
      "Strong Negative" = "#c0392b",
      "Mild Negative" = "#e67e22",
      "Neutral" = "#95a5a6",
      "Mild Positive" = "#f39c12",
      "Strong Positive" = "#27ae60"
    )) +
    labs(
      title = "Sentiment Intensity Distribution",
      x = "Intensity Level",
      y = "Count"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
      legend.position = "none",
      axis.text.x = element_text(angle = 45, hjust = 1)
    )

  return(p)
}

#' Create Word Cloud
#' @param data Dataframe with tokens column
#' @param sentiment_filter Filter by sentiment: "positive", "negative", or "all"
#' @param max_words Maximum number of words (default: 100)
#' @return Creates word cloud plot
#' @export
create_wordcloud <- function(data, sentiment_filter = "all", max_words = 100) {

  # Filter data
  if (sentiment_filter == "positive") {
    filtered_data <- data %>% filter(polarity == "Positive")
    colors <- brewer.pal(8, "Greens")[3:8]
    title <- "Positive Sentiment Word Cloud"
  } else if (sentiment_filter == "negative") {
    filtered_data <- data %>% filter(polarity == "Negative")
    colors <- brewer.pal(8, "Reds")[3:8]
    title <- "Negative Sentiment Word Cloud"
  } else {
    filtered_data <- data
    colors <- brewer.pal(8, "Set2")
    title <- "Overall Word Cloud"
  }

  # Extract words
  words <- unlist(filtered_data$tokens)
  word_freq <- table(words)
  word_freq <- sort(word_freq, decreasing = TRUE)

  # Create word cloud
  if (length(word_freq) > 0) {
    par(mar = c(0, 0, 2, 0))
    wordcloud(
      words = names(word_freq),
      freq = word_freq,
      max.words = max_words,
      random.order = FALSE,
      colors = colors,
      scale = c(3.5, 0.5),
      rot.per = 0.35
    )
    title(main = title, font.main = 2, cex.main = 1.5)
  } else {
    plot.new()
    text(0.5, 0.5, "No words to display", cex = 1.5)
  }
}

#' Create Emotion Radar Chart
#' @param data Dataframe with emotion columns
#' @return Creates radar chart
#' @export
plot_emotion_radar <- function(data) {

  emotion_cols <- c("anger", "anticipation", "disgust", "fear",
                    "joy", "sadness", "surprise", "trust")

  # Calculate average emotions
  emotion_avgs <- data %>%
    summarise(across(all_of(emotion_cols), ~ mean(.x, na.rm = TRUE))) %>%
    pivot_longer(everything(), names_to = "emotion", values_to = "score")

  # Normalize to 0-100 scale
  max_score <- max(emotion_avgs$score, na.rm = TRUE)
  if (max_score > 0) {
    emotion_avgs$score <- (emotion_avgs$score / max_score) * 100
  }

  # Prepare data for radar chart (fmsb format)
  radar_data <- data.frame(t(emotion_avgs$score))
  colnames(radar_data) <- str_to_title(emotion_avgs$emotion)

  # Add max and min rows
  radar_data <- rbind(
    rep(100, ncol(radar_data)),  # Max
    rep(0, ncol(radar_data)),    # Min
    radar_data
  )

  # Create radar chart
  par(mar = c(1, 1, 3, 1))
  radarchart(
    radar_data,
    axistype = 1,
    pcol = "#2c3e50",
    pfcol = rgb(0.2, 0.5, 0.8, 0.5),
    plwd = 2,
    cglcol = "grey",
    cglty = 1,
    axislabcol = "grey20",
    caxislabels = seq(0, 100, 25),
    cglwd = 0.8,
    vlcex = 0.9,
    title = "Emotion Distribution"
  )
}

#' Create Time-Series Sentiment Trend Line Chart
#' @param daily_sentiment Daily aggregated sentiment data
#' @return ggplot object
#' @export
plot_sentiment_trend <- function(daily_sentiment) {

  if (is.null(daily_sentiment) || nrow(daily_sentiment) == 0) {
    p <- ggplot() +
      annotate("text", x = 0.5, y = 0.5,
               label = "No time-series data available", size = 6) +
      theme_void()
    return(p)
  }

  p <- ggplot(daily_sentiment, aes(x = date, y = avg_sentiment)) +
    geom_line(color = "#3498db", size = 1.2) +
    geom_point(color = "#2c3e50", size = 2.5) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_smooth(method = "loess", se = TRUE, color = "#e74c3c",
                fill = "#e74c3c", alpha = 0.2, linetype = "dashed") +
    labs(
      title = "Sentiment Trend Over Time",
      subtitle = paste("Date Range:", min(daily_sentiment$date), "to",
                       max(daily_sentiment$date)),
      x = "Date",
      y = "Average Sentiment Score"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 11, hjust = 0.5),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )

  return(p)
}

#' Create Topic Distribution Pie Chart
#' @param data Dataframe with topic assignments
#' @param top_terms Topic top terms
#' @return ggplot object
#' @export
plot_topic_distribution <- function(data, top_terms = NULL) {

  topic_counts <- data %>%
    filter(topic > 0) %>%
    count(topic) %>%
    mutate(
      percentage = round(n / sum(n) * 100, 1),
      label = paste0("Topic ", topic, "\n", n, " (", percentage, "%)")
    )

  if (nrow(topic_counts) == 0) {
    p <- ggplot() +
      annotate("text", x = 0.5, y = 0.5,
               label = "No topic data available", size = 6) +
      theme_void()
    return(p)
  }

  p <- ggplot(topic_counts, aes(x = "", y = n, fill = factor(topic))) +
    geom_bar(stat = "identity", width = 1) +
    coord_polar("y", start = 0) +
    geom_text(aes(label = label), position = position_stack(vjust = 0.5)) +
    scale_fill_brewer(palette = "Set3") +
    labs(
      title = "Topic Distribution",
      fill = "Topic"
    ) +
    theme_void() +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
      legend.position = "right"
    )

  return(p)
}

#' Create Model Comparison Bar Chart
#' @param comparison_table Model comparison dataframe
#' @return ggplot object
#' @export
plot_model_comparison <- function(comparison_table) {

  comparison_long <- comparison_table %>%
    pivot_longer(
      cols = c(Accuracy, Precision, Recall, F1_Score),
      names_to = "Metric",
      values_to = "Score"
    ) %>%
    filter(!is.na(Score))

  p <- ggplot(comparison_long, aes(x = Model, y = Score, fill = Metric)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7) +
    geom_text(aes(label = round(Score, 1)),
              position = position_dodge(width = 0.7),
              vjust = -0.5, size = 3) +
    scale_fill_brewer(palette = "Set2") +
    labs(
      title = "Machine Learning Model Performance Comparison",
      x = "Model",
      y = "Score (%)",
      fill = "Metric"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
      axis.text.x = element_text(angle = 0, hjust = 0.5)
    )

  return(p)
}

#' Create Comprehensive Visualization Dashboard
#' @param data Complete analyzed dataset
#' @param daily_sentiment Time-series data
#' @param ml_comparison ML comparison table
#' @export
create_visualization_dashboard <- function(data, daily_sentiment = NULL,
                                           ml_comparison = NULL) {

  message("Creating comprehensive visualizations...")

  # Create all plots
  p1 <- plot_sentiment_distribution(data)
  p2 <- plot_sentiment_intensity(data)
  p_emotion <- ggplot(
    data %>%
      summarise(
        anger = sum(anger, na.rm = TRUE),
        anticipation = sum(anticipation, na.rm = TRUE),
        disgust = sum(disgust, na.rm = TRUE),
        fear = sum(fear, na.rm = TRUE),
        joy = sum(joy, na.rm = TRUE),
        sadness = sum(sadness, na.rm = TRUE),
        surprise = sum(surprise, na.rm = TRUE),
        trust = sum(trust, na.rm = TRUE)
      ) %>%
      pivot_longer(everything(), names_to = "emotion", values_to = "score"),
    aes(x = reorder(emotion, score), y = score, fill = emotion)
  ) +
    geom_col(show.legend = FALSE) +
    coord_flip() +
    labs(title = "Emotion Distribution", x = "Emotion", y = "Score") +
    theme_minimal()

  # Create word clouds (saved as separate files)
  png("wordcloud_positive.png", width = 800, height = 600)
  create_wordcloud(data, "positive")
  dev.off()

  png("wordcloud_negative.png", width = 800, height = 600)
  create_wordcloud(data, "negative")
  dev.off()

  png("wordcloud.png", width = 800, height = 600)
  create_wordcloud(data, "all")
  dev.off()

  # Emotion radar chart
  png("emotion_radar.png", width = 800, height = 600)
  plot_emotion_radar(data)
  dev.off()

  # Time-series plot
  if (!is.null(daily_sentiment)) {
    p3 <- plot_sentiment_trend(daily_sentiment)
    ggsave("sentiment_trend.png", p3, width = 10, height = 6)
    ggsave("trend.png", p3, width = 10, height = 6)
  }

  # Topic distribution
  if ("topic" %in% names(data) && any(data$topic > 0, na.rm = TRUE)) {
    p_topic <- plot_topic_distribution(data)
    ggsave("topic_distribution.png", p_topic, width = 10, height = 6)
  }

  # Fake review distribution (if available)
  if ("fake_review_flag" %in% names(data)) {
    p_fake <- data %>%
      count(fake_review_flag) %>%
      mutate(percentage = round(n / sum(n) * 100, 1)) %>%
      ggplot(aes(x = fake_review_flag, y = n, fill = fake_review_flag)) +
      geom_col(width = 0.7, show.legend = FALSE) +
      geom_text(aes(label = paste0(n, " (", percentage, "%)")), vjust = -0.4) +
      labs(
        title = "Fake Review Detection Summary",
        x = "Label",
        y = "Count"
      ) +
      theme_minimal()
    ggsave("fake_review_detection.png", p_fake, width = 10, height = 6)
  }

  # Save other plots
  ggsave("sentiment_distribution.png", p1, width = 8, height = 6)
  ggsave("sentiment_intensity.png", p2, width = 10, height = 6)
  ggsave("emotion_distribution.png", p_emotion, width = 10, height = 6)

  # ML comparison
  if (!is.null(ml_comparison)) {
    p4 <- plot_model_comparison(ml_comparison)
    ggsave("model_comparison.png", p4, width = 10, height = 6)
  }

  # Dashboard overview collage from real generated charts
  p_dash_a <- p1 + ggtitle("Sentiment")
  p_dash_b <- p2 + ggtitle("Intensity")
  p_dash_c <- p_emotion + ggtitle("Emotions")
  p_dash_d <- if (!is.null(ml_comparison)) {
    plot_model_comparison(ml_comparison) + ggtitle("ML Comparison")
  } else {
    ggplot() +
      annotate("text", x = 0.5, y = 0.5, label = "ML not enabled", size = 6) +
      theme_void() +
      ggtitle("ML Comparison")
  }

  png("dashboard_overview.png", width = 1400, height = 900)
  grid.arrange(p_dash_a, p_dash_b, p_dash_c, p_dash_d, ncol = 2)
  dev.off()

  message("✓ All visualizations created and saved!")
}

# Example usage
if (FALSE) {
  # Load complete analysis
  source("main.R")
  results <- run_complete_analysis("data/sample_data.csv")

  # Create visualizations
  create_visualization_dashboard(
    data = results$data,
    daily_sentiment = results$ts_results$daily_sentiment,
    ml_comparison = results$ml_comparison
  )
}
