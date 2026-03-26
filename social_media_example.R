# =============================================================================
# SOCIAL MEDIA SENTIMENT ANALYSIS - COMPLETE EXAMPLE
# This script demonstrates how to collect and analyze social media data
# =============================================================================

# Load required modules
source("social_media_connector.R")
source("main.R")

# =============================================================================
# CONFIGURATION
# =============================================================================

# Twitter API Configuration
TWITTER_BEARER_TOKEN <- "YOUR_TWITTER_BEARER_TOKEN_HERE"

# Facebook API Configuration
FACEBOOK_APP_ID <- "YOUR_FACEBOOK_APP_ID_HERE"
FACEBOOK_APP_SECRET <- "YOUR_FACEBOOK_APP_SECRET_HERE"

# Search parameters
TWITTER_QUERY <- "customer service OR product review"
TWITTER_COUNT <- 500

FACEBOOK_PAGE <- "YourBrandPage"
FACEBOOK_POST_COUNT <- 100

# =============================================================================
# EXAMPLE 1: TWITTER SENTIMENT ANALYSIS
# =============================================================================

twitter_sentiment_analysis <- function() {

  cat("\n╔════════════════════════════════════════════╗\n")
  cat("║   TWITTER SENTIMENT ANALYSIS WORKFLOW      ║\n")
  cat("╚════════════════════════════════════════════╝\n\n")

  # Step 1: Authenticate
  cat("[Step 1/5] Authenticating with Twitter...\n")
  twitter_authenticate(bearer_token = TWITTER_BEARER_TOKEN)

  # Step 2: Fetch tweets
  cat("\n[Step 2/5] Fetching tweets...\n")
  tweets <- fetch_tweets(
    query = TWITTER_QUERY,
    n = TWITTER_COUNT,
    include_retweets = FALSE,
    lang = "en"
  )

  if (is.null(tweets)) {
    stop("No tweets collected. Please check your query and authentication.")
  }

  # Step 3: Prepare data
  cat("\n[Step 3/5] Preparing data for analysis...\n")
  analysis_data <- prepare_social_data_for_analysis(tweets)

  # Step 4: Run complete sentiment analysis
  cat("\n[Step 4/5] Running complete sentiment analysis...\n")
  results <- run_complete_analysis(
    data = analysis_data,
    run_ml = TRUE,
    k_topics = 5
  )

  # Step 5: Export results
  cat("\n[Step 5/5] Exporting results...\n")
  output_file <- paste0("twitter_analysis_", Sys.Date(), ".csv")
  export_results_to_csv(results, output_file)

  cat("\n✓ Twitter sentiment analysis complete!\n")
  cat(sprintf("Results saved to: %s\n", output_file))

  return(results)
}

# =============================================================================
# EXAMPLE 2: FACEBOOK SENTIMENT ANALYSIS
# =============================================================================

facebook_sentiment_analysis <- function() {

  cat("\n╔════════════════════════════════════════════╗\n")
  cat("║   FACEBOOK SENTIMENT ANALYSIS WORKFLOW     ║\n")
  cat("╚════════════════════════════════════════════╝\n\n")

  # Step 1: Authenticate
  cat("[Step 1/5] Authenticating with Facebook...\n")
  fb_token <- facebook_authenticate(
    app_id = FACEBOOK_APP_ID,
    app_secret = FACEBOOK_APP_SECRET
  )

  # Step 2: Fetch posts
  cat("\n[Step 2/5] Fetching Facebook posts...\n")
  posts <- fetch_facebook_posts(
    page_name = FACEBOOK_PAGE,
    token = fb_token,
    n = FACEBOOK_POST_COUNT
  )

  if (is.null(posts)) {
    stop("No posts collected. Please check your page name and authentication.")
  }

  # Step 3: Prepare data
  cat("\n[Step 3/5] Preparing data for analysis...\n")
  analysis_data <- prepare_social_data_for_analysis(posts)

  # Step 4: Run complete sentiment analysis
  cat("\n[Step 4/5] Running complete sentiment analysis...\n")
  results <- run_complete_analysis(
    data = analysis_data,
    run_ml = TRUE,
    k_topics = 4
  )

  # Step 5: Export results
  cat("\n[Step 5/5] Exporting results...\n")
  output_file <- paste0("facebook_analysis_", Sys.Date(), ".csv")
  export_results_to_csv(results, output_file)

  cat("\n✓ Facebook sentiment analysis complete!\n")
  cat(sprintf("Results saved to: %s\n", output_file))

  return(results)
}

# =============================================================================
# EXAMPLE 3: COMBINED MULTI-SOURCE ANALYSIS
# =============================================================================

multi_source_sentiment_analysis <- function() {

  cat("\n╔════════════════════════════════════════════╗\n")
  cat("║   MULTI-SOURCE SENTIMENT ANALYSIS          ║\n")
  cat("╚════════════════════════════════════════════╝\n\n")

  # Authenticate
  twitter_authenticate(bearer_token = TWITTER_BEARER_TOKEN)
  fb_token <- facebook_authenticate(
    app_id = FACEBOOK_APP_ID,
    app_secret = FACEBOOK_APP_SECRET
  )

  # Define sources
  sources <- list(
    list(
      type = "twitter",
      query = "customer feedback",
      n = 300,
      include_retweets = FALSE,
      lang = "en"
    ),
    list(
      type = "facebook",
      page = FACEBOOK_PAGE,
      token = fb_token,
      n = 100
    )
  )

  # Collect data from all sources
  combined_data <- collect_social_media_data(sources)

  # Prepare for analysis
  analysis_data <- prepare_social_data_for_analysis(combined_data)

  # Run analysis
  results <- run_complete_analysis(
    data = analysis_data,
    run_ml = TRUE,
    k_topics = 5
  )

  # Export
  output_file <- paste0("multi_source_analysis_", Sys.Date(), ".csv")
  export_results_to_csv(results, output_file)

  # Summary by source
  summary_by_source <- results$data %>%
    group_by(source, polarity) %>%
    summarise(count = n(), .groups = 'drop') %>%
    arrange(source, polarity)

  cat("\nSentiment by Source:\n")
  print(summary_by_source)

  return(results)
}

# =============================================================================
# EXAMPLE 4: LIVE TWITTER STREAM ANALYSIS
# =============================================================================

live_stream_analysis <- function(duration = 120) {

  cat("\n╔════════════════════════════════════════════╗\n")
  cat("║   LIVE TWITTER STREAM ANALYSIS             ║\n")
  cat("╚════════════════════════════════════════════╝\n\n")

  # Authenticate
  twitter_authenticate(bearer_token = TWITTER_BEARER_TOKEN)

  # Stream live tweets
  cat(sprintf("Streaming tweets for %d seconds...\n", duration))
  stream_data <- stream_tweets_live(
    query = "customer service",
    duration = duration
  )

  if (is.null(stream_data) || nrow(stream_data) == 0) {
    stop("No tweets captured in stream. Try increasing duration.")
  }

  # Prepare and analyze
  analysis_data <- prepare_social_data_for_analysis(stream_data)
  results <- run_complete_analysis(data = analysis_data, run_ml = FALSE)

  # Export
  output_file <- paste0("live_stream_analysis_", Sys.Date(), ".csv")
  export_results_to_csv(results, output_file)

  cat("\n✓ Live stream analysis complete!\n")

  return(results)
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Uncomment the analysis you want to run:

# Run Twitter analysis
# twitter_results <- twitter_sentiment_analysis()

# Run Facebook analysis
# facebook_results <- facebook_sentiment_analysis()

# Run multi-source analysis
# multi_results <- multi_source_sentiment_analysis()

# Run live stream analysis (2 minutes)
# stream_results <- live_stream_analysis(duration = 120)

cat("\n")
cat("╔══════════════════════════════════════════════════════════╗\n")
cat("║              SOCIAL MEDIA ANALYSIS READY                 ║\n")
cat("║                                                           ║\n")
cat("║  1. Update API credentials at the top of this file       ║\n")
cat("║  2. Uncomment the analysis function you want to run      ║\n")
cat("║  3. Run: source('social_media_example.R')                ║\n")
cat("║                                                           ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n\n")
