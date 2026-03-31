setwd("C:/Users/kommi/OneDrive/Desktop/Sentiment-analysis")
source("main.R")

set.seed(42)
full <- read.csv(
  "training.1600000.processed.noemoticon.csv",
  header = FALSE,
  stringsAsFactors = FALSE,
  nrows = 5000
)

names(full) <- c("sentiment_raw", "id", "date_raw", "query", "user", "text")

demo <- data.frame(
  id = full$id,
  date = as.Date("2026-01-01") + seq_len(nrow(full)) - 1,
  user = full$user,
  text = full$text,
  stringsAsFactors = FALSE
)

write.csv(demo, "quick_demo_5000.csv", row.names = FALSE)

results <- run_complete_analysis(
  file_path = "quick_demo_5000.csv",
  run_ml = TRUE,
  k_topics = 3,
  train_ratio = 0.8,
  ml_max_features = 500,
  fast_mode = TRUE,
  use_gpu = TRUE
)

export_results_to_csv(results, "sentiment_analysis_results_quick_demo_5000.csv")

cat("\nGPU_STATUS:", if (!is.null(results$ml_results)) results$ml_results$gpu_status else "ML skipped", "\n")
cat("SECONDARY_MODEL:", if (!is.null(results$ml_results)) results$ml_results$secondary_model_name else "NA", "\n")
if (!is.null(results$ml_comparison)) print(results$ml_comparison)
