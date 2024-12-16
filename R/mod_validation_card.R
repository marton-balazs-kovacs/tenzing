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
          style = "text-align: left; color: #D45F68; font-weight: 900; margin: 10px"
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
    
    # Filter results for errors and warnings
    filtered_results <- reactive({
      purrr::keep(validation_results(), ~ .x$type %in% c("error", "warning"))
    })
    
    # Render validation results
    output$validation_results <- shiny::renderUI({
      results <- filtered_results()
      
      if (is.null(results) || length(results) == 0) {
        shiny::tags$p("No errors or warnings found.", class = "text-success")
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