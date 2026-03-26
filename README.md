# AI-Based Multi-Dimensional Sentiment & Behavioral Intelligence System

## 🎯 Project Overview

An advanced sentiment analysis system built entirely in R that goes beyond traditional sentiment analysis by incorporating emotion detection, sarcasm identification, topic modeling, time-series analysis, and machine learning classification.

### 🌟 Key Features

- **Lexicon-Based Sentiment Analysis**: Score and classify text polarity with intensity levels
- **Emotion Detection**: Identify 8 emotions (anger, anticipation, disgust, fear, joy, sadness, surprise, trust) using NRC lexicon
- **Sarcasm Detection**: Rule-based sarcasm identification with confidence scoring
- **Topic Modeling**: LDA-based topic discovery with keyword extraction
- **Time-Series Analysis**: Trend detection and critical date identification
- **Machine Learning**: Naive Bayes and SVM classifiers with performance comparison
- **Interactive Dashboard**: Full-featured Shiny web application
- **Comprehensive Visualizations**: Charts, word clouds, radar plots, and more
- **CSV Export**: Downloadable analysis reports

---

## 📋 Table of Contents

1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [Project Structure](#project-structure)
4. [Module Documentation](#module-documentation)
5. [Dashboard Usage](#dashboard-usage)
6. [Output Examples](#output-examples)
7. [Methodology](#methodology)
8. [Requirements](#requirements)
9. [Academic Context](#academic-context)
10. [Future Enhancements](#future-enhancements)

---

## 🚀 Installation

### Prerequisites

- R version 4.0 or higher
- RStudio (recommended)

### Step 1: Install Required Packages

Open R or RStudio and run:

```r
# Install required packages
install.packages(c(
  "tidyverse",      # Data manipulation and visualization
  "tm",             # Text mining
  "stringr",        # String operations
  "syuzhet",        # NRC emotion lexicon
  "caret",          # Machine learning framework
  "e1071",          # SVM and Naive Bayes
  "topicmodels",    # LDA topic modeling
  "ggplot2",        # Advanced plotting
  "wordcloud",      # Word cloud generation
  "fmsb",           # Radar charts
  "shiny",          # Interactive dashboard
  "shinydashboard", # Dashboard UI components
  "DT",             # Interactive tables
  "plotly",         # Interactive plots
  "zoo",            # Time-series analysis
  "lubridate",      # Date manipulation
  "RColorBrewer"    # Color palettes
))
```

### Step 2: Download Project Files

Place all project files in a single directory:

```
project_folder/
├── data_collection.R
├── preprocessing.R
├── lexicon_sentiment.R
├── emotion_detection.R
├── sarcasm_detection.R
├── topic_modeling.R
├── time_series_analysis.R
├── machine_learning_models.R
├── visualization.R
├── dashboard_app.R
├── main.R
├── sample_data.csv
└── README.md
```

---

## ⚡ Quick Start

### Option 1: Run Complete Analysis (Command Line)

```r
# Set working directory
setwd("path/to/project_folder")

# Run complete analysis
source("main.R")
```

This will:
- Load sample data
- Run all analysis modules
- Generate visualizations
- Export results to CSV

### Option 2: Analyze Custom CSV File

```r
source("main.R")

# Analyze your own data
results <- run_complete_analysis("your_data.csv", run_ml = TRUE, k_topics = 3)

# Export results
export_results_to_csv(results, "my_results.csv")
```

### Option 3: Launch Interactive Dashboard

```r
# Launch Shiny dashboard
source("dashboard_app.R")
```

The dashboard will open in your web browser where you can:
- Upload CSV files
- Enter text manually
- View interactive visualizations
- Download reports

---

## 📁 Project Structure

### Core Analysis Modules

#### 1. **data_collection.R**
- Load CSV files with validation
- Create datasets from manual input
- Validate data structure
- Generate data summaries

**Key Functions:**
- `load_data_from_csv()` - Load and validate CSV
- `create_manual_dataset()` - Create dataset from text
- `validate_dataset()` - Check data integrity

#### 2. **preprocessing.R**
- Text cleaning (URLs, emails, special characters)
- Lowercase conversion
- Number removal
- Stopword removal
- Tokenization

**Key Functions:**
- `preprocess_pipeline()` - Complete preprocessing
- `clean_text()` - Text normalization
- `tokenize_text()` - Word tokenization

#### 3. **lexicon_sentiment.R**
- Sentiment score calculation
- Polarity classification (Positive/Negative/Neutral)
- Intensity scoring (Strong/Mild)
- Negation handling
- Intensifier detection

**Key Functions:**
- `lexicon_sentiment_analysis()` - Full sentiment analysis
- `calculate_sentiment_score()` - Score text
- `classify_polarity()` - Determine sentiment

**Intensity Levels:**
- Score > 5: Strong Positive
- 1 to 5: Mild Positive
- 0: Neutral
- -1 to -5: Mild Negative
- < -5: Strong Negative

#### 4. **emotion_detection.R**
- NRC lexicon-based emotion detection
- 8 emotion categories: anger, anticipation, disgust, fear, joy, sadness, surprise, trust
- Dominant emotion identification
- Emotion intensity scoring

**Key Functions:**
- `emotion_analysis()` - Complete emotion detection
- `detect_emotions_nrc()` - NRC sentiment scores
- `get_dominant_emotion()` - Primary emotion per text

#### 5. **sarcasm_detection.R**
- Rule-based sarcasm detection
- Confidence scoring (0-100%)
- Multiple indicator analysis:
  - Excessive punctuation (!!, ??)
  - Laughing emojis/expressions (😂, lol, haha)
  - Quotation marks
  - Mixed signals
  - Exaggeration words
  - ALL CAPS

**Key Functions:**
- `sarcasm_analysis()` - Detect sarcasm
- `calculate_sarcasm_confidence()` - Confidence scoring

**Detection Logic:**
- Positive sentiment + laughter/punctuation = Likely sarcasm
- Quotation marks + positive words = Potential sarcasm
- Sarcasm score ≥ 3 = Flagged as sarcastic

#### 6. **topic_modeling.R**
- LDA (Latent Dirichlet Allocation) topic modeling
- Document-Term Matrix creation
- Topic keyword extraction
- Topic assignment with probability
- Topic-sentiment correlation

**Key Functions:**
- `topic_modeling_analysis()` - Complete topic modeling
- `perform_lda()` - LDA model training
- `extract_top_terms()` - Get keywords per topic

**Parameters:**
- k = 3 topics (default, configurable)
- Top 5 keywords per topic

#### 7. **time_series_analysis.R**
- Daily sentiment aggregation
- Moving average calculation
- Trend detection (Improving/Declining/Stable)
- Peak and valley identification
- Critical date analysis

**Key Functions:**
- `time_series_analysis()` - Full time-series analysis
- `aggregate_sentiment_by_date()` - Daily aggregation
- `identify_critical_dates()` - Find key dates

#### 8. **machine_learning_models.R**
- Naive Bayes classifier
- Support Vector Machine (SVM)
- Model training and evaluation
- Confusion matrix generation
- Performance metrics (Accuracy, Precision, Recall, F1)
- Comparison with lexicon method

**Key Functions:**
- `machine_learning_analysis()` - Train and evaluate models
- `train_naive_bayes()` - NB classifier
- `train_svm()` - SVM classifier
- `create_model_comparison()` - Performance table

**Data Split:**
- 70% Training
- 30% Testing

#### 9. **visualization.R**
- Sentiment distribution bar charts
- Sentiment intensity charts
- Word clouds (positive/negative)
- Emotion radar charts
- Time-series trend lines
- Topic distribution pie charts
- Model comparison charts

**Key Functions:**
- `create_visualization_dashboard()` - Generate all visualizations
- `plot_sentiment_distribution()` - Sentiment bars
- `create_wordcloud()` - Word clouds
- `plot_emotion_radar()` - Emotion radar

### Application Layer

#### 10. **dashboard_app.R**
Full-featured Shiny dashboard with 9 tabs:

1. **Dashboard**: Overview with key metrics
2. **Data Input**: CSV upload or manual text entry
3. **Sentiment Analysis**: Distribution and intensity
4. **Emotion Analysis**: Radar chart and distribution
5. **Sarcasm Detection**: Sarcasm statistics and examples
6. **Topic Modeling**: Keywords and distribution
7. **Time Trends**: Sentiment over time
8. **ML Models**: Performance comparison and confusion matrices
9. **Export Report**: Download CSV results

#### 11. **main.R**
Master orchestration script that:
- Loads all modules
- Executes complete pipeline
- Generates behavioral insights
- Exports results
- Reports execution time

---

## 🎯 Methodology

### Algorithm Flow

```
Input Data (CSV/Text)
    ↓
Data Validation & Loading
    ↓
Text Preprocessing
    ↓
┌─────────────┬─────────────┬─────────────┬─────────────┐
│  Sentiment  │   Emotion   │  Sarcasm    │   Topics    │
│  Analysis   │  Detection  │  Detection  │  Modeling   │
└─────────────┴─────────────┴─────────────┴─────────────┘
    ↓
Time-Series Analysis (if applicable)
    ↓
Machine Learning Classification
    ↓
Visualization Generation
    ↓
Behavioral Analytics Insights
    ↓
Export Results (CSV + Images)
```

### Sentiment Analysis Algorithm

1. **Tokenization**: Split text into words
2. **Lexicon Matching**: Count positive/negative words
3. **Intensifier Detection**: Multiply score if intensifiers present
4. **Negation Handling**: Flip sentiment if negation words detected
5. **Scoring**: Calculate (pos_count - neg_count) × intensifier
6. **Classification**: Map score to polarity and intensity

### Emotion Detection Algorithm

1. **NRC Lexicon Lookup**: Match words to emotion categories
2. **Score Aggregation**: Sum emotion scores per text
3. **Dominant Emotion**: Select emotion with highest score
4. **Intensity Calculation**: Total emotion score

### Sarcasm Detection Algorithm

```
IF sentiment_score > 0:
    IF has_excessive_punctuation OR has_laughter:
        sarcasm_score += 2
    IF has_quotes OR has_caps:
        sarcasm_score += 1
    IF has_negative_context:
        sarcasm_score += 2

IF sarcasm_score >= 3:
    FLAG as SARCASTIC
```

### Machine Learning Pipeline

1. **Data Preparation**: Filter Positive/Negative (binary classification)
2. **Feature Extraction**: TF-IDF Document-Term Matrix
3. **Train-Test Split**: 70-30 stratified split
4. **Model Training**:
   - Naive Bayes with Laplace smoothing
   - SVM with linear kernel
5. **Evaluation**: Confusion matrix, accuracy, precision, recall, F1

---

## 📊 Output Examples

### Console Output

```
==========================================
  AI SENTIMENT INTELLIGENCE SYSTEM v1.0  
==========================================

[STEP 1/9] DATA COLLECTION
--------------------------------------------
✓ Successfully loaded 50 records

[STEP 2/9] TEXT PREPROCESSING
--------------------------------------------
  [1/5] Cleaning text...
  [2/5] Converting to lowercase...
  [3/5] Removing numbers...
  [4/5] Removing stopwords...
  [5/5] Tokenizing text...
✓ Preprocessing complete! 50 records processed.

[STEP 3/9] LEXICON-BASED SENTIMENT ANALYSIS
--------------------------------------------
✓ Sentiment analysis complete! Processed 50 records.

Sentiment Distribution:
  Polarity   Count  Percentage
  Positive     28        56.0
  Negative     15        30.0
  Neutral       7        14.0
  Total        50       100.0

[STEP 4/9] EMOTION DETECTION
--------------------------------------------
✓ Emotion detection complete for 50 records.

Most Common Emotion: Joy
Average Emotion Intensity: 4.32

...
```

### Exported CSV Structure

```csv
id,original_text,text,date,user,sentiment_score,polarity,intensity,
dominant_emotion,anger,joy,fear,sadness,is_sarcasm,sarcasm_confidence,
topic,topic_probability
```

### Generated Visualizations

- `sentiment_distribution.png` - Bar chart of sentiment polarity
- `sentiment_intensity.png` - Intensity level distribution
- `wordcloud_positive.png` - Positive words cloud
- `wordcloud_negative.png` - Negative words cloud
- `emotion_radar.png` - Emotion distribution radar
- `sentiment_trend.png` - Time-series line chart
- `model_comparison.png` - ML performance comparison

---

## 💡 Dashboard Usage

### Uploading Data

1. Navigate to **Data Input** tab
2. Click "Choose CSV File"
3. Select your CSV (must have 'text' column)
4. Click "Load & Analyze"
5. Wait for processing (progress indicator shown)

### Manual Text Analysis

1. Go to **Data Input** tab
2. Enter text in text area (one per line)
3. Click "Analyze Text"
4. View results in other tabs

### Exploring Results

- **Dashboard**: Quick overview with key metrics
- **Sentiment Analysis**: Detailed sentiment breakdown
- **Emotion Analysis**: Interactive emotion charts
- **Sarcasm Detection**: View sarcastic texts
- **Topic Modeling**: Discover themes
- **Time Trends**: See sentiment over time
- **ML Models**: Compare model performance

### Downloading Reports

1. Go to **Export Report** tab
2. Choose:
   - **Full Results**: All columns and records
   - **Summary Report**: Key columns only
3. Click download button
4. CSV file saved to your downloads folder

---

## 🔧 Requirements

### Input CSV Format

**Required Column:**
- `text` - Text content to analyze

**Optional Columns:**
- `date` - Date in YYYY-MM-DD format (for time-series)
- `user` - User identifier

**Example:**
```csv
text,date,user
"I love this product!",2026-02-01,user001
"Terrible service",2026-02-02,user002
```

### System Requirements

- **RAM**: Minimum 4GB (8GB recommended for large datasets)
- **Storage**: 100MB for packages + data
- **R Version**: 4.0+
- **Operating System**: Windows/Mac/Linux

### Performance Notes

- Small datasets (<100 records): ~5-10 seconds
- Medium datasets (100-1000 records): ~30-60 seconds
- Large datasets (1000+ records): ~2-5 minutes
- ML training requires minimum 10 samples (5 positive, 5 negative)

---

## 🎓 Academic Context

### Suitable For

- M.Tech/Master's level projects
- Data Science capstone projects
- NLP research demonstrations
- Sentiment analysis coursework
- Text mining assignments

### Learning Outcomes

Students will understand:
1. Text preprocessing techniques
2. Lexicon-based sentiment analysis
3. Emotion detection methods
4. Topic modeling (LDA)
5. Time-series analysis
6. Machine learning classification
7. Evaluation metrics
8. Interactive visualization
9. Shiny dashboard development
10. Modular code design

### Report Structure

A complete project report should include:

1. **Abstract** (150-200 words)
2. **Introduction** (2 pages)
   - Background
   - Motivation
   - Objectives
3. **Problem Statement** (1 page)
4. **Literature Review** (3-4 pages)
5. **Methodology** (4-5 pages)
   - System architecture
   - Algorithms
   - Flowcharts
6. **Implementation** (3-4 pages)
   - Technology stack
   - Module descriptions
   - Code snippets
7. **Results & Analysis** (4-5 pages)
   - Screenshots
   - Performance metrics
   - Case studies
8. **Conclusion** (1 page)
9. **Future Scope** (1 page)
10. **References**

---

## 🚀 Future Enhancements

### Potential Improvements

1. **Deep Learning Integration**
   - BERT/GPT-based sentiment analysis
   - Neural topic modeling
   - LSTM for sequence analysis

2. **Advanced Features**
   - Aspect-based sentiment analysis
   - Entity recognition
   - Opinion mining
   - Sentiment causality detection

3. **Additional Languages**
   - Multi-language support
   - Translation integration

4. **Real-Time Analysis**
   - Twitter API integration
   - Streaming data processing
   - Live dashboard updates

5. **Advanced ML**
   - Deep neural networks
   - Ensemble methods
   - Hyperparameter tuning
   - Cross-validation

6. **Enhanced Visualizations**
   - Network graphs
   - Sankey diagrams
   - Animated time-series
   - 3D visualizations

7. **Deployment**
   - Docker containerization
   - Cloud deployment (AWS/Azure)
   - REST API development
   - Mobile app integration

---

## 📝 Citation

If you use this project in academic work, please cite:

```
AI-Based Multi-Dimensional Sentiment & Behavioral Intelligence System
Author: [Your Name]
Year: 2026
Technology: R, Shiny
GitHub: [Repository Link]
```

---

## 🤝 Contributing

Contributions are welcome! Areas for improvement:
- Additional sentiment lexicons
- More sarcasm detection rules
- Additional visualization types
- Performance optimizations
- Bug fixes

---

## 📄 License

This project is provided for educational purposes.

---

## 📧 Support

For questions or issues:
1. Check the console output for error messages
2. Verify all packages are installed
3. Ensure CSV format is correct
4. Check R and package versions

---

## 🙏 Acknowledgments

**Libraries Used:**
- tidyverse (data manipulation)
- syuzhet (NRC emotion lexicon)
- topicmodels (LDA)
- caret (ML framework)
- shiny (interactive dashboard)

**Lexicons:**
- Bing Liu Sentiment Lexicon
- NRC Emotion Lexicon

---

## 📊 Project Statistics

- **Total Lines of Code**: ~3000+
- **Modules**: 11
- **Functions**: 80+
- **Visualizations**: 8+
- **Analysis Dimensions**: 7
- **Dashboard Tabs**: 9
- **Supported Emotions**: 8
- **ML Models**: 2

---

**Version**: 1.0  
**Last Updated**: February 2026  
**Status**: Production Ready  

---

**🎯 Ready to analyze sentiment like never before!**
