#' @import shiny
#' @import shinyjs
app_server <- function(input, output, session) {
  # Popup for support
  mod_support_popup_server("support_popup")
  
  # Read in the contributors_table
  ## Save the read data as a reactive object
  read_out <- mod_read_spreadsheet_server("read_spreadsheet")
  
  # Global button state manager
  mod_global_button_manager_server(
    "global_button_manager",
    upload = read_out$upload,
    is_valid = read_out$is_valid
  )
  
  # Show the spreadsheet in viewer window
  mod_show_spreadsheet_server("show_spreadsheet", input_data = read_out$data)
  
  # Show a human readable report in viewer window
  mod_credit_roles_server("credit_roles", input_data = read_out$data)
  
  # Show the first page with contributors affiliation in viewer window
  mod_title_page_server("title_page", input_data = read_out$data)
  
  # Show a JATS XML report in viewer window
  mod_xml_report_server("xml_report", input_data = read_out$data)
  
  # Show papaja YAML in viewer window
  mod_show_yaml_server("show_yaml", input_data = read_out$data)
  
  # Show funding information in viewer window
  mod_funding_information_server("funding_information", input_data = read_out$data)
  
  # Show conflict of interest statement
  mod_conflict_statement_server("conflict_statement", input_data = read_out$data)
  
  # Hide on launch waiter screen
  waiter::waiter_hide()
}
