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
mod_check_modal_server <- function(id, table_data){
  
  moduleServer(id, function(input, output, session) {
    # Needs to be added to run if called from another module
    ns <- session$ns
    
    # Run test codes
      sf_validate_contributors_table <- purrr::safely(validate_contributors_table)
      valid <- sf_validate_contributors_table(table_data)
      if(!is.null(valid$error)) {
        check_result <- tibble::tibble(
          type = "error",
          message = as.character(valid$error["message"]))
      } else {
        check_result <- tibble::tibble(
          type = purrr::map_chr(valid$result, "type"),
          message = purrr::map_chr(valid$result, "message"))
      }
    
    # Activate modal
      if (all(check_result$type == "error")) {
       golem::invoke_js("error_alert",
                        list(error = check_result$message,
                             warning = ""))
        } else if (all(check_result$type == "success")) {
          golem::invoke_js("success_alert", "")
          } else if (all(check_result$type %in% c("warning", "success"))) {
            golem::invoke_js("warning_alert", unnamed_message(check_result, "warning"))
            } else {
              golem::invoke_js("error_alert",
                               list(error = unnamed_message(check_result, "error"),
                                    warning = unnamed_message(check_result, "warning")))
              }
    
    # Create output
      if (all(check_result$type %in% c("warning", "success"))) {
        is_valid <- TRUE
        } else {
          is_valid <-  FALSE
          }
    
    # Pass output
    return(
      list(
        is_valid = is_valid,
        check_result = check_result
        )
    )
  })
}
    
## To be copied in the UI
# mod_check_modal_ui("check_modal")
    
## To be copied in the server
# mod_check_modal_server("check_modal")
 
