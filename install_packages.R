# =============================================================================
# AUTOMATED PACKAGE INSTALLATION SCRIPT
# AI-Based Sentiment Analysis System - Setup Wizard
# Run this script once to install all required packages
# =============================================================================

cat("\n")
cat("╔═══════════════════════════════════════════════════════════════╗\n")
cat("║                                                               ║\n")
cat("║   AI-BASED SENTIMENT ANALYSIS SYSTEM - SETUP WIZARD          ║\n")
cat("║                    Version 1.0                                ║\n")
cat("║                                                               ║\n")
cat("╚═══════════════════════════════════════════════════════════════╝\n\n")

cat("This script will install all required R packages.\n")
cat("Installation may take 5-10 minutes depending on your internet speed.\n\n")

# Check R version
r_version <- getRversion()
cat(sprintf("✓ R Version: %s\n", R.version.string))

if (r_version < "4.0") {
  warning("Warning: R version 4.0 or higher is recommended.")
  cat("Your current version is older. Some packages may not work correctly.\n")
  cat("Consider upgrading R from: https://cran.r-project.org/\n\n")
}

# Ask user to proceed
cat("\nPress [ENTER] to start installation or [ESC] to cancel: ")
readline()

cat("\n")
cat("═════════════════════════════════════════════════════════════════\n")
cat("                    STARTING INSTALLATION                         \n")
cat("═════════════════════════════════════════════════════════════════\n\n")

# Set CRAN mirror
cat("Setting CRAN mirror...\n")
options(repos = c(CRAN = "https://cloud.r-project.org"))
cat("✓ Using: https://cloud.r-project.org\n\n")

# List of required packages with descriptions
packages <- list(
  list(name = "tidyverse", desc = "Data manipulation and visualization suite"),
  list(name = "tm", desc = "Text mining framework"),
  list(name = "stringr", desc = "String operations"),
  list(name = "syuzhet", desc = "NRC emotion lexicon"),
  list(name = "caret", desc = "Machine learning framework"),
  list(name = "e1071", desc = "SVM and Naive Bayes algorithms"),
  list(name = "topicmodels", desc = "LDA topic modeling"),
  list(name = "ggplot2", desc = "Advanced plotting"),
  list(name = "wordcloud", desc = "Word cloud generation"),
  list(name = "fmsb", desc = "Radar chart visualization"),
  list(name = "shiny", desc = "Interactive web applications"),
  list(name = "shinydashboard", desc = "Dashboard UI components"),
  list(name = "DT", desc = "Interactive data tables"),
  list(name = "plotly", desc = "Interactive plots"),
  list(name = "zoo", desc = "Time-series analysis"),
  list(name = "lubridate", desc = "Date manipulation"),
  list(name = "RColorBrewer", desc = "Color palettes"),
  list(name = "tidytext", desc = "Text mining tools")
)

# Initialize counters
total_packages <- length(packages)
installed_success <- 0
installed_fail <- 0
already_installed <- 0

# Installation function with error handling
install_package_safe <- function(pkg_info, index, total) {
  pkg_name <- pkg_info$name
  pkg_desc <- pkg_info$desc
  
  cat(sprintf("[%d/%d] %s - %s\n", index, total, pkg_name, pkg_desc))
  
  # Check if already installed
  if (require(pkg_name, character.only = TRUE, quietly = TRUE)) {
    cat(sprintf("      ✓ Already installed\n"))
    return("already")
  }
  
  # Try to install
  tryCatch({
    cat(sprintf("      Installing...\n"))
    install.packages(pkg_name, dependencies = TRUE, quiet = TRUE)
    
    # Verify installation
    if (require(pkg_name, character.only = TRUE, quietly = TRUE)) {
      cat(sprintf("      ✓ Successfully installed\n"))
      return("success")
    } else {
      cat(sprintf("      ✗ Installation failed (verification)\n"))
      return("fail")
    }
  }, error = function(e) {
    cat(sprintf("      ✗ Installation failed: %s\n", e$message))
    return("fail")
  })
}

# Install all packages
cat("─────────────────────────────────────────────────────────────────\n")
cat("                    INSTALLING PACKAGES                           \n")
cat("─────────────────────────────────────────────────────────────────\n\n")

start_time <- Sys.time()
failed_packages <- c()

for (i in seq_along(packages)) {
  result <- install_package_safe(packages[[i]], i, total_packages)
  
  if (result == "success") {
    installed_success <- installed_success + 1
  } else if (result == "already") {
    already_installed <- already_installed + 1
  } else {
    installed_fail <- installed_fail + 1
    failed_packages <- c(failed_packages, packages[[i]]$name)
  }
  
  cat("\n")
  Sys.sleep(0.1)  # Small delay for readability
}

end_time <- Sys.time()
elapsed_time <- round(as.numeric(difftime(end_time, start_time, units = "mins")), 2)

# Installation summary
cat("\n")
cat("═════════════════════════════════════════════════════════════════\n")
cat("                    INSTALLATION SUMMARY                          \n")
cat("═════════════════════════════════════════════════════════════════\n\n")

cat(sprintf("Total Packages: %d\n", total_packages))
cat(sprintf("  ✓ Already Installed: %d\n", already_installed))
cat(sprintf("  ✓ Newly Installed: %d\n", installed_success))
cat(sprintf("  ✗ Failed: %d\n", installed_fail))
cat(sprintf("\nTime Elapsed: %.2f minutes\n\n", elapsed_time))

if (installed_fail == 0) {
  cat("╔═══════════════════════════════════════════════════════════════╗\n")
  cat("║                                                               ║\n")
  cat("║                 ✓ INSTALLATION COMPLETE!                     ║\n")
  cat("║                                                               ║\n")
  cat("║         All packages successfully installed.                 ║\n")
  cat("║         You are ready to run the analysis!                   ║\n")
  cat("║                                                               ║\n")
  cat("╚═══════════════════════════════════════════════════════════════╝\n\n")
  
  cat("Next Steps:\n")
  cat("  1. Run: source('main.R')  # For command-line analysis\n")
  cat("  2. Or run: source('dashboard_app.R')  # For interactive dashboard\n\n")
  
} else {
  cat("╔═══════════════════════════════════════════════════════════════╗\n")
  cat("║                                                               ║\n")
  cat("║                 ⚠ INSTALLATION INCOMPLETE                    ║\n")
  cat("║                                                               ║\n")
  cat("╚═══════════════════════════════════════════════════════════════╝\n\n")
  
  cat("Failed Packages:\n")
  for (pkg in failed_packages) {
    cat(sprintf("  ✗ %s\n", pkg))
  }
  
  cat("\nTroubleshooting:\n")
  cat("  1. Check your internet connection\n")
  cat("  2. Try manually: install.packages('package_name')\n")
  cat("  3. Update R to latest version\n")
  cat("  4. Try a different CRAN mirror\n\n")
  
  cat("To retry failed packages:\n")
  for (pkg in failed_packages) {
    cat(sprintf("  install.packages('%s', dependencies = TRUE)\n", pkg))
  }
  cat("\n")
}

# Verification section
cat("─────────────────────────────────────────────────────────────────\n")
cat("                   PACKAGE VERIFICATION                           \n")
cat("─────────────────────────────────────────────────────────────────\n\n")

cat("Verifying package loading...\n\n")

verification_results <- data.frame(
  Package = character(),
  Status = character(),
  stringsAsFactors = FALSE
)

for (pkg_info in packages) {
  pkg <- pkg_info$name
  can_load <- suppressPackageStartupMessages(
    require(pkg, character.only = TRUE, quietly = TRUE)
  )
  
  status <- if (can_load) "✓ OK" else "✗ FAIL"
  verification_results <- rbind(
    verification_results,
    data.frame(Package = pkg, Status = status)
  )
}

print(verification_results, row.names = FALSE)

cat("\n")

# Final success check
all_verified <- all(grepl("✓", verification_results$Status))

if (all_verified) {
  cat("✓ All packages verified and ready to use!\n\n")
  
  # Create data directory if it doesn't exist
  if (!dir.exists("data")) {
    dir.create("data")
    cat("✓ Created 'data' directory for your CSV files\n\n")
  }
  
  # Check for sample data
  if (file.exists("sample_data.csv")) {
    cat("✓ Sample data file found\n\n")
    
    cat("═════════════════════════════════════════════════════════════════\n")
    cat("                    READY TO RUN!                                 \n")
    cat("═════════════════════════════════════════════════════════════════\n\n")
    
    cat("Quick Start:\n\n")
    cat("1. RUN ANALYSIS WITH SAMPLE DATA:\n")
    cat("   source('main.R')\n\n")
    
    cat("2. LAUNCH INTERACTIVE DASHBOARD:\n")
    cat("   source('dashboard_app.R')\n\n")
    
    cat("3. ANALYZE YOUR OWN CSV:\n")
    cat("   results <- run_complete_analysis('your_data.csv')\n")
    cat("   export_results_to_csv(results, 'output.csv')\n\n")
    
  } else {
    cat("⚠ Sample data file (sample_data.csv) not found\n")
    cat("  Place your CSV file in the project directory\n\n")
  }
  
} else {
  cat("⚠ Some packages could not be loaded. Check failed packages above.\n\n")
}

cat("═════════════════════════════════════════════════════════════════\n\n")

cat("For help, see:\n")
cat("  - README.md - Complete documentation\n")
cat("  - INSTALLATION.txt - Detailed setup guide\n")
cat("  - QUICK_REFERENCE.txt - Command quick reference\n\n")

cat("Setup wizard completed.\n")
cat("Timestamp:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")

# Cleanup
rm(list = ls())
gc()  # Garbage collection

cat("You may now proceed with the analysis. Good luck! 🎯\n\n")
