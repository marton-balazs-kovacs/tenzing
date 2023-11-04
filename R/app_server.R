#' @import shiny
app_server <- function(input, output,session) {
  # Read in the contributors_table
  ## Save the read data as a reactive object
  read_out <- mod_read_spreadsheet_server("read_spreadsheet")
  
  # Output generating button activation
  ## Disable button on start and add tooltip
  ### Buttons that need a validated contributors_table
  golem::invoke_js("disable", ".btn-validate")
  golem::invoke_js("add_tooltip",
                   list(
                     where = ".out-btn",
                     message = "Please upload a valid contributors_table"))

  ## Toggle logic for multiple uploads
  observeEvent(read_out$upload(), {
    if(read_out$is_valid()) {
      golem::invoke_js("reable", ".btn-validate")
      golem::invoke_js("remove_tooltip", ".out-btn")
      } else{
        golem::invoke_js("disable", ".btn-validate")
        golem::invoke_js("add_tooltip",
                         list(
                           where = ".out-btn",
                           message = "Please upload a valid contributors_table"))
        }
    })
  
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
