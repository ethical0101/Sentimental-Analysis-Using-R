# =============================================================================
# SOCIAL MEDIA DATA CONNECTOR
# Purpose: Fetch live data from Twitter/X and Facebook for sentiment analysis
# =============================================================================

library(rtweet)
library(Rfacebook)
library(jsonlite)
library(httr)

# =============================================================================
# TWITTER/X FUNCTIONS
# =============================================================================

#' Authenticate with Twitter API
#' @param bearer_token Your Twitter Bearer Token
#' @return Authentication object
#' @export
twitter_authenticate <- function(bearer_token = NULL) {
  if (is.null(bearer_token)) {
    stop("Please provide a bearer_token. Get one from developer.twitter.com")
  }

  auth <- rtweet_app(bearer_token = bearer_token)
  cat("✓ Twitter authentication successful!\n")
  return(auth)
}

#' Search and collect tweets
#' @param query Search query (keywords, hashtags)
#' @param n Number of tweets to fetch (max depends on API tier)
#' @param include_retweets Include retweets (default: FALSE)
#' @param lang Language filter (default: "en")
#' @return Data frame with tweet data
#' @export
fetch_tweets <- function(query, n = 1000, include_retweets = FALSE, lang = "en") {

  cat(sprintf("Searching for tweets: '%s'\n", query))
  cat(sprintf("Fetching up to %d tweets...\n", n))

  tryCatch({
    tweets <- search_tweets(
      q = query,
      n = n,
      include_rts = include_retweets,
      lang = lang,
      parse = TRUE,
      token = NULL  # Uses default authentication
    )

    if (nrow(tweets) == 0) {
      warning("No tweets found for the given query.")
      return(NULL)
    }

    # Extract relevant fields
    tweet_data <- data.frame(
      id = seq_len(nrow(tweets)),
      text = tweets$text,
      date = as.Date(tweets$created_at),
      user = tweets$screen_name,
      retweet_count = tweets$retweet_count,
      favorite_count = tweets$favorite_count,
      source = "Twitter",
      stringsAsFactors = FALSE
    )

    cat(sprintf("✓ Successfully fetched %d tweets\n", nrow(tweet_data)))
    return(tweet_data)

  }, error = function(e) {
    stop(sprintf("Error fetching tweets: %s\n", e$message))
  })
}

#' Stream live tweets in real-time
#' @param query Search query
#' @param duration Duration in seconds (default: 60)
#' @param output_file File to save streamed tweets (optional)
#' @return Data frame with tweet data
#' @export
stream_tweets_live <- function(query, duration = 60, output_file = NULL) {

  cat(sprintf("Starting live tweet stream for: '%s'\n", query))
  cat(sprintf("Streaming for %d seconds...\n", duration))

  if (is.null(output_file)) {
    output_file <- paste0("tweets_stream_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".json")
  }

  # Stream tweets
  stream_tweets(
    q = query,
    timeout = duration,
    file_name = output_file,
    parse = FALSE
  )

  # Read and parse streamed data
  if (file.exists(output_file)) {
    tweets <- parse_stream(output_file)

    tweet_data <- data.frame(
      id = seq_len(nrow(tweets)),
      text = tweets$text,
      date = as.Date(tweets$created_at),
      user = tweets$screen_name,
      retweet_count = tweets$retweet_count,
      favorite_count = tweets$favorite_count,
      source = "Twitter_Stream",
      stringsAsFactors = FALSE
    )

    cat(sprintf("✓ Captured %d tweets from live stream\n", nrow(tweet_data)))
    return(tweet_data)
  } else {
    warning("Stream file not created. No tweets captured.")
    return(NULL)
  }
}

# =============================================================================
# FACEBOOK FUNCTIONS
# =============================================================================

#' Authenticate with Facebook API
#' @param app_id Your Facebook App ID
#' @param app_secret Your Facebook App Secret
#' @return Authentication token
#' @export
facebook_authenticate <- function(app_id = NULL, app_secret = NULL) {
  if (is.null(app_id) || is.null(app_secret)) {
    stop("Please provide app_id and app_secret from developers.facebook.com")
  }

  fb_oauth <- fbOAuth(
    app_id = app_id,
    app_secret = app_secret,
    extended_permissions = TRUE
  )

  cat("✓ Facebook authentication successful!\n")
  return(fb_oauth)
}

#' Fetch Facebook page posts
#' @param page_name Facebook page name or ID
#' @param token Facebook authentication token
#' @param n Number of posts to fetch
#' @return Data frame with post data
#' @export
fetch_facebook_posts <- function(page_name, token, n = 100) {

  cat(sprintf("Fetching posts from Facebook page: '%s'\n", page_name))

  tryCatch({
    posts <- getPage(
      page = page_name,
      token = token,
      n = n,
      feed = TRUE
    )

    if (nrow(posts) == 0) {
      warning("No posts found for the given page.")
      return(NULL)
    }

    # Extract relevant fields
    post_data <- data.frame(
      id = seq_len(nrow(posts)),
      text = posts$message,
      date = as.Date(posts$created_time),
      likes = posts$likes_count,
      comments = posts$comments_count,
      shares = posts$shares_count,
      source = "Facebook",
      stringsAsFactors = FALSE
    )

    # Remove posts with empty text
    post_data <- post_data[!is.na(post_data$text) & post_data$text != "", ]

    cat(sprintf("✓ Successfully fetched %d posts\n", nrow(post_data)))
    return(post_data)

  }, error = function(e) {
    stop(sprintf("Error fetching Facebook posts: %s\n", e$message))
  })
}

#' Fetch comments from a Facebook post
#' @param post_id Facebook post ID
#' @param token Facebook authentication token
#' @param n Number of comments to fetch
#' @return Data frame with comment data
#' @export
fetch_facebook_comments <- function(post_id, token, n = 500) {

  cat(sprintf("Fetching comments from post: '%s'\n", post_id))

  tryCatch({
    post_data <- getPost(
      post = post_id,
      token = token,
      comments = TRUE,
      n = n
    )

    if (is.null(post_data$comments) || nrow(post_data$comments) == 0) {
      warning("No comments found for the given post.")
      return(NULL)
    }

    comments <- post_data$comments

    # Extract relevant fields
    comment_data <- data.frame(
      id = seq_len(nrow(comments)),
      text = comments$message,
      date = as.Date(comments$created_time),
      likes = comments$likes_count,
      user = comments$from_name,
      source = "Facebook_Comments",
      stringsAsFactors = FALSE
    )

    cat(sprintf("✓ Successfully fetched %d comments\n", nrow(comment_data)))
    return(comment_data)

  }, error = function(e) {
    stop(sprintf("Error fetching Facebook comments: %s\n", e$message))
  })
}

# =============================================================================
# UNIFIED DATA COLLECTION
# =============================================================================

#' Collect data from multiple social media sources
#' @param sources List of data sources and their parameters
#' @return Combined data frame from all sources
#' @export
collect_social_media_data <- function(sources) {

  cat("\n")
  cat("╔══════════════════════════════════════════════════════════╗\n")
  cat("║        SOCIAL MEDIA DATA COLLECTION STARTED              ║\n")
  cat("╚══════════════════════════════════════════════════════════╝\n\n")

  all_data <- list()

  for (i in seq_along(sources)) {
    source_config <- sources[[i]]

    cat(sprintf("[Source %d/%d] %s\n", i, length(sources), source_config$type))
    cat("─────────────────────────────────────────────\n")

    data <- tryCatch({
      if (source_config$type == "twitter") {
        fetch_tweets(
          query = source_config$query,
          n = source_config$n,
          include_retweets = source_config$include_retweets,
          lang = source_config$lang
        )
      } else if (source_config$type == "facebook") {
        fetch_facebook_posts(
          page_name = source_config$page,
          token = source_config$token,
          n = source_config$n
        )
      } else {
        warning(sprintf("Unknown source type: %s", source_config$type))
        NULL
      }
    }, error = function(e) {
      cat(sprintf("✗ Failed to fetch data: %s\n", e$message))
      NULL
    })

    if (!is.null(data)) {
      all_data[[i]] <- data
    }

    cat("\n")
  }

  # Combine all data
  if (length(all_data) == 0) {
    stop("No data collected from any source.")
  }

  combined_data <- do.call(rbind, all_data)
  combined_data$id <- seq_len(nrow(combined_data))

  cat("╔══════════════════════════════════════════════════════════╗\n")
  cat(sprintf("║  ✓ DATA COLLECTION COMPLETE: %d total records          ║\n", nrow(combined_data)))
  cat("╚══════════════════════════════════════════════════════════╝\n\n")

  return(combined_data)
}

#' Convert social media data to analysis format
#' @param social_data Data frame from social media sources
#' @return Data frame formatted for sentiment analysis
#' @export
prepare_social_data_for_analysis <- function(social_data) {

  # Ensure required columns exist
  if (!"text" %in% names(social_data)) {
    stop("Data must contain a 'text' column")
  }

  # Create standard format
  analysis_data <- data.frame(
    id = social_data$id,
    text = social_data$text,
    date = if ("date" %in% names(social_data)) social_data$date else Sys.Date(),
    original_text = social_data$text,
    source = if ("source" %in% names(social_data)) social_data$source else "Unknown",
    stringsAsFactors = FALSE
  )

  # Remove empty or NA text
  analysis_data <- analysis_data[!is.na(analysis_data$text) &
                                   nchar(trimws(analysis_data$text)) > 0, ]

  # Reset IDs
  analysis_data$id <- seq_len(nrow(analysis_data))

  cat(sprintf("✓ Prepared %d records for analysis\n", nrow(analysis_data)))

  return(analysis_data)
}

# =============================================================================
# EXAMPLE USAGE
# =============================================================================

#' Example workflow for social media sentiment analysis
#' @export
example_social_media_analysis <- function() {

  cat("\n")
  cat("╔══════════════════════════════════════════════════════════╗\n")
  cat("║     SOCIAL MEDIA SENTIMENT ANALYSIS - EXAMPLE           ║\n")
  cat("╚══════════════════════════════════════════════════════════╝\n\n")

  cat("STEP 1: Setup Authentication\n")
  cat("─────────────────────────────────────────────\n")
  cat("# For Twitter:\n")
  cat("twitter_auth <- twitter_authenticate(bearer_token = 'YOUR_TOKEN')\n\n")
  cat("# For Facebook:\n")
  cat("fb_auth <- facebook_authenticate(app_id = 'YOUR_APP_ID', app_secret = 'YOUR_SECRET')\n\n")

  cat("STEP 2: Collect Data\n")
  cat("─────────────────────────────────────────────\n")
  cat("# Twitter example:\n")
  cat("tweets <- fetch_tweets('customer feedback', n = 500)\n\n")
  cat("# Facebook example:\n")
  cat("fb_posts <- fetch_facebook_posts('YourBrandPage', token = fb_auth, n = 100)\n\n")

  cat("STEP 3: Prepare for Analysis\n")
  cat("─────────────────────────────────────────────\n")
  cat("data <- prepare_social_data_for_analysis(tweets)\n\n")

  cat("STEP 4: Run Sentiment Analysis\n")
  cat("─────────────────────────────────────────────\n")
  cat("source('main.R')\n")
  cat("results <- run_complete_analysis(data = data, run_ml = TRUE)\n\n")

  cat("STEP 5: Export Results\n")
  cat("─────────────────────────────────────────────\n")
  cat("export_results_to_csv(results, 'social_media_analysis.csv')\n\n")
}

# Print usage instructions when sourced
cat("\n✓ Social Media Connector module loaded\n")
cat("Run example_social_media_analysis() to see usage examples\n\n")
