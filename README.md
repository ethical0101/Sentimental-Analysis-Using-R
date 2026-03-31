# 🎯 AI-Based Multi-Dimensional Sentiment Analysis System in R

*A Comprehensive Text Intelligence Platform for Advanced Sentiment & Behavioral Analysis*

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [Installation Guide](#installation-guide)
- [Quick Start](#quick-start)
- [Module Documentation](#module-documentation)
- [API Reference](#api-reference)
- [Data Format](#data-format)
- [Output & Results](#output--results)
- [Use Cases](#use-cases)
- [Troubleshooting](#troubleshooting)
- [License & Attribution](#license--attribution)

---

## 📌 Overview

This is an **enterprise-grade sentiment analysis system** built entirely in R that transcends traditional binary positive/negative classification by incorporating **multi-dimensional analysis** including emotion detection, sarcasm identification, topic modeling, temporal trend analysis, and machine learning model comparison.

### What Makes This System Special?

Unlike standard sentiment analysis tools that only classify text as positive or negative, this system provides:

✅ **Multi-dimensional Intelligence**: Analyzes sentiment, 8 distinct emotions, sarcasm, and thematic content simultaneously
✅ **Linguistic Sophistication**: Handles negations, intensifiers, contradictions, and implicit meanings
✅ **Temporal Awareness**: Tracks sentiment trends over time with peak/valley detection
✅ **Machine Learning Validation**: Compares lexicon-based methods with Naive Bayes and SVM classifiers
✅ **Production-Ready**: Complete pipeline from raw text to actionable insights
✅ **User-Friendly**: Interactive web-based dashboard for non-technical users
✅ **Academic-Grade**: Fully documented methodology suitable for research and publication
✅ **Extensible**: Modular architecture allows easy customization and enhancement

---

## ✨ Key Features

### 1. **Sentiment Analysis**
- **Polarity Classification**: Positive, Negative, Neutral
- **Intensity Scoring**: Strong Positive → Mild Positive → Neutral → Mild Negative → Strong Negative
- **Smart Detection**: Handles negations ("not good"), intensifiers ("very bad"), and context-aware scoring
- **Confidence Scoring**: Know the strength of each sentiment classification

### 2. **Emotion Detection (NRC Lexicon)**
Identifies and quantifies 8 distinct emotions based on the NRC (Mohammad-Turney) emotion lexicon:
- **Anger** – Expressions of frustration, rage, or hostility
- **Anticipation** – Forward-looking expectations, excitement, or dread
- **Disgust** – Expressions of revulsion or distaste
- **Fear** – Expressions of anxiety, worry, or threat
- **Joy** – Positive emotional states, happiness, contentment
- **Sadness** – Expressions of sorrow, melancholy, or grief
- **Surprise** – Unexpected reactions (positive or negative)
- **Trust** – Confidence, reliability, and positive relationships

Each text receives scores for all 8 emotions, enabling nuanced emotional profiling beyond simple polarity.

### 3. **Sarcasm Detection**
Rule-based pattern matching identifies linguistic subtleties:
- **Excessive Punctuation**: Multiple exclamation marks, question marks, or ellipses
- **Automated Emoji Detection**: Use of sarcasm-indicating emoticons
- **Contradiction Patterns**: Statements that contradict themselves ("Great job... on failing")
- **Quotation Analysis**: Strategic use of quotation marks to imply irony
- **Confidence Scoring**: 0-100% confidence rating for each sarcasm detection

### 4. **Topic Modeling (LDA)**
- **Latent Dirichlet Allocation (LDA)**: Unsupervised discovery of hidden themes in text
- **Configurable Topics**: Set number of topics (default: 3)
- **Top Keywords**: Extract most relevant words for each topic
- **Topic Distribution**: See how each document maps to discovered topics
- **Sentiment-Topic Cross-Analysis**: Understand which topics drive sentiment

### 5. **Time-Series Sentiment Analysis**
- **Daily Aggregation**: Automatic grouping of sentiment by date
- **Trend Detection**: Identify improving, declining, or stable sentiment trajectories
- **Peak-Valley Analysis**: Automatically detect dates with extreme sentiment values
- **Critical Date Identification**: Highlight most positive and negative periods
- **Visualization**: Line graphs showing sentiment evolution over time

### 6. **Machine Learning Classification**
Compare lexicon-based methods with supervised learning:
- **Naive Bayes Classifier**: Probabilistic classifier trained on sentiment polarities
- **Support Vector Machine (SVM)**: Advanced kernel-based classifier for complex patterns
- **Performance Comparison**: Accuracy, precision, recall, F1-score, and confusion matrices
- **Model Validation**: Cross-validation and performance metrics
- **Feature Analysis**: Understand which words drive ML predictions

### 7. **Advanced Visualizations**
- **Sentiment Distribution**: Bar charts showing polarity distribution
- **Emotion Radar Charts**: 8-pointed radar showing emotional makeup of corpus
- **Word Clouds**: Separate clouds for positive and negative sentiment text
- **Time-Series Graphs**: Sentiment trends with trend lines
- **Topic Pie Charts**: Visual distribution across discovered topics
- **ML Comparison Charts**: Performance metrics comparison across classifiers

### 8. **Interactive Dashboard**
- **Web-Based Interface**: Built with Shiny, no installation needed for users
- **File Upload**: Support for CSV files up to 50MB
- **Manual Text Entry**: Analyze single texts or multiple pastes
- **Real-Time Analysis**: Progressive analysis display
- **Interactive Tables**: DT-powered tables with sorting, filtering, search
- **Download Results**: Export analysis to CSV with single click
- **Responsive Design**: Works on desktop, tablet, and mobile

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              INPUT LAYER                                │
│                                                                         │
│  ┌──────────────────────┐    ┌──────────────────────┐                  │
│  │    CSV File Upload   │    │    Manual Text Entry │                  │
│  │   (data_collection)  │    │   (data_collection)  │                  │
│  └──────────┬───────────┘    └──────────┬───────────┘                  │
└─────────────┼──────────────────────────┼───────────────────────────────┘
              │                          │
              └──────────────┬───────────┘
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        PREPROCESSING LAYER                              │
│                                                                         │
│  ┌─────────────┐  ┌──────────┐  ┌─────────────┐  ┌──────────────┐    │
│  │  Text       │→ │Lowercase │→ │ Remove      │→ │  Tokenize    │    │
│  │  Cleaning   │  │          │  │ Stopwords   │  │  (optional)  │    │
│  └─────────────┘  └──────────┘  └─────────────┘  └──────────────┘    │
│                                                                         │
│  • Removes special characters & HTML entities                         │
│  • Converts contractions (don't → do not)                             │
│  • Normalizes whitespace & punctuation                                │
│  • Optional number and stopword removal                               │
└─────────────┬───────────────────────────────────────────────────────┘
              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                   MULTI-DIMENSIONAL ANALYSIS LAYER                      │
│                                                                         │
│  ┌────────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │ Sentiment  │  │ Emotion  │  │ Sarcasm  │  │  Topic   │            │
│  │ Analysis   │  │Detection │  │Detection │  │ Modeling │            │
│  │(lex_sent)  │  │(emotion) │  │(sarcasm) │  │(topics)  │            │
│  └────────────┘  └──────────┘  └──────────┘  └──────────┘            │
│                                                                         │
│  ┌────────────┐  ┌──────────────┐                                     │
│  │ Time-Series│  │   Machine    │                                     │
│  │  Analysis  │  │   Learning   │                                     │
│  │  (ts_anal) │  │    Models    │                                     │
│  └────────────┘  │    (ml_mod)  │                                     │
│                  └──────────────┘                                     │
└─────────────┬───────────────────────────────────────────────────────┘
              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│              AGGREGATION, VALIDATION & ENRICHMENT LAYER                 │
│                                                                         │
│  • Merge results from all analysis modules                             │
│  • Cross-validate findings across methods                              │
│  • Generate summary statistics and reports                             │
│  • Prepare data for visualization                                      │
└─────────────┬───────────────────────────────────────────────────────┘
              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│            VISUALIZATION & OUTPUT EXPORT LAYER                          │
│                                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │  Static  │  │ Word     │  │ Emotion  │  │  CSV     │              │
│  │  Charts  │  │ Clouds   │  │  Radar   │  │ Export   │              │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘              │
│                                                                         │
│  ┌────────────────────────────────────────────────────────────┐       │
│  │       Interactive Shiny Dashboard (Web Interface)          │       │
│  └────────────────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────────────────┘
```

### Data Flow Through Modules

```
Raw Text Input
     ↓
[data_collection.R]     → Load & validate data
     ↓
[preprocessing.R]       → Clean, tokenize, normalize
     ↓
[lexicon_sentiment.R]   → Polarity & intensity scores
     ↓
[emotion_detection.R]   → 8-emotion profiling
     ↓
[sarcasm_detection.R]   → Sarcasm patterns & confidence
     ↓
[topic_modeling.R]      → LDA topic discovery
     ↓
[time_series_analysis.R]→ Temporal trends (if dates present)
     ↓
[machine_learning.R]    → Naive Bayes & SVM models
     ↓
[visualization.R]       → Generate all charts & clouds
     ↓
[main.R]               → Orchestrate entire pipeline
     ↓
Enriched Dataset + Reports + Visualizations + CSV Export
```

---

## 💾 Installation Guide

### Prerequisites

**Minimum Requirements:**
- **Operating System**: Windows 10+, macOS 10.13+, Linux (Ubuntu 18.04+)
- **RAM**: 4GB minimum (8GB recommended for large datasets)
- **Disk Space**: 2GB free (for R, packages, and outputs)
- **Internet Connection**: Required for package installation

**Recommended:**
- RAM: 16GB for datasets > 100,000 records
- SSD for faster package installation and data processing

### Step 1: Install R (4.0 or Higher)

#### **Windows:**
1. Download from: https://cran.r-project.org/bin/windows/base/
2. Run the installer (.exe file)
3. Use default installation options
4. R will be installed to: `C:\Program Files\R\R-x.x.x`
5. **Add R to PATH** (optional, for command-line access):
   - Right-click "This PC" → Properties
   - Advanced system settings → Environment Variables
   - Add R's bin folder to PATH

#### **macOS:**
1. Download from: https://cran.r-project.org/bin/macosx/
2. Run the installer (.pkg file)
3. Use default installation options
4. Alternatively, via Homebrew:
   ```bash
   brew install r
   ```

#### **Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install -y r-base r-base-dev
```

**Linux (CentOS/RHEL):**
```bash
sudo yum install R
```

**Verify Installation:**
```r
R --version
```

You should see: `R version 4.x.x or higher`

### Step 2: Install RStudio (Optional but Highly Recommended)

RStudio provides a user-friendly IDE for R with integrated package management and debugging.

1. Download: https://posit.co/download/rstudio-desktop/
2. Install and run RStudio
3. RStudio will automatically detect your R installation

### Step 3: Download Project Files

1. Clone or download the project repository
2. Extract to a folder, e.g.: `C:\Users\YourName\Documents\sentiment-analysis`
3. Ensure all project files are in this folder (see File Manifest below)

### Step 4: Install Project Dependencies

**Method A: Automated (Recommended)**

Open R or RStudio and run:

```r
setwd("C:/path/to/sentiment-analysis")  # Update with your actual path
source("install_packages.R")
```

This will:
- Detect missing packages
- Install them automatically with dependencies
- Verify successful installation
- Take 5-15 minutes depending on internet speed

**Method B: Manual Installation**

If automated installation fails, manually install each package:

```r
# Core data manipulation & text processing
install.packages("tidyverse")
install.packages("tm")
install.packages("stringr")
install.packages("tidytext")

# Sentiment & emotion analysis
install.packages("syuzhet")

# Machine learning
install.packages("caret")
install.packages("e1071")
install.packages("topicmodels")

# Visualization
install.packages("ggplot2")
install.packages("wordcloud")
install.packages("fmsb")
install.packages("plotly")
install.packages("RColorBrewer")

# Dashboard & web interface
install.packages("shiny")
install.packages("shinydashboard")
install.packages("DT")

# Time series & dates
install.packages("zoo")
install.packages("lubridate")

# Load and verify
library(tidyverse)
library(tm)
library(syuzhet)
# ... etc
```

**Install Rtools (Windows Only, if Packages Need Compilation)**

Some packages require compilation from source. If you encounter compilation errors:

1. Download from: https://cran.r-project.org/bin/windows/Rtools/
2. Run installer with default options
3. Rtools will be added to PATH automatically
4. Restart R and retry package installation

### Step 5: Verify Installation

Test that everything is working:

```r
setwd("C:/path/to/sentiment-analysis")

# Load main module
source("main.R")

# Run quick test with sample data
results <- run_complete_analysis(run_ml = FALSE, k_topics = 2)

# Export test results
export_results_to_csv(results, "test_results.csv")

# Check CSV was created
file.exists("test_results.csv")
```

If successful, you should see:
- ✓ No errors in console
- ✓ `test_results.csv` created in project folder
- ✓ Analysis took 30 seconds to 2 minutes

---

## 🚀 Quick Start

### Scenario 1: First-Time Run with Sample Data

**Time Required**: 5-10 minutes including installation

```r
# Step 1: Set working directory
setwd("C:/path/to/sentiment-analysis")

# Step 2: Install packages (first time only)
source("install_packages.R")

# Step 3: Run analysis
source("main.R")

# Step 4: View results
list.files(pattern = "\\.(csv|png)$")
```

**What You'll Get:**
- `sentiment_analysis_results.csv` – Full analysis dataset
- `sentiment_distribution.png` – Bar chart of sentiment polarity
- `emotion_radar.png` – 8-emotion radar chart
- `wordcloud_positive.png` – Word cloud of positive text
- `wordcloud_negative.png` – Word cloud of negative text
- `sentiment_trends.png` – Time-series line graph

### Scenario 2: Analyze Your Own Data

**Required File Format**: CSV with `text` column minimum

```r
setwd("C:/path/to/sentiment-analysis")

# Assuming your file is "my_reviews.csv"
results <- run_complete_analysis(
  file_path = "my_reviews.csv",
  run_ml = TRUE,           # Include ML models (takes longer)
  k_topics = 4             # Number of topics to discover
)

# Export results
export_results_to_csv(results, "my_reviews_analysis.csv")
```

### Scenario 3: Interactive Dashboard (Recommended for Exploration)

```r
setwd("C:/path/to/sentiment-analysis")

# Launch dashboard
source("dashboard_app.R")
```

This opens an interactive web interface at `http://localhost:3838` where you can:
- Upload CSV files
- Enter text manually
- View real-time results
- Download results
- Explore visualizations

### Scenario 4: Custom Analysis with Advanced Options

```r
setwd("C:/path/to/sentiment-analysis")
source("main.R")

# Load your data
data <- load_data_from_csv("my_data.csv")

# Validate
validate_dataset(data)

# Step-by-step analysis
data <- preprocess_pipeline(data, remove_nums = TRUE, remove_stops = FALSE)
data <- lexicon_sentiment_analysis(data)
data <- emotion_analysis(data)
data <- sarcasm_analysis(data)

ts_results <- time_series_analysis(data)
topic_results <- topic_modeling_analysis(data, k = 5, n_terms = 10)

# Visualize
create_visualization_dashboard(data,
                                ts_results$daily_sentiment,
                                k = 5)

# Export
export_results_to_csv(data, "custom_analysis.csv")
```

### Scenario 5: Batch Processing Multiple Files

```r
setwd("C:/path/to/sentiment-analysis")
source("main.R")

# List all CSV files
csv_files <- list.files(pattern = "\\.csv$")

# Process each
for (file in csv_files) {
  if (file != "sample_data.csv") {
    cat(sprintf("Processing %s...\n", file))
    results <- run_complete_analysis(file, run_ml = FALSE, k_topics = 3)
    output_name <- sub("\\.csv$", "_analysis.csv", file)
    export_results_to_csv(results, output_name)
  }
}
```

---

## 📚 Module Documentation

### Module 1: `data_collection.R` – Data Input & Validation

**Purpose**: Load and validate text data from various sources

**Key Functions**:

```r
# Load from CSV file
data <- load_data_from_csv("mydata.csv")
#   Returns: data.frame with columns: text, date (optional), user (optional)

# Create dataset from vectors
texts <- c("Great product!", "Terrible experience", "It's okay")
dates <- as.Date(c("2025-01-01", "2025-01-02", "2025-01-03"))
data <- create_manual_dataset(texts, dates)

# Validate dataset structure
validate_dataset(data)
#   Checks: 'text' column exists, date format (if present)
#   Returns: TRUE if valid, error message if not

# Get dataset summary
summary <- get_data_summary(data)
print(summary$row_count)      # Number of rows
print(summary$text_stats)      # Mean/min/max text length
print(summary$date_range)      # Date range (if dates present)
```

**Expected CSV Format:**

```csv
text,date,user
"I love this product! Best purchase ever!",2025-01-01,user_001
"Terrible quality. Complete waste of money.",2025-01-02,user_002
"It's okay. Nothing special but does the job.",2025-01-03,user_003
"Amazing customer service and fast shipping!",2025-01-04,user_001
```

**Error Handling**:
- File not found → Clear error message with file path
- Missing 'text' column → Lists available columns
- Invalid date format → Suggests correct format (YYYY-MM-DD)
- Empty dataset → Warning and fallback to sample data

**Output**:
- Validated data.frame with standardized column names
- Summary statistics for quality assurance

---

### Module 2: `preprocessing.R` – Text Cleaning & Normalization

**Purpose**: Prepare text for analysis through standardized cleaning

**Key Functions**:

```r
# Complete preprocessing pipeline (recommended)
data <- preprocess_pipeline(data,
                             remove_nums = TRUE,
                             remove_stops = FALSE,
                             to_lower = TRUE,
                             remove_punct = FALSE)

# Individual preprocessing steps
texts <- c("DON'T SHOUT!!!", "www.example.com", "Price: $19.99")

# 1. Lowercase conversion
texts <- to_lowercase(texts)
# Result: "don't shout!!!", "www.example.com", "price: $19.99"

# 2. Clean text (remove URLs, email, special chars)
texts <- clean_text(texts)
# Result: "don't shout", "example com", "price 19 99"

# 3. Remove numbers (optional)
texts <- remove_numbers(texts)
# Result: "don't shout", "example com", "price"

# 4. Remove stopwords (optional, common words)
texts <- remove_stopwords(texts)
# Result: "shout", "example", "price"

# 5. Tokenize into individual words
tokens <- tokenize_text(texts)
# Result: list of character vectors, one per text

# 6. Lemmatization/stemming (advanced)
texts <- stem_words(texts)  # ps → p, ing → ""
# Result: "shout", "exampl", "pric"
```

**Preprocessing Steps Explained**:

1. **HTML Entity Removal**: `&amp;` → `&`, `&quot;` → `"`
2. **URL Removal**: `https://example.com` → removed
3. **Email Removal**: `user@example.com` → removed
4. **Punctuation Handling**: Preserves contractions (don't → dont)
5. **Number Removal** (optional): `123` → removed
6. **Whitespace Normalization**: Multiple spaces → single space
7. **Case Conversion**: ALL CAPS → lowercase
8. **Stopword Removal** (optional): "the", "is", "and" → removed
9. **Stemming** (advanced): "running" → "run", "happiness" → "happi"

**Configuration Options**:

```r
data <- preprocess_pipeline(data,
                             # Boolean options
                             to_lower = TRUE,      # Convert to lowercase
                             remove_punct = FALSE, # Keep punctuation
                             remove_nums = TRUE,   # Remove numbers
                             remove_stops = FALSE, # Keep stopwords
                             remove_urls = TRUE,   # Remove URLs
                             remove_emails = TRUE) # Remove emails
```

**Use Case Recommendations**:

- **Sentiment Analysis**: Keep punctuation (!!!), remove stopwords (NO), remove numbers (YES)
- **Topic Modeling**: Remove stopwords (YES), remove numbers (YES), keep punctuation (NO)
- **Sarcasm Detection**: Keep punctuation (YES), keep numbers (YES), no stopword removal
- **ML Classification**: Aggressive cleaning with stemming is sometimes better

**Output**:
- data.frame with `text_clean` column containing preprocessed text
- Original text preserved for reference
- Tokenization details if requested

---

### Module 3: `lexicon_sentiment.R` – Polarity & Intensity Analysis

**Purpose**: Assign sentiment polarity and intensity to text using lexicon-based scoring

**Lexicons Used**:
- **Positive Words** (~2000 words): "excellent", "love", "amazing", "perfect"
- **Negative Words** (~2000 words): "terrible", "hate", "awful", "disappointing"
- **Intensifiers**: "very", "extremely", "completely", "absolutely"
- **Negations**: "not", "no", "never", "wouldn't"

**Key Functions**:

```r
# Complete sentiment analysis pipeline
data <- lexicon_sentiment_analysis(data)

# Individual functions
# Calculate raw sentiment score (-10 to +10)
score <- calculate_sentiment_score("I absolutely love this product!")
# Result: +8 (positive, with intensifier bonus)

# Classify polarity
polarity <- classify_polarity(score)
# Result: "Positive", "Negative", or "Neutral"

# Calculate intensity category
intensity <- calculate_intensity(score)
# Result: "Strong Positive", "Mild Positive", "Neutral",
#         "Mild Negative", "Strong Negative"

# Get comprehensive summary
summary <- get_sentiment_summary(data)
print(summary$table)
# Result:
#   Polarity       Count  Percentage
#   Positive         250       50.0%
#   Negative         150       30.0%
#   Neutral          100       20.0%
```

**Output Columns Added to Data**:

```r
data$sentiment_score         # Numeric: -10 to +10
data$polarity               # Character: Positive, Negative, Neutral
data$intensity              # Character: Strong +/-, Mild +/-, Neutral
data$sentiment_confidence   # Numeric: 0-100% confidence
```

**Scoring Examples**:

```
Text: "I love this!"
  • Base positive words found: 1 ("love")
  • Intensifier found: 1 ("this" context boost)
  • Final score: +5
  • Polarity: Positive
  • Intensity: Strong Positive

Text: "Not bad, but not great"
  • Positive words: 0
  • Negative words: 1 ("bad")
  • Negation count: 2 ("not", "not")
  • Negation effect: Reduces negative impact
  • Final score: -2
  • Polarity: Neutral (close to zero boundary)
  • Intensity: Mild Negative

Text: "This is a product"
  • Positive words: 0
  • Negative words: 0
  • Final score: 0
  • Polarity: Neutral
  • Intensity: Neutral
```

**Algorithm Details**:

1. **Tokenize** text into words
2. **Match** each word against sentiment lexicons
3. **Count** positive and negative words
4. **Apply Intensifiers**: "very bad" = -8, "bad" = -5
5. **Apply Negations**: "not bad" negates negative polarity
6. **Normalize** by text length (longer texts penalized to prevent bias)
7. **Classify** result into polarity (Pos/Neg/Neutral) and intensity (5 categories)

**Polarity Boundaries**:
- Positive: score > +1.5
- Negative: score < -1.5
- Neutral: score between -1.5 and +1.5

---

### Module 4: `emotion_detection.R` – Multi-Emotion Profiling

**Purpose**: Detect and quantify 8 distinct emotions in text

**Emotions Detected** (NRC Lexicon):

| Emotion | Definition | Example Words |
|---------|-----------|--------------|
| **Anger** | Frustration, rage, hostility | "furious", "outraged", "seething", "enraged" |
| **Anticipation** | Forward expectations, excitement | "looking forward", "exciting", "eager", "expect" |
| **Disgust** | Revulsion, distaste | "revolting", "disgusting", "vile", "repulsive" |
| **Fear** | Anxiety, worry, threat | "terrified", "scared", "anxious", "dread" |
| **Joy** | Happiness, contentment, pleasure | "happy", "wonderful", "delighted", "joyful" |
| **Sadness** | Sorrow, melancholy, grief | "sad", "sorrowful", "gloomy", "depressed" |
| **Surprise** | Unexpected reactions | "shocked", "amazed", "astonished", "surprised" |
| **Trust** | Confidence, reliance, positive relations | "trusted", "loyal", "faithful", "reliable" |

**Key Functions**:

```r
# Complete emotion analysis
data <- emotion_analysis(data)

# Get emotion summary
summary <- get_emotion_summary(data)

# View total counts per emotion
print(summary$emotion_totals)
# Result:
#   anger         fear        sadness       disgust
#   125          203          156           98
#   surprise      trust        anticipation   joy
#   312          456          287           389

# Get most common emotion
print(summary$most_common_emotion)
# Result: "trust" (456 occurrences)

# Get high-emotion records (records with strong emotional content)
high_emotion <- get_high_emotion_records(data, threshold = 5)
#   Returns: Rows with emotion_intensity >= 5 (threshold)

# Analyze emotion by sentiment polarity
emotion_by_sentiment <- analyze_emotions_by_polarity(data)
#   Shows: Which emotions co-occur with positive vs negative sentiment

# Get emotion distribution percentages
emotion_dist <- get_emotion_distribution(data)
# Result: Normalized percentages for each emotion
```

**Output Columns Added**:

```r
data$anger                  # Numeric: 0-N emotion count
data$anticipation          # Numeric: 0-N emotion count
data$disgust               # Numeric: 0-N emotion count
data$fear                  # Numeric: 0-N emotion count
data$joy                   # Numeric: 0-N emotion count
data$sadness               # Numeric: 0-N emotion count
data$surprise              # Numeric: 0-N emotion count
data$trust                 # Numeric: 0-N emotion count
data$dominant_emotion      # Character: Most frequent emotion
data$emotion_intensity     # Numeric: Total emotion count
data$emotion_polarity      # Character: Positive/Negative emotions
```

**Emotion Scoring Example**:

```
Text: "I'm absolutely thrilled and grateful for this amazing opportunity!"

Word-Emotion Associations:
  "thrilled" → joy(+1), surprise(+1), anticipation(+1)
  "grateful" → trust(+1), joy(+1)
  "amazing" → joy(+1), surprise(+1)
  "opportunity" → anticipation(+1)

Results:
  anger: 0,      fear: 0,         sadness: 0,      disgust: 0
  joy: 3,        trust: 1,        surprise: 2,     anticipation: 2

  dominant_emotion: "joy"
  emotion_intensity: 8
  emotion_polarity: "Positive" (no negative emotions)
```

**Interpretation Guide**:

- **High Joy**: Enthusiastic, satisfied, positive about topic
- **High Trust**: Confident, reliable feedback, loyalty expressed
- **High Anger**: Critical, frustrated, demanding change
- **High Sadness**: Disappointed, regretful, loss-focused
- **High Fear + Anticipation**: Uncertain, cautious, worried but hopeful
- **High Surprise**: Unexpected experience, unusual occurrence

---

### Module 5: `sarcasm_detection.R` – Linguistic Subtlety Detection

**Purpose**: Identify sarcastic statements that flip literal meaning

**Detection Mechanism**: Rule-based pattern matching for:

1. **Excessive Punctuation**
   - Multiple exclamation marks: `"Great job!!!"`
   - Excessive question marks: `"Really????"`
   - Pattern: `!!!`, `???`, `...` × 2+

2. **Automated Emoji/Emoticon Detection**
   - Sarcasm-indicating: `:-)`, `xD`, `😏`, `🙄`
   - Contradiction with sentiment: "Love this! 😤"

3. **Contradiction Patterns**
   - Statement vs. implicit meaning: "Sure, that's helpful... NOT!"
   - Opposite sentiment words: "Great job... failing"
   - Pattern: Positive word + negative context

4. **Quotation Mark Usage**
   - Sarcastic quotation: `"Great" customer service`
   - Implicit: Those words don't mean what they say

5. **Intensifier + Negative**
   - "Oh WONDERFUL, another failure"
   - Pattern: Strong positive + failure/problem word

**Key Functions**:

```r
# Complete sarcasm analysis
data <- sarcasm_analysis(data)

# Get sarcasm summary
summary <- get_sarcasm_summary(data)
print(summary$table)
# Result:
#   Classification Count Percentage
#   Sarcasm              35       7%
#   Not Sarcasm         465      93%

# Get sarcastic records
sarcastic <- get_sarcastic_records(data, min_confidence = 50)
# Returns: Rows where is_sarcasm=TRUE AND confidence >= 50

# Analyze sarcasm patterns
patterns <- get_sarcasm_patterns(data)
# Result: Most common sarcasm triggers
#   Excessive punctuation: 15 cases
#   Contradictions: 12 cases
#   Quotation marks: 8 cases

# Sarcasm by polarity
sarcasm_sentiment <- analyze_sarcasm_by_polarity(data)
# Result: How sarcasm correlates with sentiment
```

**Output Columns Added**:

```r
data$is_sarcasm          # Logical: TRUE/FALSE
data$sarcasm_confidence  # Numeric: 0-100% confidence
data$sarcasm_type        # Character: "punctuation", "contradiction",
                         #            "quotation", "emoji", "intensifier"
data$sarcasm_reason      # Character: Detailed explanation
```

**Sarcasm Detection Examples**:

```
Text 1: "Oh SURE, that sounds like a GREAT idea... NOT!!!"
  Matches: Excessive punctuation (!!!), intensifiers (SURE, GREAT)
           contradiction (idea + NOT), tone indicator (all caps)
  Confidence: 92%
  Type: "punctuation + contradiction"
  Sarcasm: YES

Text 2: "Really, just what I needed—another problem!"
  Matches: Rhetoric (Really + problem), contradiction
           sarcastic tone markers
  Confidence: 78%
  Type: "contradiction"
  Sarcasm: YES

Text 3: "The 'wonderful' support team..."
  Matches: Quotation marks on negative context
  Confidence: 85%
  Type: "quotation_marks"
  Sarcasm: YES

Text 4: "I absolutely love this product!"
  Matches: None (positive sentence with normal punctuation)
  Confidence: 5%
  Type: "none"
  Sarcasm: NO
```

**Handling Sarcasm in Sentiment**:

When sarcasm is detected with HIGH confidence:
- **Flip sentiment**: Positive text becomes Negative
- **Lower confidence**: Reduce sentiment intensity
- **Flag for review**: Mark sarcastic entries for manual verification

---

### Module 6: `topic_modeling.R` – Latent Theme Discovery

**Purpose**: Discover hidden themes/topics in document collection using LDA

**What is LDA (Latent Dirichlet Allocation)?**

LDA is an unsupervised algorithm that:
- Treats documents as "bags of words"
- Assumes each document contains multiple topics
- Each topic is a probability distribution over words
- Learns which words cluster together as topics

**Visual Example**:

```
Document: "I love the fast shipping and amazing customer service!"

Without LDA:
  Just see this as positive review about a product

With LDA (k=3 topics):
  Topic 1 (30%): shipping, delivery, fast, quick, arrives, package
  Topic 2 (50%): customer, service, support, help, friendly, team
  Topic 3 (20%): product, quality, love, amazing, excellent

  Document distribution: [0.30, 0.50, 0.20]
  Interpretation: Mostly about customer service, also shipping and product
```

**Key Functions**:

```r
# Complete topic modeling analysis
results <- topic_modeling_analysis(data,
                                   k = 5,         # Number of topics
                                   n_terms = 10)  # Keywords per topic
data <- results$data

# Get topic keywords table
keywords <- get_topic_keywords_table(results$top_terms)
print(keywords)
# Result:
#   Topic_1: "customer", "service", "support", "help", "team"
#   Topic_2: "product", "quality", "awesome", "love", "great"
#   Topic_3: "shipping", "fast", "delivery", "arrives", "package"
#   Topic_4: "price", "expensive", "affordable", "cheap", "cost"
#   Topic_5: "problem", "issue", "broken", "defective", "waste"

# Get topic distribution summary
distribution <- get_topic_summary(data)
print(distribution)
# Result: How many documents assigned to each topic

# Analyze topics by sentiment
topic_sentiment <- analyze_topics_by_sentiment(data)
# Result:
#   Topic_1: Positive (87%), Neutral (10%), Negative (3%)
#   Topic_2: Positive (92%), Neutral (5%), Negative (3%)
#   Topic_3: Positive (71%), Neutral (15%), Negative (14%)
#   Topic_4: Negative (68%), Neutral (20%), Positive (12%)
#   Topic_5: Negative (95%), Neutral (4%), Positive (1%)

# Get documents for specific topic
topic_1_docs <- get_documents_for_topic(data, topic = 1)
```

**Output Columns Added**:

```r
data$topic                  # Integer: 1 to k (topic number)
data$topic_probability      # Numeric: 0-1 (document's membership)
data$topic_keywords         # Character: Top keywords for assigned topic
```

**LDA Algorithm Details**:

```
Input:  Document collection D = {d₁, d₂, ..., dₙ}
          k = number of topics
          α = topic concentration parameter
          β = word concentration parameter

Process:
1. Initialize: Randomly assign each word to topic (1..k)
2. Iterate 1000s of times:
     For each document:
       For each word:
         Recalculate P(topic|word, document)
         Resample word's topic based on probability
3. Burn-in: Discard first iterations to reach convergence
4. Extract: Top words for each topic (by frequency)

Output: Topic × Word probability matrix
        Document × Topic probability matrix
```

**Choosing Number of Topics (k)**:

- **k=3-5**: Broad themes (use for initial exploration)
- **k=5-10**: Detailed themes (good for most analyses)
- **k=10+**: Fine-grained topics (for massive datasets)
- **Perplexity metric**: Lower is better (use for optimization)

**Topic Quality Evaluation**:

```r
# Visual check: Do top words for each topic make sense?
keywords <- get_topic_keywords_table(results$top_terms)
print(keywords)  # Should see coherent word clusters

# Quantitative check: Topic coherence score
coherence <- evaluate_topic_coherence(results)
# 0.5-0.6 = Good, 0.3-0.5 = Fair, <0.3 = Poor

# Recommendation: Start with k=5, check coherence, adjust if needed
```

---

### Module 7: `time_series_analysis.R` – Temporal Trend Analysis

**Purpose**: Analyze sentiment evolution over time when date information is present

**Prerequisites**: Data must contain a `date` column in `YYYY-MM-DD` format

**Key Functions**:

```r
# Complete time-series analysis
ts_results <- time_series_analysis(data)

# Check if time variation detected
if (ts_results$has_time_variation) {

  # Get time-series summary
  summary <- get_timeseries_summary(ts_results)
  print(summary$overall_trend)
  # Result: "Improving", "Declining", "Stable"

  # Access daily aggregated sentiment
  daily <- ts_results$daily_sentiment
  print(head(daily))
  # Result:
  #   date       avg_sentiment count polarity
  #   2025-01-01     +2.5       45  Positive
  #   2025-01-02     +1.2       52  Positive
  #   2025-01-03     -0.5       38  Neutral

  # Get critical dates
  critical <- ts_results$critical_dates
  print(critical$most_positive_date)   # Date with highest sentiment
  print(critical$most_negative_date)   # Date with lowest sentiment

  # Get peak and valley info
  peaks_valleys <- get_peaks_and_valleys(ts_results)
  print(peaks_valleys$peaks)     # List of peak dates
  print(peaks_valleys$valleys)   # List of valley dates
}
```

**Output Structure**:

```r
ts_results$daily_sentiment    # data.frame: aggregated sentiment by date
ts_results$trends             # list: trend direction and metrics
ts_results$critical_dates     # list: extreme value dates
ts_results$has_time_variation # logical: whether dates are spread out
ts_results$date_range         # character: "from...to"
```

**Time-Series Example**:

```
Raw data (daily sentiment scores):
  Date        Sentiment  Comment
  2025-01-01  +3         Launch day, positive reviews
  2025-01-02  +2.8       Momentum continues
  2025-01-03  +4.1       Peak: Product goes viral
  2025-01-04  +2.5       Returns to baseline
  2025-01-05  +1.2       Slight decline
  2025-01-06  -1.5       Critical issue discovered
  2025-01-07  -2.3       Peak negativity
  2025-01-08  -0.8       Recovery begins
  2025-01-09  +0.5       Fix deployed, recovering
  2025-01-10  +1.8       Sentiment normalized

Analysis results:
  Overall trend: "Volatile"
    Phase 1 (Jan 1-3): Emerging trend (+3.2)
    Phase 2 (Jan 4-5): Decline (-1.6)
    Phase 3 (Jan 6-7): Crisis (-1.9)
    Phase 4 (Jan 8-10): Recovery (+0.7)

  Peak: 2025-01-03 (sentiment: +4.1)
  Valleys: 2025-01-07 (sentiment: -2.3)

  Critical events:
    2025-01-03: Sentiment spike (product goes viral)
    2025-01-06: Sentiment crash (major issue)
    2025-01-09: Recovery inflection
```

**Trend Detection Algorithm**:

```
1. Group by date: Aggregate sentiment scores per day
2. Calculate moving average: Smooth 3-7 day rolling average
3. Detect trend: Fit linear regression to moving average
   - Slope > +0.1: "Improving"
   - Slope < -0.1: "Declining"
   - |Slope| ≤ 0.1: "Stable"
4. Find peaks: Local maxima in sentiment curve
5. Find valleys: Local minima in sentiment curve
6. Classify volatility: Std dev of daily sentiment
```

**Use Cases**:

- **Product Launch Monitoring**: Track reception of new feature/version
- **Crisis Management**: Detect when sentiment crashes
- **Campaign Effectiveness**: Measure impact of marketing campaign
- **Seasonal Analysis**: Identify time-of-year patterns
- **Customer Churn Prediction**: Declining sentiment = risk of churn

---

### Module 8: `machine_learning_models.R` – Algorithm Comparison

**Purpose**: Compare lexicon-based approach with supervised machine learning classifiers

**Models Implemented**:

1. **Naive Bayes Classifier**
   - **Type**: Probabilistic classifier
   - **How it works**: P(Positive|words) ∝ P(words|Positive) × P(Positive)
   - **Pros**: Fast, interpretable, works with small datasets
   - **Cons**: Assumes word independence (not always true)
   - **Training time**: Seconds to minutes

2. **Support Vector Machine (SVM)**
   - **Type**: Geometric classifier (finds optimal separating hyperplane)
   - **How it works**: Maps words to high-dimensional space, finds best separator
   - **Pros**: Excellent on complex patterns, handles non-linear data
   - **Cons**: Slower, less interpretable, needs more data
   - **Training time**: Minutes to hours (depending on data size)

**Key Functions**:

```r
# Complete ML analysis
ml_results <- machine_learning_analysis(data,
                                        test_split = 0.2)
                                        # 80% train, 20% test

# Create model comparison table
comparison <- create_model_comparison(ml_results)
print(comparison)
# Result:
#   Model            Accuracy Precision Recall   F1-Score
#   Lexicon_Method     0.847    0.843   0.952    0.895
#   Naive_Bayes        0.823    0.812   0.921    0.863
#   SVM                0.871    0.884   0.931    0.906

# Print detailed ML summary
print_ml_summary(ml_results)
# Shows: Model names, training time, accuracy breakdown

# Access confusion matrix (Naive Bayes)
print(ml_results$nb_evaluation$confusion_matrix)
# Result:
#        Predicted
#        Positive Negative
#   Actual Positive    156     12
#        Negative      18    114

# Access confusion matrix (SVM)
print(ml_results$svm_evaluation$confusion_matrix)

# Get model predictions on new data
new_text <- "This product is absolutely amazing!"
predictions <- predict_sentiment_ml(ml_results, new_text)
# Result:
#   Model            Prediction Confidence
#   Naive_Bayes      Positive   0.87
#   SVM              Positive   0.92
```

**Output Structure**:

```r
ml_results$nb_model            # Trained Naive Bayes model
ml_results$svm_model           # Trained SVM model
ml_results$nb_evaluation       # Metrics: accuracy, precision, recall, F1
ml_results$svm_evaluation      # Same for SVM
ml_results$nb_predictions      # Predictions on test set
ml_results$svm_predictions     # Predictions on test set
ml_results$training_accuracy   # How well models fit training data
ml_results$test_accuracy       # How well models generalize
```

**Evaluation Metrics Explained**:

```
Confusion Matrix:
                    Predicted Positive  Predicted Negative
  Actually Positive      TP                  FN
  Actually Negative      FP                  TN

Where:
  TP = True Positives (correctly predicted positive)
  FP = False Positives (incorrectly predicted positive)
  TN = True Negatives (correctly predicted negative)
  FN = False Negatives (incorrectly predicted positive)

Metrics:
  Accuracy  = (TP + TN) / Total
              How many predictions were correct overall

  Precision = TP / (TP + FP)
              Of predicted positives, how many were actually positive?
              High precision = fewer false alarms

  Recall    = TP / (TP + FN)
              Of actual positives, how many did we catch?
              High recall = fewer missed positives

  F1-Score  = 2 × (Precision × Recall) / (Precision + Recall)
              Harmonic mean of precision and recall
              Balances both metrics (best for imbalanced data)
```

**Typical Results**:

```
Dataset: 500 reviews with balanced positive/negative

Lexicon Method:
  Accuracy: 84.7% (423/500 correct)
  Precision: 84.3% (positive predictions are 84% correct)
  Recall: 95.2% (catches 95% of actual positive reviews)
  F1-Score: 0.895

Naive Bayes:
  Accuracy: 82.3% (412/500 correct)
  Precision: 81.2% (fewer false alarms than lexicon)
  Recall: 92.1% (misses some positives)
  F1-Score: 0.863 (slightly worse overall)

SVM:
  Accuracy: 87.1% (436/500 correct) ← Best overall
  Precision: 88.4% (very few false positives)
  Recall: 93.1% (excellent positive detection)
  F1-Score: 0.906 (best balanced performance)

Conclusion: SVM performs best, but lexicon method is most interpretable
```

**When to Use Which Model**:

| Scenario | Recommendation | Reason |
|----------|---|---|
| **Small dataset (<100 reviews)** | Lexicon or Naive Bayes | ML models need more data |
| **Interpretability important** | Lexicon method | Can explain why each word matters |
| **Maximum accuracy needed** | SVM | Achieves highest precision/recall |
| **Real-time predictions** | Naive Bayes | Fastest inference |
| **Domain-specific language** | Custom lexicon | Standard lexicons may miss domain terms |
| **Balanced accuracy needed** | SVM or Lexicon | Better precision/recall balance |

---

### Module 9: `visualization.R` – Charts & Graphics

**Purpose**: Create publication-quality visualizations of analysis results

**Visualizations Generated**:

```r
# Create complete visualization dashboard
create_visualization_dashboard(data,
                                daily_sentiment,    # optional
                                ml_comparison)      # optional

# This generates and saves:
#   1. sentiment_distribution.png
#   2. sentiment_intensity.png
#   Three. wordcloud_positive.png
#   4. wordcloud_negative.png
#   5. emotion_radar.png
#   6. emotion_bar_chart.png
#   7. sentiment_trend.png (if time-series data available)
#   8. model_comparison.png (if ML analysis ran)
#   9. topic_distribution.png (if topic modeling ran)
```

**Individual Visualization Functions**:

```r
# 1. Sentiment Distribution Bar Chart
p <- plot_sentiment_distribution(data)
# Shows: Count of Positive, Negative, Neutral sentiment
# Color-coded, with percentage labels

# 2. Sentiment Intensity Stacked Bar
p <- plot_sentiment_intensity(data)
# Shows: Distribution across 5 intensity categories
#   Strong Positive, Mild Positive, Neutral,
#   Mild Negative, Strong Negative

# 3. Word Cloud - Positive Text
create_wordcloud(data, polarity = "positive",
                 max_words = 100,
                 output_file = "wordcloud_positive.png")
# Words sized by frequency, warm colors (green/gold)

# 4. Word Cloud - Negative Text
create_wordcloud(data, polarity = "negative",
                 max_words = 100,
                 output_file = "wordcloud_negative.png")
# Words sized by frequency, cool colors (red/purple)

# 5. Emotion Radar Chart (8 emotion spokes)
plot_emotion_radar(data,
                   output_file = "emotion_radar.png")
# Radar with 8 axes (one per emotion)
# Visualizes emotional profile at a glance

# 6. Emotion Bar Chart
p <- plot_emotion_bar_chart(data)
# Shows: Count of each emotion type
# Grouped by emotion, color-coded

# 7. Time-Series Sentiment Trend Line
p <- plot_sentiment_trend(daily_sentiment)
# Line graph with:
#   X-axis: Date
#   Y-axis: Average sentiment
#   Trend line overlayed
#   Shaded confidence intervals

# 8. ML Model Comparison Bars
p <- plot_model_comparison(ml_comparison)
# Groups: Accuracy, Precision, Recall, F1-Score
# Models: Naive Bayes, SVM, Lexicon Method

# 9. Topic Distribution Pie Chart
p <- plot_topic_distribution(data)
# Shows: Percentage of documents in each topic
# Color-coded for easy distinction

# Save any plot
ggsave("my_custom_plot.png", p, width = 10, height = 6, dpi = 300)
```

**Visualization Features**:

- **High Resolution**: 300 DPI suitable for publication
- **Professional Colors**: Colorblind-friendly palettes (via RColorBrewer)
- **Annotations**: All charts include labels, legends, percentages
- **Thematic Consistency**: Unified color scheme across all charts
- **Export Formats**: PNG (web), PDF (print), SVG (vector)

**Chart Interpretation Guide**:

```
SENTIMENT DISTRIBUTION (Bar Chart)
  High Positive bar: Mostly satisfied users
  High Negative bar: Serious issues to address
  High Neutral bar: Product is "meh", needs improvement

EMOTION RADAR (8-Pointed Star)
  Balanced points: Mixed emotional response
  Peak at joy/trust: Highly satisfied
  Peak at anger/disgust: Frustrated customers
  Peak at fear/sadness: Safety concerns or disappointment

WORD CLOUD (Size indicates frequency)
  Large words: Most commonly discussed (important!)
  Small words: Niche concerns
  Positive cloud only "love", "amazing": Strong satisfaction
  Negative cloud shows "broken", "waste": Quality issues

TIME-SERIES TREND (Line Graph)
  Upward slope: Sentiment improving over time
  Downward slope: Sentiment worsening (potential crisis)
  Flat line: Consistent reception
  Sharp drop: Major negative event occurred
  Sharp spike: Product/campaign went viral
```

---

### Module 10: `dashboard_app.R` – Interactive Shiny Web Interface

**Purpose**: Provide web-based interactive interface for non-technical users

**Features**:

```yaml
User Interface:
  - Tabbed interface (multiple sections)
  - Responsive design (works on mobile/tablet/desktop)
  - Real-time progress indicators
  - Helpful tooltips and documentation

Input Methods:
  - File Upload (CSV files up to 50MB)
  - Manual Text Entry (paste/type single or multiple texts)
  - URL Input (analyze text from web pages)

Processing:
  - Real-time analysis with progress bars
  - Handles 10s to 1000s of records instantly
  - Memory-efficient processing

Output Display:
  - Interactive visualization (charts, word clouds)
  - Sortable/filterable data tables
  - Summary statistics
  - Downloadable results (CSV)

Parameters:
  - Number of topics (slider: 1-10)
  - ML model inclusion (toggle)
  - Include sarcasm detection (toggle)
  - Visualization theme selector
```

**Launching the Dashboard**:

```r
setwd("C:/path/to/sentiment-analysis")
source("dashboard_app.R")
```

**Output**:
```
Listening on http://127.0.0.1:3838
```

Open browser to: `http://localhost:3838` or `http://127.0.0.1:3838`

**Dashboard Workflow**:

```
1. Upload File or Enter Text
   ↓
2. Click "Analyze" (or auto-analyze on change)
   ↓
3. Progress bar shows: Data Loading... Preprocessing... Analysis...
   ↓
4. Results appear in tabs:
   - Summary (Overview statistics)
   - Sentiment (Distribution, intensity)
   - Emotions (Radar chart, bar chart)
   - Topics (Word clouds, distribution)
   - Time-Series (Trends, if dates present)
   - ML Comparison (Model performance)
   - Raw Data (Sortable, filterable table)
   ↓
5. Download CSV with all results
```

**Accessing Results**:

```
After downloading from dashboard:
  - Column 1: Original text
  - Columns 2-4: Sentiment (score, polarity, intensity)
  - Columns 5-12: Emotion counts (anger, fear, etc.)
  - Columns 13-14: Sarcasm (is_sarcasm, confidence)
  - Columns 15-16: Topic (topic_number, probability)
  - Column 17: Date (if present)
```

---

### Module 11: `main.R` – Master Orchestration

**Purpose**: High-level function orchestrating entire analysis pipeline

**Primary Function**:

```r
results <- run_complete_analysis(
  file_path = NULL,           # Path to CSV file (optional)
  run_ml = TRUE,              # Include ML models? (default: TRUE)
  k_topics = 3,               # Number of topics (default: 3)
  remove_stopwords = FALSE,   # Remove stopwords? (default: FALSE)
  include_sarcasm = TRUE      # Include sarcasm? (default: TRUE)
)

# Returns: List with all analysis results
```

**Function Behavior**:

```
run_complete_analysis() does the following:

1. Load Data:
   - If file_path provided: Load from CSV
   - If file_path NULL: Use built-in sample data

2. Validate:
   - Check for 'text' column
   - Check date format (if present)
   - Handle missing values

3. Preprocess:
   - Clean text (URLs, emails, special characters)
   - Convert to lowercase
   - Tokenize (optional)
   - Remove stopwords (if requested)

4. Analyze (in this order):
   a. Lexicon Sentiment Analysis → sentiment_score, polarity, intensity
   b. Emotion Detection → 8 emotion counts
   c. Sarcasm Detection → is_sarcasm, confidence
   d. Topic Modeling → topic, topic_probability
   e. Time-Series Analysis (if dates present) → daily trends
   f. Machine Learning (if run_ml=TRUE) → NB & SVM models

5. Visualize:
   - Create all standard charts
   - Save as PNG files

6. Export:
   - Create CSV with all results
   - Create summary report

7. Return:
   - List containing all above results and data
```

**Return Value Structure**:

```r
# Access results:
results$data                    # data.frame with all enriched data
results$sentiment_summary       # Sentiment polarity summary
results$emotion_summary         # Emotion distribution summary
results$sarcasm_summary         # Sarcasm prevalence
results$topic_results           # Topic modeling output
results$timeseries_results      # Time-series analysis (if applicable)
results$ml_results              # Machine learning results (if run_ml=TRUE)
results$visualizations          # List of generated chart file paths
results$export_file             # Path to exported CSV

# Example usage:
print(results$sentiment_summary$table)  # View sentiment breakdown
print(results$emotion_summary$emotion_totals)  # View emotion counts
export_results_to_csv(results, "myfile_analysis.csv")
```

**Export Function**:

```r
# Export results to CSV (recommended for further analysis)
export_results_to_csv(results, "output_file.csv")

# This creates a CSV with columns:
#   text (original, unmodified)
#   text_clean (preprocessed)
#   sentiment_score (numeric)
#   polarity (Positive/Negative/Neutral)
#   intensity (Strong +/-, Mild +/-, Neutral)
#   anger, anticipation, disgust, fear, joy, sadness, surprise, trust
#   dominant_emotion
#   emotion_intensity
#   is_sarcasm
#   sarcasm_confidence
#   topic
#   topic_probability
#   date (if present)
#   user (if present)
```

---

## 🔌 API Reference

### Function Signatures

#### Data Collection Module

```r
load_data_from_csv(file_path)
# Args: file_path (character) - Path to CSV file
# Returns: data.frame with text, date (optional), user (optional)
# Errors: File not found, missing 'text' column, invalid date format

create_manual_dataset(texts, dates = NULL, users = NULL)
# Args: texts (character vector), dates (optional, Date or character)
# Returns: data.frame

validate_dataset(data)
# Args: data (data.frame)
# Returns: logical (TRUE if valid)
# Errors: Prints error message if invalid

get_data_summary(data)
# Args: data (data.frame)
# Returns: list with summary statistics
```

#### Preprocessing Module

```r
preprocess_pipeline(data,
                    to_lower = TRUE,
                    remove_punct = FALSE,
                    remove_nums = TRUE,
                    remove_stops = FALSE)
# Args: data (data.frame), flags (logical)
# Returns: data.frame with text_clean column

clean_text(text)
to_lowercase(text)
remove_numbers(text)
remove_stopwords(text)
tokenize_text(text)
stem_words(text)
# Args: text (character vector or string)
# Returns: character vector (same structure)
```

#### Sentiment Analysis Module

```r
lexicon_sentiment_analysis(data)
# Args: data (data.frame with text column)
# Returns: data with sentiment_score, polarity, intensity columns

calculate_sentiment_score(text)
# Args: text (character string)
# Returns: numeric (-10 to +10)

classify_polarity(score)
# Args: score (numeric)
# Returns: character ("Positive", "Negative", "Neutral")

calculate_intensity(score)
# Args: score (numeric)
# Returns: character

get_sentiment_summary(data)
# Args: data (data.frame with sentiment columns)
# Returns: list with summary statistics
```

#### Emotion Detection Module

```r
emotion_analysis(data)
# Args: data (data.frame with text column)
# Returns: data with emotion columns (anger, fear, etc.)

get_emotion_summary(data)
# Args: data (data.frame with emotion columns)
# Returns: list with emotion distributions

get_high_emotion_records(data, threshold = 5)
# Args: data, threshold (numeric)
# Returns: subset of data.frame with high emotion content
```

#### Sarcasm Detection Module

```r
sarcasm_analysis(data)
# Args: data (data.frame with text column)
# Returns: data with is_sarcasm and sarcasm_confidence columns

get_sarcasm_summary(data)
# Args: data (data.frame with sarcasm columns)
# Returns: list with sarcasm counts

get_sarcastic_records(data, min_confidence = 50)
# Args: data, min_confidence (0-100)
# Returns: subset with sarcastic records above confidence threshold
```

#### Topic Modeling Module

```r
topic_modeling_analysis(data, k = 3, n_terms = 5)
# Args: data (data.frame), k (number of topics), n_terms (keywords per topic)
# Returns: list with LDA model and results

get_topic_keywords_table(top_terms)
# Args: top_terms (from results)
# Returns: data.frame with topics and keywords

get_topic_summary(data)
# Args: data (with topic columns)
# Returns: list with topic distribution
```

#### Time-Series Module

```r
time_series_analysis(data)
# Args: data (data.frame with date column)
# Returns: list with daily_sentiment, trends, critical_dates

get_timeseries_summary(ts_results)
# Args: ts_results (output from time_series_analysis)
# Returns: list with overall trend and key metrics
```

#### Machine Learning Module

```r
machine_learning_analysis(data, test_split = 0.2)
# Args: data, test_split (0-1 proportion for testing)
# Returns: list with trained models and evaluations

create_model_comparison(ml_results)
# Args: ml_results (output from machine_learning_analysis)
# Returns: data.frame with accuracy, precision, recall, F1 for all models
```

#### Visualization Module

```r
create_visualization_dashboard(data, daily_sentiment = NULL, ml_comparison = NULL)
# Args: data, optional time-series and ML results
# Effects: Saves multiple PNG files in working directory

plot_sentiment_distribution(data)
plot_sentiment_intensity(data)
plot_emotion_bar_chart(data)
plot_emotion_radar(data)
plot_sentiment_trend(daily_sentiment)
plot_model_comparison(comparison)
# Args: Respective data structures
# Returns: ggplot2 plot object (can be saved with ggsave())

create_wordcloud(data, polarity = "positive", max_words = 100, output_file = NULL)
# Args: data, polarity ("positive" or "negative"), max_words
# Effects: Displays and optionally saves wordcloud
```

#### Main Pipeline Module

```r
run_complete_analysis(file_path = NULL, run_ml = TRUE, k_topics = 3, ...)
# Args: file_path (optional), ML flag, topic count
# Returns: list with complete results (data, summaries, paths)
# Effects: Generates CSV export and PNG visualizations

export_results_to_csv(results, output_file)
# Args: results list (from run_complete_analysis), output filename
# Effects: Writes CSV file to disk
```

---

## 📊 Data Format

### Input CSV Format

**Required Column:**

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `text` | Character | The text content to analyze | "I love this product!" |

**Optional Columns:**

| Column | Type | Description | Example | Format |
|--------|------|-------------|---------|--------|
| `date` | Date/Character | When the text was posted | "2025-03-15" | YYYY-MM-DD |
| `user` | Character | User identifier | "user_001" | Any string |
| `rating` | Numeric | Optional numeric rating | 5 | 0-10, 1-5, etc. |
| `source` | Character | Origin of text | "amazon", "twitter" | Categorical |

**Example CSV File** (`my_reviews.csv`):

```csv
text,date,user,rating,source
"I absolutely love this product! Best purchase ever!",2025-03-01,user_001,5,amazon
"Terrible quality. Broke after one week.",2025-03-02,user_002,1,amazon
"It's okay. Does what it says but nothing special.",2025-03-03,user_003,3,amazon
"Amazing customer service! They fixed my issue quickly!",2025-03-04,user_001,5,twitter
"Expensive and not worth the hype.",2025-03-05,user_004,2,amazon
```

### Output CSV Format

**Columns Generated by Analysis:**

| Column | Type | Description | Values |
|--------|------|-------------|--------|
| `text` | Character | Original input text | Any string |
| `text_clean` | Character | Preprocessed text | Lowercase, cleaned |
| `sentiment_score` | Numeric | Raw sentiment score | -10 to +10 |
| `polarity` | Character | Sentiment classification | "Positive", "Negative", "Neutral" |
| `intensity` | Character | Intensity category | "Strong Positive", "Mild Positive", "Neutral", "Mild Negative", "Strong Negative" |
| `anger` | Numeric | Anger emotion count | 0, 1, 2, ... |
| `anticipation` | Numeric | Anticipation emotion count | 0, 1, 2, ... |
| `disgust` | Numeric | Disgust emotion count | 0, 1, 2, ... |
| `fear` | Numeric | Fear emotion count | 0, 1, 2, ... |
| `joy` | Numeric | Joy emotion count | 0, 1, 2, ... |
| `sadness` | Numeric | Sadness emotion count | 0, 1, 2, ... |
| `surprise` | Numeric | Surprise emotion count | 0, 1, 2, ... |
| `trust` | Numeric | Trust emotion count | 0, 1, 2, ... |
| `dominant_emotion` | Character | Most frequent emotion | "anger", "fear", "joy", etc. |
| `emotion_intensity` | Numeric | Total emotion count | 0, 1, 2, ... |
| `is_sarcasm` | Logical | Sarcasm detected? | TRUE, FALSE |
| `sarcasm_confidence` | Numeric | Sarcasm confidence | 0-100 |
| `topic` | Numeric | Assigned topic | 1 to k |
| `topic_probability` | Numeric | Probability for topic | 0-1 |
| `date` | Character | Date (if provided) | YYYY-MM-DD |
| `user` | Character | User ID (if provided) | Any string |

**Example Output CSV** (first 3 rows):

```csv
text,sentiment_score,polarity,intensity,anger,fear,sadness,disgust,anticipation,surprise,trust,joy,topic
"I absolutely love this!",+7.5,Positive,Strong Positive,0,0,0,0,1,0,2,3,1
"Terrible quality",--6.2,Negative,Strong Negative,2,1,2,1,0,0,0,0,3
"It's okay",+0.3,Neutral,Neutral,0,0,0,0,0,0,1,0,2
```

---

## 📈 Output & Results

### Files Generated

**After running `run_complete_analysis()`:**

```
Project Folder/
├── sentiment_analysis_results.csv      ← Main results file
├── sentiment_distribution.png          ← Bar chart
├── sentiment_intensity.png             ← Stacked bar chart
├── emotion_radar.png                   ← 8-point radar
├── emotion_bar_chart.png               ← Emotion counts
├── wordcloud_positive.png              ← Large words = frequent
├── wordcloud_negative.png              ← Negative sentiment words
├── sentiment_trends.png                ← Time-series line graph
├── model_comparison.png                ← ML performance comparison
├── topic_distribution.png              ← Topic pie chart
└── [OTHER ANALYSIS FILES]
```

### Interpretation Guide

#### Sentiment Distribution

```
If 70% Positive, 20% Neutral, 10% Negative:
  ✓ Product/Service is well-received
  ✓ Focus on maintaining quality
  → Make improvements suggested in negative 10%

If 40% Positive, 30% Neutral, 30% Negative:
  ⚠ Mixed reception - potential issues
  ⚠ Examine negative feedback for patterns
  → Priority: Address top complaints

If 10% Positive, 20% Neutral, 70% Negative:
  ✗ Major problems detected
  ✗ Immediate action required
  → Crisis management: Urgent improvements needed
```

#### Top Emotions

```
High Joy + Trust: Satisfied, loyal customers
  → Excellent sentiment, maintain quality

High Anger + Disgust: Angry customers, quality issues
  → Address complaints urgently

High Fear + Sadness: Disappointed, hesitant customers
  → Improve product/service reliability

High Anticipation: Excited, hopeful customers
  → New feature/launch was well-received
```

#### Topics

```
Topic 1: "shipping", "delivery", "fast", "arrived"
  → Logistics/delivery experiences

Topic 2: "customer", "service", "support", "help"
  → Customer service experiences

Topic 3: "quality", "durable", "excellent", "reliable"
  → Product quality feedback

This tells you: What aspects of business are being discussed
```

#### Time-Trends

```
Upward trend (Improving):
  ✓ Customer satisfaction increasing
  ✓ Recent changes had positive impact

Downward trend (Declining):
  ⚠ Growing dissatisfaction
  ⚠ Possible quality decline or perception issue

Flat trend (Stable):
  → Consistent customer reception

Sudden drops (Crisis):
  ✗ Major event triggered negative response
  ✗ Product/issue caused backlash
```

---

## 💡 Use Cases

### 1. E-Commerce Product Review Analysis

**Scenario**: Amazon seller wants to improve product ratings

**Process**:
```r
# 1. Export all reviews as CSV from Amazon/Shopify
# 2. Load and analyze
results <- run_complete_analysis("reviews.csv", run_ml = TRUE, k_topics = 5)

# 3. Examine results
print(results$sentiment_summary$table)        # See satisfaction rate
print(results$emotion$emotion_totals)         # What emotions drive reviews?
sarcasm_records <- get_sarcastic_records(results$data, 90)  # Find hidden criticism
```

**Insights Obtained**:
- Overall satisfaction rate (sentiment%)
- Key complaint themes (topics)
- Emotional drivers (which emotions matter most)
- Sarcastic complaints (people saying opposite of intent)

**Action Items**:
- Address #1 complained topic
- Improve aspects in top "anger" mentions
- Monitor trend: Is satisfaction improving?

---

### 2. Social Media Campaign Monitoring

**Scenario**: Marketing team launched new campaign, wants to measure impact

**Process**:
```r
# Collect tweets/comments daily during campaign
# Save to dated CSV files: campaign_day1.csv, campaign_day2.csv, etc.

# Run time-series analysis
for (day in 1:7) {
  file <- sprintf("campaign_day%d.csv", day)
  results <- run_complete_analysis(file, run_ml = FALSE, k_topics = 3)
  daily_sentiment[[day]] <- results$sentiment_summary
}

# Plot sentiment trend
plot_sentiment_trend(daily_sentiment)
```

**Insights Obtained**:
- Campaign receptiveness over time
- Emotional response (joy vs disgust)
- Key topics being discussed
- Peak engagement moments

**Action Items**:
- If sentiment improving: Effective campaign
- If sentiment declining: Adjust messaging
- Key themes: Focus future content on winners

---

### 3. Customer Service Quality Evaluation

**Scenario**: Call center manager wants to evaluate support quality

**Process**:
```r
# Transcribe customer service calls/chats
# Save transcripts as CSV with date column

results <- run_complete_analysis("support_transcripts.csv")

# Find patterns
sarcastic <- get_sarcastic_records(results$data, min_confidence = 70)
# These are likely frustrated customers (saying opposite of real sentiment)

high_emotion <- get_high_emotion_records(results$data, threshold = 4)
# These represent strong emotional reactions (good or bad)
```

**Insights Obtained**:
- Agent satisfaction impact (sentiment)
- Dominant customer emotions
- Hidden frustrations (sarcasm)
- Topic distribution (what customers ask about most)

**Action Items**:
- Train agents on high-anger conversations
- Recognize excellent interactions (high trust/joy)
- Identify systemic issues (recurring topics)

---

### 4. Product Development Feedback Loop

**Scenario**: Development team wants to know feature reception

**Process**:
```r
# Collect user feedback (surveys, support tickets, app reviews)
# Analyze separately: old version vs. new version

old_results <- run_complete_analysis("feedback_v1.0.csv")
new_results <- run_complete_analysis("feedback_v2.0.csv")

# Compare
old_sent <- old_results$sentiment_summary$table
new_sent <- new_results$sentiment_summary$table

# Did sentiment improve? What changed?
old_topics <- old_results$topic_results
new_topics <- new_results$topic_results
# Topics shifting → users discussing different things
```

**Insights Obtained**:
- Feature adoption sentiment
- What users love vs hate
- Dominant concerns (topics)
- Emotional reception

**Action Items**:
- Popular features: Prioritize in next release
- Criticized features: Fix or deprecate
- Neutral features: Not important to users

---

### 5. Crisis Management & Brand Monitoring

**Scenario**: PR team detected negative social media spike

**Process**:
```r
# Collect all mentions in past 48 hours
results <- run_complete_analysis("mentions_crisis_period.csv")

# Find root cause
anger_records <- results$data$anger > 3
disgust_records <- results$data$disgust > 2
crisis_records <- results$data[which(anger_records | disgust_records), ]

# What's being said?
top_topics <- get_topic_keywords_table(results$topic_results$top_terms)
print(top_topics)  # What are angry people talking about?

# Time-series: When did it start?
ts <- time_series_analysis(results$data)
print(ts$critical_dates$most_negative_date)  # When was peak negativity?
```

**Insights Obtained**:
- Root cause of crisis (dominant topics in negative mentions)
- Scale of problem (% of total mentions)
- Emotional intensity (anger vs sadness vs fear)
- Timeline (when did it start? Is it recurring?)

**Action Items**:
- Immediate: Address root cause publicly
- Monitor: Track sentiment recovery
- Prevent: Identify trigger patterns
- Improve**: Process changes to prevent recurrence

---

### 6. Academic Research & Publication

**Scenario**: Researcher analyzing public opinion on policy topic

**Process**:
```r
# Collect tweets/comments about policy
tweets <- load_data_from_csv("policy_tweets.csv")

#Full analysis
results <- run_complete_analysis("policy_tweets.csv",
                                  run_ml = TRUE,
                                  k_topics = 8)

# Report findings
print(results$sentiment_summary$table)          # Policy sentiment
print(results$emotion_summary$emotion_totals)   # Emotional dimensions
print(results$ml_results$comparison)            # Model performance
create_visualization_dashboard(results$data)   # Publication-ready charts
export_results_to_csv(results, "policy_analysis.csv")
```

**Insights Obtained**:
- Public opinion distribution
- Multi-dimensional emotional response
- Dominant discourse themes (topics)
- Temporal trends (opinion evolution)
- Model performance for reproducibility

**Deliverables**:
- CSV dataset with all enriched columns
- PNG visualizations (suitable for publication)
- Statistical summary tables
- Reproducible methodology documentation

---

## 🔧 Troubleshooting

### Issue: "Package X not found" Error

**Symptom**: `Error in library(X) : there is no package called 'X'`

**Solution**:
```r
# 1. Try automated installer
source("install_packages.R")

# 2. If that fails, install package manually
install.packages("package_name")
# Wait for installation to complete, then:
library(package_name)

# 3. If still fails, check internet connection and try:
install.packages("package_name", repos = "https://cloud.r-project.org")

# 4. Last resort: specify exact version
devtools::install_version("package_name", version = "1.0.0")
```

---

### Issue: "File not found" Error

**Symptom**: `Error: file 'mydata.csv' not found`

**Solution**:
```r
# 1. Check working directory
getwd()
# Result should show your project folder

# 2. Set correct working directory
setwd("C:/path/to/sentiment-analysis")

# 3. Verify file exists in that folder
list.files()
# Should show your CSV files

# 4. Use full path if file is elsewhere
results <- run_complete_analysis("C:/Users/YourName/Documents/mydata.csv")

# 5. Check file name spelling (case-sensitive on Mac/Linux):
# "MyData.csv" ≠ "mydata.csv"
```

---

### Issue: Analysis is Very Slow

**Symptom**: Analysis taking hours for 1000s of records

**Causes & Solutions**:

```r
# 1. Disable ML models (they're slow)
results <- run_complete_analysis("bigdata.csv",
                                  run_ml = FALSE)  # Skip Naive Bayes & SVM

# 2. Use fewer topics (LDA is slow)
results <- run_complete_analysis("bigdata.csv",
                                  run_ml = FALSE,
                                  k_topics = 3)  # Default 5, reduce to 3

# 3. Process in batches
# Instead of 10,000 records at once:
chunk_size <- 1000
for (i in seq(1, nrow(big_data), chunk_size)) {
  chunk <- big_data[i:(i+chunk_size-1), ]
  results <- run_complete_analysis(data = chunk, run_ml = FALSE)
  # Save partial results
}

# 4. Close other programs to free up RAM
# Check: View Task Manager → Memory usage
# Should see R using <5 GB for typical analysis
```

---

### Issue: Dashboard Won't Start

**Symptom**: `Error: could not find function "shinyApp"`

**Solution**:
```r
# 1. Reinstall Shiny
remove.packages("shiny")
install.packages("shiny")

# 2. Try dashboard again
source("dashboard_app.R")

# 3. If you see "Warning: Error in eval"
library(shiny)
library(shinydashboard)
library(DT)
source("dashboard_app.R")

# 4. Check port availability (3838 might be in use)
# Kill process using port 3838:
#   Windows: netstat -ano | findstr 3838
#   Mac/Linux: lsof -i :3838
#   Then kill the PID
```

---

### Issue: CSV Not Loading Correctly

**Symptom**: `Error: Column 'text' not found` OR wrong encoding/special characters

**Solution**:
```r
# 1. Verify CSV format
csv <- read.csv("mydata.csv", nrows = 5)
head(csv)
colnames(csv)  # Should show: text, date (optional), etc.

# 2. Check for encoding issues (special characters garbled)
csv <- read.csv("mydata.csv", encoding = "UTF-8")

# 3. Check CSV is properly formatted (no missing columns)
# Try loading with readr package:
library(readr)
csv <- read_csv("mydata.csv",
                col_types = cols(text = col_character()))

# 4. As last resort, manually inspect CSV:
# Open in Excel/Notepad to see actual structure
# Make sure first column is "text"
```

---

### Issue: Charts Not Saving

**Symptom**: `Error: cannot open file 'sentiment_distribution.png'`

**Solution**:
```r
# 1. Check working directory is writable
setwd("C:/Users/YourName/Documents/sentiment-analysis")
file.create("test.txt")  # Should succeed
file.remove("test.txt")

# 2. Ensure directory exists and is writable
dir.create("output", showWarnings = FALSE)

# 3. Manually save plots
p <- plot_sentiment_distribution(results$data)
ggsave("sentiment_distribution.png", p, width = 10, height = 6, dpi = 300)

# 4. Check for special characters in filenames
# Use simple names: "result.csv" not "result-2025-03-31 (final v3).csv"
```

---

### Issue: Sarcasm Detection Too Aggressive

**Symptom**: Normal exclamatory sentences marked as sarcasm

**Solution**:
```r
# Current behavior: Sarcasm confidence threshold is 50%
# To be stricter, filter for only high-confidence sarcasm:

sarcastic <- get_sarcastic_records(results$data, min_confidence = 75)
# Now only detects very obvious sarcasm (75%+ confidence)

# Or, disable sarcasm in preprocessing
# Modify the sarcasm_analysis function call or:
results$data$is_sarcasm <- FALSE  # Override for analysis
```

---

### Issue: Topic Modeling Slow

**LDA is computationally expensive.** Symptoms: Takes minutes for 5-10k records

**Solutions**:
```r
# 1. Reduce number of topics
results <- run_complete_analysis("data.csv",
                                  k_topics = 3)  # Instead of 5-10

# 2. Reduce iterations (less accurate but faster)
# (This requires modifying topic_modeling.R)

# 3. Pre-filter data
# Only analyze reviews with 10+ words (skips short texts):
for filtered_data <- results$data[nchar(results$data$text) > 50, ]
results <- run_complete_analysis(data = filtered_data, k_topics = 3)

# 4. Use smaller dataset for initial testing
sample_data <- results$data[sample(nrow(results$data), 100), ]
results <- run_complete_analysis(data = sample_data, k_topics = 3)
```

---

## 📄 License & Attribution

### Package Dependencies

This system uses the following open-source R packages:

| Package | Purpose | License | Citation |
|---------|---------|---------|----------|
| `tidyverse` | Data manipulation | MIT | Wickham et al. |
| `tm` | Text mining | Apache 2.0 | Feinerer et al. |
| `syuzhet` | Emotion detection | GPL-3 | Jockers |
| `topicmodels` | LDA topic modeling | GPL-2 | Grün & Hornik |
| `ggplot2` | Visualization | MIT | Wickham |
| `shiny` | Web framework | GPL-3 | RStudio |
| `caret` | Machine learning | GPL-2 | Kuhn |
| `e1071` | SVM & Naive Bayes | GPL-2 | Meyer et al. |

### Lexicon Attribution

- **NRC Emotion Lexicon**: Mohammad, S. M., & Turney, P. D. (2013). "Crowdsourcing a Word-Emotion Association Lexicon". Computational Intelligence, 29(3), 436-465.
- **Sentiment Lexicon**: Adapted from Bing Liu's opinion lexicon

### Citation

If you use this system in research, please cite:

```bibtex
@software{sentiment_analysis_r_2025,
  title={AI-Based Multi-Dimensional Sentiment Analysis System in R},
  author={Your Name},
  year={2025},
  url={https://github.com/yourusername/sentiment-analysis}
}
```

---

## 📞 Support & Contribution

For issues, improvements, or questions:

1. **Check Troubleshooting** section above
2. **Review** [PROJECT_METHODOLOGY.txt](PROJECT_METHODOLOGY.txt) for technical details
3. **Submit issues** on GitHub
4. **Contributing**: Fork repository, make improvements, submit pull request

---

**Version**: 1.0
**Last Updated**: March 2025
**Status**: Production Ready
**Maintainer**: [Your Name]

For detailed technical methodology, see [PROJECT_METHODOLOGY.txt](PROJECT_METHODOLOGY.txt)
- user

If optional columns are missing, defaults are added automatically.

## 4. Launch Interactive Dashboard

Inside the R console:

```r
setwd("E:/Sentimental Analysis Using R")
source("dashboard_app.R")
```

This starts the Shiny app. Use the Data Input tab to:

- Upload a CSV file
- Or paste manual text (one line per text entry)

## 5. Expected Outputs

After a successful run, you should see:

- Console summary of all analysis steps
- Generated plots in the active graphics device
- Exported CSV file (for example: sentiment_analysis_results.csv)

## 6. Recommended Execution Order

1. source("install_packages.R")
2. source("main.R")
3. run_complete_analysis(...)
4. export_results_to_csv(...)
5. source("dashboard_app.R") (optional UI mode)

## 7. Troubleshooting

### Problem: commands fail in PowerShell

Cause: R code was executed in PowerShell instead of an R console.

Fix:

1. Run `R` in terminal first.
2. Then execute R statements.

### Problem: package install fails

Fix:

1. Re-run source("install_packages.R")
2. Try manual install for failed package:

```r
install.packages("package_name", dependencies = TRUE)
```

### Problem: file not found

Fix:

```r
getwd()
setwd("E:/Sentimental Analysis Using R")
list.files()
```

### Problem: dashboard does not open

Fix:

1. Ensure shiny and shinydashboard are installed.
2. Re-run source("dashboard_app.R") in R console.
3. Check firewall/browser pop-up restrictions.

## 8. Key Project Files

- main.R: pipeline orchestration and export helper
- install_packages.R: one-time dependency installer
- dashboard_app.R: Shiny dashboard application
- sample_data.csv: sample input data

## 9. One-Command Starter (after setup)

If dependencies are already installed:

```r
setwd("E:/Sentimental Analysis Using R")
source("main.R")
results <- run_complete_analysis("sample_data.csv", run_ml = TRUE, k_topics = 3)
export_results_to_csv(results, "sentiment_analysis_results.csv")
```
