# Standalone export function test
library(tidyverse)

# Copy of fixed export function
export_results_to_csv <- function(results, output_file = "sentiment_analysis_results.csv") {
  
  cat(sprintf("\nExporting results to %s...\n", output_file))
  
  # Select key columns (only if they exist)
  export_data <- results$data %>%
    select(any_of(c(
      "id",
      "original_text",
      "text",
      "date",
      "user",
      "sentiment_score",
      "polarity",
      "intensity",
      "dominant_emotion",
      "anger", "anticipation", "disgust", "fear", "joy", "sadness", "surprise", "trust",
      "is_sarcasm",
      "sarcasm_confidence",
      "topic",
      "topic_probability"
    )))
  
  # Convert list columns to character (to avoid write.csv errors)
  list_cols <- sapply(export_data, is.list)
  if (any(list_cols)) {
    cat(sprintf("Found %d list column(s), converting to character...\n", sum(list_cols)))
    for (col_name in names(export_data)[list_cols]) {
      export_data[[col_name]] <- as.character(export_data[[col_name]])
    }
  }
  
  # Write to CSV
  tryCatch({
    write.csv(export_data, output_file, row.names = FALSE)
    cat(sprintf("✓ Results exported successfully (%d records, %d columns)\n", 
                nrow(export_data), 
                ncol(export_data)))
  }, error = function(e) {
    cat(sprintf("✗ Export failed: %s\n", e$message))
    cat("Attempting simplified export...\n")
    
    # Fallback: only export simple columns
    simple_data <- export_data %>% 
      select(where(~!is.list(.)))
    
    write.csv(simple_data, output_file, row.names = FALSE)
    cat(sprintf("✓ Simplified export complete (%d records, %d columns)\n", 
                nrow(simple_data), 
                ncol(simple_data)))
  })
}

# Create test data
cat("Creating test data...\n")
test_data <- tibble(
  id = 1:5,
  original_text = c("Good product", "Bad service", "Okay", "Great!", "Poor quality"),
  text = c("good product", "bad service", "okay", "great", "poor quality"),
  date = Sys.Date(),
  user = paste0("user", 1:5),
  sentiment_score = c(2, -2, 0, 3, -1),
  polarity = c("Positive", "Negative", "Neutral", "Positive", "Negative"),
  intensity = c("Mild Positive", "Mild Negative", "Neutral", "Strong Positive", "Mild Negative"),
  dominant_emotion = c("joy", "sadness", "trust", "joy", "anger"),
  is_sarcasm = c(FALSE, FALSE, FALSE, FALSE, TRUE),
  sarcasm_confidence = c(0, 0, 0, 0, 75),
  topic = c(1L, 2L, 1L, 1L, 2L),
  topic_probability = c(0.8, 0.9, 0.7, 0.85, 0.95)
)

cat("\n=== TEST 1: Normal export ===\n")
results1 <- list(data = test_data)
export_results_to_csv(results1, "test_normal.csv")

cat("\n=== TEST 2: Export with list column ===\n")
test_data_list <- test_data
test_data_list$some_list <- list(c(1,2), c(3), c(4,5,6), c(7,8), c(9))
results2 <- list(data = test_data_list)
export_results_to_csv(results2, "test_with_list.csv")

cat("\n=== VERIFICATION ===\n")
cat(sprintf("test_normal.csv exists: %s\n", file.exists("test_normal.csv")))
cat(sprintf("test_with_list.csv exists: %s\n", file.exists("test_with_list.csv")))

if (file.exists("test_normal.csv")) {
  cat("\nPreview of test_normal.csv:\n")
  preview <- read.csv("test_normal.csv", nrows = 2)
  print(str(preview))
}

cat("\n✓ Export test complete!\n")
