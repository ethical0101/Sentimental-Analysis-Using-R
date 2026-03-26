# AI-Based Multi-Dimensional Sentiment Analysis in R

This project performs end-to-end sentiment intelligence on text data using R, including:

- Lexicon-based sentiment scoring
- Emotion detection (NRC)
- Sarcasm detection
- Topic modeling (LDA)
- Time-series trend analysis
- Optional machine learning models (Naive Bayes and SVM)
- Interactive Shiny dashboard

## 1. Run From Scratch in VS Code

Follow this section exactly on a new machine.

### 1.1 Install prerequisites

1. Install R (4.0+ recommended): https://cran.r-project.org/
2. Install VS Code: https://code.visualstudio.com/
3. In VS Code, install extension(s):
   - R (REditorSupport.r)
   - R Debugger (optional, but useful)

Optional (Windows): install Rtools if a package build requires compilation.

### 1.2 Open project in VS Code

1. Open VS Code.
2. File -> Open Folder.
3. Select this folder: E:/Sentimental Analysis Using R

### 1.3 Start an R session in VS Code terminal

Important: run R commands inside an R console, not plain PowerShell.

In Terminal:

1. Open terminal in VS Code.
2. Start R by running:

```powershell
R
```

If `R` is not recognized, add your R install path to PATH or launch R from its full executable path.

## 2. Install Project Packages

Inside the R console:

```r
setwd("E:/Sentimental Analysis Using R")
source("install_packages.R")
```

Notes:

- The installer script asks you to press Enter before continuing.
- First-time install can take several minutes.

## 3. Run Full Analysis Pipeline

Inside the R console:

```r
setwd("E:/Sentimental Analysis Using R")
source("main.R")
```

Then run one of these:

### 3.1 Quick run (built-in sample fallback)

```r
results <- run_complete_analysis()
export_results_to_csv(results, "sentiment_analysis_results.csv")
```

### 3.2 Run with provided dataset file

```r
results <- run_complete_analysis("sample_data.csv", run_ml = TRUE, k_topics = 3)
export_results_to_csv(results, "sentiment_analysis_results.csv")
```

### 3.3 Run with your own dataset

```r
results <- run_complete_analysis("my_data.csv", run_ml = TRUE, k_topics = 3)
export_results_to_csv(results, "my_results.csv")
```

Required CSV column:

- text

Optional CSV columns:

- date
- user

If optional columns are missing, defaults are added automatically.

## 4. Launch Interactive Dashboard

Inside the R console:

```r
setwd("E:/Sentimental Analysis Using R")
source("dashboard_app.R")
```

This starts the Shiny app. Use the Data Input tab to:

- Upload a CSV file
- Or paste manual text (one line per text entry)

## 5. Expected Outputs

After a successful run, you should see:

- Console summary of all analysis steps
- Generated plots in the active graphics device
- Exported CSV file (for example: sentiment_analysis_results.csv)

## 6. Recommended Execution Order

1. source("install_packages.R")
2. source("main.R")
3. run_complete_analysis(...)
4. export_results_to_csv(...)
5. source("dashboard_app.R") (optional UI mode)

## 7. Troubleshooting

### Problem: commands fail in PowerShell

Cause: R code was executed in PowerShell instead of an R console.

Fix:

1. Run `R` in terminal first.
2. Then execute R statements.

### Problem: package install fails

Fix:

1. Re-run source("install_packages.R")
2. Try manual install for failed package:

```r
install.packages("package_name", dependencies = TRUE)
```

### Problem: file not found

Fix:

```r
getwd()
setwd("E:/Sentimental Analysis Using R")
list.files()
```

### Problem: dashboard does not open

Fix:

1. Ensure shiny and shinydashboard are installed.
2. Re-run source("dashboard_app.R") in R console.
3. Check firewall/browser pop-up restrictions.

## 8. Key Project Files

- main.R: pipeline orchestration and export helper
- install_packages.R: one-time dependency installer
- dashboard_app.R: Shiny dashboard application
- sample_data.csv: sample input data

## 9. One-Command Starter (after setup)

If dependencies are already installed:

```r
setwd("E:/Sentimental Analysis Using R")
source("main.R")
results <- run_complete_analysis("sample_data.csv", run_ml = TRUE, k_topics = 3)
export_results_to_csv(results, "sentiment_analysis_results.csv")
```
