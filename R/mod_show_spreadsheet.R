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
      actionButton(inputId = NS(id, "show_data"),
                   label = "Show infosheet",
                   class = "btn btn-primary")
  )
}
    
# Module Server
    
#' @rdname mod_show_spreadsheet
#' @export
#' @keywords internal
    
mod_show_spreadsheet_server <- function(id, input_data, uploaded) {
  stopifnot(is.reactive(input_data))
  
  moduleServer(id, function(input, output, session) {
    # Disable download button if the gs is not printed
    observe({
      if(!is.null(uploaded())){
        shinyjs::enable("show_data")
      } else{
        shinyjs::disable("show_data")
      }
    })
    
    # Clean data for table output
    table_data <- reactive({
      
      # Table data validation
      req(input_data())
      
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
      
    })
    
    # Rendering datatable
    output$table <- DT::renderDataTable({
      
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
            visible = FALSE, targets = which(colnames(table_data()) == "credit_sum") - 1),
          list(
            targets = c(19, 20),
            render = htmlwidgets::JS(
              "function(data, type, row, meta) {",
              "return type === 'display' && data != null && data.length > 25 ?",
              "'<span title=\"' + data + '\">' + data.substr(0, 25) + '...</span>' : data;",
              "}")
          ))),
        class = "display") %>% 
        DT::formatStyle("credit_sum",
                    target = "row",
                    backgroundColor = DT::styleEqual(0, "#FFFF66"))
      })
    
    # Build modal
    modal <- function() {
      modalDialog(
        easyClose = TRUE,
        DT::dataTableOutput(NS(id, "table")),
        footer = modalButton("Close Modal"),
        size = "l")
    }
    
    observeEvent(input$show_data, {
      showModal(modal())})
    
  })
}
    
## To be copied in the UI
# mod_show_spreadsheet_ui("show_spreadsheet_ui_1")
    
## To be copied in the server
# mod_show_spreadsheet_server("show_spreadsheet_ui_1")
 
