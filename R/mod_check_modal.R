#' check_modal UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_check_modal_ui <- function(id){
  tagList(
 
  )
}
    
#' check_modal Server Function
#'
#' @noRd 
mod_check_modal_server <- function(id, activate, table_data){
  
  moduleServer(id, function(input, output, session) {
    # Needs to be added to run if called from another module
    ns <- session$ns
    
    # Run test codes
    check_result <- eventReactive(activate(), {
      sf_validate_infosheet <- purrr::safely(validate_infosheet)
      valid <- sf_validate_infosheet(table_data())
      if(!is.null(valid$error)) {
        tibble::tibble(
          type = "error",
          message = as.character(valid$error["message"]))
      } else {
        tibble::tibble(
          type = purrr::map_chr(valid$result, "type"),
          message = purrr::map_chr(valid$result, "message"))
      }
    })
    
    # Render output text
    output$check <- renderText({
      if (all(check_result()$type == "error")) {
        paste0("<p style=\"color:#D45F68\">", check_result()$message, "</p>")
      } else if (all(check_result()$type == "success")) {
        paste0("<p style=\"color:#b2dcce\">", "The infosheet is valid!", "</p>")
      } else if (all(check_result()$type %in% c("warning", "success"))) {
        check_warning <- dplyr::filter(check_result(), type == "warning")
        paste0("<p style=\"color:#ffec9b\">", check_warning$message, "</p>")
      } else {
        check_warning <- dplyr::filter(check_result(), type == "warning")
        check_error <- dplyr::filter(check_result(), type == "error")
        paste0("<p style=\"color:#D45F68\">", check_error$message, "</p>",
               "<p style=\"color:#ffec9b\">", check_warning$message, "</p>")
      }
    })
    
    # Build modal
    modal <- function() {
      modalDialog(
        h1("Validating the infosheet"),
        htmlOutput(ns("check")),
        easyClose = TRUE,
        footer = modalButton("Close"),
        size = "m")
    }
    
    # Activate modal
    observeEvent(activate(), {
      showModal(modal())})
    })
  
  # Create return output
  
  # Pass output

}
    
## To be copied in the UI
# mod_check_modal_ui("check_modal_ui_1")
    
## To be copied in the server
# mod_check_modal_server("check_modal_ui_1")
 
