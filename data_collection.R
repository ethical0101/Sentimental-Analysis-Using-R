# =============================================================================
# DATA COLLECTION MODULE
# Purpose: Load and validate input data from CSV or manual input
# Author: AI-Based Sentiment Intelligence System
# =============================================================================

# Load required libraries
library(tidyverse)
library(readr)

#' Load Data from CSV File
#' @param file_path Path to CSV file
#' @return Dataframe with validated columns
#' @export
load_data_from_csv <- function(file_path) {
  tryCatch({
    # Read CSV file
    data <- read_csv(file_path, show_col_types = FALSE)
    
    # Validate required column
    if (!"text" %in% colnames(data)) {
      stop("Error: CSV must contain 'text' column")
    }
    
    # Add optional columns if missing
    if (!"date" %in% colnames(data)) {
      data$date <- Sys.Date()
      message("Info: 'date' column not found. Using current date.")
    }
    
    if (!"user" %in% colnames(data)) {
      data$user <- "Unknown"
      message("Info: 'user' column not found. Setting to 'Unknown'.")
    }
    
    # Convert date column to Date type
    data$date <- as.Date(data$date)
    
    # Add unique ID for each record
    data$id <- seq_len(nrow(data))
    
    message(sprintf("✓ Successfully loaded %d records", nrow(data)))
    return(data)
    
  }, error = function(e) {
    stop(sprintf("Error loading CSV: %s", e$message))
  })
}

#' Create Dataset from Manual Input
#' @param text_vector Vector of text strings
#' @param dates_vector Optional vector of dates
#' @param users_vector Optional vector of user names
#' @return Dataframe ready for analysis
#' @export
create_manual_dataset <- function(text_vector, 
                                   dates_vector = NULL, 
                                   users_vector = NULL) {
  
  # Validate input
  if (length(text_vector) == 0) {
    stop("Error: Text vector cannot be empty")
  }
  
  # Create base dataframe
  data <- tibble(
    id = seq_along(text_vector),
    text = text_vector
  )
  
  # Add dates
  if (!is.null(dates_vector) && length(dates_vector) == length(text_vector)) {
    data$date <- as.Date(dates_vector)
  } else {
    data$date <- Sys.Date()
  }
  
  # Add users
  if (!is.null(users_vector) && length(users_vector) == length(text_vector)) {
    data$user <- users_vector
  } else {
    data$user <- "Unknown"
  }
  
  message(sprintf("✓ Created dataset with %d records", nrow(data)))
  return(data)
}

#' Validate Dataset Structure
#' @param data Input dataframe
#' @return TRUE if valid, stops execution if invalid
#' @export
validate_dataset <- function(data) {
  
  # Check if dataframe
  if (!is.data.frame(data)) {
    stop("Error: Input must be a dataframe")
  }
  
  # Check for required columns
  required_cols <- c("text", "date", "user")
  missing_cols <- setdiff(required_cols, colnames(data))
  
  if (length(missing_cols) > 0) {
    stop(sprintf("Error: Missing columns: %s", paste(missing_cols, collapse = ", ")))
  }
  
  # Check for empty text
  empty_rows <- sum(is.na(data$text) | data$text == "")
  if (empty_rows > 0) {
    warning(sprintf("Warning: %d rows have empty text", empty_rows))
  }
  
  message("✓ Dataset validation successful")
  return(TRUE)
}

#' Get Dataset Summary Statistics
#' @param data Input dataframe
#' @return Summary statistics
#' @export
get_data_summary <- function(data) {
  summary_stats <- list(
    total_records = nrow(data),
    unique_users = length(unique(data$user)),
    date_range = range(data$date),
    avg_text_length = mean(nchar(data$text), na.rm = TRUE),
    empty_records = sum(is.na(data$text) | data$text == "")
  )
  
  return(summary_stats)
}

# Example usage
if (FALSE) {
  # Load from CSV
  data <- load_data_from_csv("data/sample_data.csv")
  
  # Or create manually
  texts <- c("I love this product!", "Terrible service", "Not bad")
  data <- create_manual_dataset(texts)
  
  # Validate
  validate_dataset(data)
  
  # Get summary
  summary <- get_data_summary(data)
  print(summary)
}
