# =============================================================================
# SHINY DASHBOARD APPLICATION
# Purpose: Interactive web dashboard for sentiment analysis system
# Author: AI-Based Sentiment Intelligence System
# =============================================================================

# Load required libraries
library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(plotly)
library(tidyverse)

# Source all analysis modules
source("data_collection.R", local = TRUE)
source("preprocessing.R", local = TRUE)
source("lexicon_sentiment.R", local = TRUE)
source("emotion_detection.R", local = TRUE)
source("sarcasm_detection.R", local = TRUE)
source("topic_modeling.R", local = TRUE)
source("time_series_analysis.R", local = TRUE)
source("machine_learning_models.R", local = TRUE)
source("visualization.R", local = TRUE)

# =============================================================================
# UI DEFINITION
# =============================================================================

ui <- dashboardPage(
    skin = "blue",

    # Dashboard Header
    dashboardHeader(
        title = "AI Sentiment Intelligence System",
        titleWidth = 350
    ),

    # Dashboard Sidebar
    dashboardSidebar(
        width = 250,
        sidebarMenu(
            menuItem("📊 Dashboard", tabName = "dashboard", icon = icon("dashboard")),
            menuItem("📁 Data Input", tabName = "data_input", icon = icon("upload")),
            menuItem("📈 Sentiment Analysis", tabName = "sentiment", icon = icon("chart-line")),
            menuItem("😊 Emotion Analysis", tabName = "emotion", icon = icon("smile")),
            menuItem("🎭 Sarcasm Detection", tabName = "sarcasm", icon = icon("theater-masks")),
            menuItem("🔍 Topic Modeling", tabName = "topics", icon = icon("tags")),
            menuItem("📉 Time Trends", tabName = "trends", icon = icon("chart-area")),
            menuItem("🤖 ML Models", tabName = "ml_models", icon = icon("robot")),
            menuItem("💾 Export Report", tabName = "export", icon = icon("download"))
        )
    ),

    # Dashboard Body
    dashboardBody(
        tags$head(
            tags$style(HTML("
        .content-wrapper { background-color: #ecf0f1; }
        .box { border-top: 3px solid #3498db; }
        .small-box { border-radius: 5px; }
        .info-box { border-radius: 5px; }
      "))
        ),
        tabItems(
            # ====================================================================
            # TAB 1: DASHBOARD OVERVIEW
            # ====================================================================
            tabItem(
                tabName = "dashboard",
                fluidRow(
                    valueBoxOutput("total_records", width = 3),
                    valueBoxOutput("positive_pct", width = 3),
                    valueBoxOutput("negative_pct", width = 3),
                    valueBoxOutput("neutral_pct", width = 3)
                ),
                fluidRow(
                    box(
                        title = "Sentiment Distribution",
                        status = "primary",
                        solidHeader = TRUE,
                        width = 6,
                        plotlyOutput("dash_sentiment_plot", height = 300)
                    ),
                    box(
                        title = "Emotion Distribution",
                        status = "info",
                        solidHeader = TRUE,
                        width = 6,
                        plotlyOutput("dash_emotion_plot", height = 300)
                    )
                ),
                fluidRow(
                    box(
                        title = "Key Insights",
                        status = "success",
                        solidHeader = TRUE,
                        width = 12,
                        verbatimTextOutput("key_insights")
                    )
                )
            ),

            # ====================================================================
            # TAB 2: DATA INPUT
            # ====================================================================
            tabItem(
                tabName = "data_input",
                fluidRow(
                    box(
                        title = "Upload CSV File",
                        status = "primary",
                        solidHeader = TRUE,
                        width = 6,
                        fileInput("csv_file", "Choose CSV File (must have 'text' column)",
                            accept = c(".csv")
                        ),
                        helpText("Optional columns: 'date', 'user'"),
                        actionButton("load_csv", "Load & Analyze",
                            class = "btn-primary", icon = icon("play")
                        )
                    ),
                    box(
                        title = "Manual Text Input",
                        status = "info",
                        solidHeader = TRUE,
                        width = 6,
                        textAreaInput("manual_text", "Enter Text (one per line)",
                            height = "150px",
                            placeholder = "I love this product!\nTerrible service.\nIt's okay."
                        ),
                        actionButton("analyze_manual", "Analyze Text",
                            class = "btn-info", icon = icon("search")
                        )
                    )
                ),
                fluidRow(
                    box(
                        title = "Data Preview",
                        status = "warning",
                        solidHeader = TRUE,
                        width = 12,
                        DTOutput("data_preview")
                    )
                )
            ),

            # ====================================================================
            # TAB 3: SENTIMENT ANALYSIS
            # ====================================================================
            tabItem(
                tabName = "sentiment",
                fluidRow(
                    box(
                        title = "Sentiment Distribution",
                        status = "primary",
                        solidHeader = TRUE,
                        width = 6,
                        plotlyOutput("sentiment_bar", height = 400)
                    ),
                    box(
                        title = "Sentiment Intensity",
                        status = "info",
                        solidHeader = TRUE,
                        width = 6,
                        plotlyOutput("intensity_bar", height = 400)
                    )
                ),
                fluidRow(
                    box(
                        title = "Detailed Sentiment Results",
                        status = "success",
                        solidHeader = TRUE,
                        width = 12,
                        DTOutput("sentiment_table")
                    )
                )
            ),

            # ====================================================================
            # TAB 4: EMOTION ANALYSIS
            # ====================================================================
            tabItem(
                tabName = "emotion",
                fluidRow(
                    box(
                        title = "Emotion Radar Chart",
                        status = "primary",
                        solidHeader = TRUE,
                        width = 6,
                        plotOutput("emotion_radar", height = 400)
                    ),
                    box(
                        title = "Emotion Distribution",
                        status = "info",
                        solidHeader = TRUE,
                        width = 6,
                        plotlyOutput("emotion_bar", height = 400)
                    )
                ),
                fluidRow(
                    box(
                        title = "Emotion Summary Statistics",
                        status = "warning",
                        solidHeader = TRUE,
                        width = 12,
                        DTOutput("emotion_summary_table")
                    )
                )
            ),

            # ====================================================================
            # TAB 5: SARCASM DETECTION
            # ====================================================================
            tabItem(
                tabName = "sarcasm",
                fluidRow(
                    infoBoxOutput("sarcasm_count", width = 4),
                    infoBoxOutput("sarcasm_rate", width = 4),
                    infoBoxOutput("avg_confidence", width = 4)
                ),
                fluidRow(
                    box(
                        title = "Sarcastic vs Non-Sarcastic",
                        status = "primary",
                        solidHeader = TRUE,
                        width = 6,
                        plotlyOutput("sarcasm_pie", height = 350)
                    ),
                    box(
                        title = "Sarcasm by Sentiment",
                        status = "info",
                        solidHeader = TRUE,
                        width = 6,
                        plotlyOutput("sarcasm_sentiment", height = 350)
                    )
                ),
                fluidRow(
                    box(
                        title = "Detected Sarcastic Texts",
                        status = "danger",
                        solidHeader = TRUE,
                        width = 12,
                        DTOutput("sarcasm_table")
                    )
                )
            ),

            # ====================================================================
            # TAB 6: TOPIC MODELING
            # ====================================================================
            tabItem(
                tabName = "topics",
                fluidRow(
                    box(
                        title = "Topic Keywords",
                        status = "primary",
                        solidHeader = TRUE,
                        width = 6,
                        DTOutput("topic_keywords")
                    ),
                    box(
                        title = "Topic Distribution",
                        status = "info",
                        solidHeader = TRUE,
                        width = 6,
                        plotlyOutput("topic_dist", height = 300)
                    )
                ),
                fluidRow(
                    box(
                        title = "Topics by Sentiment",
                        status = "success",
                        solidHeader = TRUE,
                        width = 12,
                        DTOutput("topic_sentiment_table")
                    )
                )
            ),

            # ====================================================================
            # TAB 7: TIME TRENDS
            # ====================================================================
            tabItem(
                tabName = "trends",
                fluidRow(
                    box(
                        title = "Sentiment Trend Over Time",
                        status = "primary",
                        solidHeader = TRUE,
                        width = 12,
                        plotlyOutput("trend_line", height = 400)
                    )
                ),
                fluidRow(
                    box(
                        title = "Critical Dates",
                        status = "warning",
                        solidHeader = TRUE,
                        width = 12,
                        verbatimTextOutput("critical_dates")
                    )
                )
            ),

            # ====================================================================
            # TAB 8: MACHINE LEARNING MODELS
            # ====================================================================
            tabItem(
                tabName = "ml_models",
                fluidRow(
                    box(
                        title = "Model Performance Comparison",
                        status = "primary",
                        solidHeader = TRUE,
                        width = 12,
                        plotlyOutput("ml_comparison", height = 400)
                    )
                ),
                fluidRow(
                    box(
                        title = "Confusion Matrix - Naive Bayes",
                        status = "info",
                        solidHeader = TRUE,
                        width = 6,
                        verbatimTextOutput("nb_confusion")
                    ),
                    box(
                        title = "Confusion Matrix - SVM",
                        status = "success",
                        solidHeader = TRUE,
                        width = 6,
                        verbatimTextOutput("svm_confusion")
                    )
                )
            ),

            # ====================================================================
            # TAB 9: EXPORT REPORT
            # ====================================================================
            tabItem(
                tabName = "export",
                fluidRow(
                    box(
                        title = "Download Analysis Report",
                        status = "primary",
                        solidHeader = TRUE,
                        width = 12,
                        h4("Export Options:"),
                        downloadButton("download_csv", "Download Full Results (CSV)",
                            class = "btn-primary"
                        ),
                        br(), br(),
                        downloadButton("download_summary", "Download Summary Report (CSV)",
                            class = "btn-info"
                        ),
                        br(), br(),
                        h4("Report Contents:"),
                        tags$ul(
                            tags$li("All sentiment scores and classifications"),
                            tags$li("Emotion detection results"),
                            tags$li("Sarcasm flags"),
                            tags$li("Topic assignments"),
                            tags$li("Timestamp of analysis")
                        )
                    )
                )
            )
        )
    )
)

# =============================================================================
# SERVER LOGIC
# =============================================================================

server <- function(input, output, session) {
    # Reactive values to store analysis results
    analysis_results <- reactiveValues(
        data = NULL,
        raw_data = NULL,
        ts_results = NULL,
        topic_results = NULL,
        ml_results = NULL,
        analyzed = FALSE
    )

    # ============================================================================
    # DATA LOADING AND ANALYSIS
    # ============================================================================

    # Load CSV and run complete analysis
    observeEvent(input$load_csv, {
        req(input$csv_file)

        withProgress(message = "Analyzing data...", value = 0, {
            tryCatch(
                {
                    # Load data
                    incProgress(0.1, detail = "Loading CSV...")
                    data <- load_data_from_csv(input$csv_file$datapath)
                    analysis_results$raw_data <- data

                    # Preprocess
                    incProgress(0.2, detail = "Preprocessing text...")
                    data <- preprocess_pipeline(data, remove_stops = FALSE)

                    # Sentiment analysis
                    incProgress(0.3, detail = "Analyzing sentiment...")
                    data <- lexicon_sentiment_analysis(data)

                    # Emotion detection
                    incProgress(0.4, detail = "Detecting emotions...")
                    data <- emotion_analysis(data)

                    # Sarcasm detection
                    incProgress(0.5, detail = "Detecting sarcasm...")
                    data <- sarcasm_analysis(data)

                    # Topic modeling
                    incProgress(0.6, detail = "Modeling topics...")
                    topic_results <- topic_modeling_analysis(data, k = 3, n_terms = 5)
                    analysis_results$topic_results <- topic_results
                    data <- topic_results$data

                    # Time-series analysis
                    incProgress(0.7, detail = "Analyzing trends...")
                    ts_results <- time_series_analysis(data)
                    analysis_results$ts_results <- ts_results

                    # Machine learning (if enough data)
                    incProgress(0.8, detail = "Training ML models...")
                    if (nrow(data) >= 20) {
                        ml_results <- machine_learning_analysis(data)
                        analysis_results$ml_results <- ml_results
                    }

                    # Store results
                    incProgress(1.0, detail = "Complete!")
                    analysis_results$data <- data
                    analysis_results$analyzed <- TRUE

                    showNotification("Analysis complete!", type = "message", duration = 3)
                },
                error = function(e) {
                    showNotification(paste("Error:", e$message), type = "error", duration = 10)
                }
            )
        })
    })

    # Analyze manual text input
    observeEvent(input$analyze_manual, {
        req(input$manual_text)

        withProgress(message = "Analyzing text...", value = 0, {
            tryCatch(
                {
                    # Parse manual input
                    texts <- unlist(strsplit(input$manual_text, "\n"))
                    texts <- trimws(texts)
                    texts <- texts[texts != ""]

                    if (length(texts) == 0) {
                        showNotification("Please enter at least one text", type = "warning")
                        return()
                    }

                    # Create dataset
                    incProgress(0.1, detail = "Creating dataset...")
                    data <- create_manual_dataset(texts)
                    analysis_results$raw_data <- data

                    # Run analysis pipeline (same as CSV)
                    incProgress(0.2, detail = "Preprocessing...")
                    data <- preprocess_pipeline(data, remove_stops = FALSE)

                    incProgress(0.3, detail = "Analyzing sentiment...")
                    data <- lexicon_sentiment_analysis(data)

                    incProgress(0.5, detail = "Detecting emotions...")
                    data <- emotion_analysis(data)

                    incProgress(0.6, detail = "Detecting sarcasm...")
                    data <- sarcasm_analysis(data)

                    incProgress(0.8, detail = "Modeling topics...")
                    topic_results <- topic_modeling_analysis(
                        data,
                        k = min(3, nrow(data)),
                        n_terms = 5,
                        min_word_length = 2,
                        min_term_doc_freq = 1
                    )
                    analysis_results$topic_results <- topic_results
                    data <- topic_results$data
                    if (isTRUE(topic_results$skipped)) {
                        showNotification("Topic modeling skipped: not enough text for LDA.", type = "warning", duration = 5)
                    }

                    incProgress(1.0, detail = "Complete!")
                    analysis_results$data <- data
                    analysis_results$ts_results <- NULL
                    analysis_results$ml_results <- NULL
                    analysis_results$analyzed <- TRUE

                    showNotification("Text analysis complete!", type = "message", duration = 3)
                },
                error = function(e) {
                    showNotification(paste("Error:", e$message), type = "error", duration = 10)
                }
            )
        })
    })

    # ============================================================================
    # DASHBOARD TAB OUTPUTS
    # ============================================================================

    output$total_records <- renderValueBox({
        req(analysis_results$analyzed)
        valueBox(
            nrow(analysis_results$data),
            "Total Records",
            icon = icon("database"),
            color = "blue"
        )
    })

    output$positive_pct <- renderValueBox({
        req(analysis_results$analyzed)
        pct <- mean(analysis_results$data$polarity == "Positive") * 100
        valueBox(
            paste0(round(pct, 1), "%"),
            "Positive",
            icon = icon("smile"),
            color = "green"
        )
    })

    output$negative_pct <- renderValueBox({
        req(analysis_results$analyzed)
        pct <- mean(analysis_results$data$polarity == "Negative") * 100
        valueBox(
            paste0(round(pct, 1), "%"),
            "Negative",
            icon = icon("frown"),
            color = "red"
        )
    })

    output$neutral_pct <- renderValueBox({
        req(analysis_results$analyzed)
        pct <- mean(analysis_results$data$polarity == "Neutral") * 100
        valueBox(
            paste0(round(pct, 1), "%"),
            "Neutral",
            icon = icon("meh"),
            color = "yellow"
        )
    })

    output$dash_sentiment_plot <- renderPlotly({
        req(analysis_results$analyzed)
        p <- plot_sentiment_distribution(analysis_results$data)
        ggplotly(p)
    })

    output$dash_emotion_plot <- renderPlotly({
        req(analysis_results$analyzed)
        emotion_summary <- get_emotion_summary(analysis_results$data)
        p <- ggplot(
            emotion_summary$emotion_totals,
            aes(x = reorder(Emotion, -Total_Count), y = Total_Count, fill = Emotion)
        ) +
            geom_bar(stat = "identity") +
            theme_minimal() +
            labs(x = "Emotion", y = "Count", title = NULL) +
            theme(legend.position = "none", axis.text.x = element_text(angle = 45, hjust = 1))
        ggplotly(p)
    })

    output$key_insights <- renderPrint({
        req(analysis_results$analyzed)
        data <- analysis_results$data

        cat("KEY INSIGHTS\n")
        cat("=", rep("=", 70), "\n\n", sep = "")

        cat("📊 Sentiment Overview:\n")
        cat(sprintf(
            "   - Most common sentiment: %s\n",
            names(which.max(table(data$polarity)))
        ))
        cat(sprintf(
            "   - Average sentiment score: %.2f\n",
            mean(data$sentiment_score)
        ))

        cat("\n😊 Emotion Analysis:\n")
        emotion_summary <- get_emotion_summary(data)
        cat(sprintf(
            "   - Dominant emotion: %s\n",
            emotion_summary$most_common_emotion
        ))

        cat("\n🎭 Sarcasm Detection:\n")
        sarcasm_summary <- get_sarcasm_summary(data)
        cat(sprintf(
            "   - Sarcastic texts: %d (%.1f%%)\n",
            sarcasm_summary$stats$sarcastic_count,
            sarcasm_summary$stats$sarcasm_rate
        ))

        if (!is.null(analysis_results$topic_results)) {
            cat("\n🔍 Topic Insights:\n")
            cat(sprintf(
                "   - Number of topics discovered: %d\n",
                max(data$topic, na.rm = TRUE)
            ))
        }
    })

    # ============================================================================
    # DATA INPUT TAB OUTPUTS
    # ============================================================================

    output$data_preview <- renderDT({
        req(analysis_results$analyzed)
        data <- analysis_results$data %>%
            select(id, original_text, polarity, sentiment_score, dominant_emotion) %>%
            head(100)

        datatable(data, options = list(pageLength = 10, scrollX = TRUE))
    })

    # ============================================================================
    # SENTIMENT TAB OUTPUTS
    # ============================================================================

    output$sentiment_bar <- renderPlotly({
        req(analysis_results$analyzed)
        p <- plot_sentiment_distribution(analysis_results$data)
        ggplotly(p)
    })

    output$intensity_bar <- renderPlotly({
        req(analysis_results$analyzed)
        p <- plot_sentiment_intensity(analysis_results$data)
        ggplotly(p)
    })

    output$sentiment_table <- renderDT({
        req(analysis_results$analyzed)
        data <- analysis_results$data %>%
            select(id, text, sentiment_score, polarity, intensity) %>%
            arrange(desc(abs(sentiment_score)))

        datatable(data, options = list(pageLength = 15, scrollX = TRUE))
    })

    # ============================================================================
    # EMOTION TAB OUTPUTS
    # ============================================================================

    output$emotion_radar <- renderPlot({
        req(analysis_results$analyzed)
        plot_emotion_radar(analysis_results$data)
    })

    output$emotion_bar <- renderPlotly({
        req(analysis_results$analyzed)
        emotion_summary <- get_emotion_summary(analysis_results$data)
        p <- ggplot(
            emotion_summary$dominant_distribution,
            aes(
                x = reorder(dominant_emotion, -Count), y = Count,
                fill = dominant_emotion
            )
        ) +
            geom_bar(stat = "identity") +
            theme_minimal() +
            labs(x = "Emotion", y = "Count", title = "Dominant Emotion Distribution") +
            theme(legend.position = "none", axis.text.x = element_text(angle = 45, hjust = 1))
        ggplotly(p)
    })

    output$emotion_summary_table <- renderDT({
        req(analysis_results$analyzed)
        emotion_summary <- get_emotion_summary(analysis_results$data)
        datatable(emotion_summary$emotion_totals,
            options = list(pageLength = 10, dom = "t")
        )
    })

    # ============================================================================
    # SARCASM TAB OUTPUTS
    # ============================================================================

    output$sarcasm_count <- renderInfoBox({
        req(analysis_results$analyzed)
        count <- sum(analysis_results$data$is_sarcasm)
        infoBox(
            "Sarcastic Texts",
            count,
            icon = icon("theater-masks"),
            color = "red"
        )
    })

    output$sarcasm_rate <- renderInfoBox({
        req(analysis_results$analyzed)
        rate <- mean(analysis_results$data$is_sarcasm) * 100
        infoBox(
            "Sarcasm Rate",
            paste0(round(rate, 1), "%"),
            icon = icon("percent"),
            color = "orange"
        )
    })

    output$avg_confidence <- renderInfoBox({
        req(analysis_results$analyzed)
        avg_conf <- mean(analysis_results$data$sarcasm_confidence[
            analysis_results$data$is_sarcasm
        ], na.rm = TRUE)
        infoBox(
            "Avg Confidence",
            paste0(round(avg_conf, 1), "%"),
            icon = icon("chart-line"),
            color = "yellow"
        )
    })

    output$sarcasm_pie <- renderPlotly({
        req(analysis_results$analyzed)
        sarcasm_summary <- get_sarcasm_summary(analysis_results$data)
        plot_ly(sarcasm_summary$table, labels = ~Category, values = ~Count, type = "pie")
    })

    output$sarcasm_sentiment <- renderPlotly({
        req(analysis_results$analyzed)
        analysis <- analyze_sarcasm_by_polarity(analysis_results$data)
        p <- ggplot(analysis, aes(x = polarity, y = Sarcasm_Rate, fill = polarity)) +
            geom_bar(stat = "identity") +
            theme_minimal() +
            labs(x = "Sentiment", y = "Sarcasm Rate (%)", title = NULL)
        ggplotly(p)
    })

    output$sarcasm_table <- renderDT({
        req(analysis_results$analyzed)
        sarcastic <- get_sarcastic_records(analysis_results$data, min_confidence = 0)
        datatable(sarcastic, options = list(pageLength = 10, scrollX = TRUE))
    })

    # ============================================================================
    # TOPIC TAB OUTPUTS
    # ============================================================================

    output$topic_keywords <- renderDT({
        req(analysis_results$topic_results)
        keywords <- get_topic_keywords_table(analysis_results$topic_results$top_terms)
        datatable(keywords, options = list(dom = "t"))
    })

    output$topic_dist <- renderPlotly({
        req(analysis_results$analyzed)
        topic_dist <- get_topic_summary(analysis_results$data)
        if (nrow(topic_dist) == 0) {
            plotly_empty() %>%
                layout(title = "No topic assignments available for current input")
        } else {
            plot_ly(topic_dist, x = ~Topic_Label, y = ~Count, type = "bar")
        }
    })

    output$topic_sentiment_table <- renderDT({
        req(analysis_results$analyzed)
        topic_sentiment <- analyze_topics_by_sentiment(analysis_results$data)
        datatable(topic_sentiment, options = list(pageLength = 10))
    })

    # ============================================================================
    # TRENDS TAB OUTPUTS
    # ============================================================================

    output$trend_line <- renderPlotly({
        req(analysis_results$ts_results)
        if (analysis_results$ts_results$has_time_variation) {
            p <- plot_sentiment_trend(analysis_results$ts_results$daily_sentiment)
            ggplotly(p)
        } else {
            plotly_empty() %>%
                layout(title = "No time variation in data")
        }
    })

    output$critical_dates <- renderPrint({
        req(analysis_results$ts_results)
        if (analysis_results$ts_results$has_time_variation) {
            cd <- analysis_results$ts_results$critical_dates
            cat("CRITICAL DATES ANALYSIS\n")
            cat(rep("=", 60), "\n\n", sep = "")
            cat(sprintf(
                "📉 Most Negative Date: %s (Score: %.2f)\n",
                cd$most_negative_date, cd$most_negative_score
            ))
            cat(sprintf(
                "📈 Most Positive Date: %s (Score: %.2f)\n",
                cd$most_positive_date, cd$most_positive_score
            ))
            cat(sprintf(
                "📊 Highest Activity Date: %s (%d records)\n",
                cd$highest_activity_date, cd$highest_activity_count
            ))
        } else {
            cat("No time variation in data.")
        }
    })

    # ============================================================================
    # ML TAB OUTPUTS
    # ============================================================================

    output$ml_comparison <- renderPlotly({
        req(analysis_results$ml_results)
        comparison <- create_model_comparison(analysis_results$ml_results)
        p <- plot_model_comparison(comparison)
        ggplotly(p)
    })

    output$nb_confusion <- renderPrint({
        req(analysis_results$ml_results)
        cat("NAIVE BAYES CONFUSION MATRIX\n")
        cat(rep("=", 40), "\n\n", sep = "")
        print(analysis_results$ml_results$nb_evaluation$confusion_matrix)
    })

    output$svm_confusion <- renderPrint({
        req(analysis_results$ml_results)
        cat("SVM CONFUSION MATRIX\n")
        cat(rep("=", 40), "\n\n", sep = "")
        print(analysis_results$ml_results$svm_evaluation$confusion_matrix)
    })

    # ============================================================================
    # EXPORT TAB OUTPUTS
    # ============================================================================

    output$download_csv <- downloadHandler(
        filename = function() {
            paste0("sentiment_analysis_", Sys.Date(), ".csv")
        },
        content = function(file) {
            req(analysis_results$analyzed)
            write.csv(analysis_results$data, file, row.names = FALSE)
        }
    )

    output$download_summary <- downloadHandler(
        filename = function() {
            paste0("analysis_summary_", Sys.Date(), ".csv")
        },
        content = function(file) {
            req(analysis_results$analyzed)

            # Create summary
            summary_data <- analysis_results$data %>%
                select(
                    id, original_text, polarity, sentiment_score, intensity,
                    dominant_emotion, is_sarcasm, topic
                )

            write.csv(summary_data, file, row.names = FALSE)
        }
    )
}

# =============================================================================
# RUN APPLICATION
# =============================================================================

shinyApp(ui = ui, server = server)
