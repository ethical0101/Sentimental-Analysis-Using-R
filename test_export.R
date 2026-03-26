# Quick test of export functionality
cat("Testing export fix...\n\n")

# Load required libraries
suppressPackageStartupMessages({
  library(tidyverse)
})

# Source modules needed for export
source("main.R")

# Create simple test data
test_data <- tibble(
  id = 1:5,
  original_text = c("Good", "Bad", "Okay", "Great", "Poor"),
  text = c("good", "bad", "okay", "great", "poor"),
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

# Test simple export
cat("Test 1: Simple export with atomic columns\n")
results <- list(data = test_data)
export_results_to_csv(results, "test_export1.csv")

# Test with list column added
cat("\nTest 2: Export with list column (should handle gracefully)\n")
test_data_with_list <- test_data
test_data_with_list$list_col <- list(c(1,2), c(3,4), c(5), c(6,7,8), c(9))
results2 <- list(data = test_data_with_list)
export_results_to_csv(results2, "test_export2.csv")

# Verify files
cat("\n=== VERIFICATION ===\n")
if (file.exists("test_export1.csv")) {
  cat("✓ test_export1.csv created\n")
  cat(sprintf("  Lines: %d\n", length(readLines("test_export1.csv"))))
} else {
  cat("✗ test_export1.csv NOT created\n")
}

if (file.exists("test_export2.csv")) {
  cat("✓ test_export2.csv created\n")
  cat(sprintf("  Lines: %d\n", length(readLines("test_export2.csv"))))
} else {
  cat("✗ test_export2.csv NOT created\n")
}

cat("\n✓ Export test complete!\n")
