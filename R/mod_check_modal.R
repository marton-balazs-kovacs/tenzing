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
    
    # Activate modal
    observeEvent(activate(), {
      if (all(check_result()$type == "error")) {
       golem::invoke_js("error_alert",
                        list(error = check_result()$message,
                             warning = ""))
        } else if (all(check_result()$type == "success")) {
          golem::invoke_js("success_alert", "")
          } else if (all(check_result()$type %in% c("warning", "success"))) {
            golem::invoke_js("warning_alert", unnamed_message(check_result(), "warning"))
            } else {
              golem::invoke_js("error_alert",
                               list(error = unnamed_message(check_result(), "error"),
                                    warning = unnamed_message(check_result(), "warning")))
              }
      })
    
    # Create output
    valid_infosheet <- reactive({
      if (all(check_result()$type %in% c("warning", "success"))) {
        TRUE
        } else {
          NULL
          }
      })
    
    # Pass output
    return(valid_infosheet)
  })
}
    
## To be copied in the UI
# mod_check_modal_ui("check_modal_ui_1")
    
## To be copied in the server
# mod_check_modal_server("check_modal_ui_1")
 
