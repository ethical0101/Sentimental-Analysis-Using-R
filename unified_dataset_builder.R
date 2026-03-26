# =============================================================================
# UNIFIED DATASET BUILDER
# Purpose: Build an enriched dataset (sentiment + emotion + sarcasm) from main data
# =============================================================================

suppressPackageStartupMessages({
    library(tidyverse)
})

source("data_collection.R", local = TRUE)
source("preprocessing.R", local = TRUE)
source("lexicon_sentiment.R", local = TRUE)
source("emotion_detection.R", local = TRUE)
source("sarcasm_detection.R", local = TRUE)
source("machine_learning_models.R", local = TRUE)

#' Load Sentiment140 data with optional balanced sampling
#' @param file_path Path to Sentiment140 CSV
#' @param sample_size Number of rows to sample (NULL for full file)
#' @param balanced Whether to sample equal positive/negative rows
#' @param chunk_size Chunk size for streaming sample
#' @return Dataframe with standardized columns
#' @export
load_main_dataset <- function(file_path,
                              sample_size = 50000,
                              balanced = TRUE,
                              chunk_size = 100000) {
    if (!file.exists(file_path)) {
        stop(sprintf("Main dataset not found: %s", file_path))
    }

    col_names <- c("sentiment", "tweet_id", "date", "query", "user", "text")

    if (is.null(sample_size)) {
        raw <- read.csv(
            file_path,
            header = FALSE,
            col.names = col_names,
            stringsAsFactors = FALSE,
            encoding = "UTF-8"
        )
    } else if (balanced) {
        target_per_class <- ceiling(sample_size / 2)
        positive_samples <- data.frame()
        negative_samples <- data.frame()

        max_chunks <- 40
        for (i in seq_len(max_chunks)) {
            skip_rows <- (i - 1) * chunk_size

            chunk <- tryCatch(
                {
                    read.csv(
                        file_path,
                        header = FALSE,
                        col.names = col_names,
                        stringsAsFactors = FALSE,
                        skip = skip_rows,
                        nrows = chunk_size,
                        encoding = "UTF-8"
                    )
                },
                error = function(e) NULL
            )

            if (is.null(chunk) || nrow(chunk) == 0) {
                break
            }

            pos <- chunk[chunk$sentiment == 4, ]
            neg <- chunk[chunk$sentiment == 0, ]

            if (nrow(positive_samples) < target_per_class && nrow(pos) > 0) {
                needed <- target_per_class - nrow(positive_samples)
                positive_samples <- rbind(positive_samples, head(pos, needed))
            }

            if (nrow(negative_samples) < target_per_class && nrow(neg) > 0) {
                needed <- target_per_class - nrow(negative_samples)
                negative_samples <- rbind(negative_samples, head(neg, needed))
            }

            if (nrow(positive_samples) >= target_per_class && nrow(negative_samples) >= target_per_class) {
                break
            }
        }

        raw <- rbind(positive_samples, negative_samples)
        if (nrow(raw) == 0) {
            stop("Balanced sampling failed: no rows were collected")
        }
        raw <- raw[sample(nrow(raw)), ]
    } else {
        raw <- read.csv(
            file_path,
            header = FALSE,
            col.names = col_names,
            stringsAsFactors = FALSE,
            nrows = sample_size,
            encoding = "UTF-8"
        )
    }

    raw$ground_truth <- ifelse(raw$sentiment == 0, "Negative", "Positive")
    parsed_dates <- as.Date(raw$date, format = "%a %b %d %H:%M:%S PDT %Y")
    parsed_dates[is.na(parsed_dates)] <- Sys.Date()

    data <- data.frame(
        id = seq_len(nrow(raw)),
        text = raw$text,
        original_text = raw$text,
        date = parsed_dates,
        user = raw$user,
        source = "Sentiment140",
        ground_truth = raw$ground_truth,
        stringsAsFactors = FALSE
    )

    message(sprintf("Loaded %d rows from main dataset", nrow(data)))
    return(data)
}

#' Build a unified enriched dataset from main dataset
#' @param main_dataset_path Path to Sentiment140 main dataset
#' @param output_file Output CSV path
#' @param sample_size Number of rows to process (NULL for full file)
#' @param balanced Whether to sample equal positive/negative rows
#' @return Enriched dataframe
#' @export
build_unified_dataset <- function(main_dataset_path = "training.1600000.processed.noemoticon.csv",
                                  output_file = "unified_sentiment_sarcasm_dataset.csv",
                                  sample_size = 50000,
                                  balanced = TRUE) {
    message("Step 1/5: Loading main dataset...")
    data <- load_main_dataset(
        file_path = main_dataset_path,
        sample_size = sample_size,
        balanced = balanced
    )

    message("Step 2/5: Preprocessing text...")
    data <- preprocess_pipeline(data, remove_nums = TRUE, remove_stops = FALSE)

    message("Step 3/5: Running sentiment + emotion + sarcasm enrichment...")
    data <- lexicon_sentiment_analysis(data)
    data <- emotion_analysis(data)
    data <- sarcasm_analysis(data)

    message("Step 4/5: Building final unified columns...")
    data$sarcasm_label <- ifelse(data$is_sarcasm, "Sarcastic", "Non-Sarcastic")
    data$final_sentiment <- ifelse(data$is_sarcasm & data$ground_truth == "Positive", "Negative", data$ground_truth)

    export_data <- data %>%
        select(any_of(c(
            "id", "date", "user", "source",
            "original_text", "text",
            "ground_truth", "final_sentiment",
            "sentiment_score", "polarity", "intensity",
            "dominant_emotion", "emotion_intensity",
            "anger", "anticipation", "disgust", "fear", "joy", "sadness", "surprise", "trust",
            "is_sarcasm", "sarcasm_label", "sarcasm_confidence"
        )))

    message("Step 5/5: Exporting unified dataset...")
    write.csv(export_data, output_file, row.names = FALSE)

    message(sprintf("Unified dataset created: %s", output_file))
    message(sprintf("Rows: %d | Columns: %d", nrow(export_data), ncol(export_data)))
    return(export_data)
}

#' Train and save manual predictor models from unified dataset
#' @param unified_dataset_file Path to unified dataset CSV
#' @param model_output_file Output RDS path
#' @param max_features Maximum text features
#' @return Model bundle
#' @export
build_and_save_predictor <- function(unified_dataset_file = "unified_sentiment_sarcasm_dataset.csv",
                                     model_output_file = "sentiment_sarcasm_model.rds",
                                     max_features = 1200) {
    if (!file.exists(unified_dataset_file)) {
        stop(sprintf("Unified dataset not found: %s", unified_dataset_file))
    }

    data <- read.csv(unified_dataset_file, stringsAsFactors = FALSE)

    model_bundle <- train_manual_text_predictors(
        training_data = data,
        text_col = "text",
        sentiment_label_col = "ground_truth",
        sarcasm_label_col = "sarcasm_label",
        max_features = max_features
    )

    saveRDS(model_bundle, model_output_file)
    message(sprintf("Saved predictor model to: %s", model_output_file))

    return(model_bundle)
}

if (FALSE) {
    # Example run:
    unified <- build_unified_dataset(
        main_dataset_path = "training.1600000.processed.noemoticon.csv",
        output_file = "unified_sentiment_sarcasm_dataset.csv",
        sample_size = 50000,
        balanced = TRUE
    )

    model_bundle <- build_and_save_predictor(
        unified_dataset_file = "unified_sentiment_sarcasm_dataset.csv",
        model_output_file = "sentiment_sarcasm_model.rds",
        max_features = 1200
    )
}
