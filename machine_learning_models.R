# =============================================================================
# MACHINE LEARNING MODELS MODULE
# Purpose: Train and evaluate ML models (Naive Bayes, SVM) for sentiment classification
# Author: AI-Based Sentiment Intelligence System
# =============================================================================

# Load required libraries
library(tidyverse)
library(caret)
library(e1071)
library(tm)

#' Prepare Data for Machine Learning
#' @param data Dataframe with text and polarity
#' @param label_column Column name to use as labels (default: "polarity")
#' @return Prepared dataset for ML
#' @export
prepare_ml_data <- function(data, label_column = "polarity") {

  message("Preparing data for machine learning...")

  # Use specified label column or default to polarity
  if (label_column %in% names(data)) {
    data$label_source <- data[[label_column]]
  } else {
    warning(sprintf("Label column '%s' not found, using 'polarity'", label_column))
    data$label_source <- data$polarity
  }

  # Filter out neutral sentiments for binary classification
  ml_data <- data %>%
    filter(label_source %in% c("Positive", "Negative")) %>%
    mutate(label = factor(label_source, levels = c("Negative", "Positive")))

  if (nrow(ml_data) < 10) {
    stop("Error: Insufficient data for ML training (need at least 10 samples)")
  }

  message(sprintf("✓ Prepared %d samples for ML (%d Positive, %d Negative)",
                  nrow(ml_data),
                  sum(ml_data$label == "Positive"),
                  sum(ml_data$label == "Negative")))

  return(ml_data)
}

#' Create Document-Term Matrix for ML
#' @param data Dataframe with text column
#' @param max_features Maximum number of features (default: 500)
#' @return Document-Term Matrix
#' @export
create_ml_dtm <- function(data, max_features = 500) {

  # Create corpus
  corpus <- Corpus(VectorSource(data$text))

  # Create DTM
  dtm <- DocumentTermMatrix(corpus, control = list(
    weighting = weightTfIdf,
    removePunctuation = TRUE,
    removeNumbers = TRUE,
    stopwords = TRUE,
    wordLengths = c(3, Inf)
  ))

  # Reduce to top features
  if (ncol(dtm) > max_features) {
    freq <- colSums(as.matrix(dtm))
    top_terms <- names(sort(freq, decreasing = TRUE)[1:max_features])
    dtm <- dtm[, top_terms]
  }

  # Convert to matrix
  dtm_matrix <- as.matrix(dtm)

  message(sprintf("✓ Created DTM with %d features", ncol(dtm_matrix)))

  return(dtm_matrix)
}

#' Split Data into Training and Testing Sets
#' @param ml_data Prepared ML dataset
#' @param dtm_matrix Document-Term Matrix
#' @param train_ratio Training set ratio (default: 0.7)
#' @return List with train and test splits
#' @export
split_train_test <- function(ml_data, dtm_matrix, train_ratio = 0.7) {

  set.seed(123)

  # Create stratified split
  train_index <- createDataPartition(
    ml_data$label,
    p = train_ratio,
    list = FALSE
  )

  # Split data
  train_dtm <- dtm_matrix[train_index, ]
  test_dtm <- dtm_matrix[-train_index, ]

  train_labels <- ml_data$label[train_index]
  test_labels <- ml_data$label[-train_index]

  message(sprintf("✓ Split: %d training, %d testing samples",
                  length(train_labels), length(test_labels)))

  return(list(
    train_dtm = train_dtm,
    test_dtm = test_dtm,
    train_labels = train_labels,
    test_labels = test_labels
  ))
}

#' Train Naive Bayes Classifier
#' @param train_dtm Training DTM
#' @param train_labels Training labels
#' @return Trained Naive Bayes model
#' @export
train_naive_bayes <- function(train_dtm, train_labels) {

  message("Training Naive Bayes classifier...")

  # Train model
  nb_model <- naiveBayes(
    x = train_dtm,
    y = train_labels,
    laplace = 1
  )

  message("✓ Naive Bayes training complete!")

  return(nb_model)
}

#' Train SVM Classifier
#' @param train_dtm Training DTM
#' @param train_labels Training labels
#' @return Trained SVM model
#' @export
train_svm <- function(train_dtm, train_labels) {

  message("Training SVM classifier...")

  # Train model
  svm_model <- svm(
    x = train_dtm,
    y = train_labels,
    kernel = "linear",
    cost = 1,
    scale = TRUE
  )

  message("✓ SVM training complete!")

  return(svm_model)
}

#' Evaluate Model Performance
#' @param predictions Predicted labels
#' @param actual_labels True labels
#' @return Performance metrics
#' @export
evaluate_model <- function(predictions, actual_labels) {

  # Create confusion matrix
  cm <- confusionMatrix(
    data = predictions,
    reference = actual_labels,
    positive = "Positive"
  )

  # Extract metrics
  metrics <- tibble(
    Accuracy = cm$overall["Accuracy"],
    Precision = cm$byClass["Precision"],
    Recall = cm$byClass["Recall"],
    F1_Score = cm$byClass["F1"],
    Specificity = cm$byClass["Specificity"]
  )

  return(list(
    metrics = metrics,
    confusion_matrix = cm$table
  ))
}

#' Perform Complete Machine Learning Analysis
#' @param data Dataframe with text and polarity
#' @param label_column Column name to use as ground truth labels (default: "polarity")
#' @param max_features Maximum DTM features (default: 500)
#' @return ML analysis results
#' @export
machine_learning_analysis <- function(data, label_column = "polarity", max_features = 500) {

  message("Starting machine learning analysis...")

  # Prepare data
  ml_data <- prepare_ml_data(data, label_column = label_column)

  # Create DTM
  dtm_matrix <- create_ml_dtm(ml_data, max_features = max_features)

  # Split data
  splits <- split_train_test(ml_data, dtm_matrix, train_ratio = 0.7)

  # Train Naive Bayes
  message("\n[1/4] Training Naive Bayes...")
  nb_model <- train_naive_bayes(splits$train_dtm, splits$train_labels)

  # Predict with Naive Bayes
  message("[2/4] Evaluating Naive Bayes...")
  nb_pred <- predict(nb_model, splits$test_dtm)
  nb_eval <- evaluate_model(nb_pred, splits$test_labels)

  # Train SVM
  message("\n[3/4] Training SVM...")
  svm_model <- train_svm(splits$train_dtm, splits$train_labels)

  # Predict with SVM
  message("[4/4] Evaluating SVM...")
  svm_pred <- predict(svm_model, splits$test_dtm)
  svm_eval <- evaluate_model(svm_pred, splits$test_labels)

  # Compare with lexicon method (if polarity exists)
  if ("polarity" %in% names(ml_data)) {
    lexicon_accuracy <- mean(ml_data$polarity == ml_data$label)
  } else {
    lexicon_accuracy <- NA
  }

  message("\n✓ Machine learning analysis complete!")

  # Return cleaned metrics
  return(list(
    nb_model = nb_model,
    svm_model = svm_model,
    nb_metrics = list(
      accuracy = as.numeric(nb_eval$metrics$Accuracy),
      precision = as.numeric(nb_eval$metrics$Precision),
      recall = as.numeric(nb_eval$metrics$Recall),
      f1_score = as.numeric(nb_eval$metrics$F1_Score),
      confusion_matrix = nb_eval$confusion_matrix
    ),
    svm_metrics = list(
      accuracy = as.numeric(svm_eval$metrics$Accuracy),
      precision = as.numeric(svm_eval$metrics$Precision),
      recall = as.numeric(svm_eval$metrics$Recall),
      f1_score = as.numeric(svm_eval$metrics$F1_Score),
      confusion_matrix = svm_eval$confusion_matrix
    ),
    nb_evaluation = nb_eval,
    svm_evaluation = svm_eval,
    lexicon_accuracy = lexicon_accuracy,
    test_data = list(
      dtm = splits$test_dtm,
      labels = splits$test_labels,
      predictions_nb = nb_pred,
      predictions_svm = svm_pred
    )
  ))
}

#' Create Model Comparison Table
#' @param ml_results Results from machine_learning_analysis()
#' @param lexicon_baseline Lexicon method accuracy
#' @return Comparison table
#' @export
create_model_comparison <- function(ml_results) {

  comparison <- tibble(
    Model = c("Lexicon-Based", "Naive Bayes", "SVM"),
    Accuracy = c(
      ml_results$lexicon_accuracy * 100,
      ml_results$nb_evaluation$metrics$Accuracy * 100,
      ml_results$svm_evaluation$metrics$Accuracy * 100
    ),
    Precision = c(
      NA,  # Not applicable for lexicon
      ml_results$nb_evaluation$metrics$Precision * 100,
      ml_results$svm_evaluation$metrics$Precision * 100
    ),
    Recall = c(
      NA,
      ml_results$nb_evaluation$metrics$Recall * 100,
      ml_results$svm_evaluation$metrics$Recall * 100
    ),
    F1_Score = c(
      NA,
      ml_results$nb_evaluation$metrics$F1_Score * 100,
      ml_results$svm_evaluation$metrics$F1_Score * 100
    )
  ) %>%
    mutate(across(where(is.numeric), ~ round(.x, 2)))

  return(comparison)
}

#' Print Model Performance Summary
#' @param ml_results ML analysis results
#' @export
print_ml_summary <- function(ml_results) {

  cat("\n========== MACHINE LEARNING SUMMARY ==========\n\n")

  cat("Naive Bayes Confusion Matrix:\n")
  print(ml_results$nb_evaluation$confusion_matrix)

  cat("\n\nSVM Confusion Matrix:\n")
  print(ml_results$svm_evaluation$confusion_matrix)

  cat("\n\nModel Comparison:\n")
  comparison <- create_model_comparison(ml_results)
  print(comparison)

  cat("\n==============================================\n")
}

# Example usage
if (FALSE) {
  # Load and analyze data
  source("data_collection.R")
  source("preprocessing.R")
  source("lexicon_sentiment.R")

  data <- load_data_from_csv("data/sample_data.csv")
  data <- preprocess_pipeline(data)
  data <- lexicon_sentiment_analysis(data)

  # Perform ML analysis
  ml_results <- machine_learning_analysis(data)

  # Print summary
  print_ml_summary(ml_results)

  # Get comparison table
  comparison <- create_model_comparison(ml_results)
  print(comparison)
}
