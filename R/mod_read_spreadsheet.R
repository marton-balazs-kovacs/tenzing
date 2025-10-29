# Module UI
  
#' @title   mod_read_spreadsheet_ui and mod_read_spreadsheet_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#'
#' @rdname mod_read_spreadsheet
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList
mod_read_spreadsheet_ui <- function(id){

  tagList(
    tabsetPanel(
      id = NS(id, "which_input"),
      type = "tabs",
      tabPanel(
        "URL",
        h5("Paste the url of a shared googlesheet and click the upload button", class = "main-steps-desc"),
        textInput(
          NS(id, "url"),
          label = NULL,
          value = "", 
          width = NULL, 
          placeholder = "https://docs.google.com/spreadsheets/d/.../edit?usp=sharing")
      ),
      tabPanel(
        "Local file",
        h5("Choose the spreadsheet on your computer", class = "main-steps-desc"),
        fileInput(
          NS(id, "file"),
          label = NULL,
          accept = c(
            '.csv',
            '.tsv',
            '.xlsx'),
          multiple = FALSE)
        )
      ),
    actionButton(
      NS(id, "upload"),
      label = uiOutput(NS(id, "upload_label")),
      class = "btn-primary")
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
    # Upload button label ---------------------------
    output$upload_label <- renderText({
      if (input$which_input == "Local file") {
        paste("Process spreadsheet")
      } else if (input$which_input == "URL") {
        paste("Upload from URL", icon("fas fa-upload", lib = "font-awesome"))
      }
    })
    
    # Reading contributors_table ---------------------------
    table_data <- eventReactive(input$upload, {
      # Googlesheets authentication
      googlesheets4::gs4_deauth()
      
      # Select the path to read based on which action button is pressed
      if (input$which_input == "Local file") {
        if (is.null(input$file)) {
          contributors_table_path <- ""
          } else {
            contributors_table_path <- input$file$datapath
            }
        } else if (input$which_input == "URL") {
          contributors_table_path <- input$url
          }
      
      # Reading data
      # The purrr::safely function catches the errors on read
      # and returns a list
      sf_read_contributors_table <- purrr::safely(read_contributors_table)
      read_output <- sf_read_contributors_table(contributors_table_path = contributors_table_path)
      if (is.null(read_output$result)) {
        # Extract error message
        error_msg <- if (!is.null(read_output$error) && !is.null(read_output$error[["message"]])) {
          read_output$error[["message"]]
        } else {
          "Unknown error occurred while reading the spreadsheet."
        }
        
        # Check if this is a Google Sheets permission error
        is_google_sheets_url <- grepl("https", contributors_table_path)
        permission_keywords <- c("403", "permission", "access denied", "forbidden", 
                                 "PERMISSION_DENIED", "insufficient permissions",
                                 "not shared", "cannot access", "unauthorized")
        is_permission_error <- any(sapply(permission_keywords, function(keyword) {
          grepl(keyword, error_msg, ignore.case = TRUE)
        }))
        
        # Provide user-friendly error message
        if (is_google_sheets_url && is_permission_error) {
          user_friendly_error <- paste0(
            "Unable to access the Google Spreadsheet. ",
            "The spreadsheet may have restricted viewing permissions. ",
            "Please ensure the spreadsheet is shared with 'Anyone with the link' ",
            "or with the appropriate viewing permissions."
          )
        } else {
          user_friendly_error <- error_msg
        }
        
        js_error_alert(error = user_friendly_error)
        return(NULL)
        } else { # Have successfully read the file or Google Sheet
          message("File or Google Sheet has been uploaded.") # Print message for logfile so we know when people have uploaded a contributor table
          return(read_output$result)
          }
      })
    
    # Hide show spreadsheet on start
    js_hide_id("show-div")
    
    # Control show spreadsheet button behavior based on read
    observe({
      if(!is.null(table_data())) {
        js_enable_buttons("#show_spreadsheet-show_data")
        js_show_id("show-div")
        js_remove_tooltip("#show-div")
        } else{
          js_disable_buttons("#show_spreadsheet-show_data")
          js_add_tooltip("#show-div", "Please upload a contributors_table")
          }
      })
    
    # General validation of contributors_table ---------------------------
    # Alert modal to check contributors_table validity
    check_output <- reactive({
      req(table_data())
      mod_check_modal_server("check_modal", table_data = table_data())
      })
    
    is_valid <- reactive({
      if (!is.null(table_data())) {
        return(check_output()$is_valid)
        } else {
          return(FALSE)
          }
      })

    # Cleaning contributors_table ---------------------------
    # Delete empty rows
    table_data_clean <- reactive({
      if (all(c("Firstname", "Middle name", "Surname") %in% colnames(table_data()))) {
        clean_contributors_table(table_data())
        } else {
          table_data()
          }
      })
    
    # Remove rows where Author/Acknowledgee == "Don't agree to be named"
    table_data_filtered <- reactive({
      req(table_data_clean())
      df <- table_data_clean()
      if ("Author/Acknowledgee" %in% names(df)) {
        df %>%
          dplyr::filter(is.na(.data$`Author/Acknowledgee`) | .data$`Author/Acknowledgee` != "Don't agree to be named")
      } else {
        df
      }
    })
    
    # Return output ---------------------------
    return(
      list(
        data = table_data_filtered,
        is_valid = is_valid,
        check_result = reactive(check_output()$check_result),
        upload = reactive(input$upload)
        ))
    })
}
    
## To be copied in the UI
# mod_read_spreadsheet_ui("read_spreadsheet")
    
## To be copied in the server
# mod_read_spreadsheet_server("read_spreadsheet")
