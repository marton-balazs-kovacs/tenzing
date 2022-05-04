# Module UI
  
#' @title   mod_show_spreadsheet_ui and mod_show_spreadsheet_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_show_spreadsheet
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
#' @importFrom rlang .data
mod_show_spreadsheet_ui <- function(id) {
  tagList(
    div(
      # style = "display: block; text-align: right;",
      title = "Click to upload from file",
      id = "show-div",
      actionButton(
        NS(id, "show_data"),
        label = list(
          "Review contributors table",
          icon("fas fa-eye", lib = "font-awesome")
        ),
        class = "btn-primary")
      )
    )
  }
    
# Module Server
    
#' @rdname mod_show_spreadsheet
#' @export
#' @keywords internal
mod_show_spreadsheet_server <- function(id, input_data) {
  stopifnot(is.reactive(input_data))
  
  moduleServer(id, function(input, output, session) {
    # Needs to be added to run if called from another module
    ns <- session$ns
    
    # Validation ---------------------------
    credit_check_cols <- c("Firstname", "Middle name", "Surname", dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`))
    
    # Clean data for table output
    table_data <- reactive({
      # Table data validation
      req(input_data())
      
      if (all(credit_check_cols %in% colnames(input_data()))) {
        # Sum of credit taxonomy activities that a contributor participated in
        credit_all_empty_col <- 
          input_data() %>% 
          dplyr::select(.data$Firstname, .data$`Middle name`, .data$Surname, dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)) %>%
          tidyr::gather(key = "credit", value  = "present", -.data$Firstname, -.data$`Middle name`, -.data$Surname) %>%
          dplyr::group_by(.data$Firstname, .data$`Middle name`, .data$Surname) %>% 
          dplyr::summarise(credit_sum = sum(.data$present))
        
        table_data <- 
          input_data() %>% 
          dplyr::left_join(., credit_all_empty_col, by = c("Firstname", "Middle name", "Surname"))
      } else {
        input_data()
      }
    })
    
    # Rendering datatable
    output$table <- DT::renderDataTable({
      
      # Text in these columns will be condensed
      if (all(c("Primary affiliation", "Secondary affiliation", "Funding") %in% colnames(input_data()))) {
        condensed_cols <- which(colnames(table_data()) %in% c("Primary affiliation", "Secondary affiliation", "Funding")) - 1
      } else {
        condensed_cols <- NULL
      }
    
      table <-
        DT::datatable(table_data(), rownames = FALSE, options = list(
          scrollX = TRUE,
          lengthMenu = c(5,10),
          pageLength = 5,
          initComplete = htmlwidgets::JS(
            "function(settings, json) {",
            "$(this.api().table().header()).css({'background-color': '#ffec9b', 'color': '#D45F68'});",
            "}"),
          columnDefs = list(
            list(
              className = 'dt-center', targets = 0),
            list(
              visible = FALSE,
              targets = which(colnames(table_data()) == "credit_sum") - 1),
            list(
              targets = condensed_cols,
              render = htmlwidgets::JS(
                "function(data, type, row, meta) {",
                "return type === 'display' && data != null && data.length > 25 ?",
                "'<span title=\"' + data + '\">' + data.substr(0, 25) + '...</span>' : data;",
                "}")
              )
            )
          ),
          class = "display")
      
      if(all(credit_check_cols %in% colnames(input_data()))) {
        table <-
          table %>%
          DT::formatStyle(
            "credit_sum",
            target = "row",
            backgroundColor = DT::styleEqual(0, "#ffec9b"))
        }
      
      table
      })
    
    # Build modal
    modal <- function() {
      modalDialog(
        easyClose = TRUE,
        DT::dataTableOutput(NS(id, "table")),
        footer = modalButton("Close"),
        size = "l")
    }
    
    observeEvent(input$show_data, {
      showModal(modal())
      })
    
  })
}
    
## To be copied in the UI
# mod_show_spreadsheet_ui("show_spreadsheet")
    
## To be copied in the server
# mod_show_spreadsheet_server("show_spreadsheet")
 
