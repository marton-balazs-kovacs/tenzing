# Module UI
  
#' @title   mod_read_spreadsheet_ui and mod_read_spreadsheet_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_read_spreadsheet
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_read_spreadsheet_ui <- function(id){
  ns <- NS(id)
  tagList(
    fileInput(ns("file"),
              label = NULL,
              accept = c(
                '.csv',
                '.tsv',
                '.xlsx'),
              multiple = FALSE),
    h3("or give a sharing url of your googlesheet", class = "main-steps-title"),
    textInput(ns("url"),
              label= NULL,
              value = "", 
              width = NULL, 
              placeholder = "https://docs.google.com/spreadsheets/d/.../edit?usp=sharing"
    ),
    actionButton(ns("submit"),
                 label = "Submit url")
  )
}
    
# Module Server
    
#' @rdname mod_read_spreadsheet
#' @export
#' @keywords internal
    
mod_read_spreadsheet_server <- function(id) {
  # File uploading limit: 9MB.
  options(shiny.maxRequestSize = 9*1024^2)
  
  moduleServer(id, function(input, output, session) {
    # Reading infosheet from local
    
    inputchange <- observe({
      inputchange <- c(input$file, input$url,1)
    })
    
    table_data <- eventReactive(input$file, {
      # File input requirement
      req(input$file)

      read_infosheet(infosheet_path = input$file$datapath)
      })

    
    table_data <- eventReactive(input$url, {
      # File input requirement
      #req(input$url)
      
      #browser()
      googlesheets4::gs4_deauth()
      googlesheets4::range_read(input$url, sheet = 1)
      
    })
    
    table_data <- eventReactive(input$submit, {
      # File input requirement
      #req(input$url)
      
      browser()
    #  googlesheets4::gs4_deauth()
    #  googlesheets4::range_read(input$url, sheet = 1)
      
    })
    
    
    # Alert modal if infosheet is incomplete
    valid_infosheet <- mod_check_modal_server("check_modal_ui_1", activate = reactive(inputchange), table_data = table_data)
    
    # Delete empty rows
    table_data_clean <- eventReactive(valid_infosheet, {
      table_data() %>%
      tibble::as_tibble() %>%
      dplyr::filter_at(
        dplyr::vars(Firstname, `Middle name`, Surname),
        dplyr::any_vars(!is.na(.)))
    })
    
    # Return module output
    return(list(
      data = table_data_clean,
      valid_infosheet = valid_infosheet,
      uploaded = reactive(inputchange)
      ))
  })
}
    
## To be copied in the UI
# mod_read_spreadsheet_ui("read_spreadsheet_ui_1")
    
## To be copied in the server
# mod_read_spreadsheet_server("read_spreadsheet_ui_1")