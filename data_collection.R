# =============================================================================
# DATA COLLECTION MODULE
# Purpose: Load and validate input data from CSV or manual input
# Author: AI-Based Sentiment Intelligence System
# =============================================================================

# Load required libraries
library(tidyverse)
library(readr)

#' Replace line breaks inside JSON string literals with spaces
#' @param json_lines Character vector from readLines()
#' @return Sanitized JSON text
#' @export
sanitize_json_string_newlines <- function(json_lines) {
  if (length(json_lines) == 0) {
    return("")
  }

  out <- ""
  in_string <- FALSE

  for (line in json_lines) {
    if (out == "") {
      out <- line
    } else {
      out <- paste0(out, if (in_string) " " else "\n", line)
    }

    # Update quote-state while respecting escaped quotes.
    chars <- strsplit(line, "", fixed = TRUE)[[1]]
    escaped <- FALSE

    for (ch in chars) {
      if (escaped) {
        escaped <- FALSE
      } else if (ch == "\\") {
        escaped <- TRUE
      } else if (ch == '"') {
        in_string <- !in_string
      }
    }
  }

  return(out)
}

#' Parse JSON with newline-sanitization fallback for malformed records
#' @param file_path Path to JSON file
#' @return Parsed dataframe
#' @export
load_json_with_fallback <- function(file_path) {
  jsonlite_available <- requireNamespace("jsonlite", quietly = TRUE)
  if (!jsonlite_available) {
    stop("Error: Package 'jsonlite' is required to load JSON files")
  }

  max_records <- getOption("sentometrics_json_max_records", 5000)
  file_size <- file.info(file_path)$size
  use_loose_only <- !is.na(file_size) && file_size > 5 * 1024 * 1024

  if (use_loose_only) {
    warning("Large JSON detected. Using loose parser directly for faster loading.")
  }

  primary <- if (use_loose_only) {
    structure(list(message = "Skipped strict parse for large file"), class = "error")
  } else {
    tryCatch(
      jsonlite::fromJSON(file_path, flatten = TRUE),
      error = function(e) e
    )
  }

  if (!inherits(primary, "error")) {
    return(as_tibble(primary))
  }

  if (use_loose_only) {
    warning("Skipping full-file sanitization for large JSON. Using loose parser.")
  }

  warning("JSON parse failed on first attempt. Retrying with newline sanitization.")

  # Some source datasets contain raw newline characters inside quoted strings.
  # This pass preserves structure while replacing those in-string newlines by spaces.
  secondary <- if (use_loose_only) {
    structure(list(message = "Skipped sanitized strict parse for large file"), class = "error")
  } else {
    json_lines <- readLines(file_path, warn = FALSE, encoding = "UTF-8")
    sanitized_text <- sanitize_json_string_newlines(json_lines)
    tryCatch(
      jsonlite::fromJSON(sanitized_text, flatten = TRUE),
      error = function(e) e
    )
  }

  if (!inherits(secondary, "error")) {
    return(as_tibble(secondary))
  }

  warning("Sanitized JSON parse failed. Retrying with loose object-by-object parser.")

  lines <- readLines(file_path, warn = FALSE, encoding = "UTF-8")
  records <- list()
  record_idx <- 0

  collecting <- FALSE
  buffer <- character(0)

  for (line in lines) {
    trimmed <- trimws(line)

    if (!collecting && trimmed == "{") {
      collecting <- TRUE
      buffer <- "{"
      next
    }

    if (collecting) {
      buffer <- c(buffer, line)

      if (trimmed == "}," || trimmed == "}") {
        obj_text <- sanitize_json_string_newlines(buffer)
        obj_text <- sub(",\\s*$", "", obj_text)

        parsed_obj <- tryCatch(
          jsonlite::fromJSON(obj_text, flatten = TRUE),
          error = function(e) NULL
        )

        if (!is.null(parsed_obj)) {
          record_idx <- record_idx + 1
          records[[record_idx]] <- as_tibble(parsed_obj)

          if (!is.null(max_records) && is.finite(max_records) && record_idx >= max_records) {
            message(sprintf("Info: JSON fallback parser capped at %d records for performance.", max_records))
            break
          }
        }

        collecting <- FALSE
        buffer <- character(0)
      }
    }
  }

  if (length(records) == 0) {
    stop(sprintf("Error loading JSON after all fallbacks: %s", secondary$message))
  }

  bind_rows(records)
}

#' Standardize incoming dataset columns for downstream pipeline compatibility
#' @param data Input dataframe
#' @return Dataframe with required text/date/user columns
#' @export
standardize_input_dataset <- function(data) {
  if (!is.data.frame(data)) {
    stop("Error: Input must be a dataframe")
  }

  # Build text from common news-style fields when 'text' is absent.
  if (!"text" %in% colnames(data)) {
    if (all(c("headline", "short_description") %in% colnames(data))) {
      data$text <- paste(data$headline, data$short_description)
      message("Info: Created 'text' from 'headline' + 'short_description'.")
    } else if ("headline" %in% colnames(data)) {
      data$text <- data$headline
      message("Info: Created 'text' from 'headline'.")
    } else if ("short_description" %in% colnames(data)) {
      data$text <- data$short_description
      message("Info: Created 'text' from 'short_description'.")
    } else if ("content" %in% colnames(data)) {
      data$text <- data$content
      message("Info: Created 'text' from 'content'.")
    } else {
      stop("Error: Dataset must provide 'text' or one of: headline, short_description, content")
    }
  }

  data$text <- as.character(data$text)
  data$text[is.na(data$text)] <- ""

  # Add optional columns if missing
  if (!"date" %in% colnames(data)) {
    start_date <- as.Date("2024-01-01")
    data$date <- seq.Date(from = start_date, by = "day", length.out = nrow(data))
    message("Info: 'date' column not found. Created synthetic sequential dates.")
  }

  if (!"user" %in% colnames(data)) {
    if ("authors" %in% colnames(data)) {
      data$user <- as.character(data$authors)
      data$user[is.na(data$user) | trimws(data$user) == ""] <- "Unknown"
      message("Info: Created 'user' from 'authors'.")
    } else {
      data$user <- "Unknown"
      message("Info: 'user' column not found. Setting to 'Unknown'.")
    }
  }

  # Convert date column to Date type and backfill invalid dates.
  parsed_dates <- suppressWarnings(as.Date(data$date))
  if (all(is.na(parsed_dates))) {
    parsed_dates <- seq.Date(from = as.Date("2024-01-01"), by = "day", length.out = nrow(data))
    message("Info: All date values were invalid. Replaced with synthetic sequential dates.")
  } else if (any(is.na(parsed_dates))) {
    first_valid <- parsed_dates[which(!is.na(parsed_dates))[1]]
    fallback_dates <- seq.Date(from = first_valid, by = "day", length.out = nrow(data))
    parsed_dates[is.na(parsed_dates)] <- fallback_dates[is.na(parsed_dates)]
    message("Info: Some date values were invalid. Filled missing dates with sequential values.")
  }
  data$date <- parsed_dates

  # Add/refresh unique ID for each record
  data$id <- seq_len(nrow(data))
  return(data)
}

#' Load Data from CSV or JSON File
#' @param file_path Path to CSV or JSON file
#' @return Dataframe with validated columns
#' @export
load_data_from_csv <- function(file_path) {
  tryCatch({
    file_ext <- tolower(tools::file_ext(file_path))

    if (file_ext == "json") {
      data <- load_json_with_fallback(file_path)
      message("Info: Loaded JSON file.")
    } else {
      data <- read_csv(file_path, show_col_types = FALSE)
      message("Info: Loaded CSV file.")
    }

    data <- standardize_input_dataset(data)

    message(sprintf("✓ Successfully loaded %d records", nrow(data)))
    return(data)

  }, error = function(e) {
    stop(sprintf("Error loading dataset: %s", e$message))
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
