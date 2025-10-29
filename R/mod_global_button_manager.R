# Module UI

#' @title   mod_global_button_manager_ui and mod_global_button_manager_server
#' @description  Manages the enable/disable state of buttons across the application
#'               based on upload and validation status from the read_spreadsheet module.
#'
#' @param id shiny id
#'
#' @rdname mod_global_button_manager
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList
mod_global_button_manager_ui <- function(id) {
  # This module has no UI components - it only manages button states
  tagList()
}

# Module Server

#' @rdname mod_global_button_manager
#' @param upload A reactive that triggers when upload occurs (e.g., upload button click)
#' @param is_valid A reactive that returns TRUE/FALSE indicating if data is valid
#' @export
#' @keywords internal
mod_global_button_manager_server <- function(id, upload, is_valid) {
  moduleServer(id, function(input, output, session) {
    # Initial state - disable buttons on startup and add tooltip
    js_disable_buttons(".btn-validate")
    js_add_tooltip(".out-btn", "Please upload a valid contributors_table")
    
    # Toggle logic for multiple uploads
    observeEvent(upload(), {
      if(is_valid()) {
        js_enable_buttons(".btn-validate")
        js_remove_tooltip(".out-btn")
      } else {
        js_disable_buttons(".btn-validate")
        js_add_tooltip(".out-btn", "Please upload a valid contributors_table")
      }
    })
  })
}

## To be copied in the UI
# mod_global_button_manager_ui("global_button_manager")

## To be copied in the server
# mod_global_button_manager_server("global_button_manager", upload, is_valid)

