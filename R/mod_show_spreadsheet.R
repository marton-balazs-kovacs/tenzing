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
mod_show_spreadsheet_ui <- function(id) {
  tagList(
    div(id = "out-btn",
      actionButton(inputId = NS(id, "show_data"),
                   label = "Show infosheet",
                   class = "btn btn-primary btn-validate")
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
    waitress <- waiter::Waitress$new(theme = "overlay", infinite = TRUE)
    
    # Clean data for table output
    table_data <- reactive({
      # Table data validation
      req(input_data())
      
      if (all(c("Firstname", "Middle name", "Surname") %in% colnames(input_data()))) {
        # Sum of credit taxonomy activities that a contributor participated in
        credit_all_empty_col <- 
          input_data() %>% 
          dplyr::select(Firstname, `Middle name`, Surname, dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)) %>%
          tidyr::gather(key = "credit", value  = "present", -Firstname, -`Middle name`, -Surname) %>%
          dplyr::group_by(Firstname, `Middle name`, Surname) %>% 
          dplyr::summarise(credit_sum = sum(present))
        
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
      condensed_cols <- which(colnames(table_data()) %in% c("Primary affiliation", "Secondary affiliation")) - 1
    
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
      
      if(all(c("Firstname", "Middle name", "Surname") %in% colnames(input_data()))) {
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
      waitress$notify()
      showModal(modal())
      waitress$close()
      })
    
  })
}
    
## To be copied in the UI
# mod_show_spreadsheet_ui("show_spreadsheet_ui_1")
    
## To be copied in the server
# mod_show_spreadsheet_server("show_spreadsheet_ui_1")
 
