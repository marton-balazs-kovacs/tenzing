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
    h5("Choose the spreadsheet on your computer", class = "main-steps-title"),
    fileInput(ns("file"),
              label = NULL,
              accept = c(
                '.csv',
                '.tsv',
                '.xlsx'),
              multiple = FALSE),
    h5("or copy the url of a shared googlesheet,", class = "main-steps-title"),
    textInput(ns("url"),
              label= NULL,
              value = "", 
              width = NULL, 
              placeholder = "https://docs.google.com/spreadsheets/d/.../edit?usp=sharing"
    ),
    h5("then upload the infosheet into tenzing:", class = "main-steps-title"),
    div(class = "out-btn",
        actionButton(inputId = ns("submit"),
                     label = "Load and validate")
    ),
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
    
    
    table_data <- eventReactive(input$submit, {
      # File input requirement
      #req(input$file)
      infosheet_path = ifelse(is.null(input$file),input$url,input$file$datapath)
      
      googlesheets4::gs4_deauth()
      read_infosheet(infosheet_path = infosheet_path)
      })

    
    
    
    
    # Alert modal if infosheet is incomplete
    #valid_infosheet <- mod_check_modal_server("check_modal_ui_1", activate = reactive(input$file), table_data = table_data)
    
    valid_infosheet <- mod_check_modal_server("check_modal_ui_1", activate = reactive(input$submit), table_data = table_data)
    
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
      uploaded = reactive(input$submit)
      ))
  })
}
    
## To be copied in the UI
# mod_read_spreadsheet_ui("read_spreadsheet_ui_1")
    
## To be copied in the server
# mod_read_spreadsheet_server("read_spreadsheet_ui_1")