# =============================================================================
# TOPIC MODELING MODULE
# Purpose: Perform LDA topic modeling to discover themes in text data
# Author: AI-Based Sentiment Intelligence System
# =============================================================================

# Load required libraries
library(tidyverse)
library(tm)
library(topicmodels)
library(tidytext)

#' Create Document-Term Matrix
#' @param data Dataframe with 'text' column
#' @param min_word_length Minimum token length to keep (default: 3)
#' @param min_term_doc_freq Minimum number of documents a term must appear in (default: 2)
#' @return DocumentTermMatrix object
#' @export
create_dtm <- function(data, min_word_length = 3, min_term_doc_freq = 2) {
    message("Creating Document-Term Matrix...")

    # Create corpus
    corpus <- Corpus(VectorSource(data$text))

    # Create DTM
    dtm <- DocumentTermMatrix(corpus, control = list(
        removePunctuation = TRUE,
        removeNumbers = TRUE,
        stopwords = TRUE,
        stemming = FALSE,
        wordLengths = c(min_word_length, Inf), # Keep words above configured length
        bounds = list(global = c(min_term_doc_freq, Inf)) # Keep terms by document frequency
    ))

    message(sprintf(
        "✓ DTM created: %d documents, %d terms",
        nrow(dtm), ncol(dtm)
    ))

    return(dtm)
}

#' Perform LDA Topic Modeling
#' @param dtm DocumentTermMatrix
#' @param k Number of topics (default: 3)
#' @param seed Random seed for reproducibility
#' @return LDA model object
#' @export
perform_lda <- function(dtm, k = 3, seed = 1234) {
    message(sprintf("Performing LDA with k=%d topics...", k))

    # Remove empty documents
    row_totals <- slam::row_sums(dtm)
    dtm <- dtm[row_totals > 0, ]

    if (nrow(dtm) == 0 || ncol(dtm) == 0) {
        stop("Insufficient data for topic modeling after preprocessing.")
    }

    effective_k <- min(k, nrow(dtm))
    if (effective_k < 2) {
        stop("LDA requires at least 2 valid documents/topics (k >= 2).")
    }

    # Run LDA
    lda_model <- LDA(
        dtm,
        k = effective_k,
        method = "Gibbs",
        control = list(seed = seed, iter = 1000, thin = 100)
    )

    message("✓ LDA modeling complete!")

    return(lda_model)
}

#' Extract Top Terms per Topic
#' @param lda_model LDA model object
#' @param n_terms Number of top terms per topic (default: 5)
#' @return Dataframe with topics and top terms
#' @export
extract_top_terms <- function(lda_model, n_terms = 5) {
    if (is.null(lda_model)) {
        return(list(
            detailed = tibble(topic = integer(), term = character(), beta = numeric(), rank = integer()),
            summary = tibble(topic = integer())
        ))
    }

    # Get beta (word-topic probabilities)
    topics <- tidy(lda_model, matrix = "beta")

    # Get top terms per topic
    top_terms <- topics %>%
        group_by(topic) %>%
        slice_max(beta, n = n_terms) %>%
        arrange(topic, desc(beta)) %>%
        mutate(rank = row_number()) %>%
        ungroup()

    # Create wide format
    top_terms_wide <- top_terms %>%
        select(topic, term, rank) %>%
        pivot_wider(
            names_from = rank,
            values_from = term,
            names_prefix = "Term_"
        )

    return(list(detailed = top_terms, summary = top_terms_wide))
}

#' Assign Topics to Documents
#' @param lda_model LDA model object
#' @param data Original dataframe
#' @return Dataframe with assigned topics
#' @export
assign_topics <- function(lda_model, data) {
    if (is.null(lda_model)) {
        data$topic <- rep(0L, nrow(data))
        data$topic_probability <- rep(0.0, nrow(data))
        return(data)
    }

    message("Assigning topics to documents...")

    # Get gamma (document-topic probabilities)
    doc_topics <- tidy(lda_model, matrix = "gamma")

    # Get dominant topic for each document
    dominant_topics <- doc_topics %>%
        group_by(document) %>%
        slice_max(gamma, n = 1) %>%
        ungroup() %>%
        mutate(document = as.integer(document))

    # Handle removed documents (empty ones)
    row_totals <- slam::row_sums(create_dtm(data))
    valid_docs <- which(row_totals > 0)

    # Create mapping with proper initialization
    data$topic <- rep(0L, nrow(data)) # Initialize as integer
    data$topic_probability <- rep(0.0, nrow(data)) # Initialize as numeric

    # Assign topics to valid documents (ensure matching lengths)
    if (nrow(dominant_topics) == length(valid_docs)) {
        data$topic[valid_docs] <- as.integer(dominant_topics$topic)
        data$topic_probability[valid_docs] <- as.numeric(dominant_topics$gamma)
    } else {
        # Create a proper mapping when lengths don't match
        for (i in seq_len(nrow(dominant_topics))) {
            doc_idx <- dominant_topics$document[i]
            if (doc_idx <= nrow(data)) {
                data$topic[doc_idx] <- as.integer(dominant_topics$topic[i])
                data$topic_probability[doc_idx] <- as.numeric(dominant_topics$gamma[i])
            }
        }
    }

    message(sprintf("✓ Topics assigned to %d documents", nrow(data)))

    return(data)
}

#' Perform Complete Topic Modeling Analysis
#' @param data Dataframe with preprocessed text
#' @param k Number of topics (default: 3)
#' @param n_terms Top terms per topic (default: 5)
#' @param min_word_length Minimum token length to keep in DTM (default: 3)
#' @param min_term_doc_freq Minimum document frequency for terms (default: 2)
#' @return List with data and topic model results
#' @export
topic_modeling_analysis <- function(data, k = 3, n_terms = 5,
                                    min_word_length = 3,
                                    min_term_doc_freq = 2) {
    message("Starting topic modeling analysis...")

    # Initialize topic columns so downstream steps always have expected schema
    data$topic <- rep(0L, nrow(data))
    data$topic_probability <- rep(0.0, nrow(data))

    # Create DTM
    dtm <- create_dtm(
        data,
        min_word_length = min_word_length,
        min_term_doc_freq = min_term_doc_freq
    )

    row_totals <- slam::row_sums(dtm)
    valid_doc_count <- sum(row_totals > 0)
    term_count <- ncol(dtm)

    if (valid_doc_count < 2 || term_count < 1) {
        message("Insufficient documents/terms for LDA. Skipping topic modeling.")
        empty_terms <- list(
            detailed = tibble(topic = integer(), term = character(), beta = numeric(), rank = integer()),
            summary = tibble(topic = integer())
        )
        return(list(
            data = data,
            lda_model = NULL,
            top_terms = empty_terms,
            dtm = dtm,
            skipped = TRUE,
            skip_reason = "Insufficient documents/terms for LDA (need at least 2 valid documents)"
        ))
    }

    # Perform LDA
    lda_model <- perform_lda(dtm, k = min(k, valid_doc_count))

    # Extract top terms
    message("  [1/2] Extracting top terms per topic...")
    top_terms <- extract_top_terms(lda_model, n_terms = n_terms)

    # Assign topics to documents
    message("  [2/2] Assigning topics to documents...")
    data <- assign_topics(lda_model, data)

    message("✓ Topic modeling analysis complete!")

    return(list(
        data = data,
        lda_model = lda_model,
        top_terms = top_terms,
        dtm = dtm,
        skipped = FALSE,
        skip_reason = NULL
    ))
}

#' Get Topic Distribution Summary
#' @param data Dataframe with topic assignments
#' @return Summary of topic distribution
#' @export
get_topic_summary <- function(data) {
    topic_dist <- data %>%
        filter(topic > 0) %>% # Exclude unassigned
        count(topic, name = "Count") %>%
        mutate(
            Percentage = round((Count / sum(Count)) * 100, 2),
            Topic_Label = paste0("Topic ", topic)
        ) %>%
        arrange(topic)

    return(topic_dist)
}

#' Get Topic Keywords Table
#' @param top_terms Top terms from extract_top_terms()
#' @param n_display Number of keywords to display (default: 5)
#' @return Formatted topic keywords table
#' @export
get_topic_keywords_table <- function(top_terms, n_display = 5) {
    if (is.null(top_terms) || is.null(top_terms$summary) || nrow(top_terms$summary) == 0) {
        return(tibble(Topic_Label = character(), Keywords = character()))
    }

    if (!any(startsWith(names(top_terms$summary), "Term_"))) {
        return(tibble(Topic_Label = character(), Keywords = character()))
    }

    keywords_table <- top_terms$summary %>%
        mutate(
            Topic_Label = paste0("Topic ", topic),
            Keywords = apply(select(., starts_with("Term_")), 1, function(x) {
                terms <- na.omit(x)
                paste(terms[1:min(n_display, length(terms))], collapse = ", ")
            })
        ) %>%
        select(Topic_Label, Keywords)

    return(keywords_table)
}

#' Analyze Topics by Sentiment
#' @param data Dataframe with topic and sentiment columns
#' @return Topic-sentiment analysis
#' @export
analyze_topics_by_sentiment <- function(data) {
    if (!"polarity" %in% colnames(data)) {
        stop("Error: 'polarity' column required. Run sentiment analysis first.")
    }

    if (!"topic" %in% colnames(data) || sum(data$topic > 0, na.rm = TRUE) == 0) {
        return(tibble(
            topic = integer(),
            Positive = integer(),
            Negative = integer(),
            Neutral = integer(),
            Total = integer(),
            Positive_Pct = numeric(),
            Negative_Pct = numeric(),
            Neutral_Pct = numeric()
        ))
    }

    topic_sentiment <- data %>%
        filter(topic > 0) %>%
        group_by(topic, polarity) %>%
        summarise(Count = n(), .groups = "drop") %>%
        pivot_wider(
            names_from = polarity,
            values_from = Count,
            values_fill = 0
        ) %>%
        mutate(
            Total = rowSums(select(., -topic)),
            Positive_Pct = round((Positive / Total) * 100, 2),
            Negative_Pct = round((Negative / Total) * 100, 2),
            Neutral_Pct = round((Neutral / Total) * 100, 2)
        ) %>%
        arrange(topic)

    return(topic_sentiment)
}

#' Get Sample Documents per Topic
#' @param data Dataframe with topic assignments
#' @param n_samples Number of samples per topic (default: 3)
#' @return Sample documents for each topic
#' @export
get_topic_samples <- function(data, n_samples = 3) {
    samples <- data %>%
        filter(topic > 0) %>%
        group_by(topic) %>%
        slice_max(topic_probability, n = n_samples) %>%
        select(topic, text, original_text, topic_probability) %>%
        ungroup() %>%
        arrange(topic, desc(topic_probability))

    return(samples)
}

# Example usage
if (FALSE) {
    # Load and preprocess data
    source("data_collection.R")
    source("preprocessing.R")
    source("lexicon_sentiment.R")

    data <- load_data_from_csv("data/sample_data.csv")
    data <- preprocess_pipeline(data)
    data <- lexicon_sentiment_analysis(data)

    # Perform topic modeling
    results <- topic_modeling_analysis(data, k = 3, n_terms = 5)

    # Get summaries
    topic_dist <- get_topic_summary(results$data)
    print(topic_dist)

    keywords <- get_topic_keywords_table(results$top_terms)
    print(keywords)

    topic_sentiment <- analyze_topics_by_sentiment(results$data)
    print(topic_sentiment)
}
