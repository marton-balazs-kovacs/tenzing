#' validation_card UI Function
#'
#' @description A shiny module for displaying validation results in a single collapsible section
#' with a custom header and background color.
#'
#' @param id Internal parameters for {shiny}.
#'
#' @noRd
mod_validation_card_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shiny::div(
      id = ns("validation_card"),
      class = "card",
      style = "border: 2px solid #D45F68; border-radius: 8px; width: 100%;", 
      shiny::div(
        id = ns("validation_header"),
        class = "card-header collapsible-header",
        `data-target` = ns("validation_section"),
        `data-collapsed` = "true", # Default state is collapsed
        style = "cursor: pointer;", # Header style
        shiny::tags$p(
          "Table Validation ",
          shiny::tags$i(class = "fas fa-chevron-down"), # Icon for collapsed state
          style = "text-align: left; color: #D45F68; font-weight: 900; margin: 10px",
          id = ns("header_text")
        )
      ),
      shiny::div(
        id = ns("validation_section"),
        class = "collapsible-content",
        style = "visibility: hidden; height: 0; overflow: hidden; padding-left: 10px; padding-right: 10px;", 
        shiny::uiOutput(ns("validation_results"))
      )
    )
  )
}

#' validation_card Server Function
#'
#' @description A server module for managing and displaying validation results in a single collapsible section.
#'
#' @param id Module ID.
#' @param contributors_table A reactive object containing the contributors table.
#' @param output_type The type of output being validated (e.g., "credit", "title").
#'
#' @noRd
mod_validation_card_server <- function(id, contributors_table, output_type) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Perform validation based on the contributors table and output type
    validation_results <- reactive({
      validate_contributors_table(contributors_table(), output_type)
    })
    
    observe({print(validation_results())})
    # Filter results for errors and warnings
    filtered_results <- reactive({
      purrr::keep(validation_results(), ~ .x$type %in% c("error", "warning"))
    })
    
    # Determine validation severity
    severity <- reactive({
      results <- filtered_results()
      if (any(purrr::map_chr(results, "type") == "error")) {
        list(type = "error", textColor = "#D45F68", borderColor = "#D45F68") # Red for errors
      } else if (any(purrr::map_chr(results, "type") == "warning")) {
        list(type = "warning", textColor = "#ecd149", borderColor = "#ecd149") # Yellow for warnings
      } else {
        list(type = "success", textColor = "#7ec4ad", borderColor = "#7ec4ad") # Green for success
      }
    })
    
    # Dynamically update card and header styles using JavaScript
    observe({
      current_severity <- severity()
      golem::invoke_js(
        "update_card_styles",
        list(
          cardId = ns("validation_card"),
          headerTextId = ns("header_text"),
          textColor = current_severity$textColor,
          borderColor = current_severity$borderColor
        )
      )
    })
    
    # Render validation results
    output$validation_results <- shiny::renderUI({
      results <- filtered_results()
      
      if (is.null(results) || length(results) == 0) {
        shiny::tags$div(
          class = "alert alert-success",
          shiny::tags$strong("Success: "),
          "No errors or warnings found."
        )
      } else {
        shiny::tags$div(
          lapply(results, function(result) {
            shiny::tags$div(
              class = paste("alert", if (result$type == "error") "alert-danger" else "alert-warning"),
              shiny::tags$strong(if (result$type == "error") "Error: " else "Warning: "),
              result$message
            )
          })
        )
      }
    })
  })
}

## To be copied in the UI
# mod_validation_card_ui("validation_card")
## To be copied in the server
# mod_validation_card_server("validation_card")