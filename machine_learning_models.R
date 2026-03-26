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

    message(sprintf(
        "✓ Prepared %d samples for ML (%d Positive, %d Negative)",
        nrow(ml_data),
        sum(ml_data$label == "Positive"),
        sum(ml_data$label == "Negative")
    ))

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

    message(sprintf(
        "✓ Split: %d training, %d testing samples",
        length(train_labels), length(test_labels)
    ))

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
            NA, # Not applicable for lexicon
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

#' Create Top-Term Dictionary for Text Models
#' @param text_vector Character vector of text
#' @param max_features Maximum number of terms to keep
#' @return Character vector of selected terms
#' @export
create_feature_dictionary <- function(text_vector, max_features = 1000) {
    corpus <- Corpus(VectorSource(text_vector))
    dtm <- DocumentTermMatrix(corpus, control = list(
        weighting = weightTfIdf,
        removePunctuation = TRUE,
        removeNumbers = TRUE,
        stopwords = TRUE,
        wordLengths = c(3, Inf)
    ))

    if (ncol(dtm) == 0) {
        stop("No terms found while creating feature dictionary")
    }

    freq <- colSums(as.matrix(dtm))
    top_n <- min(max_features, length(freq))
    dictionary <- names(sort(freq, decreasing = TRUE))[1:top_n]
    dictionary <- make.unique(dictionary)

    return(dictionary)
}

#' Create DTM Matrix from Existing Dictionary
#' @param text_vector Character vector of text
#' @param dictionary Character vector of terms to keep
#' @return Matrix aligned to dictionary terms
#' @export
create_dtm_from_dictionary <- function(text_vector, dictionary) {
    dictionary <- make.unique(as.character(dictionary))

    corpus <- Corpus(VectorSource(text_vector))
    dtm <- DocumentTermMatrix(corpus, control = list(
        dictionary = dictionary,
        weighting = weightTfIdf,
        removePunctuation = TRUE,
        removeNumbers = TRUE,
        stopwords = TRUE,
        wordLengths = c(3, Inf)
    ))

    dtm_matrix <- as.matrix(dtm)

    missing_terms <- setdiff(dictionary, colnames(dtm_matrix))
    if (length(missing_terms) > 0) {
        zero_mat <- matrix(0, nrow = nrow(dtm_matrix), ncol = length(missing_terms))
        colnames(zero_mat) <- missing_terms
        dtm_matrix <- cbind(dtm_matrix, zero_mat)
    }

    dtm_matrix <- dtm_matrix[, dictionary, drop = FALSE]
    colnames(dtm_matrix) <- make.unique(colnames(dtm_matrix))
    return(dtm_matrix)
}

#' Train Sentiment and Sarcasm Predictors for Manual Text Input
#' @param training_data Dataframe containing text and labels
#' @param text_col Text column name (default: "text")
#' @param sentiment_label_col Sentiment label column (default: "ground_truth")
#' @param sarcasm_label_col Sarcasm label column (default: "is_sarcasm")
#' @param max_features Maximum number of text features
#' @return List containing models, dictionary, and metadata
#' @export
train_manual_text_predictors <- function(training_data,
                                         text_col = "text",
                                         sentiment_label_col = "ground_truth",
                                         sarcasm_label_col = "is_sarcasm",
                                         max_features = 1200) {
    required_cols <- c(text_col, sentiment_label_col)
    missing_cols <- setdiff(required_cols, names(training_data))
    if (length(missing_cols) > 0) {
        stop(sprintf("Missing required columns for training: %s", paste(missing_cols, collapse = ", ")))
    }

    model_data <- training_data %>%
        mutate(
            train_text = .data[[text_col]],
            train_sentiment = as.character(.data[[sentiment_label_col]])
        ) %>%
        filter(!is.na(train_text), train_text != "") %>%
        filter(train_sentiment %in% c("Positive", "Negative"))

    if (nrow(model_data) < 20) {
        stop("Need at least 20 labeled rows (Positive/Negative) to train manual predictor")
    }

    model_data$train_text <- to_lowercase(clean_text(model_data$train_text))

    dictionary <- create_feature_dictionary(model_data$train_text, max_features = max_features)
    x_train <- create_dtm_from_dictionary(model_data$train_text, dictionary)
    y_train <- factor(model_data$train_sentiment, levels = c("Negative", "Positive"))

    sentiment_model <- naiveBayes(x = x_train, y = y_train, laplace = 1)

    sarcasm_model <- NULL
    has_sarcasm_model <- FALSE
    if (sarcasm_label_col %in% names(model_data)) {
        sarcasm_values <- model_data[[sarcasm_label_col]]
        if (is.logical(sarcasm_values)) {
            sarcasm_values <- ifelse(sarcasm_values, "Sarcastic", "Non-Sarcastic")
        }
        sarcasm_values <- as.character(sarcasm_values)
        valid_sarcasm <- sarcasm_values %in% c("Sarcastic", "Non-Sarcastic")

        if (sum(valid_sarcasm) >= 20 && length(unique(sarcasm_values[valid_sarcasm])) == 2) {
            y_sarcasm <- factor(
                sarcasm_values[valid_sarcasm],
                levels = c("Non-Sarcastic", "Sarcastic")
            )
            sarcasm_model <- naiveBayes(
                x = x_train[valid_sarcasm, , drop = FALSE],
                y = y_sarcasm,
                laplace = 1
            )
            has_sarcasm_model <- TRUE
        }
    }

    return(list(
        dictionary = dictionary,
        sentiment_model = sentiment_model,
        sarcasm_model = sarcasm_model,
        has_sarcasm_model = has_sarcasm_model,
        train_rows = nrow(model_data),
        feature_count = length(dictionary),
        trained_at = Sys.time()
    ))
}

#' Predict Manual Text with Trained Models and Sarcasm Rules
#' @param text_vector Character vector of texts
#' @param model_bundle Output from train_manual_text_predictors()
#' @return Dataframe with model predictions and sarcasm-adjusted output
#' @export
predict_manual_text_with_models <- function(text_vector, model_bundle) {
    if (length(text_vector) == 0) {
        stop("No text provided for prediction")
    }

    data <- create_manual_dataset(text_vector)
    data <- preprocess_pipeline(data, remove_nums = TRUE, remove_stops = FALSE)
    data <- lexicon_sentiment_analysis(data)
    data <- emotion_analysis(data)
    data <- sarcasm_analysis(data)

    model_text <- to_lowercase(clean_text(data$original_text))
    x_pred <- create_dtm_from_dictionary(model_text, model_bundle$dictionary)

    sentiment_prob <- predict(model_bundle$sentiment_model, x_pred, type = "raw")
    predicted_sentiment <- colnames(sentiment_prob)[max.col(sentiment_prob, ties.method = "first")]
    sentiment_confidence <- apply(sentiment_prob, 1, max)

    # Fallback for texts with no known model terms.
    known_term_counts <- rowSums(x_pred)
    no_feature_idx <- known_term_counts <= 0
    if (any(no_feature_idx)) {
        fallback_sentiment <- ifelse(
            data$polarity[no_feature_idx] %in% c("Positive", "Negative"),
            data$polarity[no_feature_idx],
            predicted_sentiment[no_feature_idx]
        )
        predicted_sentiment[no_feature_idx] <- fallback_sentiment
        sentiment_confidence[no_feature_idx] <- 0.60
    }

    model_sarcasm <- rep(NA_character_, nrow(data))
    model_sarcasm_conf <- rep(NA_real_, nrow(data))
    if (isTRUE(model_bundle$has_sarcasm_model)) {
        sarcasm_prob <- predict(model_bundle$sarcasm_model, x_pred, type = "raw")
        model_sarcasm <- colnames(sarcasm_prob)[max.col(sarcasm_prob, ties.method = "first")]
        model_sarcasm_conf <- apply(sarcasm_prob, 1, max)
    }

    final_sentiment <- predicted_sentiment
    flip_idx <- data$is_sarcasm & predicted_sentiment == "Positive"
    final_sentiment[flip_idx] <- "Negative"

    final_reason <- rep("Model prediction", nrow(data))
    final_reason[no_feature_idx] <- "Lexicon fallback (no known model terms)"
    final_reason[data$is_sarcasm & !flip_idx] <- "Sarcasm detected; model sentiment retained"
    final_reason[flip_idx] <- "Sarcasm rule flipped Positive to Negative"

    result <- data %>%
        transmute(
            id = id,
            original_text = original_text,
            model_sentiment = predicted_sentiment,
            model_sentiment_confidence = round(sentiment_confidence * 100, 2),
            known_feature_terms = known_term_counts,
            model_sarcasm = model_sarcasm,
            model_sarcasm_confidence = round(model_sarcasm_conf * 100, 2),
            rule_sarcasm = is_sarcasm,
            rule_sarcasm_confidence = sarcasm_confidence,
            dominant_emotion = dominant_emotion,
            lexicon_polarity = polarity,
            final_sentiment = final_sentiment,
            final_reason = final_reason
        )

    return(result)
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
