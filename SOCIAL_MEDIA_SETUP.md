# 🌐 Social Media Integration Guide

This guide helps you connect your sentiment analysis system to live social media data from Twitter/X and Facebook.

---

## 📋 Prerequisites

### Install Required R Packages

```r
install.packages(c(
  "rtweet",      # Twitter API
  "Rfacebook",   # Facebook API
  "jsonlite",    # JSON parsing
  "httr"         # HTTP requests
))
```

---

## 🐦 Twitter/X Setup

### Step 1: Get API Access

1. Go to [developer.twitter.com](https://developer.twitter.com)
2. Sign up for a developer account (verification required)
3. Create a new Project and App
4. Navigate to "Keys and Tokens"
5. Copy your **Bearer Token** (for v2 API)

### Step 2: API Tiers

| Tier | Cost | Monthly Tweets | Rate Limit |
|------|------|----------------|------------|
| Free | $0 | 500,000 reads | 10,000/month |
| Basic | $100 | 10M reads | Higher limits |
| Pro | $5,000 | 50M reads | Enterprise limits |

### Step 3: Configure in R

```r
# Open social_media_example.R
# Replace line 14:
TWITTER_BEARER_TOKEN <- "YOUR_ACTUAL_BEARER_TOKEN_HERE"
```

### Step 4: Test Connection

```r
source("social_media_connector.R")
twitter_authenticate(bearer_token = "YOUR_TOKEN")

# Test search
tweets <- fetch_tweets("customer service", n = 10)
head(tweets)
```

---

## 📘 Facebook Setup

### Step 1: Create Facebook App

1. Go to [developers.facebook.com](https://developers.facebook.com)
2. Create a new App
3. Select "Business" type
4. Add "Facebook Login" product
5. Get your **App ID** and **App Secret**

### Step 2: Get Access Token

**Option 1: Using Graph API Explorer**
1. Go to [Graph API Explorer](https://developers.facebook.com/tools/explorer)
2. Select your app
3. Request these permissions:
   - `pages_read_engagement`
   - `pages_read_user_content`
   - `public_profile`
4. Generate Access Token

**Option 2: Using R (OAuth flow)**
```r
library(Rfacebook)
fb_token <- fbOAuth(
  app_id = "YOUR_APP_ID",
  app_secret = "YOUR_APP_SECRET",
  extended_permissions = TRUE
)
```

### Step 3: Configure in R

```r
# Open social_media_example.R
# Replace lines 17-18:
FACEBOOK_APP_ID <- "YOUR_ACTUAL_APP_ID"
FACEBOOK_APP_SECRET <- "YOUR_ACTUAL_APP_SECRET"
```

### Step 4: Test Connection

```r
source("social_media_connector.R")
fb_auth <- facebook_authenticate(
  app_id = "YOUR_APP_ID",
  app_secret = "YOUR_APP_SECRET"
)

# Test page fetch
posts <- fetch_facebook_posts("Nike", token = fb_auth, n = 10)
head(posts)
```

---

## 🚀 Usage Examples

### Example 1: Basic Twitter Analysis

```r
source("social_media_connector.R")
source("main.R")

# Fetch tweets
tweets <- fetch_tweets("iPhone review", n = 500)

# Prepare for analysis
data <- prepare_social_data_for_analysis(tweets)

# Run complete analysis
results <- run_complete_analysis(data = data, run_ml = TRUE)

# Export
export_results_to_csv(results, "twitter_iphone_analysis.csv")
```

### Example 2: Facebook Page Analysis

```r
source("social_media_connector.R")
source("main.R")

# Authenticate
fb_token <- facebook_authenticate(
  app_id = "YOUR_ID",
  app_secret = "YOUR_SECRET"
)

# Fetch posts from a brand page
posts <- fetch_facebook_posts("Starbucks", token = fb_token, n = 200)

# Analyze
data <- prepare_social_data_for_analysis(posts)
results <- run_complete_analysis(data = data, run_ml = TRUE)

# Export
export_results_to_csv(results, "starbucks_facebook_analysis.csv")
```

### Example 3: Live Twitter Stream

```r
source("social_media_connector.R")
source("main.R")

# Authenticate first
twitter_authenticate(bearer_token = "YOUR_TOKEN")

# Stream live tweets for 5 minutes
stream_data <- stream_tweets_live(
  query = "customer support",
  duration = 300  # 5 minutes
)

# Analyze immediately
data <- prepare_social_data_for_analysis(stream_data)
results <- run_complete_analysis(data = data)
```

### Example 4: Multi-Source Analysis

```r
source("social_media_example.R")

# Update credentials first, then run:
multi_results <- multi_source_sentiment_analysis()

# Compare sentiment across platforms
multi_results$data %>%
  group_by(source, polarity) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = source, y = count, fill = polarity)) +
  geom_bar(stat = "identity", position = "dodge")
```

---

## ⚙️ Advanced Features

### Scheduling Regular Data Collection

Create a scheduled task to collect data hourly:

```r
# Create schedule_collection.R
library(taskscheduleR)

taskscheduler_create(
  taskname = "HourlySentimentAnalysis",
  rscript = "e:/Sentimental Analysis Using R/social_media_example.R",
  schedule = "HOURLY",
  starttime = "09:00"
)
```

### Real-Time Dashboard Updates

Modify your dashboard to refresh with live data:

```r
# Add to dashboard_app.R server function
observe({
  invalidateLater(300000)  # Refresh every 5 minutes

  new_tweets <- fetch_tweets("customer feedback", n = 100)
  new_data <- prepare_social_data_for_analysis(new_tweets)

  # Update reactive data
  analysis_results$data <- rbind(analysis_results$data, new_data)
})
```

### Filter by Sentiment Thresholds

```r
# Get only highly negative tweets for crisis management
negative_tweets <- tweets %>%
  filter(sentiment_score < -5)

# Alert system
if (nrow(negative_tweets) > 10) {
  send_email_alert("High volume of negative sentiment detected!")
}
```

---

## 🔍 Search Query Tips

### Twitter Query Operators

```r
# Exact phrase
fetch_tweets('"customer service"', n = 500)

# Multiple keywords (OR)
fetch_tweets('support OR help OR assistance', n = 500)

# Exclude retweets
fetch_tweets('product review -filter:retweets', n = 500)

# Hashtags
fetch_tweets('#customerfeedback', n = 500)

# From specific user
fetch_tweets('from:brand_name', n = 500)

# Location-based
fetch_tweets('near:"New York" within:15mi', n = 500)
```

### Facebook Search Tips

```r
# Page posts
fetch_facebook_posts("BrandPageName", token, n = 100)

# Specific post comments
fetch_facebook_comments("PAGE_ID_POST_ID", token, n = 500)
```

---

## 📊 Rate Limits & Best Practices

### Twitter Rate Limits

- **Search (Basic)**: 10,000 tweets/month
- **Streaming**: Real-time, connection-based
- **User Timeline**: 900 requests per 15 minutes

**Best Practice**: Cache results, don't re-query same data

```r
# Save fetched tweets
saveRDS(tweets, "tweets_cache.rds")

# Load later
tweets <- readRDS("tweets_cache.rds")
```

### Facebook Rate Limits

- **Per App**: ~200 calls/hour/user
- **Page Access**: Depends on page role and permissions

**Best Practice**: Use Graph API efficiently

```r
# Batch multiple pages
pages <- c("Page1", "Page2", "Page3")
all_posts <- lapply(pages, function(p) {
  fetch_facebook_posts(p, token, n = 50)
})
```

---

## 🛠️ Troubleshooting

### Common Issues

**1. Authentication Failed**
```r
# Check token validity
httr::GET("https://api.twitter.com/2/tweets/search/recent",
          httr::add_headers(Authorization = paste("Bearer", YOUR_TOKEN)))
```

**2. No Data Returned**
- Verify API permissions
- Check query syntax
- Ensure rate limits not exceeded

**3. Package Installation Errors**
```r
# If Rfacebook fails to install
install.packages("Rfacebook", repos = "http://cran.us.r-project.org")

# If rtweet fails
remotes::install_github("ropensci/rtweet")
```

---

## 📈 Results You'll Get

After running social media analysis, you'll have:

1. **CSV Export** with columns:
   - Original text
   - Sentiment score & polarity
   - Emotion detection (8 categories)
   - Sarcasm detection
   - Topic assignment
   - Source platform
   - Engagement metrics

2. **Visualizations**:
   - Sentiment trends over time
   - Word clouds by sentiment
   - Emotion distribution
   - Topic keyword charts
   - Source comparison

3. **Insights**:
   - Peak negative/positive periods
   - Most common complaints/praises
   - Sarcasm detection for crisis management
   - Topic trends

---

## 🎯 Next Steps

1. **Set up API credentials** (Twitter & Facebook)
2. **Test connections** with small queries
3. **Run example scripts** in `social_media_example.R`
4. **Schedule automated collection** for ongoing monitoring
5. **Integrate with dashboard** for real-time visualization

---

## 📚 Additional Resources

- [Twitter API Documentation](https://developer.twitter.com/en/docs)
- [Facebook Graph API](https://developers.facebook.com/docs/graph-api)
- [rtweet Package Guide](https://docs.ropensci.org/rtweet/)
- [Rfacebook Documentation](https://cran.r-project.org/web/packages/Rfacebook/Rfacebook.pdf)

---

**Need Help?** Check the example files or run:
```r
source("social_media_connector.R")
example_social_media_analysis()
```
