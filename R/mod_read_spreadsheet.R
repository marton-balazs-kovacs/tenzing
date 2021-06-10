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

  tagList(
    tabsetPanel(
      type = "tabs",
      tabPanel(
        "Local file",
    h5("Choose the spreadsheet on your computer and click the upload button", class = "main-steps-desc"),
    fileInput(
      NS(id, "file"),
      label = NULL,
      accept = c(
        '.csv',
        '.tsv',
        '.xlsx'),
      multiple = FALSE),
    actionButton(
      NS(id, "upload_file"),
      label = list(
        "Upload from file",
        icon("fas fa-upload", lib = "font-awesome")
        ),
      class = "btn-primary")
    ),
    # hr(style = "margin-top: 15px; margin-bottom: 15px; border-top: 1px solid #467d6e; width : 80%"),
    # h3("OR", style = "font-weight: 500; line-height: 1.1; text-align: center; margin-top: 15px !important; margin-bottom: 15px !important;"),
    tabPanel(
      "URL",
      h5("Paste the url of a shared googlesheet and click the upload button", class = "main-steps-desc"),
    textInput(
      NS(id, "url"),
      label= NULL,
      value = "", 
      width = NULL, 
      placeholder = "https://docs.google.com/spreadsheets/d/.../edit?usp=sharing"),
    actionButton(
      NS(id, "upload_url"),
      label = list(
        "Upload from url",
        icon("fas fa-upload", lib = "font-awesome")
        ),
      class = "btn-primary")
    )
    )
  )
}
    
# Module Server
    
#' @rdname mod_read_spreadsheet
#' @export
#' @keywords internal
    
mod_read_spreadsheet_server <- function(id) {
  # File uploading limit: 9MB
  options(shiny.maxRequestSize = 9*1024^2)
  
  moduleServer(id, function(input, output, session) {
    # Reading infosheet ---------------------------
    # Create one activate reactive from two buttons
    # If either of the buttons are pressed the reactive fires
    # TODO: This current solution is designed for to inputs on the
    # same page. However, now that they are separated to two tabs
    # the input should be triggered by which tab is open and one
    # upload button should be enough.
    activate <- reactive(
      if (input$upload_url == 0 & input$upload_file == 0) {
        NULL
      } else {
        input$upload_url + input$upload_file
      }
    )
    
    # Decide which input to read
    # The app reads the input of the latest upload button is pressed
    which_input <- reactiveVal(NULL)
    
    observe({
      req(input$upload_file)
      which_input("file")
    })
    
    observe({
      req(input$upload_url)
      which_input("url")
    })
    
    # Reading infosheet
    table_data <- eventReactive(activate(), {
      # Googlesheets authentication
      googlesheets4::gs4_deauth()
      
      # Select the path to read based on which action button is pressed
      if (which_input() == "file") {
        if (is.null(input$file)) {
          infosheet_path <- ""
          } else {
            infosheet_path <- input$file$datapath
            }
        } else if (which_input() == "url") {
          infosheet_path <- input$url
          }
      
      # Reading data
      # The purrr::safely function catches the errors on read
      # and returns a list
      sf_read_infosheet <- purrr::safely(read_infosheet)
      read_output <- sf_read_infosheet(infosheet_path = infosheet_path)
      if (is.null(read_output$result)) {
        golem::invoke_js("error_alert",
                         list(error = read_output$error[["message"]],
                              warning = ""))
        return(NULL)
      } else {
        return(read_output$result)
      }
      })
    
    # Hide show spreadsheet on start
    golem::invoke_js("hideid", "show-div")
    
    # Control show spreadsheet button behaviour based on read
    observeEvent(activate(),{
      if(!is.null(table_data())) {
        golem::invoke_js("reable", "#show_spreadsheet-show_data")
        golem::invoke_js("showid", "show-div")
        golem::invoke_js("remove_tooltip", "#show-div")
      } else{
        golem::invoke_js("disable", "#show_spreadsheet-show_data")
        golem::invoke_js("add_tooltip",
                         list(
                           where = "#show-div",
                           message = "Please upload an infosheet"))
      }
    })
    
    # General validation of infosheet ---------------------------
    # Alert modal to check infosheet validity
    valid_infosheet <- reactive({
    if (!is.null(table_data())) {
      check_output <- mod_check_modal_server("check_modal", activate = activate, table_data = table_data)
      return(check_output())
    } else {
      return(FALSE)
    }
  })
    
    # Cleaning infosheet ---------------------------
    # Delete empty rows
    table_data_clean <- eventReactive(activate(), {
      if (all(c("Firstname", "Middle name", "Surname") %in% colnames(table_data()))) {
        table_data() %>%
          tibble::as_tibble() %>%
          dplyr::filter_at(
            dplyr::vars(Firstname, `Middle name`, Surname),
            dplyr::any_vars(!is.na(.)))
        } else {
          table_data()
          }
      })
    
    # Return output ---------------------------
    return(
      list(
        data = table_data_clean,
        valid_infosheet = valid_infosheet,
        uploaded = activate
        ))
    })
}
    
## To be copied in the UI
# mod_read_spreadsheet_ui("read_spreadsheet")
    
## To be copied in the server
# mod_read_spreadsheet_server("read_spreadsheet")
