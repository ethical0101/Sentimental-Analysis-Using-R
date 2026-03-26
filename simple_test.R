# SIMPLE EXPORT TEST - No external dependencies
cat("Testing CSV export...\n\n")

# Manual test data
test_df <- data.frame(
  id = 1:3,
  text = c("Good", "Bad", "Okay"),
  sentiment = c("Positive", "Negative", "Neutral"),
  score = c(1, -1, 0),
  stringsAsFactors = FALSE
)

cat("Test data created:\n")
print(test_df)

# Test basic export
cat("\nAttempting CSV export...\n")
tryCatch({
  write.csv(test_df, "simple_test.csv", row.names = FALSE)
  cat("✓ Export successful!\n")
  
  # Verify
  if (file.exists("simple_test.csv")) {
    cat("✓ File exists!\n")
    cat(sprintf("  Size: %d bytes\n", file.info("simple_test.csv")$size))
    
    # Read back
    read_back <- read.csv("simple_test.csv")
    cat(sprintf("  Rows: %d\n", nrow(read_back)))
    cat(sprintf("  Columns: %d\n", ncol(read_back)))
  }
}, error = function(e) {
  cat(sprintf("✗ Error: %s\n", e$message))
})

cat("\n✓ Test complete!\n")
