setwd("c:/Users/Lenovo/Desktop/Sentimental-Analysis-Using-R")
source("fake_review_detection.R")

d <- read.csv("fake_review_test_input.csv", stringsAsFactors = FALSE)
out <- fake_review_analysis(d, text_col = "text")
out$match_expected <- ifelse(out$fake_review_flag == out$expected_fake_label, "Yes", "No")

write.csv(out, "fake_review_test_results.csv", row.names = FALSE)

cat("Summary by predicted flag:\n")
print(table(out$fake_review_flag))

cat("\nConfusion (expected vs predicted):\n")
print(table(Expected = out$expected_fake_label, Predicted = out$fake_review_flag))

cat("\nMismatches:\n")
print(out[out$match_expected == "No", c("id", "text", "expected_fake_label", "fake_review_flag", "credibility_score")])

acc <- mean(out$match_expected == "Yes")
cat(sprintf("\nAccuracy vs expected labels: %.2f%%\n", acc * 100))
