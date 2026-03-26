# =============================================================================
# QUICK REFERENCE GUIDE
# AI-Based Multi-Dimensional Sentiment Analysis System
# =============================================================================

## 🎯 CORE MODULES & KEY FUNCTIONS

### 1. DATA COLLECTION (data_collection.R)
```r
# Load CSV file
data <- load_data_from_csv("mydata.csv")

# Create from text
texts <- c("I love this!", "Hate it", "It's okay")
data <- create_manual_dataset(texts)

# Validate dataset
validate_dataset(data)

# Get summary
summary <- get_data_summary(data)
```

### 2. PREPROCESSING (preprocessing.R)
```r
# Complete preprocessing pipeline
data <- preprocess_pipeline(data,
                             remove_nums = TRUE,
                             remove_stops = FALSE)

# Individual steps
data$text <- clean_text(data$text)
data$text <- to_lowercase(data$text)
data$text <- remove_numbers(data$text)
data$text <- remove_stopwords(data$text)
tokens <- tokenize_text(data$text)
```

### 3. SENTIMENT ANALYSIS (lexicon_sentiment.R)
```r
# Complete sentiment analysis
data <- lexicon_sentiment_analysis(data)

# Individual functions
score <- calculate_sentiment_score(text)
polarity <- classify_polarity(score)
intensity <- calculate_intensity(score)

# Get summary
summary <- get_sentiment_summary(data)
print(summary$table)
```

Output columns added:
- sentiment_score (numeric)
- polarity (Positive/Negative/Neutral)
- intensity (Strong Positive/Mild Positive/Neutral/Mild Negative/Strong Negative)

### 4. EMOTION DETECTION (emotion_detection.R)
```r
# Complete emotion analysis
data <- emotion_analysis(data)

# Get summary
summary <- get_emotion_summary(data)
print(summary$emotion_totals)
print(summary$most_common_emotion)

# High emotion records
high_emotion <- get_high_emotion_records(data, threshold = 5)
```

Output columns added:
- anger, anticipation, disgust, fear, joy, sadness, surprise, trust (numeric)
- dominant_emotion (character)
- emotion_intensity (numeric)

### 5. SARCASM DETECTION (sarcasm_detection.R)
```r
# Complete sarcasm analysis
data <- sarcasm_analysis(data)

# Get summary
summary <- get_sarcasm_summary(data)
print(summary$table)

# Get sarcastic records
sarcastic <- get_sarcastic_records(data, min_confidence = 30)
```

Output columns added:
- is_sarcasm (TRUE/FALSE)
- sarcasm_confidence (0-100%)

### 6. TOPIC MODELING (topic_modeling.R)
```r
# Complete topic modeling
results <- topic_modeling_analysis(data, k = 3, n_terms = 5)
data <- results$data

# Get keywords
keywords <- get_topic_keywords_table(results$top_terms)
print(keywords)

# Topic distribution
dist <- get_topic_summary(data)
print(dist)

# Topics by sentiment
topic_sent <- analyze_topics_by_sentiment(data)
```

Output columns added:
- topic (integer)
- topic_probability (0-1)

### 7. TIME-SERIES ANALYSIS (time_series_analysis.R)
```r
# Complete time-series analysis
ts_results <- time_series_analysis(data)

if (ts_results$has_time_variation) {
  # Get summary
  summary <- get_timeseries_summary(ts_results)
  
  # Daily sentiment
  daily <- ts_results$daily_sentiment
  
  # Critical dates
  critical <- ts_results$critical_dates
  print(critical$most_negative_date)
  print(critical$most_positive_date)
}
```

Returns:
- daily_sentiment (aggregated by date)
- trends (peaks, valleys, overall)
- critical_dates (key dates)

### 8. MACHINE LEARNING (machine_learning_models.R)
```r
# Complete ML analysis
ml_results <- machine_learning_analysis(data)

# Model comparison
comparison <- create_model_comparison(ml_results)
print(comparison)

# Print summary
print_ml_summary(ml_results)

# Access confusion matrices
print(ml_results$nb_evaluation$confusion_matrix)
print(ml_results$svm_evaluation$confusion_matrix)
```

Returns:
- Naive Bayes model & evaluation
- SVM model & evaluation
- Comparison table

### 9. VISUALIZATION (visualization.R)
```r
# Create all visualizations
create_visualization_dashboard(data,
                                daily_sentiment,
                                ml_comparison)

# Individual plots
p <- plot_sentiment_distribution(data)
p <- plot_sentiment_intensity(data)
create_wordcloud(data, "positive", max_words = 100)
plot_emotion_radar(data)
p <- plot_sentiment_trend(daily_sentiment)
p <- plot_model_comparison(comparison)

# Save plot
ggsave("my_plot.png", p, width = 10, height = 6)
```

### 10. DASHBOARD (dashboard_app.R)
```r
# Launch interactive dashboard
source("dashboard_app.R")
```

### 11. MAIN PIPELINE (main.R)
```r
# Complete analysis
results <- run_complete_analysis(
  file_path = "mydata.csv",
  run_ml = TRUE,
  k_topics = 3
)

# Export results
export_results_to_csv(results, "output.csv")

# Access results components
data <- results$data
sentiment_summary <- results$sentiment_summary
emotion_summary <- results$emotion_summary
topic_results <- results$topic_results
ml_results <- results$ml_results
```

---

## 📊 QUICK COMMANDS

### Run Everything (Sample Data)
```r
setwd("path/to/project")
source("main.R")
```

### Run Everything (Your CSV)
```r
results <- run_complete_analysis("your_data.csv")
export_results_to_csv(results, "results.csv")
```

### Launch Dashboard
```r
source("dashboard_app.R")
```

### Module-by-Module
```r
# Load all modules
source("data_collection.R")
source("preprocessing.R")
source("lexicon_sentiment.R")
source("emotion_detection.R")
source("sarcasm_detection.R")
source("topic_modeling.R")
source("time_series_analysis.R")
source("machine_learning_models.R")
source("visualization.R")

# Run pipeline
data <- load_data_from_csv("data.csv")
data <- preprocess_pipeline(data, remove_stops = FALSE)
data <- lexicon_sentiment_analysis(data)
data <- emotion_analysis(data)
data <- sarcasm_analysis(data)
topic_results <- topic_modeling_analysis(data, k = 3)
data <- topic_results$data
ts_results <- time_series_analysis(data)
ml_results <- machine_learning_analysis(data)

# Export
write.csv(data, "results.csv", row.names = FALSE)
```

---

## 🎯 COMMON WORKFLOWS

### Workflow 1: Basic Sentiment Analysis
```r
data <- load_data_from_csv("reviews.csv")
data <- preprocess_pipeline(data)
data <- lexicon_sentiment_analysis(data)
summary <- get_sentiment_summary(data)
print(summary$table)
write.csv(data, "sentiment_results.csv", row.names = FALSE)
```

### Workflow 2: Sentiment + Emotions
```r
data <- load_data_from_csv("comments.csv")
data <- preprocess_pipeline(data, remove_stops = FALSE)
data <- lexicon_sentiment_analysis(data)
data <- emotion_analysis(data)

# Summaries
print(get_sentiment_summary(data)$table)
print(get_emotion_summary(data)$emotion_totals)

# Export
write.csv(data, "sentiment_emotion_results.csv", row.names = FALSE)
```

### Workflow 3: Complete Analysis
```r
results <- run_complete_analysis("data.csv", run_ml = TRUE, k_topics = 3)
export_results_to_csv(results, "complete_results.csv")
```

### Workflow 4: Dashboard Only
```r
# Just launch the interactive dashboard
source("dashboard_app.R")
# Upload your CSV in the browser
```

---

## 📈 INTERPRETING RESULTS

### Sentiment Score Ranges:
- **> 5**: Strong Positive
- **1 to 5**: Mild Positive
- **0**: Neutral
- **-1 to -5**: Mild Negative
- **< -5**: Strong Negative

### Emotion Scores:
- Higher value = more of that emotion
- Compare across emotions to find dominant
- Total intensity = sum of all emotions

### Sarcasm Confidence:
- **0-30%**: Low confidence (likely not sarcastic)
- **30-60%**: Medium confidence
- **60-100%**: High confidence (likely sarcastic)

### Topic Probability:
- **> 0.5**: Strong topic association
- **0.3-0.5**: Moderate association
- **< 0.3**: Weak association

### ML Model Metrics:
- **Accuracy**: Overall correctness (aim for > 70%)
- **Precision**: Positive prediction accuracy
- **Recall**: Positive detection rate
- **F1 Score**: Balanced metric (harmonic mean)

---

## 🔍 ACCESSING RESULTS

### From Complete Analysis:
```r
results <- run_complete_analysis("data.csv")

# Processed data
data <- results$data

# Sentiment
sentiment_summary <- results$sentiment_summary
positive_pct <- sentiment_summary$stats$positive_pct

# Emotions
emotion_summary <- results$emotion_summary
most_common_emotion <- emotion_summary$most_common_emotion

# Sarcasm
sarcasm_summary <- results$sarcasm_summary
sarcasm_count <- sarcasm_summary$stats$sarcastic_count

# Topics
topic_keywords <- results$topic_keywords

# Time-series
if (results$ts_results$has_time_variation) {
  daily_sentiment <- results$ts_results$daily_sentiment
  most_negative_date <- results$ts_results$critical_dates$most_negative_date
}

# Machine Learning
if (!is.null(results$ml_results)) {
  ml_comparison <- results$ml_comparison
  nb_accuracy <- ml_comparison$Accuracy[2]
}
```

### From Data Frame:
```r
# After running analysis
data <- lexicon_sentiment_analysis(data)

# Access columns
positive_texts <- data[data$polarity == "Positive", ]
strong_positive <- data[data$intensity == "Strong Positive", ]
high_scores <- data[data$sentiment_score > 3, ]

# Filter by emotion
joyful_texts <- data[data$dominant_emotion == "Joy", ]

# Sarcastic only
sarcastic <- data[data$is_sarcasm == TRUE, ]

# By topic
topic1_texts <- data[data$topic == 1, ]
```

---

## 🎨 CUSTOMIZATION

### Modify Lexicons:
Edit in lexicon_sentiment.R:
```r
load_lexicons <- function() {
  positive_words <- c("good", "great", "YOUR_WORD")
  negative_words <- c("bad", "terrible", "YOUR_WORD")
  # ... rest of function
}
```

### Adjust Sarcasm Rules:
Edit in sarcasm_detection.R:
```r
detect_sarcasm <- function(text, sentiment_score) {
  # Add your own rules here
  # Increase or decrease sarcasm_score based on patterns
}
```

### Change Number of Topics:
```r
topic_results <- topic_modeling_analysis(data, k = 5)  # 5 topics instead of 3
```

### Modify Visualizations:
Edit in visualization.R - change colors, sizes, themes

---

## 🚨 TROUBLESHOOTING

### Error: "Cannot open file"
```r
# Check working directory
getwd()
# Set correct directory
setwd("C:/correct/path")
```

### Error: "Package not found"
```r
install.packages("package_name", dependencies = TRUE)
library(package_name)
```

### Error: "Object not found"
```r
# Make sure you ran previous steps
source("module_name.R")
```

### Error: "Insufficient data for ML"
```r
# Need at least 10 samples (5 positive, 5 negative)
# Check: table(data$polarity)
```

### Warning: "No time variation"
```r
# All dates are the same - time-series not meaningful
# Check: unique(data$date)
```

---

## 💾 FILE OUTPUTS

After running complete analysis:

**Generated Files:**
- `sentiment_analysis_results.csv` - Full results
- `sentiment_distribution.png` - Bar chart
- `sentiment_intensity.png` - Intensity chart
- `wordcloud_positive.png` - Positive words
- `wordcloud_negative.png` - Negative words
- `emotion_radar.png` - Emotion radar
- `sentiment_trend.png` - Time-series (if applicable)
- `model_comparison.png` - ML comparison (if applicable)

**CSV Columns:**
- id, original_text, text, date, user
- sentiment_score, polarity, intensity
- anger, anticipation, disgust, fear, joy, sadness, surprise, trust
- dominant_emotion, emotion_intensity
- is_sarcasm, sarcasm_confidence
- topic, topic_probability

---

## 📚 FUNCTION PARAMETERS

### preprocess_pipeline()
- `data`: Dataframe with 'text' column
- `remove_nums`: TRUE/FALSE - remove numbers
- `remove_stops`: TRUE/FALSE - remove stopwords
- `custom_stopwords`: Vector of additional stopwords

### topic_modeling_analysis()
- `data`: Preprocessed dataframe
- `k`: Number of topics (default: 3)
- `n_terms`: Top terms per topic (default: 5)

### run_complete_analysis()
- `file_path`: Path to CSV (NULL for sample data)
- `run_ml`: TRUE/FALSE - run ML models
- `k_topics`: Number of topics (default: 3)

### create_wordcloud()
- `data`: Dataframe with tokens
- `sentiment_filter`: "positive", "negative", or "all"
- `max_words`: Maximum words to show (default: 100)

---

## 🎓 QUICK TIPS

1. **Always preprocess before analysis**: `preprocess_pipeline()`
2. **Keep stopwords for sentiment**: Use `remove_stops = FALSE`
3. **Check date format**: YYYY-MM-DD works best
4. **Start with sample data**: Verify installation
5. **Use dashboard for exploration**: Easier than code
6. **Export results frequently**: Don't lose your work
7. **Read console messages**: They guide you
8. **Check CSV encoding**: Use UTF-8
9. **Monitor memory**: Large datasets need more RAM
10. **Update packages**: Keep them current

---

## ⚡ PERFORMANCE TIPS

- Reduce `k_topics` for faster topic modeling
- Set `run_ml = FALSE` to skip ML (faster)
- Process large files in chunks
- Close other programs to free memory
- Use `max_words` parameter to limit word clouds
- Filter data before analysis if testing

---

**Quick Reference Version 1.0**  
**Keep this handy while coding!** 📖
