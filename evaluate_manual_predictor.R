# =============================================================================
# MANUAL PREDICTOR HOLDOUT EVALUATION
# Purpose: Evaluate sentiment_sarcasm_model on a holdout set with Accuracy/F1
# =============================================================================

suppressPackageStartupMessages({
    library(tidyverse)
    library(caret)
})

source("data_collection.R", local = TRUE)
source("preprocessing.R", local = TRUE)
source("lexicon_sentiment.R", local = TRUE)
source("emotion_detection.R", local = TRUE)
source("sarcasm_detection.R", local = TRUE)
source("machine_learning_models.R", local = TRUE)
source("unified_dataset_builder.R", local = TRUE)

#' Evaluate manual predictor using a holdout split from Sentiment140
#' @param main_dataset_path Path to Sentiment140 CSV
#' @param train_size Number of training rows
#' @param holdout_size Number of holdout rows
#' @param max_features Number of text features for model training
#' @param set_seed Random seed
#' @return List of evaluation results and metrics
#' @export
evaluate_manual_predictor_holdout <- function(
  main_dataset_path = "training.1600000.processed.noemoticon.csv",
  train_size = 50000,
  holdout_size = 10000,
  max_features = 1200,
  set_seed = 123
) {
    set.seed(set_seed)

    total_size <- train_size + holdout_size
    cat(sprintf("Loading %d rows (train=%d, holdout=%d)...\n", total_size, train_size, holdout_size))

    base_data <- load_main_dataset(
        file_path = main_dataset_path,
        sample_size = total_size,
        balanced = TRUE
    )

    # Stratified split by ground truth labels.
    train_idx <- createDataPartition(base_data$ground_truth, p = train_size / total_size, list = FALSE)
    train_raw <- base_data[train_idx, ]
    holdout_raw <- base_data[-train_idx, ]

    cat(sprintf("Actual split -> train=%d, holdout=%d\n", nrow(train_raw), nrow(holdout_raw)))

    # Build enriched training set (needed for sarcasm-aware model training).
    train_enriched <- preprocess_pipeline(train_raw, remove_nums = TRUE, remove_stops = FALSE)
    train_enriched <- lexicon_sentiment_analysis(train_enriched)
    train_enriched <- emotion_analysis(train_enriched)
    train_enriched <- sarcasm_analysis(train_enriched)
    train_enriched$sarcasm_label <- ifelse(train_enriched$is_sarcasm, "Sarcastic", "Non-Sarcastic")

    model_bundle <- train_manual_text_predictors(
        training_data = train_enriched,
        text_col = "text",
        sentiment_label_col = "ground_truth",
        sarcasm_label_col = "sarcasm_label",
        max_features = max_features
    )

    # Predict holdout texts and align labels by stable row IDs.
    holdout_ref <- data.frame(
        id = seq_len(nrow(holdout_raw)),
        ground_truth = holdout_raw$ground_truth,
        stringsAsFactors = FALSE
    )

    holdout_preds <- predict_manual_text_with_models(holdout_raw$original_text, model_bundle) %>%
        left_join(holdout_ref, by = "id") %>%
        filter(!is.na(ground_truth))

    # Evaluate raw model sentiment.
    y_true <- factor(holdout_preds$ground_truth, levels = c("Negative", "Positive"))
    y_model <- factor(holdout_preds$model_sentiment, levels = c("Negative", "Positive"))
    y_final <- factor(holdout_preds$final_sentiment, levels = c("Negative", "Positive"))

    cm_model <- confusionMatrix(y_model, y_true, positive = "Positive")
    cm_final <- confusionMatrix(y_final, y_true, positive = "Positive")

    metrics_model <- list(
        accuracy = as.numeric(cm_model$overall["Accuracy"]),
        precision = as.numeric(cm_model$byClass["Precision"]),
        recall = as.numeric(cm_model$byClass["Recall"]),
        f1 = as.numeric(cm_model$byClass["F1"])
    )

    metrics_final <- list(
        accuracy = as.numeric(cm_final$overall["Accuracy"]),
        precision = as.numeric(cm_final$byClass["Precision"]),
        recall = as.numeric(cm_final$byClass["Recall"]),
        f1 = as.numeric(cm_final$byClass["F1"])
    )

    cat("\n===== HOLDOUT EVALUATION =====\n")
    cat(sprintf("Rows: %d\n", nrow(holdout_preds)))

    cat("\nModel Sentiment (before sarcasm adjustment):\n")
    cat(sprintf("  Accuracy : %.4f\n", metrics_model$accuracy))
    cat(sprintf("  Precision: %.4f\n", metrics_model$precision))
    cat(sprintf("  Recall   : %.4f\n", metrics_model$recall))
    cat(sprintf("  F1       : %.4f\n", metrics_model$f1))

    cat("\nFinal Sentiment (after sarcasm adjustment):\n")
    cat(sprintf("  Accuracy : %.4f\n", metrics_final$accuracy))
    cat(sprintf("  Precision: %.4f\n", metrics_final$precision))
    cat(sprintf("  Recall   : %.4f\n", metrics_final$recall))
    cat(sprintf("  F1       : %.4f\n", metrics_final$f1))

    return(list(
        model_bundle = model_bundle,
        holdout_predictions = holdout_preds,
        model_metrics = metrics_model,
        final_metrics = metrics_final,
        model_confusion_matrix = cm_model$table,
        final_confusion_matrix = cm_final$table
    ))
}

if (FALSE) {
    results <- evaluate_manual_predictor_holdout(
        main_dataset_path = "training.1600000.processed.noemoticon.csv",
        train_size = 50000,
        holdout_size = 10000,
        max_features = 1200,
        set_seed = 123
    )
}
