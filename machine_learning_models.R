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
#' @param train_ratio Training set ratio (default: 0.8)
#' @return List with train and test splits
#' @export
split_train_test <- function(ml_data, dtm_matrix, train_ratio = 0.8) {
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
        train_index = train_index,
        test_index = setdiff(seq_len(nrow(ml_data)), train_index),
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

#' Train Torch Binary Classifier (GPU-aware)
#' @param train_dtm Training feature matrix
#' @param train_labels Training labels (factor: Negative/Positive)
#' @param test_dtm Test feature matrix
#' @param test_labels Test labels (factor: Negative/Positive)
#' @param use_gpu Whether GPU execution is requested
#' @param epochs Number of training epochs
#' @param batch_size Batch size for mini-batch training
#' @param learning_rate Optimizer learning rate
#' @return List with model, predictions, evaluation, device and training metadata
train_torch_classifier <- function(train_dtm,
                                   train_labels,
                                   test_dtm,
                                   test_labels,
                                   use_gpu = TRUE,
                                   epochs = 8,
                                   batch_size = 1024,
                                   learning_rate = 0.001) {
    if (!requireNamespace("torch", quietly = TRUE)) {
        stop("Torch package is not installed")
    }

    gpu_enabled <- isTRUE(use_gpu) && isTRUE(torch::cuda_is_available())
    device <- if (gpu_enabled) torch::torch_device("cuda") else torch::torch_device("cpu")

    x_train <- as.matrix(train_dtm)
    x_test <- as.matrix(test_dtm)

    # Ensure numeric storage for torch tensors
    storage.mode(x_train) <- "double"
    storage.mode(x_test) <- "double"

    y_train_num <- as.numeric(train_labels == "Positive")

    x_train_t <- torch::torch_tensor(x_train, dtype = torch::torch_float(), device = device)
    y_train_t <- torch::torch_tensor(matrix(y_train_num, ncol = 1), dtype = torch::torch_float(), device = device)
    x_test_t <- torch::torch_tensor(x_test, dtype = torch::torch_float(), device = device)

    model <- torch::nn_sequential(
        torch::nn_linear(ncol(x_train), 256),
        torch::nn_relu(),
        torch::nn_dropout(p = 0.20),
        torch::nn_linear(256, 64),
        torch::nn_relu(),
        torch::nn_linear(64, 1)
    )

    model$to(device = device)
    optimizer <- torch::optim_adam(model$parameters, lr = learning_rate)
    criterion <- torch::nn_bce_with_logits_loss()

    n <- nrow(x_train)
    batch_size <- max(32, min(batch_size, n))

    model$train()
    for (epoch in seq_len(epochs)) {
        idx <- sample.int(n)
        for (start in seq(1, n, by = batch_size)) {
            end <- min(start + batch_size - 1, n)
            batch_idx <- idx[start:end]

            xb <- x_train_t[batch_idx, ]
            yb <- y_train_t[batch_idx, ]

            optimizer$zero_grad()
            logits <- model(xb)
            loss <- criterion(logits, yb)
            loss$backward()
            optimizer$step()
        }
    }

    model$eval()
    probs <- torch::with_no_grad({
        torch::torch_sigmoid(model(x_test_t))$to(device = torch::torch_device("cpu"))
    })

    probs_vec <- as.numeric(as.matrix(probs))
    pred_labels <- factor(
        ifelse(probs_vec >= 0.5, "Positive", "Negative"),
        levels = c("Negative", "Positive")
    )

    eval <- evaluate_model(pred_labels, test_labels)

    return(list(
        model = model,
        predictions = pred_labels,
        probabilities = probs_vec,
        evaluation = eval,
        device = if (gpu_enabled) "cuda" else "cpu",
        gpu_enabled = gpu_enabled,
        epochs = epochs,
        batch_size = batch_size,
        learning_rate = learning_rate
    ))
}

#' Perform Complete Machine Learning Analysis
#' @param data Dataframe with text and polarity
#' @param label_column Column name to use as ground truth labels (default: "polarity")
#' @param train_ratio Training split ratio (default: 0.8)
#' @param max_features Maximum DTM features (default: 1200)
#' @param fast_mode If TRUE, uses faster defaults for large datasets
#' @param use_gpu If TRUE, attempts torch-based GPU path and otherwise falls back to CPU models
#' @return ML analysis results
#' @export
machine_learning_analysis <- function(data,
                                      label_column = "polarity",
                                      train_ratio = 0.8,
                                      max_features = 1200,
                                      fast_mode = TRUE,
                                      use_gpu = TRUE) {
    message("Starting machine learning analysis...")

    # Conservative speed optimization for large real-world datasets.
    if (fast_mode && nrow(data) > 50000 && max_features > 800) {
        max_features <- 800
        message("Fast mode enabled: reducing max_features to 800 for faster training.")
    }

    gpu_enabled <- FALSE
    gpu_backend <- "CPU"
    torch_available <- requireNamespace("torch", quietly = TRUE)
    if (use_gpu) {
        if (torch_available && isTRUE(torch::cuda_is_available())) {
            gpu_enabled <- TRUE
            gpu_backend <- "GPU enabled (torch CUDA available)"
        } else if (torch_available) {
            gpu_backend <- "Torch installed, but CUDA GPU is unavailable (running on CPU)"
        } else {
            gpu_backend <- "GPU not configured (install 'torch' and CUDA runtime)"
        }
        message(sprintf("GPU status: %s", gpu_backend))
    }

    # Prepare data
    ml_data <- prepare_ml_data(data, label_column = label_column)

    # Create DTM
    dtm_matrix <- create_ml_dtm(ml_data, max_features = max_features)

    # Split data
    splits <- split_train_test(ml_data, dtm_matrix, train_ratio = train_ratio)

    # Train Naive Bayes
    message("\n[1/4] Training Naive Bayes...")
    nb_model <- train_naive_bayes(splits$train_dtm, splits$train_labels)

    # Predict with Naive Bayes
    message("[2/4] Evaluating Naive Bayes...")
    nb_pred <- predict(nb_model, splits$test_dtm)
    nb_eval <- evaluate_model(nb_pred, splits$test_labels)

    # Secondary classifier path: Torch when requested and available; otherwise SVM.
    secondary_model_name <- "SVM"
    torch_results <- NULL

    if (use_gpu && torch_available) {
        message("\n[3/4] Training Torch classifier...")
        # For very large datasets, use compact epochs/batch in fast mode.
        torch_epochs <- if (fast_mode) 6 else 10
        torch_batch <- if (fast_mode) 2048 else 1024

        torch_results <- tryCatch(
            {
                train_torch_classifier(
                    train_dtm = splits$train_dtm,
                    train_labels = splits$train_labels,
                    test_dtm = splits$test_dtm,
                    test_labels = splits$test_labels,
                    use_gpu = use_gpu,
                    epochs = torch_epochs,
                    batch_size = torch_batch,
                    learning_rate = 0.001
                )
            },
            error = function(e) {
                warning(sprintf("Torch path failed, falling back to SVM: %s", e$message))
                NULL
            }
        )
    }

    if (!is.null(torch_results)) {
        secondary_model_name <- "Torch Neural Net"
        message("[4/4] Evaluating Torch classifier...")
        svm_model <- torch_results$model
        svm_pred <- torch_results$predictions
        svm_eval <- torch_results$evaluation
        gpu_enabled <- isTRUE(torch_results$gpu_enabled)
        gpu_backend <- sprintf("Torch backend (%s)", torch_results$device)
    } else {
        message("\n[3/4] Training SVM...")
        svm_model <- train_svm(splits$train_dtm, splits$train_labels)

        message("[4/4] Evaluating SVM...")
        svm_pred <- predict(svm_model, splits$test_dtm)
        svm_eval <- evaluate_model(svm_pred, splits$test_labels)
    }

    # Compare with lexicon method using held-out test split.
    lexicon_accuracy <- NA_real_
    lexicon_confusion_matrix <- NULL
    if ("lexicon_based_polarity" %in% names(ml_data)) {
        lexicon_pred <- factor(
            ml_data$lexicon_based_polarity[splits$test_index],
            levels = c("Negative", "Positive")
        )
        lexicon_actual <- factor(splits$test_labels, levels = c("Negative", "Positive"))

        valid_idx <- !is.na(lexicon_pred) & !is.na(lexicon_actual)
        if (sum(valid_idx) > 0) {
            lexicon_accuracy <- mean(lexicon_pred[valid_idx] == lexicon_actual[valid_idx])
            lexicon_confusion_matrix <- table(
                Predicted = lexicon_pred[valid_idx],
                Actual = lexicon_actual[valid_idx]
            )
        }
    }

    message("\n✓ Machine learning analysis complete!")

    # Return cleaned metrics
    return(list(
        nb_model = nb_model,
        svm_model = svm_model,
        train_ratio = train_ratio,
        max_features = max_features,
        fast_mode = fast_mode,
        secondary_model_name = secondary_model_name,
        gpu_requested = use_gpu,
        gpu_enabled = gpu_enabled,
        gpu_status = gpu_backend,
        torch_results = torch_results,
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
        lexicon_confusion_matrix = lexicon_confusion_matrix,
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
    secondary_name <- if ("secondary_model_name" %in% names(ml_results)) {
        ml_results$secondary_model_name
    } else {
        "SVM"
    }

    comparison <- tibble(
        Model = c("Lexicon-Based", "Naive Bayes", secondary_name),
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
